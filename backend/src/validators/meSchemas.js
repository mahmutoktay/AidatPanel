import { z } from "zod";
import { fcmSchemas } from "./notificationValidator.js";
import {
  expenseCategoryEnum,
  listPaginationFields,
  profileEmail,
  profilePhone,
  passwordSchema,
} from "./shared.js";

export const meSchemas = {
  updateProfile: {
    body: z
      .object({
        name: z
          .string()
          .min(2, "İsim en az 2 karakter olmalıdır")
          .max(50, "İsim en fazla 50 karakter olabilir")
          .optional(),
        email: profileEmail,
        phone: profilePhone,
        language: z.enum(["tr", "en"]).optional(),
        currentPassword: z.string().optional(),
      })
      .refine(
        (d) =>
          d.name !== undefined ||
          d.phone !== undefined ||
          d.language !== undefined ||
          d.email !== undefined,
        {
          message:
            "En az bir alan gönderin (name, email, phone veya language). E-posta veya telefonu silmek için null gönderin.",
        }
      ),
  },

  updatePassword: {
    body: z.object({
      currentPassword: z.string().min(1, "Mevcut şifre gereklidir"),
      newPassword: passwordSchema,
    }),
  },

  updateLanguage: {
    body: z.object({
      language: z.enum(["tr", "en"]),
    }),
  },

  updateFcmToken: fcmSchemas.updateToken,

  myExpenses: {
    query: z.object({
      month: z.string().optional(),
      year: z.string().optional(),
      category: expenseCategoryEnum.optional(),
      ...listPaginationFields,
    }),
  },
};
