import { prisma } from "../config/db.js";

/**
 * Davet kodunu doğrular. Hata durumunda anlamlı mesajlı `Error` fırlatır.
 */
export const validateInviteCode = async (code) => {
  const inviteCode = await prisma.inviteCode.findUnique({
    where: { code },
    include: { apartment: { include: { building: true } } },
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
