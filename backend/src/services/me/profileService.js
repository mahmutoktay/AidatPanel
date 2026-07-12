import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { toPublicUser, userPublicSelect } from "./userPublic.js";
import { consumePhoneChangeOtp } from "../otpService.js";
import {
  assertCurrentPasswordForSensitiveChange,
  assertEmailAvailableForUser,
  assertMinContactRequired,
  assertPhoneAvailableForUser,
  assertResidentPhoneRequired,
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
  { name, email, phone, language, currentPassword, otpCode }
) {
  const user = await findActiveUserById(userId);
  if (!user) {
    throw new HttpError(401, "Kullanıcı bulunamadı.");
  }

  const isResident = user.role === "RESIDENT";
  // Sakinlerde e-posta tutulmaz; istemci gönderse bile yok say.
  const emailInput = isResident ? undefined : email;

  const { isEmailChanged, isPhoneChanged, newEmail, newPhone } =
    resolveContactValues(user, { email: emailInput, phone });

  if (isResident) {
    assertResidentPhoneRequired(newPhone);
  } else {
    assertMinContactRequired(newEmail, newPhone);
  }

  if (isResident) {
    if (isPhoneChanged) {
      if (!otpCode) {
        throw new HttpError(
          400,
          "Telefon numaranızı değiştirmek için SMS doğrulama kodu gereklidir."
        );
      }
      await assertPhoneAvailableForUser(userId, phone, user.role);
      await consumePhoneChangeOtp({ phone: newPhone, code: otpCode });
    }
  } else {
    await assertCurrentPasswordForSensitiveChange(user, {
      isEmailChanged,
      isPhoneChanged,
      currentPassword,
    });

    if (isEmailChanged) {
      await assertEmailAvailableForUser(userId, emailInput);
    }
    if (isPhoneChanged) {
      await assertPhoneAvailableForUser(userId, phone, user.role);
    }
  }

  const data = {};
  if (name !== undefined) data.name = name;
  if (!isResident && emailInput !== undefined) data.email = emailInput;
  if (phone !== undefined) data.phone = phone;
  if (language !== undefined) data.language = language;

  const updated = await prisma.user.update({
    where: { id: userId },
    data,
    select: userPublicSelect,
  });
  return toPublicUser(updated);
}
