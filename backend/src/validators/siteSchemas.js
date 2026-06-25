import { z } from "zod";
import { optionalIban } from "./shared.js";

const dueDaySchema = z
  .number()
  .int("Aidat günü tam sayı olmalıdır")
  .min(1, "Aidat günü 1-28 arasında olmalıdır")
  .max(28, "Aidat günü 1-28 arasında olmalıdır")
  .optional();

export const siteSchemas = {
  create: {
    body: z.object({
      name: z.string().min(2).max(100),
      address: z.string().min(5).max(200),
      city: z.string().min(2).max(50),
      dueAmount: z.number().positive("Aidat tutarı pozitif olmalıdır").optional(),
      dueDay: dueDaySchema,
      currency: z.string().length(3).optional(),
      collectionIban: optionalIban,
      collectionAccountTitle: z.string().max(200).optional().nullable(),
      paymentReferenceTemplate: z.string().max(100).optional().nullable(),
    }),
  },

  update: {
    params: z.object({ id: z.string().uuid() }),
    body: z.object({
      name: z.string().min(2).max(100).optional(),
      address: z.string().min(5).max(200).optional(),
      city: z.string().min(2).max(50).optional(),
      dueAmount: z.number().positive().optional().nullable(),
      dueDay: dueDaySchema,
      currency: z.string().length(3).optional(),
    }),
  },

  getById: {
    params: z.object({ id: z.string().uuid() }),
  },

  delete: {
    params: z.object({ id: z.string().uuid() }),
  },

  updateCollection: {
    params: z.object({ id: z.string().uuid() }),
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

  createSiteBuilding: {
    params: z.object({ id: z.string().uuid() }),
    body: z.object({
      blockLabel: z
        .string()
        .min(1, "Blok adı zorunludur")
        .max(50, "Blok adı en fazla 50 karakter olabilir"),
      name: z.string().max(100).optional().nullable(),
      addressExtra: z.string().max(200).optional().nullable(),
      totalFloors: z.number().int().min(1).max(200).optional(),
      apartmentsPerFloor: z.number().int().min(1).max(50).optional(),
      dueAmount: z.number().positive().optional().nullable(),
      dueDay: dueDaySchema,
      currency: z.string().length(3).optional(),
      collectionIban: optionalIban,
      collectionAccountTitle: z.string().max(200).optional().nullable(),
      paymentReferenceTemplate: z.string().max(100).optional().nullable(),
    }),
  },

  listBuildings: {
    params: z.object({ id: z.string().uuid() }),
  },

  aggregation: {
    params: z.object({ id: z.string().uuid() }),
  },

  siteReport: {
    params: z.object({ id: z.string().uuid() }),
    query: z.object({
      type: z.enum(["monthly", "annual"]),
      month: z.coerce.number().int().min(1).max(12).optional(),
      year: z.coerce.number().int().min(2000).max(2100),
    }),
  },

  siteExpenses: {
    params: z.object({ id: z.string().uuid() }),
    query: z
      .object({
        month: z.coerce.number().int().min(1).max(12).optional(),
        year: z.coerce.number().int().optional(),
        category: z.string().optional(),
        cursor: z.string().optional(),
        limit: z.coerce.number().int().optional(),
        paginated: z.enum(["true", "false"]).optional(),
      })
      .optional(),
  },

  createSiteExpense: {
    params: z.object({ id: z.string().uuid() }),
    body: z.object({
      title: z.string().min(1).max(200),
      amount: z.number().positive(),
      category: z.string(),
      date: z.string().datetime({ offset: true }).or(z.string().date()),
      targetMonth: z.number().int().min(1).max(12),
      targetYear: z.number().int().min(2000).max(2100),
      note: z.string().max(500).optional().nullable(),
      splitMonths: z.number().int().min(1).max(12).optional(),
      carryForwardPolicy: z.enum(["NONE", "CARRY_TO_NEXT_MONTH"]).optional(),
    }),
  },

  updateSiteExpense: {
    params: z.object({
      siteId: z.string().uuid(),
      expenseId: z.string().uuid(),
    }),
    body: z.object({
      title: z.string().min(1).max(200).optional(),
      amount: z.number().positive().optional(),
      category: z.string().optional(),
      date: z.string().datetime({ offset: true }).or(z.string().date()).optional(),
      note: z.string().max(500).optional().nullable(),
    }),
  },

  deleteSiteExpense: {
    params: z.object({
      siteId: z.string().uuid(),
      expenseId: z.string().uuid(),
    }),
  },

  aggregation: {
    params: z.object({ id: z.string().uuid() }),
    query: z.object({
      month: z.coerce.number().int().min(1).max(12).optional(),
      year: z.coerce.number().int().min(2000).max(2100).optional(),
    }).optional(),
  },
};
