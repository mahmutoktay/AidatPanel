import { prisma } from "../config/db.js";
import bcrypt from "bcryptjs";

/**
 * Kullanıcı oluşturma servisi
 */
export const createUserService = async (userData) => {
  const { name, email, password, role = "MANAGER", apartmentId = null } = userData;

  const hashedPassword = await bcrypt.hash(password, 10);

  return await prisma.user.create({
    data: {
      name,
      email,
      passwordHash: hashedPassword,
      role,
      apartmentId,
    },
  });
};

/**
 * Email kontrolü servisi
 */
export const findUserByEmail = async (email) => {
  return await prisma.user.findUnique({
    where: { email },
  });
};

/**
 * Şifre doğrulama servisi
 */
export const validatePassword = async (plainPassword, hashedPassword) => {
  return await bcrypt.compare(plainPassword, hashedPassword);
};

/**
 * Davet kodu kontrolü servisi
 * Hata durumunda Error throw eder (controller ile uyumlu)
 */
export const validateInviteCode = async (code) => {
  const inviteCode = await prisma.inviteCode.findUnique({
    where: { code },
    include: { apartment: { include: { building: true } } }
  });

  if (!inviteCode) {
    throw new Error("Geçersiz davet kodu.");
  }

  if (inviteCode.usedAt) {
    throw new Error("Bu davet kodu zaten kullanılmış.");
  }

  if (inviteCode.expiresAt < new Date()) {
    throw new Error("Davet kodunun süresi dolmuş.");
  }

  return inviteCode;
};

/**
 * Davet kodu kullanıldı olarak işaretleme servisi
 */
export const markInviteCodeAsUsed = async (codeId, userId) => {
  return await prisma.inviteCode.update({
    where: { id: codeId },
    data: {
      usedAt: new Date(),
      usedBy: userId,
    },
  });
};
