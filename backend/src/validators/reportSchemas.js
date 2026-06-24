import { z } from "zod";

const yearField = z.string().regex(/^\d{4}$/, "Yil dort haneli olmalidir");
const monthField = z
  .string()
  .regex(/^(?:[1-9]|1[0-2])$/, "Ay 1-12 arasinda olmalidir");

export const reportSchemas = {
  buildingReport: {
    params: z.object({
      id: z.string().uuid("Gecerli bir bina ID'si giriniz"),
    }),
    query: z
      .object({
        type: z.enum(["monthly", "annual"], {
          errorMap: () => ({
            message: "Rapor turu monthly veya annual olmalidir",
          }),
        }),
        year: yearField,
        month: monthField.optional(),
      })
      .superRefine((q, ctx) => {
        if (q.type === "monthly" && !q.month) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Aylik rapor icin ay zorunludur",
            path: ["month"],
          });
        }
        if (q.type === "annual" && q.month) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Yillik raporda ay gonderilmemelidir",
            path: ["month"],
          });
        }
      }),
  },

  siteReport: {
    params: z.object({
      id: z.string().uuid("Gecerli bir site ID'si giriniz"),
    }),
    query: z
      .object({
        type: z.enum(["monthly", "annual"], {
          errorMap: () => ({
            message: "Rapor turu monthly veya annual olmalidir",
          }),
        }),
        year: yearField,
        month: monthField.optional(),
      })
      .superRefine((q, ctx) => {
        if (q.type === "monthly" && !q.month) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Aylik rapor icin ay zorunludur",
            path: ["month"],
          });
        }
        if (q.type === "annual" && q.month) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Yillik raporda ay gonderilmemelidir",
            path: ["month"],
          });
        }
      }),
  },
};
