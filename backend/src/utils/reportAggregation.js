/**
 * Saf hesaplama yardımcıları — Jest ile test edilir.
 */

/** @param {import("@prisma/client").Decimal | number | string | null | undefined} value */
export function toMoneyDecimal(value) {
  if (value == null) return 0;
  if (typeof value === "object" && typeof value.toNumber === "function") {
    return value.toNumber();
  }
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
}

/**
 * @param {Array<{ amount: unknown, status: string }>} dues
 */
export function summarizeDues(dues) {
  let expected = 0;
  let collected = 0;
  let overdueAmount = 0;
  let pendingAmount = 0;
  let waivedAmount = 0;
  let paidCount = 0;
  let overdueCount = 0;
  let pendingCount = 0;
  let waivedCount = 0;

  for (const due of dues) {
    const amt = toMoneyDecimal(due.amount);
    expected += amt;
    switch (due.status) {
      case "PAID":
        collected += amt;
        paidCount += 1;
        break;
      case "OVERDUE":
        overdueAmount += amt;
        overdueCount += 1;
        break;
      case "PENDING":
        pendingAmount += amt;
        pendingCount += 1;
        break;
      case "WAIVED":
        waivedAmount += amt;
        waivedCount += 1;
        break;
      default:
        break;
    }
  }

  const collectionRate = expected > 0 ? (collected / expected) * 100 : 0;

  return {
    expected,
    collected,
    overdueAmount,
    pendingAmount,
    waivedAmount,
    paidCount,
    overdueCount,
    pendingCount,
    waivedCount,
    totalCount: dues.length,
    collectionRate,
  };
}

export function computeNet(collected, expenseTotal) {
  return collected - expenseTotal;
}

/**
 * Gider satırından rapor tutarı (amount veya parsedAmount).
 * @param {{ amount?: unknown, parsedAmount?: unknown }} expense
 */
export function resolveExpenseAmount(expense) {
  if (expense.amount != null) return toMoneyDecimal(expense.amount);
  if (expense.parsedAmount != null) return toMoneyDecimal(expense.parsedAmount);
  return null;
}
