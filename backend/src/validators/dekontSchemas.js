import { z } from "zod";
import { dekontStatusEnum, listPaginationFields } from "./shared.js";

export const dekontSchemas = {
  upload: {
    body: z.object({
      dueId: z.string().uuid("Geçerli bir aidat ID'si giriniz").optional(),
    }),
  },

  getById: {
    params: z.object({
      id: z.string().uuid("Geçerli bir dekont ID'si giriniz"),
    }),
    query: z.object({
      download: z.enum(["0", "1"]).optional(),
    }),
  },

  getFile: {
    params: z.object({
      id: z.string().uuid("Geçerli bir dekont ID'si giriniz"),
    }),
    query: z.object({
      download: z.enum(["0", "1"]).optional(),
    }),
  },

  myList: {
    query: z.object({
      status: dekontStatusEnum.optional(),
      ...listPaginationFields,
    }),
  },

  listByBuilding: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    query: z.object({
      status: dekontStatusEnum.optional(),
      apartmentId: z.string().uuid("Geçerli bir daire ID'si giriniz").optional(),
      ...listPaginationFields,
    }),
  },

  review: {
    params: z.object({
      id: z.string().uuid("Geçerli bir dekont ID'si giriniz"),
    }),
    body: z.object({
      decision: z.enum(["APPROVE", "REJECT"], {
        errorMap: () => ({ message: "Karar APPROVE veya REJECT olmalıdır" }),
      }),
      note: z.string().max(500).optional().nullable(),
      dueId: z.string().uuid().optional(),
    }),
  },
};
