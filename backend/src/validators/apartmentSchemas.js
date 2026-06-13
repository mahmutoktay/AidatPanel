import { z } from "zod";

export const apartmentSchemas = {
  create: {
    params: z.object({
      buildingId: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    body: z.object({
      number: z
        .string()
        .min(1, "Daire numarası gereklidir")
        .max(10, "Daire numarası en fazla 10 karakter olabilir"),
      floor: z
        .number()
        .int("Kat tam sayı olmalıdır")
        .min(-5, "Kat -5'ten küçük olamaz")
        .max(200, "Kat 200'den büyük olamaz")
        .optional(),
    }),
  },

  getByBuilding: {
    params: z.object({
      buildingId: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
  },

  delete: {
    params: z.object({
      buildingId: z.string().uuid("Geçerli bir bina ID'si giriniz"),
      id: z.string().uuid("Geçerli bir daire ID'si giriniz"),
    }),
  },

  removeResident: {
    params: z.object({
      buildingId: z.string().uuid("Geçerli bir bina ID'si giriniz"),
      id: z.string().uuid("Geçerli bir daire ID'si giriniz"),
    }),
  },

  update: {
    params: z.object({
      buildingId: z.string().uuid("Geçerli bir bina ID'si giriniz"),
      id: z.string().uuid("Geçerli bir daire ID'si giriniz"),
    }),
    body: z.object({
      number: z
        .string()
        .min(1, "Daire numarası gereklidir")
        .max(10, "Daire numarası en fazla 10 karakter olabilir")
        .optional(),
      floor: z
        .number()
        .int("Kat tam sayı olmalıdır")
        .min(-5, "Kat -5'ten küçük olamaz")
        .max(200, "Kat 200'den büyük olamaz")
        .optional(),
    }),
  },

  generateInviteCode: {
    params: z.object({
      apartmentId: z.string().uuid("Geçerli bir daire ID'si giriniz"),
    }),
  },
};
