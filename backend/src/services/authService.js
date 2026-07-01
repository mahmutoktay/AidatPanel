import crypto from "crypto";
import { prisma } from "../config/db.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { generateAccessToken, generateRefreshToken } from "../utils/generateTokens.js";
import { validateInviteCode } from "./inviteCodeService.js";
import { HttpError } from "../utils/httpError.js";
import {
  createSession,
  revokeOtherSessions,
} from "./sessionService.js";
import {
  normalizeTrPhone,
  normalizeLoginIdentifier,
} from "../utils/normalizeTrPhone.js";

/** Refresh token'ın SHA-256 özeti — DB'de saklanır, replay tespiti için. */
function hashToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
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

function deviceMeta(body) {
  return {
    deviceLabel: body?.deviceLabel,
    platform: body?.platform,
  };
}

async function issueTokenPair(user, sessionId) {
  return {
    accessToken: generateAccessToken(user, sessionId),
    refreshToken: generateRefreshToken(user, sessionId),
  };
}

async function assertEmailAvailable(email) {
  const existing = await prisma.user.findFirst({
    where: { email, deletedAt: null },
  });
  if (existing) {
    throw new HttpError(409, "Bu email adresi zaten kullanılıyor.");
  }
}

async function assertPhoneAvailable(phone, role) {
  if (!phone) return;
  const existing = await prisma.user.findFirst({
    where: { phone, role, deletedAt: null },
  });
  if (existing) {
    throw new HttpError(409, "Bu telefon numarası zaten kullanılıyor.");
  }
}

async function findActiveUserByIdentifier(identifier) {
  const normalized = normalizeLoginIdentifier(identifier);
  const isEmail = normalized.includes("@");
  return prisma.user.findFirst({
    where: isEmail
      ? { email: normalized, deletedAt: null }
      : { phone: normalized, deletedAt: null },
  });
}

function assertMinContactRequired(email, phone) {
  if (!email && !phone) {
    throw new HttpError(400, "E-posta veya telefon numarası gereklidir.");
  }
}

/**
 * POST /auth/check-identifier — kayıt/giriş öncesi e-posta veya telefon uygunluğu.
 */
export async function checkIdentifierService({ identifier, purpose }) {
  const normalized = normalizeLoginIdentifier(identifier);
  const isEmail = normalized.includes("@");

  if (!normalized) {
    throw new HttpError(400, "E-posta veya telefon numarası gereklidir.");
  }

  if (purpose === "manager_register") {
    if (isEmail) {
      await assertEmailAvailable(normalized);
    } else {
      await assertPhoneAvailable(normalized, "MANAGER");
    }
    return { ok: true };
  }

  if (purpose === "manager_login") {
    const user = await prisma.user.findFirst({
      where: isEmail
        ? { email: normalized, deletedAt: null, role: "MANAGER" }
        : { phone: normalized, deletedAt: null, role: "MANAGER" },
    });
    if (!user) {
      throw new HttpError(
        404,
        isEmail
          ? "Bu e-posta adresiyle kayıtlı hesap bulunamadı."
          : "Bu telefon numarasıyla kayıtlı hesap bulunamadı."
      );
    }
    return { ok: true };
  }

  throw new HttpError(400, "Geçersiz istek.");
}

/**
 * Yönetici kaydı — POST /auth/register
 */
export async function registerService({ name, email, phone, password }) {
  const normalizedPhone = phone ? normalizeTrPhone(phone) : null;
  if (normalizedPhone === null && phone) {
    throw new HttpError(400, "Geçerli bir telefon numarası giriniz.");
  }
  const normalizedEmail = email?.trim().toLowerCase() || null;

  assertMinContactRequired(normalizedEmail, normalizedPhone);
  if (normalizedEmail) await assertEmailAvailable(normalizedEmail);
  if (normalizedPhone) await assertPhoneAvailable(normalizedPhone, "MANAGER");

  const hashedPassword = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
    data: {
      name,
      email: normalizedEmail,
      phone: normalizedPhone,
      passwordHash: hashedPassword,
      role: "MANAGER",
    },
  });

  return {
    user: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    language: user.language,
    apartmentId: user.apartmentId,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };
}

/**
 * Giriş — POST /auth/login
 */
export async function loginService(body) {
  const { password } = body;
  const identifier = normalizeLoginIdentifier(body.identifier);
  const user = await findActiveUserByIdentifier(identifier);

  if (!user) {
    throw new HttpError(401, "Email/telefon veya şifre hatalı.");
  }

  const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
  if (!isPasswordValid) {
    throw new HttpError(401, "Email/telefon veya şifre hatalı.");
  }

  const session = await createSession(user.id, deviceMeta(body));

  // Token üretimi + hash kaydı atomik (crash-window önleme)
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
 * Access token yenileme — POST /auth/refresh
 */
export async function refreshAccessTokenService(refreshToken, body = {}) {
  if (!refreshToken) {
    throw new HttpError(401, "Refresh token gerekli.");
  }

  let decoded;
  try {
    decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
  } catch {
    throw new HttpError(401, "Oturum sonlandırıldı. Lütfen tekrar giriş yapın.");
  }

  const tokenRv = decoded.rv ?? 0;
  const tokenSid = decoded.sid ?? null;
  const user = await prisma.user.findFirst({
    where: { id: decoded.id, deletedAt: null },
  });

  if (!user) {
    throw new HttpError(401, "Kullanıcı bulunamadı.");
  }

  if ((user.refreshTokenVersion ?? 0) !== tokenRv) {
    throw new HttpError(401, "Oturum sonlandırıldı. Lütfen tekrar giriş yapın.");
  }

  // Session kontrolü + token üretimi + hash güncellemesi — TOCTOU race önleme için atomik transaction.
  const tokens = await prisma.$transaction(async (tx) => {
    let finalSessionId = tokenSid;

    if (finalSessionId) {
      // Row-Level Lock için raw SQL
      const sessions = await tx.$queryRawUnsafe(
        'SELECT id, "lastTokenHash" FROM "UserSession" WHERE id = $1 AND "revokedAt" IS NULL FOR UPDATE',
        finalSessionId
      );
      const session = sessions[0];

      if (!session) {
        throw new HttpError(401, "Oturum sonlandırıldı. Lütfen tekrar giriş yapın.");
      }

      // Token replay detection: eski token tekrar kullanıldıysa tüm oturumu iptal et.
      const currentHash = hashToken(refreshToken);
      if (session.lastTokenHash && session.lastTokenHash !== currentHash) {
        // Eski token kullanıldı — saldırı şüphesi, tüm oturumları revoke et
        await tx.user.update({
          where: { id: user.id },
          data: { refreshTokenVersion: { increment: 1 } },
        });
        await tx.userSession.updateMany({
          where: { userId: user.id, revokedAt: null },
          data: { revokedAt: new Date() },
        });
        throw new HttpError(401, "Şüpheli oturum aktivitesi tespit edildi. Tüm oturumlar sonlandırıldı.");
      }

      await tx.userSession.update({
        where: { id: finalSessionId },
        data: { lastSeenAt: new Date() },
      });
    } else {
      const session = await tx.userSession.create({
        data: {
          userId: user.id,
          deviceLabel: body?.deviceLabel ?? "unknown",
          platform: body?.platform ?? "unknown",
        },
      });
      finalSessionId = session.id;
    }

    const newTokens = await issueTokenPair(user, finalSessionId);

    // Yeni refresh token hash'ini session'a kaydet
    if (newTokens.refreshToken) {
      await tx.userSession.update({
        where: { id: finalSessionId },
        data: { lastTokenHash: hashToken(newTokens.refreshToken) },
      });
    }

    return newTokens;
  }, { isolationLevel: "ReadCommitted" });

  return tokens;
}

/**
 * Davet koduyla sakin kaydı — POST /auth/join
 */
export async function joinWithInviteCodeService(body) {
  const { name, email, password, inviteCode } = body;
  const phone = body.phone ? normalizeTrPhone(body.phone) : null;
  if (body.phone && !phone) {
    throw new HttpError(400, "Geçerli bir telefon numarası giriniz.");
  }
  let inviteCodeData;
  try {
    inviteCodeData = await validateInviteCode(inviteCode);
  } catch (err) {
    throw new HttpError(400, err.message);
  }

  await assertEmailAvailable(email);
  await assertPhoneAvailable(phone, "RESIDENT");

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await prisma.$transaction(async (tx) => {
    const created = await tx.user.create({
      data: {
        name,
        email,
        phone,
        passwordHash: hashedPassword,
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

  // Token üretimi + hash kaydı atomik (crash-window önleme)
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
 * Tek cihaz çıkışı — POST /auth/logout
 */
export async function logoutService(userId, sessionId) {
  // Sadece bu session'ı sonlandır, tüm cihazların FCM token'ını silme
  if (sessionId) {
    await prisma.userSession.updateMany({
      where: { id: sessionId, userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }
}

/**
 * Diğer cihazlardan çıkış — POST /auth/logout-all-devices
 */
export async function logoutAllDevicesService(userId, currentSessionId) {
  const user = await prisma.user.update({
    where: { id: userId },
    data: {
      refreshTokenVersion: { increment: 1 },
    },
  });

  await revokeOtherSessions(userId, currentSessionId);

  // Token üretimi + hash kaydı atomik (crash-window önleme)
  const tokens = await prisma.$transaction(async (tx) => {
    const t = await issueTokenPair(user, currentSessionId ?? null);
    if (currentSessionId && t.refreshToken) {
      await tx.userSession.update({
        where: { id: currentSessionId },
        data: { lastTokenHash: hashToken(t.refreshToken) },
      });
    }
    return t;
  });

  return tokens;
}
