import { z } from "zod";

export const moderationSchemas = {
  reportTicket: {
    params: z.object({
      ticketId: z.string().uuid("Geçerli bir talep ID'si giriniz"),
    }),
    body: z.object({
      ticketUpdateId: z.string().uuid("Geçerli bir güncelleme ID'si giriniz").optional(),
    }),
  },

  createRestriction: {
    params: z.object({
      apartmentId: z.string().uuid("Geçerli bir daire ID'si giriniz"),
    }),
    body: z.object({
      ticketId: z.string().uuid("Geçerli bir talep ID'si giriniz"),
      note: z.string().max(300).optional(),
    }),
  },

  getApartmentRestriction: {
    params: z.object({
      apartmentId: z.string().uuid("Geçerli bir daire ID'si giriniz"),
    }),
  },
};
