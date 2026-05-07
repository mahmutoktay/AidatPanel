import { z } from "zod";

/**
 * Zod schema validation middleware'i oluşturur
 * @param {z.ZodSchema} schema - Zod schema objesi
 * @returns {Function} Express middleware
 * 
 * Kullanım:
 * router.post("/register", validate(registerSchema), register);
 */
export const validate = (schema) => {
  return (req, res, next) => {
    try {
      // Body'yi validate et
      if (schema.body) {
        req.body = schema.body.parse(req.body);
      }

      // Query parametrelerini validate et
      if (schema.query) {
        req.query = schema.query.parse(req.query);
      }

      // URL parametrelerini validate et
      if (schema.params) {
        req.params = schema.params.parse(req.params);
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};

/**
 * Auth endpoint'leri için validation schemaları
 */
export const authSchemas = {
  register: {
    body: z.object({
      name: z
        .string()
        .min(2, "İsim en az 2 karakter olmalıdır")
        .max(50, "İsim en fazla 50 karakter olabilir"),
      email: z
        .string()
        .email("Geçerli bir email adresi giriniz"),
      phone: z
        .string()
        .min(10, "Telefon numarası en az 10 karakter olmalıdır")
        .max(15, "Telefon numarası en fazla 15 karakter olabilir")
        .optional(),
      password: z
        .string()
        .min(6, "Şifre en az 6 karakter olmalıdır")
        .max(100, "Şifre en fazla 100 karakter olabilir"),
    }),
  },

  login: {
    body: z.object({
      identifier: z
        .string()
        .min(1, "Email veya telefon numarası gereklidir"),
      password: z
        .string()
        .min(1, "Şifre gereklidir"),
    }),
  },

  refreshToken: {
    body: z.object({
      refreshToken: z
        .string()
        .min(1, "Refresh token gereklidir"),
    }),
  },

  join: {
    body: z.object({
      name: z
        .string()
        .min(2, "İsim en az 2 karakter olmalıdır")
        .max(50, "İsim en fazla 50 karakter olabilir"),
      email: z
        .string()
        .email("Geçerli bir email adresi giriniz"),
      password: z
        .string()
        .min(6, "Şifre en az 6 karakter olmalıdır")
        .max(100, "Şifre en fazla 100 karakter olabilir"),
      inviteCode: z
        .string()
        .min(1, "Davet kodu gereklidir")
        .max(20, "Davet kodu en fazla 20 karakter olabilir"),
    }),
  },
};

/**
 * Building endpoint'leri için validation schemaları
 * Yusuf'un kullanması için hazır
 */
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
      dueAmount: z
        .number()
        .positive("Aidat tutarı pozitif olmalıdır")
        .optional(),
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
};

/**
 * Apartment endpoint'leri için validation schemaları
 */
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

/**
 * Due (Aidat) endpoint'leri için validation schemaları
 */
export const dueSchemas = {
  getByBuilding: {
    params: z.object({
      buildingId: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    query: z.object({
      month: z.string().optional(),
      year: z.string().optional(),
      status: z.enum(["PENDING", "PAID", "OVERDUE", "WAIVED"]).optional(),
    }).optional(),
  },

  updateStatus: {
    params: z.object({
      dueId: z.string().uuid("Geçerli bir aidat ID'si giriniz"),
    }),
    body: z.object({
      status: z.enum(["PENDING", "PAID", "OVERDUE", "WAIVED"], {
        errorMap: () => ({ message: "Geçersiz durum değeri" }),
      }),
      paidAt: z.string().datetime().optional(),
      note: z.string().max(500, "Not en fazla 500 karakter olabilir").optional(),
    }),
  },

  updateAmount: {
    params: z.object({
      buildingId: z.string().uuid("Geçerli bir bina ID'si giriniz"),
    }),
    body: z.object({
      dueAmount: z
        .number()
        .positive("Aidat tutarı pozitif olmalıdır"),
      dueDay: z
        .number()
        .int("Aidat günü tam sayı olmalıdır")
        .min(1, "Aidat günü 1-28 arasında olmalıdır")
        .max(28, "Aidat günü 1-28 arasında olmalıdır")
        .optional(),
      currency: z
        .string()
        .length(3, "Para birimi 3 karakter olmalıdır")
        .optional(),
      affectCurrent: z
        .boolean()
        .optional(),
    }),
  },
};
