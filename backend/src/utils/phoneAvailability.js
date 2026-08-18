import { prisma } from "../config/db.js";
import { HttpError } from "./httpError.js";
import { normalizeTrPhone, phoneLookupVariants } from "./normalizeTrPhone.js";

/**
 * Aktif kullanıcı — telefon kanonik + legacy yazılışlarla aranır.
 * @param {string} phone
 * @param {{ excludeUserId?: string }} [opts]
 */
export async function findActiveUserByPhone(phone, { excludeUserId } = {}) {
  const normalized = normalizeTrPhone(phone) ?? phone;
  const variants = phoneLookupVariants(normalized);
  if (!variants.length) return null;

  return prisma.user.findFirst({
    where: {
      phone: { in: variants },
      deletedAt: null,
      ...(excludeUserId ? { NOT: { id: excludeUserId } } : {}),
    },
    select: { id: true, role: true, phone: true },
  });
}

/**
 * Telefon tüm roller arasında tekil — sakin numarası yönetici hesabında kullanılamaz.
 * @param {string|null|undefined} phone
 * @param {{ excludeUserId?: string, requestingRole?: "MANAGER"|"RESIDENT" }} [opts]
 */
export async function assertPhoneGloballyAvailable(
  phone,
  { excludeUserId, requestingRole } = {}
) {
  if (phone == null || phone === "") return;

  const existing = await findActiveUserByPhone(phone, { excludeUserId });
  if (!existing) return;

  if (requestingRole === "MANAGER" && existing.role === "RESIDENT") {
    throw new HttpError(
      409,
      "Bu telefon numarası bir sakin hesabına kayıtlı. Yönetici hesabında kullanılamaz."
    );
  }

  if (requestingRole === "RESIDENT" && existing.role === "MANAGER") {
    throw new HttpError(
      409,
      "Bu telefon numarası bir yönetici hesabına kayıtlı. Sakin hesabında kullanılamaz."
    );
  }

  throw new HttpError(409, "Bu telefon numarası zaten kullanılıyor.");
}
