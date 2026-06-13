import { z } from "zod";
import { expenseCategoryEnum, listPaginationFields } from "./shared.js";

export const expenseSchemas = {
  listByBuilding: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    query: z.object({
      month: z.string().optional(),
      year: z.string().optional(),
      category: expenseCategoryEnum.optional(),
      ...listPaginationFields,
    }),
  },

  summaryByBuilding: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    query: z.object({
      month: z.string().regex(/^\d{1,2}$/, "Ay 1-12 arasında olmalıdır"),
      year: z.string().regex(/^\d{4}$/, "Yıl dört haneli olmalıdır"),
    }),
  },

  create: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    body: z.object({
      title: z.string().min(1).max(200),
      category: expenseCategoryEnum,
      date: z.string().datetime({ message: "Geçerli bir tarih giriniz (ISO 8601)" }),
      note: z.string().max(500).optional(),
    }),
  },

  update: {
    params: z.object({
      expenseId: z.string().uuid("Geçerli bir gider ID'si giriniz"),
    }),
    body: z
      .object({
        title: z.string().min(1).max(200).optional(),
        amount: z.number().positive().optional(),
        category: expenseCategoryEnum.optional(),
        date: z.string().datetime().optional(),
        note: z.string().max(500).optional().nullable(),
        receiptUrl: z.string().url().max(2048).optional().nullable(),
      })
      .refine((d) => Object.keys(d).length > 0, {
        message: "En az bir alan gönderin.",
      }),
  },

  delete: {
    params: z.object({
      expenseId: z.string().uuid("Geçerli bir gider ID'si giriniz"),
    }),
  },

  uploadProof: {
    params: z.object({
      expenseId: z.string().uuid("Geçerli bir gider ID'si giriniz"),
    }),
  },
};
