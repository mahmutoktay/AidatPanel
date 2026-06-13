import { prisma } from "../config/db.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { generateAccessToken, generateRefreshToken } from "../utils/generateTokens.js";
import { validateInviteCode } from "./inviteCodeService.js";
import { HttpError } from "../utils/httpError.js";
import { publishToUser } from "../realtime/realtimeHub.js";

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

async function assertEmailAvailable(email) {
  const existing = await prisma.user.findFirst({
    where: { email, deletedAt: null },
  });
  if (existing) {
    throw new HttpError(409, "Bu email adresi zaten kullanılıyor.");
  }
}

async function assertPhoneAvailable(phone) {
  if (!phone) return;
  const existing = await prisma.user.findFirst({
    where: { phone, deletedAt: null },
  });
  if (existing) {
    throw new HttpError(409, "Bu telefon numarası zaten kullanılıyor.");
  }
}

async function findActiveUserByIdentifier(identifier) {
  const isEmail = identifier.includes("@");
  return prisma.user.findFirst({
    where: isEmail
      ? { email: identifier, deletedAt: null }
      : { phone: identifier, deletedAt: null },
  });
}

/**
 * Yönetici kaydı — POST /auth/register
 */
export async function registerService({ name, email, phone, password }) {
  await assertEmailAvailable(email);
  await assertPhoneAvailable(phone);

  const hashedPassword = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({
    data: {
      name,
      email,
      phone,
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
export async function loginService({ identifier, password }) {
  const user = await findActiveUserByIdentifier(identifier);

  if (!user) {
    throw new HttpError(401, "Email/telefon veya şifre hatalı.");
  }

  const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
  if (!isPasswordValid) {
    throw new HttpError(401, "Email/telefon veya şifre hatalı.");
  }

  return {
    accessToken: generateAccessToken(user),
    refreshToken: generateRefreshToken(user),
    user: authUserPayload(user),
  };
}

/**
 * Access token yenileme — POST /auth/refresh
 */
export async function refreshAccessTokenService(refreshToken) {
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
  const user = await prisma.user.findFirst({
    where: { id: decoded.id, deletedAt: null },
  });

  if (!user) {
    throw new HttpError(401, "Kullanıcı bulunamadı.");
  }

  if ((user.refreshTokenVersion ?? 0) !== tokenRv) {
    throw new HttpError(401, "Oturum sonlandırıldı. Lütfen tekrar giriş yapın.");
  }

  return { accessToken: generateAccessToken(user) };
}

/**
 * Davet koduyla sakin kaydı — POST /auth/join
 */
export async function joinWithInviteCodeService({ name, email, phone, password, inviteCode }) {
  let inviteCodeData;
  try {
    inviteCodeData = await validateInviteCode(inviteCode);
  } catch (err) {
    throw new HttpError(400, err.message);
  }

  await assertEmailAvailable(email);
  await assertPhoneAvailable(phone);

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

  return {
    accessToken: generateAccessToken(user),
    refreshToken: generateRefreshToken(user),
    user: authUserPayload(user),
  };
}

/**
 * Tek cihaz çıkışı — POST /auth/logout
 */
export async function logoutService(userId) {
  await prisma.user.update({
    where: { id: userId },
    data: { fcmToken: null },
  });
}

/**
 * Diğer cihazlardan çıkış — POST /auth/logout-all-devices
 */
export async function logoutAllDevicesService(userId) {
  const user = await prisma.user.update({
    where: { id: userId },
    data: {
      refreshTokenVersion: { increment: 1 },
    },
  });

  publishToUser(user.id, { event: "force_logout" });

  return {
    accessToken: generateAccessToken(user),
    refreshToken: generateRefreshToken(user),
  };
}
