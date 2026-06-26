import { z } from "zod";
import { optionalPhone, passwordSchema } from "./shared.js";

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

export const authSchemas = {
  register: {
    body: z.object({
      name: z
        .string()
        .min(2, "İsim en az 2 karakter olmalıdır")
        .max(50, "İsim en fazla 50 karakter olabilir"),
      email: z.string().email("Geçerli bir email adresi giriniz"),
      phone: optionalPhone,
      password: passwordSchema,
    }),
  },

  login: {
    body: z.object({
      identifier: z.string().min(1, "Email veya telefon numarası gereklidir"),
      password: z.string().min(1, "Şifre gereklidir"),
      ...deviceMetaFields,
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
    body: z.object({
      email: z.string().email("Geçerli bir email adresi giriniz"),
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
};
