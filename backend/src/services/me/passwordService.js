import bcrypt from "bcryptjs";
import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { findActiveUserById } from "./profileHelpers.js";
import { revokeAllUserSessions } from "../sessionService.js";

export async function changePasswordService(userId, currentPassword, newPassword) {
  const user = await findActiveUserById(userId);
  if (!user) {
    throw new HttpError(401, "Kullanıcı bulunamadı.");
  }

  const ok = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!ok) {
    throw new HttpError(400, "Mevcut şifre hatalı.");
  }

  const passwordHash = await bcrypt.hash(newPassword, 10);
  await prisma.user.update({
    where: { id: userId },
    data: {
      passwordHash,
      refreshTokenVersion: { increment: 1 },
    },
  });
  await revokeAllUserSessions(userId);
}
