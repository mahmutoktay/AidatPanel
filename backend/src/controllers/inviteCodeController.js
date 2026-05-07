import { prisma } from "../config/db.js";
import crypto from "crypto";

/**
 * Benzersiz davet kodu üret (collision durumunda retry)
 */
const generateUniqueCode = async (maxRetries = 3) => {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    // 12 karakterlik rastgele kod üret: APXX-XXXX-XXXX
    const code = crypto.randomBytes(4).toString('hex').toUpperCase();
    const formattedCode = `AP${code.slice(0, 2)}-${code.slice(2, 6)}-${code.slice(6, 10)}`;

    // Kodun benzersiz olduğunu kontrol et
    const existing = await prisma.inviteCode.findUnique({
      where: { code: formattedCode }
    });

    if (!existing) {
      return formattedCode;
    }
  }

  throw new Error("Benzersiz davet kodu üretilemedi. Lütfen tekrar deneyin.");
};

// Davet kodu üret
const generateInviteCode = async (req, res, next) => {
  try {
    // POST /api/v1/apartments/:apartmentId/invite-code
    const { apartmentId } = req.params;
    const managerId = req.user.id;

    // Apartmanın bu yöneticiye ait olduğunu kontrol et
    const apartment = await prisma.apartment.findFirst({
      where: {
        id: apartmentId,
        building: { managerId }
      }
    });

    if (!apartment) {
      return res.status(403).json({
        success: false,
        message: "Bu daire için davet kodu üretme yetkiniz yok."
      });
    }

    // Benzersiz kod üret
    const formattedCode = await generateUniqueCode();

    // 7 gün geçerlilik süresi
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    const inviteCode = await prisma.inviteCode.create({
      data: {
        code: formattedCode,
        apartmentId,
        expiresAt
      }
    });

    res.status(201).json({
      success: true,
      data: {
        code: inviteCode.code,
        expiresAt: inviteCode.expiresAt
      }
    });
  } catch (error) {
    next(error);
  }
};

// Davet kodu doğrula (dahili kullanım için)
const validateInviteCode = async (code) => {
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

export { generateInviteCode, validateInviteCode };
