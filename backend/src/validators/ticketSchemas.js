import { z } from "zod";
import {
  listPaginationFields,
  ticketCategoryEnum,
  ticketStatusEnum,
} from "./shared.js";

export const ticketSchemas = {
  listByBuilding: {
    params: z.object({
      id: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    query: z.object({
      status: ticketStatusEnum.optional(),
      category: ticketCategoryEnum.optional(),
      ...listPaginationFields,
    }),
  },

  myTickets: {
    query: z.object({
      status: ticketStatusEnum.optional(),
      category: ticketCategoryEnum.optional(),
      ...listPaginationFields,
    }),
  },

  getById: {
    params: z.object({
      ticketId: z.string().uuid("Geçerli bir talep ID'si giriniz"),
    }),
  },

  create: {
    params: z.object({
      apartmentId: z.string().uuid("Geçerli bir daire ID'si giriniz"),
    }),
    body: z.object({
      title: z.string().min(1).max(120),
      description: z.string().min(1).max(2000),
      category: ticketCategoryEnum,
    }),
  },

  addUpdate: {
    params: z.object({
      ticketId: z.string().uuid("Geçerli bir talep ID'si giriniz"),
    }),
    body: z.object({
      message: z.string().min(1).max(2000),
    }),
  },

  updateStatus: {
    params: z.object({
      ticketId: z.string().uuid("Geçerli bir talep ID'si giriniz"),
    }),
    body: z.object({
      status: ticketStatusEnum,
    }),
  },
};
