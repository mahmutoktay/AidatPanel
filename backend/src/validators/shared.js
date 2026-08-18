import { z } from "zod";
import { LIST_MAX_ROWS } from "../utils/listQuery.js";
import { normalizeTrPhone } from "../utils/normalizeTrPhone.js";

/**
 * Ortak şifre şeması — Flutter InputValidators ile uyumlu.
 * En az 6 karakter, en az bir harf ve bir rakam. Özel karakter isteğe bağlı.
 */
export const passwordSchema = z
  .string()
  .min(6, "Şifre en az 6 karakter olmalıdır")
  .max(100, "Şifre en fazla 100 karakter olabilir")
  .regex(/[A-Za-zÇĞİÖŞÜçğıöşü]/, "Şifre en az bir harf içermelidir")
  .regex(/[0-9]/, "Şifre en az bir rakam içermelidir");

export const optionalListLimit = z.coerce
  .number()
  .int("limit tam sayı olmalıdır")
  .min(1)
  .max(LIST_MAX_ROWS)
  .optional();

export const optionalListCursor = z.string().uuid("Geçersiz cursor").optional();

export const optionalPaginatedFlag = z.enum(["true", "false"]).optional();

export const listPaginationFields = {
  limit: optionalListLimit,
  cursor: optionalListCursor,
  paginated: optionalPaginatedFlag,
};

export const optionalPhone = z.preprocess(
  (v) => {
    if (v === "" || v === null || v === undefined) return undefined;
    return normalizeTrPhone(String(v)) ?? v;
  },
  z
    .string()
    .regex(/^5[0-9]{9}$/, "Geçerli bir telefon numarası giriniz (10 hane)")
    .optional()
);

/** OTP / zorunlu telefon alanları */
export const normalizedPhoneSchema = z.preprocess(
  (v) => normalizeTrPhone(typeof v === "string" ? v : ""),
  z.string().regex(/^5[0-9]{9}$/, "Geçerli bir telefon numarası giriniz")
);

/** PUT /me — `phone: null` veya boş string profilden telefonu siler (meService). */
export const profilePhone = z.preprocess(
  (v) => {
    if (v === "") return null;
    if (v === undefined) return undefined;
    if (v === null) return null;
    return normalizeTrPhone(String(v)) ?? v;
  },
  z
    .union([
      z.null(),
      z
        .string()
        .regex(/^5[0-9]{9}$/, "Geçerli bir telefon numarası giriniz (10 hane)"),
    ])
    .optional()
);

export const profileEmail = z.preprocess(
  (v) => {
    if (v === "") return null;
    if (v === undefined) return undefined;
    return v;
  },
  z
    .union([
      z.null(),
      z.string().email("Geçerli bir email adresi giriniz"),
    ])
    .optional()
);

export const optionalIban = z
  .string()
  .transform((v) => v.replace(/\s/g, "").toUpperCase())
  .refine((v) => v === "" || /^TR\d{24}$/.test(v), "Geçersiz TR IBAN")
  .optional()
  .nullable();

export const expenseCategoryEnum = z.enum([
  "CLEANING",
  "ELEVATOR",
  "ELECTRICITY",
  "WATER",
  "INSURANCE",
  "REPAIR",
  "GARDEN",
  "OTHER",
]);

export const ticketStatusEnum = z.enum(["OPEN", "IN_PROGRESS", "RESOLVED", "CLOSED"]);

export const ticketCategoryEnum = z.enum([
  "COMPLAINT",
  "REQUEST",
  "MALFUNCTION",
  "OTHER",
]);

export const dueStatusEnum = z.enum(["PENDING", "PAID", "OVERDUE", "WAIVED"], {
  errorMap: () => ({ message: "Geçersiz durum değeri" }),
});

export const dekontStatusEnum = z.enum(
  [
    "RECEIVED",
    "EXTRACTING",
    "EXTRACT_FAILED",
    "PARSED",
    "PARSE_LOW_CONFIDENCE",
    "MATCHING",
    "MATCHED",
    "MATCH_AMBIGUOUS",
    "UNMATCHED",
    "PAYMENT_APPLIED",
    "PAYMENT_PARTIAL",
    "REJECTED",
    "RECIPIENT_MISMATCH",
    "NEEDS_MANAGER_REVIEW",
  ],
  { errorMap: () => ({ message: "Geçersiz dekont durumu" }) }
);

export const monthYearPairRefine = (data) =>
  (data.month == null && data.year == null) ||
  (data.month != null && data.year != null);

export const monthYearPairMessage = { message: "Ay ve yıl birlikte gönderilmelidir." };
