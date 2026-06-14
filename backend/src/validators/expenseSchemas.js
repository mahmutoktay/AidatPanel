import { z } from "zod";
import { expenseCategoryEnum, listPaginationFields } from "./shared.js";

const carryForwardPolicyEnum = z.enum(["CARRY_TO_NEXT_MONTH", "WARN_ONLY"]);

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
      amount: z.number().positive("Gider tutarı pozitif olmalıdır").optional().nullable(),
      category: expenseCategoryEnum,
      date: z.string().datetime({ message: "Geçerli bir tarih giriniz (ISO 8601)" }),
      targetMonth: z.number().int().min(1).max(12),
      targetYear: z.number().int().min(2020).max(2100),
      note: z.string().max(500).optional(),
      splitMonths: z.number().int().min(1).max(12).optional().default(1),
      carryForwardPolicy: carryForwardPolicyEnum.optional().default("WARN_ONLY"),
      confirmPaidImpact: z.boolean().optional().default(false),
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
        targetMonth: z.number().int().min(1).max(12).optional(),
        targetYear: z.number().int().min(2020).max(2100).optional(),
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
