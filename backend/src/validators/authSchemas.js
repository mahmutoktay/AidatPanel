import { z } from "zod";
import { optionalPhone, passwordSchema, normalizedPhoneSchema } from "./shared.js";

const deviceMetaFields = {
  deviceLabel: z
    .string()
    .min(1, "Cihaz adı en az 1 karakter olmalıdır")
    .max(120, "Cihaz adı en fazla 120 karakter olabilir")
    .optional(),
  platform: z
    .string()
    .min(1, "Platform en az 1 karakter olmalıdır")
    .max(20, "Platform en fazla 20 karakter olabilir")
    .optional(),
};

const otpPurpose = z.enum([
  "manager_register",
  "manager_login",
  "resident_join",
  "resident_login",
  "resident_phone_change",
]);

export const authSchemas = {
  register: {
    body: z
      .object({
        name: z
          .string()
          .min(2, "İsim en az 2 karakter olmalıdır")
          .max(50, "İsim en fazla 50 karakter olabilir"),
        email: z
          .preprocess(
            (v) => (v === "" || v === null || v === undefined ? undefined : v),
            z.string().email("Geçerli bir email adresi giriniz").optional()
          ),
        phone: optionalPhone,
        password: passwordSchema,
      })
      .refine((d) => d.email || d.phone, {
        message: "E-posta veya telefon numarası gereklidir.",
      }),
  },

  login: {
    body: z.object({
      identifier: z.string().min(1, "Email veya telefon numarası gereklidir"),
      password: z.string().min(1, "Şifre gereklidir"),
      ...deviceMetaFields,
    }),
  },

  checkIdentifier: {
    body: z.object({
      identifier: z.string().min(1, "E-posta veya telefon numarası gereklidir"),
      purpose: z.enum([
        "manager_identifier",
        "manager_register",
        "manager_login",
        "resident_phone",
      ]),
    }),
  },

  refreshToken: {
    body: z.object({
      refreshToken: z.string().min(1, "Refresh token gereklidir"),
      ...deviceMetaFields,
    }),
  },

  join: {
    body: z.object({
      name: z
        .string()
        .min(2, "İsim en az 2 karakter olmalıdır")
        .max(50, "İsim en fazla 50 karakter olabilir"),
      email: z.string().email("Geçerli bir email adresi giriniz"),
      phone: optionalPhone,
      password: passwordSchema,
      inviteCode: z.preprocess(
        (v) => (typeof v === "string" ? v.trim().toUpperCase().replace(/\s+/g, "") : v),
        z
          .string()
          .min(1, "Davet kodu gereklidir")
          .max(20, "Davet kodu en fazla 20 karakter olabilir")
      ),
      ...deviceMetaFields,
    }),
  },

  forgotPassword: {
    body: z
      .object({
        email: z
          .preprocess(
            (v) => (v === "" || v === null || v === undefined ? undefined : v),
            z.string().email("Geçerli bir email adresi giriniz").optional()
          ),
        phone: optionalPhone,
        channel: z.enum(["email", "sms"]).optional(),
      })
      .refine((d) => d.email || d.phone, {
        message: "E-posta veya telefon numarası gereklidir.",
      }),
  },

  resetPassword: {
    body: z.object({
      token: z.preprocess(
        (v) => (typeof v === "string" ? v.trim().toUpperCase().replace(/\s+/g, "") : v),
        z
          .string()
          .length(6, "Kod tam 6 karakter olmalıdır")
          .regex(
            /^[23456789ABCDEFGHJKLMNPQRSTUVWXYZ]{6}$/,
            "Geçersiz kod (6 karakter: rakam 2–9 ve büyük harf; 0, O, 1, I, L kullanılmaz)"
          )
      ),
      password: passwordSchema,
    }),
  },

  otpSend: {
    body: z
      .object({
        phone: optionalPhone,
        email: z
          .preprocess(
            (v) => (v === "" || v === null || v === undefined ? undefined : v),
            z.string().email("Geçerli bir e-posta adresi giriniz").optional()
          ),
        purpose: otpPurpose,
        payload: z.record(z.unknown()).optional(),
      })
      .refine((d) => d.phone || d.email, {
        message: "Telefon veya e-posta gereklidir.",
      })
      .refine((d) => !(d.phone && d.email), {
        message: "Telefon veya e-posta gönderin, ikisini birden değil.",
      }),
  },

  otpVerify: {
    body: z
      .object({
        phone: optionalPhone,
        email: z
          .preprocess(
            (v) => (v === "" || v === null || v === undefined ? undefined : v),
            z.string().email("Geçerli bir e-posta adresi giriniz").optional()
          ),
        code: z
          .string()
          .length(6, "Doğrulama kodu 6 haneli olmalıdır")
          .regex(/^\d{6}$/, "Doğrulama kodu yalnızca rakam içermelidir"),
        purpose: otpPurpose,
        payload: z.record(z.unknown()).optional(),
        name: z.string().min(2).max(50).optional(),
        password: passwordSchema.optional(),
        inviteCode: z.string().min(1).max(20).optional(),
        ...deviceMetaFields,
      })
      .refine((d) => d.phone || d.email, {
        message: "Telefon veya e-posta gereklidir.",
      })
      .refine((d) => !(d.phone && d.email), {
        message: "Telefon veya e-posta gönderin, ikisini birden değil.",
      }),
  },

  completeResidentJoin: {
    body: z.object({
      phone: normalizedPhoneSchema,
      name: z
        .string()
        .min(2, "İsim en az 2 karakter olmalıdır")
        .max(50, "İsim en fazla 50 karakter olabilir"),
      inviteCode: z.preprocess(
        (v) => (typeof v === "string" ? v.trim().toUpperCase().replace(/\s+/g, "") : v),
        z.string().min(1, "Davet kodu gereklidir").max(20)
      ),
      ...deviceMetaFields,
    }),
  },

  inviteValidate: {
    body: z.object({
      inviteCode: z.preprocess(
        (v) => (typeof v === "string" ? v.trim().toUpperCase().replace(/\s+/g, "") : v),
        z.string().min(1, "Davet kodu gereklidir").max(20)
      ),
    }),
  },

  firebasePhone: {
    body: z.object({
      idToken: z
        .string()
        .min(1, "Firebase doğrulama jetonu gereklidir")
        .max(4096, "Firebase doğrulama jetonu geçersiz"),
      purpose: z.enum([
        "resident_login",
        "resident_join",
        "resident_phone_change",
      ]),
      name: z.string().min(2).max(50).optional(),
      inviteCode: z
        .preprocess(
          (v) =>
            typeof v === "string"
              ? v.trim().toUpperCase().replace(/\s+/g, "")
              : v,
          z.string().min(1).max(20).optional()
        ),
      ...deviceMetaFields,
    }),
  },
};
