/** Prisma due sorgularında ödeme toplamı için ortak include. */
export const duePaymentsAmountInclude = {
  payments: { select: { amount: true } },
};
