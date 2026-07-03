import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { toPublicUser, userPublicSelect } from "./userPublic.js";
import {
  assertCurrentPasswordForSensitiveChange,
  assertEmailAvailableForUser,
  assertMinContactRequired,
  assertPhoneAvailableForUser,
  findActiveUserById,
  resolveContactValues,
} from "./profileHelpers.js";

export async function getProfileService(userId) {
  const user = await findActiveUserById(userId, userPublicSelect);
  if (!user) {
    throw new HttpError(401, "Kullanıcı bulunamadı.");
  }
  return toPublicUser(user);
}

export async function updateProfileService(
  userId,
  { name, email, phone, language, currentPassword }
) {
  const user = await findActiveUserById(userId);
  if (!user) {
    throw new HttpError(401, "Kullanıcı bulunamadı.");
  }

  const { isEmailChanged, isPhoneChanged, newEmail, newPhone } =
    resolveContactValues(user, { email, phone });

  assertMinContactRequired(newEmail, newPhone);

  await assertCurrentPasswordForSensitiveChange(user, {
    isEmailChanged,
    isPhoneChanged,
    currentPassword,
  });

  if (isEmailChanged) {
    await assertEmailAvailableForUser(userId, email);
  }
  if (isPhoneChanged) {
    await assertPhoneAvailableForUser(userId, phone, user.role);
  }

  const data = {};
  if (name !== undefined) data.name = name;
  if (email !== undefined) data.email = email;
  if (phone !== undefined) data.phone = phone;
  if (language !== undefined) data.language = language;

  const updated = await prisma.user.update({
    where: { id: userId },
    data,
    select: userPublicSelect,
  });
  return toPublicUser(updated);
}
