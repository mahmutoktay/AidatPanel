import crypto from "node:crypto";
import bcrypt from "bcryptjs";
import { appendFile, mkdir } from "node:fs/promises";
import { dirname } from "node:path";
import { prisma } from "../config/db.js";
import { logger } from "../config/logger.js";
import { HttpError } from "../utils/httpError.js";
import {
  normalizeTrPhone,
  phoneLookupVariants,
} from "../utils/normalizeTrPhone.js";
import { revokeAllUserSessions } from "./sessionService.js";
import { sendSms } from "./sms/sendSms.js";

const DEFAULT_EXPIRES_MIN = 60;
const SMS_RESET_MAX_PER_HOUR = 3;
const SMS_RESET_WINDOW_MS = 60 * 60 * 1000;

/** @type {Map<string, number[]>} userId → SMS gönderim zamanları */
const smsResetSendTimestamps = new Map();

/** 32 karakter: rakam (2–9) + büyük harf; 0/O/1/I/L yok (okunabilirlik). */
const RESET_CODE_CHARSET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";

const EMPTY_RESULT = Object.freeze({
  deliveredVia: null,
  smsFallbackAvailable: false,
});

function generateResetCode() {
  for (let attempt = 0; attempt < 64; attempt++) {
    let s = "";
    for (let i = 0; i < 6; i++) {
      s += RESET_CODE_CHARSET[crypto.randomInt(0, RESET_CODE_CHARSET.length)];
    }
    if (/[2-9]/.test(s) && /[A-Z]/.test(s)) {
      return s;
    }
  }
  let s = "";
  for (let i = 0; i < 6; i++) {
    s += RESET_CODE_CHARSET[crypto.randomInt(0, RESET_CODE_CHARSET.length)];
  }
  return s;
}

function hashToken(plain) {
  return crypto.createHash("sha256").update(plain, "utf8").digest("hex");
}

function expiresAt() {
  const min =
    Number(process.env.PASSWORD_RESET_EXPIRES_MINUTES) || DEFAULT_EXPIRES_MIN;
  return new Date(Date.now() + min * 60 * 1000);
}

function normalizeEmail(raw) {
  if (typeof raw !== "string") return null;
  const v = raw.trim().toLowerCase();
  if (!v || !v.includes("@")) return null;
  return v;
}

function assertSmsResetRateLimit(userId) {
  const now = Date.now();
  const recent = (smsResetSendTimestamps.get(userId) || []).filter(
    (t) => now - t < SMS_RESET_WINDOW_MS,
  );
  if (recent.length >= SMS_RESET_MAX_PER_HOUR) {
    throw new HttpError(
      429,
      "SMS ile kod gönderme limiti aşıldı. Lütfen daha sonra tekrar deneyin.",
    );
  }
  recent.push(now);
  smsResetSendTimestamps.set(userId, recent);
}

async function findUserForReset({ email, phone }) {
  if (email) {
    return prisma.user.findFirst({
      where: { email, deletedAt: null },
      select: { id: true, email: true, phone: true },
    });
  }
  if (phone) {
    const variants = phoneLookupVariants(phone);
    return prisma.user.findFirst({
      where: { phone: { in: variants }, deletedAt: null },
      select: { id: true, email: true, phone: true },
    });
  }
  return null;
}

/**
 * Kanal kuralı:
 * - channel === "sms" → yalnızca telefonu olan hesaplara SMS
 * - aksi halde e-posta varsa e-posta; yoksa telefon varsa SMS
 */
function resolveDeliveryChannel(user, requestedChannel) {
  const hasEmail = Boolean(user.email);
  const hasPhone = Boolean(user.phone);

  if (requestedChannel === "sms") {
    if (!hasPhone) return null;
    return "sms";
  }
  if (hasEmail) return "email";
  if (hasPhone) return "sms";
  return null;
}

async function sendResendEmail({ to, subject, html }) {
  const key = process.env.RESEND_API_KEY;
  if (!key) {
    return false;
  }
  const from =
    process.env.RESEND_FROM_EMAIL || "AidatPanel <onboarding@resend.dev>";
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ from, to: [to], subject, html }),
  });
  if (!res.ok) {
    const text = await res.text();
    logger.error({ type: "resend_email_error", status: res.status, body: text });
    return false;
  }
  return true;
}

async function createResetToken(userId) {
  await prisma.passwordResetToken.deleteMany({
    where: { userId, usedAt: null },
  });

  let plain = generateResetCode();
  let tokenHash = hashToken(plain);
  let created = false;
  for (let attempt = 0; attempt < 8; attempt++) {
    try {
      await prisma.passwordResetToken.create({
        data: {
          userId,
          tokenHash,
          expiresAt: expiresAt(),
        },
      });
      created = true;
      break;
    } catch (e) {
      if (e?.code === "P2002") {
        plain = generateResetCode();
        tokenHash = hashToken(plain);
        continue;
      }
      throw e;
    }
  }
  if (!created) {
    throw new Error("Şifre sıfırlama kodu üretilemedi; lütfen tekrar deneyin.");
  }
  return { plain, tokenHash };
}

async function maybeLogE2E({ userId, tokenHash }) {
  const e2ePath = process.env.AIDATPANEL_E2E_RESET_LOG;
  const isE2E = process.env.AIDATPANEL_E2E === "1";
  if (!e2ePath || !isE2E) return;
  try {
    const dir = dirname(e2ePath);
    if (dir && dir !== ".") {
      await mkdir(dir, { recursive: true });
    }
    await appendFile(
      e2ePath,
      `${JSON.stringify({
        userId,
        tokenHash,
        createdAt: new Date().toISOString(),
      })}\n`,
      "utf8",
    );
  } catch (e) {
    logger.error({ type: "e2e_reset_log_write_failed", err: e?.message });
  }
}

async function deliverByEmail(user, plain) {
  const key = process.env.RESEND_API_KEY;
  if (!key) {
    if (process.env.NODE_ENV === "development") {
      logger.warn({ type: "password_reset_no_resend_key" });
    }
    return;
  }

  const appHint =
    process.env.PASSWORD_RESET_APP_HINT ||
    "Uygulamada «Şifre sıfırla» ekranına bu kodu yapıştırın.";

  const mins =
    Number(process.env.PASSWORD_RESET_EXPIRES_MINUTES) || DEFAULT_EXPIRES_MIN;
  const html = `
    <p>AidatPanel şifre sıfırlama talebi alındı.</p>
    <p><strong>6 haneli kod (${mins} dk geçerli):</strong></p>
    <p style="font-size:22px;font-weight:700;letter-spacing:4px;font-family:monospace;">${plain}</p>
    <p>${appHint}</p>
  `;

  await sendResendEmail({
    to: user.email,
    subject: "AidatPanel — şifre sıfırlama",
    html,
  });
}

async function deliverBySms(user, plain) {
  const phone10 = normalizeTrPhone(user.phone) || user.phone;
  if (!phone10) {
    logger.warn({ type: "password_reset_sms_no_phone", userId: user.id });
    return;
  }
  assertSmsResetRateLimit(user.id);
  const mins =
    Number(process.env.PASSWORD_RESET_EXPIRES_MINUTES) || DEFAULT_EXPIRES_MIN;
  const message = `AidatPanel sifre sifirlama kodunuz: ${plain} (${mins} dk gecerli)`;
  const result = await sendSms(phone10, message);
  if (!result?.ok) {
    logger.error({
      type: "password_reset_sms_failed",
      userId: user.id,
      error: result?.error,
    });
  }
}

/**
 * Şifre sıfırlama kodu ister.
 *
 * Geriye dönük uyumluluk: `requestPasswordResetService(emailString)` hâlâ çalışır.
 * Yeni imza: `{ email?, phone?, channel? }` — channel `"sms"` yalnızca opt-in SMS.
 *
 * Enumeration koruması: kullanıcı yoksa da aynı yapıda sonuç döner.
 * @returns {{ deliveredVia: "email"|"sms"|null, smsFallbackAvailable: boolean }}
 */
export async function requestPasswordResetService(input) {
  const opts =
    typeof input === "string"
      ? { email: input }
      : input && typeof input === "object"
        ? input
        : {};

  const email = normalizeEmail(opts.email);
  const phone = opts.phone
    ? normalizeTrPhone(String(opts.phone)) ||
      (typeof opts.phone === "string" && /^5\d{9}$/.test(opts.phone.trim())
        ? opts.phone.trim()
        : null)
    : null;
  const channel =
    opts.channel === "sms" || opts.channel === "email" ? opts.channel : undefined;

  if (!email && !phone) {
    return { ...EMPTY_RESULT };
  }

  const user = await findUserForReset({ email, phone });
  if (!user) {
    return { ...EMPTY_RESULT };
  }

  const delivery = resolveDeliveryChannel(user, channel);
  if (!delivery) {
    return { ...EMPTY_RESULT };
  }

  const { plain, tokenHash } = await createResetToken(user.id);
  await maybeLogE2E({ userId: user.id, tokenHash });

  if (delivery === "email") {
    await deliverByEmail(user, plain);
    return {
      deliveredVia: "email",
      smsFallbackAvailable: Boolean(user.phone),
    };
  }

  await deliverBySms(user, plain);
  return {
    deliveredVia: "sms",
    smsFallbackAvailable: false,
  };
}

/** Kullanıcı küçük harf veya boşluk girerse normalize et (e-postadaki kod büyük harf). */
function normalizeResetCode(raw) {
  if (typeof raw !== "string") {
    return "";
  }
  return raw.trim().toUpperCase().replace(/\s+/g, "");
}

export async function resetPasswordWithTokenService(plainToken, newPassword) {
  const normalized = normalizeResetCode(plainToken);
  const tokenHash = hashToken(normalized);
  const row = await prisma.passwordResetToken.findUnique({
    where: { tokenHash },
    include: { user: true },
  });

  if (!row || row.usedAt || row.user.deletedAt) {
    throw new HttpError(400, "Geçersiz veya süresi dolmuş sıfırlama kodu.");
  }
  if (row.expiresAt < new Date()) {
    throw new HttpError(400, "Geçersiz veya süresi dolmuş sıfırlama kodu.");
  }

  const passwordHash = await bcrypt.hash(newPassword, 10);

  await prisma.$transaction([
    prisma.user.update({
      where: { id: row.userId },
      data: {
        passwordHash,
        refreshTokenVersion: { increment: 1 },
      },
    }),
    prisma.passwordResetToken.update({
      where: { id: row.id },
      data: { usedAt: new Date() },
    }),
  ]);
  await revokeAllUserSessions(row.userId);
}
