import { z } from "zod";

export const adminSchemas = {
  login: {
    body: z.object({
      email: z.string().email(),
      password: z.string().min(8),
    }),
  },
  refresh: {
    body: z.object({
      refreshToken: z.string().min(10),
    }),
  },
  listUsers: {
    query: z.object({
      q: z.string().optional(),
      role: z.enum(["MANAGER", "RESIDENT"]).optional(),
      deleted: z.enum(["true", "false"]).optional(),
      hasSubscription: z.enum(["true", "false"]).optional(),
      page: z.coerce.number().int().min(1).optional(),
      limit: z.coerce.number().int().min(1).max(100).optional(),
    }),
  },
  closeAccount: {
    body: z.object({
      reason: z.string().min(5),
      forceManager: z.boolean().optional(),
    }),
  },
  grantSubscription: {
    body: z.object({
      durationDays: z.coerce.number().int().min(1).max(730),
      plan: z.enum(["monthly", "annual"]).optional(),
      reason: z.string().min(3),
    }),
  },
  createPromo: {
    body: z
      .object({
        userId: z.string().uuid().optional(),
        contact: z.string().min(3).optional(),
        type: z.enum(["FREE_PERIOD", "DISCOUNT_PERCENT"]),
        plan: z.string().optional(),
        durationDays: z.coerce.number().int().optional(),
        discountPercent: z.coerce.number().int().min(1).max(100).optional(),
        reason: z.string().min(3),
        expiresAt: z.string().datetime().optional(),
      })
      .refine((d) => d.userId || d.contact, { message: "Kullanıcı ID veya e-posta/telefon gerekli." }),
  },
  grantByContact: {
    body: z.object({
      contact: z.string().min(3),
      durationDays: z.coerce.number().int().min(1).max(730),
      plan: z.enum(["monthly", "annual"]).optional(),
      reason: z.string().min(3),
    }),
  },
  broadcast: {
    body: z.object({
      title: z.string().min(1),
      body: z.string().min(1),
      segment: z
        .object({
          role: z.enum(["MANAGER", "RESIDENT"]).optional(),
          plan: z.string().optional(),
          city: z.string().optional(),
          expiringWithinDays: z.coerce.number().int().optional(),
        })
        .optional(),
    }),
  },
  listDekonts: {
    query: z.object({
      status: z.string().optional(),
      lowConfidence: z.enum(["true", "false"]).optional(),
      page: z.coerce.number().int().min(1).optional(),
      limit: z.coerce.number().int().min(1).max(100).optional(),
    }),
  },
  analytics: {
    query: z.object({
      period: z.enum(["day", "month"]).optional(),
      role: z.enum(["MANAGER", "RESIDENT"]).optional(),
      days: z.coerce.number().int().min(7).max(365).optional(),
    }),
  },
  listManagers: {
    query: z.object({
      q: z.string().optional(),
      page: z.coerce.number().int().min(1).optional(),
      limit: z.coerce.number().int().min(1).max(100).optional(),
    }),
  },
  broadcastPreview: {
    body: z.object({
      segment: z
        .object({
          role: z.enum(["MANAGER", "RESIDENT"]).optional(),
          plan: z.string().optional(),
          city: z.string().optional(),
          expiringWithinDays: z.coerce.number().int().optional(),
        })
        .optional(),
    }),
  },
};
