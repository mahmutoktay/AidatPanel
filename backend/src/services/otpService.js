import crypto from "crypto";
import bcrypt from "bcryptjs";
import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { normalizeTrPhone } from "../utils/normalizeTrPhone.js";
import { sendSms } from "./sms/sendSms.js";
import {
  checkTwilioVerification,
  isTwilioVerifyConfigured,
  startTwilioVerification,
} from "./sms/twilioVerifyProvider.js";
import { sendOtpEmail } from "./email/resendEmail.js";
import { validateInviteCode, normalizeInviteCode } from "./inviteCodeService.js";
import { createSession } from "./sessionService.js";
import { generateAccessToken, generateRefreshToken } from "../utils/generateTokens.js";
import { logger } from "../config/logger.js";

const OTP_TTL_MS = 5 * 60 * 1000;
const MAX_ATTEMPTS = 3;

const LOGIN_PURPOSES = new Set([
  "manager_login",
  "resident_login",
]);
const REGISTER_PURPOSES = new Set([
  "manager_register",
  "resident_join",
]);

function hashOtp(code) {
  return crypto.createHash("sha256").update(String(code).trim(), "utf8").digest("hex");
}

function generateNumericOtp() {
  return String(crypto.randomInt(100000, 999999));
}

function hashToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function normalizeEmail(raw) {
  if (typeof raw !== "string") return null;
  const v = raw.trim().toLowerCase();
  if (!v || !v.includes("@")) return null;
  return v;
}

function resolveOtpContact({ phone, email }) {
  const normalizedPhone = phone ? normalizeTrPhone(phone) : null;
  const normalizedEmail = email ? normalizeEmail(email) : null;

  if (normalizedPhone && normalizedEmail) {
    throw new HttpError(400, "Telefon veya e-posta gönderin, ikisini birden değil.");
  }
  if (!normalizedPhone && !normalizedEmail) {
    throw new HttpError(400, "Geçerli bir telefon numarası veya e-posta giriniz.");
  }
  if (phone && !normalizedPhone) {
    throw new HttpError(400, "Geçerli bir telefon numarası giriniz.");
  }
  if (email && !normalizedEmail) {
    throw new HttpError(400, "Geçerli bir e-posta adresi giriniz.");
  }

  return {
    phone: normalizedPhone,
    email: normalizedEmail,
    channel: normalizedPhone ? "phone" : "email",
  };
}

function contactWhere(contact) {
  return contact.phone ? { phone: contact.phone } : { email: contact.email };
}

function authUserPayload(user) {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role,
    phone: user.phone,
    language: user.language,
    apartmentId: user.apartmentId,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };
}

async function issueTokenPair(user, sessionId) {
  return {
    accessToken: generateAccessToken(user, sessionId),
    refreshToken: generateRefreshToken(user, sessionId),
  };
}

function deviceMeta(body) {
  return {
    deviceLabel: body?.deviceLabel,
    platform: body?.platform,
  };
}

async function purgeExpiredOtps(contact, purpose) {
  await prisma.phoneOtpToken.deleteMany({
    where: {
      ...contactWhere(contact),
      purpose,
      OR: [
        { expiresAt: { lt: new Date() } },
        { usedAt: { not: null } },
      ],
    },
  });
}

/**
 * POST /auth/otp/send
 */
export async function sendOtpService({ phone, email, purpose, payload }) {
  const contact = resolveOtpContact({ phone, email });

  const allPurposes = new Set([...LOGIN_PURPOSES, ...REGISTER_PURPOSES]);
  if (!allPurposes.has(purpose)) {
    throw new HttpError(400, "Geçersiz doğrulama isteği.");
  }

  if (LOGIN_PURPOSES.has(purpose)) {
    const role = purpose.startsWith("manager") ? "MANAGER" : "RESIDENT";
    const user = await prisma.user.findFirst({
      where: { ...contactWhere(contact), role, deletedAt: null },
    });
    if (!user) {
      if (purpose === "resident_login") {
        throw new HttpError(
          404,
          contact.email
            ? "Bu e-posta adresiyle kayıtlı hesap bulunamadı."
            : "Bu telefon numarasıyla kayıtlı hesap bulunamadı."
        );
      }
      return { sent: true };
    }
  }

  if (purpose === "manager_register" || purpose === "resident_join") {
    const role = purpose === "manager_register" ? "MANAGER" : "RESIDENT";
    const existing = await prisma.user.findFirst({
      where: { ...contactWhere(contact), role, deletedAt: null },
    });
    if (existing) {
      throw new HttpError(
        409,
        contact.email
          ? "Bu e-posta adresi zaten kullanılıyor."
          : "Bu telefon numarası zaten kullanılıyor."
      );
    }
  }

  await purgeExpiredOtps(contact, purpose);

  if (contact.channel === "email") {
    const code = generateNumericOtp();
    const tokenHash = hashOtp(code);

    await prisma.phoneOtpToken.create({
      data: {
        email: contact.email,
        purpose,
        tokenHash,
        payload: payload ?? undefined,
        expiresAt: new Date(Date.now() + OTP_TTL_MS),
      },
    });

    const mailResult = await sendOtpEmail(contact.email, code);

    if (process.env.NODE_ENV !== "production") {
      logger.info({
        type: "otp_dev",
        email: contact.email,
        purpose,
        code,
      });
    }

    if (!mailResult.ok) {
      if (process.env.NODE_ENV !== "production") {
        logger.warn({
          type: "otp_email_failed_dev_continue",
          email: contact.email,
          error: mailResult.error,
        });
        return { sent: true, devFallback: true, channel: "email" };
      }
      throw new HttpError(
        503,
        "E-posta gönderilemedi. Lütfen biraz sonra tekrar deneyin."
      );
    }

    logger.info({
      type: "otp_email_channel",
      email: contact.email,
      purpose,
      channel: "email",
    });
    return { sent: true, channel: "email" };
  }

  const useTwilioVerify = isTwilioVerifyConfigured();

  if (useTwilioVerify) {
    await prisma.phoneOtpToken.create({
      data: {
        phone: contact.phone,
        purpose,
        tokenHash: hashOtp(`twilio_verify:${crypto.randomUUID()}`),
        payload: { ...(payload ?? {}), twilioVerify: true },
        expiresAt: new Date(Date.now() + OTP_TTL_MS),
      },
    });

    const verifyResult = await startTwilioVerification(contact.phone);
    if (!verifyResult.ok) {
      if (verifyResult.code === 21408) {
        throw new HttpError(
          503,
          "Twilio'da Türkiye SMS izni kapalı. Console → Messaging → Geo permissions → Turkey açın."
        );
      }
      throw new HttpError(
        503,
        "Doğrulama kodu gönderilemedi. Lütfen biraz sonra tekrar deneyin."
      );
    }

    logger.info({
      type: "otp_verify_channel",
      phone: contact.phone,
      purpose,
      channel: "twilio_verify",
    });
    return { sent: true, channel: "twilio_verify" };
  }

  const code = generateNumericOtp();
  const tokenHash = hashOtp(code);

  await prisma.phoneOtpToken.create({
    data: {
      phone: contact.phone,
      purpose,
      tokenHash,
      payload: payload ?? undefined,
      expiresAt: new Date(Date.now() + OTP_TTL_MS),
    },
  });

  const smsResult = await sendSms(
    contact.phone,
    `AidatPanel doğrulama kodunuz: ${code}. 5 dakika geçerlidir.`
  );

  // sendSms sağlayıcı yoksa { ok: true, dev: true } döner — prod'da SMS gitmemiş olur.
  if (smsResult.dev) {
    if (process.env.NODE_ENV === "production") {
      logger.error({
        type: "sms_dev_skip_in_production",
        phone: contact.phone,
        purpose,
      });
      throw new HttpError(
        503,
        "SMS gönderilemedi. Lütfen biraz sonra tekrar deneyin."
      );
    }
    logger.info({ type: "otp_dev", phone: contact.phone, purpose, code });
    logger.warn({
      type: "otp_sms_dev_skip",
      phone: contact.phone,
      purpose,
      hint: "Twilio Verify veya TWILIO_PHONE_FROM yapılandırın; kod yalnızca logda.",
    });
    return { sent: true, devFallback: true, channel: "dev" };
  }

  if (process.env.NODE_ENV !== "production") {
    logger.info({ type: "otp_dev", phone: contact.phone, purpose, code });
  }

  if (!smsResult.ok) {
    if (process.env.NODE_ENV !== "production" && smsResult.dev) {
      logger.warn({
        type: "otp_sms_failed_dev_continue",
        phone: contact.phone,
        error: smsResult.error,
        code: smsResult.code,
      });
      return { sent: true, devFallback: true };
    }
    if (process.env.NODE_ENV !== "production") {
      logger.warn({
        type: "otp_sms_failed",
        phone: contact.phone,
        error: smsResult.error,
        code: smsResult.code,
      });
    }
    if (smsResult.code === 21408) {
      throw new HttpError(
        503,
        "Twilio'da Türkiye SMS izni kapalı. Console → Messaging → Geo permissions → Turkey açın."
      );
    }
    throw new HttpError(503, "SMS gönderilemedi. Lütfen biraz sonra tekrar deneyin.");
  }

  return { sent: true, channel: "sms" };
}

/**
 * POST /auth/otp/verify
 */
export async function verifyOtpService(body) {
  const { code, purpose } = body;
  const contact = resolveOtpContact({ phone: body.phone, email: body.email });

  if (!code || String(code).trim().length !== 6) {
    throw new HttpError(400, "Doğrulama kodu 6 haneli olmalıdır.");
  }

  const record = await prisma.phoneOtpToken.findFirst({
    where: {
      ...contactWhere(contact),
      purpose,
      usedAt: null,
      expiresAt: { gt: new Date() },
    },
    orderBy: { createdAt: "desc" },
  });

  if (!record) {
    throw new HttpError(400, "Kod süresi dolmuş veya geçersiz. Yeni kod isteyin.");
  }

  if (record.attempts >= MAX_ATTEMPTS) {
    throw new HttpError(429, "Çok fazla deneme yaptınız. Yeni kod isteyin.");
  }

  const twilioVerify =
    contact.channel === "phone" &&
    record.payload &&
    typeof record.payload === "object" &&
    record.payload.twilioVerify === true;

  if (twilioVerify) {
    const check = await checkTwilioVerification(contact.phone, code);
    if (!check.ok) {
      await prisma.phoneOtpToken.update({
        where: { id: record.id },
        data: { attempts: { increment: 1 } },
      });
      throw new HttpError(400, "Kod yanlış. Tekrar deneyin.");
    }
  } else {
    const codeHash = hashOtp(code);
    if (codeHash !== record.tokenHash) {
      await prisma.phoneOtpToken.update({
        where: { id: record.id },
        data: { attempts: { increment: 1 } },
      });
      throw new HttpError(400, "Kod yanlış. Tekrar deneyin.");
    }
  }

  let result;
  if (LOGIN_PURPOSES.has(purpose)) {
    result = await loginWithOtp(contact, purpose, body);
  } else if (purpose === "manager_register") {
    result = await registerManagerWithOtp(contact, body, record.payload);
  } else if (purpose === "resident_join") {
    const inviteCode = body.inviteCode ?? record.payload?.inviteCode;
    const name = body.name?.trim();
    if (!inviteCode) {
      throw new HttpError(400, "Davet kodu gereklidir.");
    }
    if (!name || name.length < 2) {
      await validateInviteCode(inviteCode);
      await prisma.phoneOtpToken.update({
        where: { id: record.id },
        data: {
          payload: {
            ...(record.payload && typeof record.payload === "object"
              ? record.payload
              : {}),
            inviteCode,
            joinOtpConfirmed: true,
          },
        },
      });
      return { requireName: true };
    }
    result = await joinResidentWithOtp(
      contact,
      body,
      {
        ...(record.payload && typeof record.payload === "object"
          ? record.payload
          : {}),
        inviteCode,
      }
    );
  } else {
    throw new HttpError(400, "Geçersiz doğrulama isteği.");
  }

  await prisma.phoneOtpToken.update({
    where: { id: record.id },
    data: { usedAt: new Date() },
  });

  return result;
}

/**
 * POST /auth/otp/complete-resident-join — OTP doğrulandıktan sonra isim ile kaydı tamamlar.
 */
export async function completeResidentJoinService({ phone, name, inviteCode }) {
  const contact = resolveOtpContact({ phone });
  const trimmedName = name?.trim();
  if (!trimmedName || trimmedName.length < 2) {
    throw new HttpError(400, "İsim en az 2 karakter olmalıdır.");
  }
  if (!inviteCode) {
    throw new HttpError(400, "Davet kodu gereklidir.");
  }

  const record = await prisma.phoneOtpToken.findFirst({
    where: {
      ...contactWhere(contact),
      purpose: "resident_join",
      usedAt: null,
      expiresAt: { gt: new Date() },
    },
    orderBy: { createdAt: "desc" },
  });

  const payload =
    record?.payload && typeof record.payload === "object" ? record.payload : null;
  if (!record || !payload?.joinOtpConfirmed) {
    throw new HttpError(400, "Önce telefon doğrulamasını tamamlayın.");
  }

  const code = inviteCode ?? payload.inviteCode;
  const result = await joinResidentWithOtp(
    contact,
    { name: trimmedName, inviteCode: code },
    { ...payload, inviteCode: code }
  );

  await prisma.phoneOtpToken.update({
    where: { id: record.id },
    data: { usedAt: new Date() },
  });

  return result;
}

async function loginWithOtp(contact, purpose, body) {
  const role = purpose.startsWith("manager") ? "MANAGER" : "RESIDENT";
  const user = await prisma.user.findFirst({
    where: { ...contactWhere(contact), role, deletedAt: null },
  });
  if (!user) {
    throw new HttpError(401, "Giriş yapılamadı.");
  }

  const session = await createSession(user.id, deviceMeta(body));
  const tokens = await prisma.$transaction(async (tx) => {
    const t = await issueTokenPair(user, session.id);
    if (t.refreshToken) {
      await tx.userSession.update({
        where: { id: session.id },
        data: { lastTokenHash: hashToken(t.refreshToken) },
      });
    }
    return t;
  });

  return {
    ...tokens,
    user: authUserPayload(user),
  };
}

async function registerManagerWithOtp(contact, body, storedPayload) {
  const payload = { ...(storedPayload ?? {}), ...(body.payload ?? {}) };
  const name = payload.name ?? body.name;
  const password = payload.password ?? body.password;

  if (!name || name.trim().length < 2) {
    throw new HttpError(400, "İsim en az 2 karakter olmalıdır.");
  }
  if (!password) {
    throw new HttpError(400, "Şifre gereklidir.");
  }

  const existing = await prisma.user.findFirst({
    where: { ...contactWhere(contact), role: "MANAGER", deletedAt: null },
  });
  if (existing) {
    throw new HttpError(
      409,
      contact.email
        ? "Bu e-posta adresi zaten kullanılıyor."
        : "Bu telefon numarası zaten kullanılıyor."
    );
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
    data: {
      name: name.trim(),
      phone: contact.phone,
      email: contact.email,
      passwordHash,
      role: "MANAGER",
    },
  });

  const session = await createSession(user.id, deviceMeta(body));
  const tokens = await prisma.$transaction(async (tx) => {
    const t = await issueTokenPair(user, session.id);
    if (t.refreshToken) {
      await tx.userSession.update({
        where: { id: session.id },
        data: { lastTokenHash: hashToken(t.refreshToken) },
      });
    }
    return t;
  });

  return {
    ...tokens,
    user: authUserPayload(user),
  };
}

async function joinResidentWithOtp(contact, body, storedPayload) {
  const payload = { ...(storedPayload ?? {}), ...(body.payload ?? {}) };
  const name = payload.name ?? body.name;
  const inviteCode = payload.inviteCode ?? body.inviteCode;

  if (!name || name.trim().length < 2) {
    throw new HttpError(400, "İsim en az 2 karakter olmalıdır.");
  }
  if (!inviteCode) {
    throw new HttpError(400, "Davet kodu gereklidir.");
  }

  let inviteCodeData;
  try {
    inviteCodeData = await validateInviteCode(inviteCode);
  } catch {
    throw new HttpError(400, "Davet kodu geçersiz veya süresi dolmuş.");
  }

  const existing = await prisma.user.findFirst({
    where: { ...contactWhere(contact), role: "RESIDENT", deletedAt: null },
  });
  if (existing) {
    throw new HttpError(
      409,
      contact.email
        ? "Bu e-posta adresi zaten kullanılıyor."
        : "Bu telefon numarası zaten kullanılıyor."
    );
  }

  const randomSecret = crypto.randomBytes(32).toString("hex");
  const passwordHash = await bcrypt.hash(randomSecret, 10);

  const user = await prisma.$transaction(async (tx) => {
    const created = await tx.user.create({
      data: {
        name: name.trim(),
        phone: contact.phone,
        email: contact.email,
        passwordHash,
        role: "RESIDENT",
        apartmentId: inviteCodeData.apartmentId,
      },
    });

    await tx.inviteCode.update({
      where: { id: inviteCodeData.id },
      data: {
        usedAt: new Date(),
        usedBy: created.id,
      },
    });

    return created;
  });

  const session = await createSession(user.id, deviceMeta(body));
  const tokens = await prisma.$transaction(async (tx) => {
    const t = await issueTokenPair(user, session.id);
    if (t.refreshToken) {
      await tx.userSession.update({
        where: { id: session.id },
        data: { lastTokenHash: hashToken(t.refreshToken) },
      });
    }
    return t;
  });

  return {
    ...tokens,
    user: authUserPayload(user),
  };
}

/**
 * POST /auth/invite/validate — tek tip hata, maskeli bilgi
 */
export async function validateInvitePublicService(inviteCode) {
  const normalized = normalizeInviteCode(inviteCode);
  if (!normalized) {
    throw new HttpError(400, "Davet kodu geçersiz veya süresi dolmuş.");
  }

  try {
    const data = await validateInviteCode(normalized);
    const building = data.apartment?.building;
    const block = building?.blockLabel?.trim();
    const buildingName = building?.name?.trim() || block || "Apartman";
    const masked = block ? `${buildingName} · ${block}` : buildingName;
    return { valid: true, label: masked };
  } catch {
    throw new HttpError(400, "Davet kodu geçersiz veya süresi dolmuş.");
  }
}

export { authUserPayload, issueTokenPair, deviceMeta, hashToken };
