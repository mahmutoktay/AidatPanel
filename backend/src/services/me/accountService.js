import bcrypt from "bcryptjs";
import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { revokeAllUserSessions } from "../sessionService.js";
/**
 * KVKK: kayıt silinmez; PII maskelenir, oturumlar iptal edilir.
 * Yöneticinin en az bir yönettiği bina varsa 409.
 */
export async function softDeleteAccountService(userId) {
  const user = await prisma.user.findFirst({
    where: { id: userId, deletedAt: null },
    include: {
      _count: { select: { managedBuildings: true } },
    },
  });
  if (!user) {
    throw new HttpError(401, "Kullanıcı bulunamadı.");
  }
  if (user._count.managedBuildings > 0) {
    throw new HttpError(
      409,
      "Yönettiğiniz bina kayıtları varken hesap kapatılamaz. Önce binaları silin veya başka yöneticiye devredin."
    );
  }

  const ghostEmail = `deleted.${user.id}@closed.aidatpanel.invalid`;
  const random = await bcrypt.hash(`${user.id}:${Date.now()}`, 4);

  await prisma.$transaction([
    prisma.passwordResetToken.deleteMany({ where: { userId } }),
    prisma.user.update({
      where: { id: userId },
      data: {
        deletedAt: new Date(),
        email: ghostEmail,
        phone: null,
        name: "Silinmiş kullanıcı",
        passwordHash: random,
        apartmentId: null,
        fcmToken: null,
        refreshTokenVersion: { increment: 1 },
      },
    }),
  ]);
  await revokeAllUserSessions(userId);
}
