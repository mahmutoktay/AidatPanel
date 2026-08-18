import bcrypt from "bcryptjs";
import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { normalizeTrPhone } from "../../utils/normalizeTrPhone.js";
import { assertPhoneGloballyAvailable } from "../../utils/phoneAvailability.js";

export function buildPaymentReference(template, apartmentNumber) {
  const normalizedTemplate = template ?? "";
  const number = String(apartmentNumber);
  const paymentReference = normalizedTemplate
    ? normalizedTemplate.replace(/\{\{number\}\}/g, number)
    : null;
  return paymentReference || null;
}

export function resolveContactValues(user, { email, phone }) {
  const isEmailChanged = email !== undefined && email !== user.email;
  const isPhoneChanged = phone !== undefined && phone !== user.phone;
  const newEmail = email !== undefined ? email : user.email;
  const newPhone = phone !== undefined ? phone : user.phone;

  return { isEmailChanged, isPhoneChanged, newEmail, newPhone };
}

export function assertMinContactRequired(newEmail, newPhone) {
  if (!newEmail && !newPhone) {
    throw new HttpError(
      400,
      "Sistemde e-posta adresi veya telefon numarasından en az biri mutlaka bulunmalıdır.",
      { code: "MIN_CONTACT_REQUIRED" }
    );
  }
}

export async function assertCurrentPasswordForSensitiveChange(
  user,
  { isEmailChanged, isPhoneChanged, currentPassword }
) {
  if (!isEmailChanged && !isPhoneChanged) return;

  if (!currentPassword) {
    throw new HttpError(
      400,
      "E-posta veya telefon numarası değiştirmek için mevcut şifrenizi girmelisiniz."
    );
  }

  const ok = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!ok) {
    throw new HttpError(400, "Mevcut şifreniz hatalı.");
  }
}

/** Sakin telefonu zorunludur (e-posta tutulmaz). */
export function assertResidentPhoneRequired(newPhone) {
  if (!newPhone) {
    throw new HttpError(400, "Telefon numarası gereklidir.", {
      code: "RESIDENT_PHONE_REQUIRED",
    });
  }
}

export async function assertEmailAvailableForUser(userId, email) {
  if (email === null || email === undefined) return;

  const taken = await prisma.user.findFirst({
    where: { email, NOT: { id: userId }, deletedAt: null },
    select: { id: true },
  });
  if (taken) {
    throw new HttpError(409, "Bu e-posta adresi zaten kullanılıyor.");
  }
}

export async function assertPhoneAvailableForUser(userId, phone, role) {
  if (phone === null || phone === undefined) return;

  const normalized = normalizeTrPhone(phone) ?? phone;
  await assertPhoneGloballyAvailable(normalized, {
    excludeUserId: userId,
    requestingRole: role,
  });
}

export async function findActiveUserById(userId, select) {
  return prisma.user.findFirst({
    where: { id: userId, deletedAt: null },
    ...(select ? { select } : {}),
  });
}
