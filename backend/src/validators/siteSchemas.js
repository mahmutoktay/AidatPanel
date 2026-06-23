import { z } from "zod";
import { optionalIban, listPaginationFields } from "./shared.js";

const siteCoreFields = {
  name: z
    .string()
    .min(2, "Site adı en az 2 karakter olmalıdır")
    .max(100, "Site adı en fazla 100 karakter olabilir"),
  address: z
    .string()
    .min(5, "Adres en az 5 karakter olmalıdır")
    .max(200, "Adres en fazla 200 karakter olabilir"),
  city: z
    .string()
    .min(2, "Şehir en az 2 karakter olmalıdır")
    .max(50, "Şehir en fazla 50 karakter olabilir"),
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
};

const siteBuildingFields = {
  name: z
    .string()
    .min(2, "Bina adı en az 2 karakter olmalıdır")
    .max(100, "Bina adı en fazla 100 karakter olabilir"),
  address: z.string().min(5).max(200).optional(),
  city: z.string().min(2).max(50).optional(),
  blockLabel: z.string().max(50).optional().nullable(),
  addressExtra: z.string().max(200).optional().nullable(),
  totalFloors: z.number().int().min(1).max(200).optional(),
  apartmentsPerFloor: z.number().int().min(1).max(50).optional(),
  dueAmount: z.number().positive().optional(),
  dueDay: z.number().int().min(1).max(28).optional(),
  currency: z.string().length(3).optional(),
  collectionIban: optionalIban,
  collectionAccountTitle: z.string().max(200).optional().nullable(),
  paymentReferenceTemplate: z.string().max(100).optional().nullable(),
};

export const siteSchemas = {
  create: {
    body: z.object(siteCoreFields),
  },

  list: {
    query: z.object({
      ...listPaginationFields,
      search: z.string().max(100).optional(),
    }),
  },

  getById: {
    params: z.object({
      id: z.string().uuid("Geçerli bir ID giriniz"),
    }),
  },

  update: {
    params: z.object({
      id: z.string().uuid("Geçerli bir ID giriniz"),
    }),
    body: z
      .object({
        name: siteCoreFields.name.optional(),
        address: siteCoreFields.address.optional(),
        city: siteCoreFields.city.optional(),
        dueAmount: siteCoreFields.dueAmount.optional().nullable(),
        dueDay: siteCoreFields.dueDay.optional(),
        currency: siteCoreFields.currency.optional(),
      })
      .refine((data) => Object.keys(data).length > 0, {
        message: "En az bir alan güncellenmelidir.",
      }),
  },

  delete: {
    params: z.object({
      id: z.string().uuid("Geçerli bir ID giriniz"),
    }),
  },

  updateCollection: {
    params: z.object({
      id: z.string().uuid("Geçerli bir site ID'si giriniz"),
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

  createBuilding: {
    params: z.object({
      id: z.string().uuid("Geçerli bir site ID'si giriniz"),
    }),
    body: z.object(siteBuildingFields),
  },

  listBuildings: {
    params: z.object({
      id: z.string().uuid("Geçerli bir site ID'si giriniz"),
    }),
  },
};
