import { z } from "zod";
import { optionalIban } from "./shared.js";

export const buildingSchemas = {
  create: {
    body: z.object({
      name: z
        .string()
        .min(2, "Bina adı en az 2 karakter olmalıdır")
        .max(100, "Bina adı en fazla 100 karakter olabilir"),
      address: z
        .string()
        .min(5, "Adres en az 5 karakter olmalıdır")
        .max(200, "Adres en fazla 200 karakter olabilir"),
      city: z
        .string()
        .min(2, "Şehir en az 2 karakter olmalıdır")
        .max(50, "Şehir en fazla 50 karakter olabilir"),
      totalFloors: z
        .number()
        .int("Kat sayısı tam sayı olmalıdır")
        .min(1, "Kat sayısı en az 1 olmalıdır")
        .max(200, "Kat sayısı en fazla 200 olabilir")
        .optional(),
      apartmentsPerFloor: z
        .number()
        .int("Daire sayısı tam sayı olmalıdır")
        .min(1, "Daire sayısı en az 1 olmalıdır")
        .max(50, "Daire sayısı en fazla 50 olabilir")
        .optional(),
      dueAmount: z.number().positive("Aidat tutarı pozitif olmalıdır").optional(),
      dueDay: z
        .number()
        .int("Aidat günü tam sayı olmalıdır")
        .min(1, "Aidat günü 1-28 arasında olmalıdır")
        .max(28, "Aidat günü 1-28 arasında olmalıdır")
        .optional(),
      currency: z
        .string()
        .length(3, "Para birimi 3 karakter olmalıdır (TRY, USD, EUR)")
        .optional(),
      collectionIban: optionalIban,
      collectionAccountTitle: z.string().max(200).optional().nullable(),
      paymentReferenceTemplate: z.string().max(100).optional().nullable(),
    }),
  },

  update: {
    params: z.object({
      id: z.string().uuid("Geçerli bir ID giriniz"),
    }),
    body: z.object({
      name: z
        .string()
        .min(2, "Bina adı en az 2 karakter olmalıdır")
        .max(100, "Bina adı en fazla 100 karakter olabilir")
        .optional(),
      address: z
        .string()
        .min(5, "Adres en az 5 karakter olmalıdır")
        .max(200, "Adres en fazla 200 karakter olabilir")
        .optional(),
      city: z
        .string()
        .min(2, "Şehir en az 2 karakter olmalıdır")
        .max(50, "Şehir en fazla 50 karakter olabilir")
        .optional(),
    }),
  },

  getById: {
    params: z.object({
      id: z.string().uuid("Geçerli bir ID giriniz"),
    }),
  },

  delete: {
    params: z.object({
      id: z.string().uuid("Geçerli bir ID giriniz"),
    }),
  },

  updateCollection: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    body: z
      .object({
        collectionIban: optionalIban,
        collectionAccountTitle: z.string().max(200).optional().nullable(),
        paymentReferenceTemplate: z.string().max(100).optional().nullable(),
      })
      .refine(
        (data) =>
          data.collectionIban !== undefined ||
          data.collectionAccountTitle !== undefined ||
          data.paymentReferenceTemplate !== undefined,
        { message: "En az bir alan güncellenmelidir." }
      ),
  },
};
