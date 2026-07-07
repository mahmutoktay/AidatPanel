import { z } from "zod";
import {
  dueStatusEnum,
  listPaginationFields,
  monthYearPairMessage,
  monthYearPairRefine,
} from "./shared.js";

const duesListQuery = z.object({
  month: z.string().optional(),
  year: z.string().optional(),
  status: dueStatusEnum.optional(),
  ...listPaginationFields,
});

const monthYearBodyFields = {
  month: z
    .number()
    .int("Ay tam sayı olmalıdır")
    .min(1, "Ay 1-12 arasında olmalıdır")
    .max(12, "Ay 1-12 arasında olmalıdır")
    .optional(),
  year: z
    .number()
    .int("Yıl tam sayı olmalıdır")
    .min(2000, "Geçerli bir yıl giriniz")
    .max(2100, "Geçerli bir yıl giriniz")
    .optional(),
};

export const dueSchemas = {
  getByBuilding: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    query: duesListQuery,
  },

  myDues: {
    query: duesListQuery,
  },

  updateStatus: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
      dueId: z.string().uuid("Geçerli bir aidat ID'si giriniz"),
    }),
    body: z.object({
      status: dueStatusEnum,
      paidAt: z.string().datetime().optional(),
      note: z.string().max(500, "Not en fazla 500 karakter olabilir").optional(),
    }),
  },

  remind: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    body: z
      .object({
        ...monthYearBodyFields,
        dueIds: z
          .array(z.string().uuid("Geçerli bir aidat ID'si giriniz"))
          .optional(),
      })
      .refine(monthYearPairRefine, monthYearPairMessage),
  },

  bulk: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    body: z
      .object(monthYearBodyFields)
      .refine(monthYearPairRefine, monthYearPairMessage)
      .optional()
      .default({}),
  },

  updateAmount: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    body: z.object({
      dueAmount: z.number().positive("Aidat tutarı pozitif olmalıdır"),
      dueDay: z
        .number()
        .int("Aidat günü tam sayı olmalıdır")
        .min(1, "Aidat günü 1-28 arasında olmalıdır")
        .max(28, "Aidat günü 1-28 arasında olmalıdır")
        .optional(),
      currency: z.string().length(3, "Para birimi 3 karakter olmalıdır").optional(),
      affectCurrent: z.boolean().optional(),
    }),
  },

  transactions: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    query: z.object({
      ...listPaginationFields,
    }),
  },
};
