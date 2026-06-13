import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { toPublicUser, userPublicSelect } from "./userPublic.js";
import { findActiveUserById } from "./profileHelpers.js";

export async function updateLanguageService(userId, language) {
  const ok = await findActiveUserById(userId, { id: true });
  if (!ok) {
    throw new HttpError(401, "Kullanıcı bulunamadı.");
  }

  const updated = await prisma.user.update({
    where: { id: userId },
    data: { language },
    select: userPublicSelect,
  });
  return toPublicUser(updated);
}
