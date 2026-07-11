/** Aidat ödeme toplamları ve FIFO dağıtım yardımcıları. */

const AMOUNT_TOLERANCE = Number(process.env.DEKONT_AMOUNT_TOLERANCE) || 0.05;
/** 1 kuruş altı kalan borç yok sayılır. */
const REMAINING_EPS = 0.01;

export function withinAmountTolerance(a, b) {
  if (a == null || b == null) return false;
  const aa = Number(a);
  const bb = Number(b);
  if (!Number.isFinite(aa) || !Number.isFinite(bb) || bb === 0) return false;
  return Math.abs(aa - bb) / Math.abs(bb) <= AMOUNT_TOLERANCE;
}

export function sumPaymentAmounts(payments) {
  if (!Array.isArray(payments)) return 0;
  return payments.reduce((sum, p) => sum + Number(p.amount ?? 0), 0);
}

export function computeDuePaymentTotals(due) {
  const amount = Number(due.amount ?? 0);
  const paidAmount = sumPaymentAmounts(due.payments);
  const remainingAmount = Math.max(0, Math.round((amount - paidAmount) * 100) / 100);
  return { amount, paidAmount, remainingAmount };
}

export function isDueFullyPaid(due) {
  const { amount, paidAmount, remainingAmount } = computeDuePaymentTotals(due);
  if (remainingAmount <= REMAINING_EPS) return true;
  return withinAmountTolerance(paidAmount, amount);
}

/** En eski dönem önce (FIFO). */
export function sortDuesOldestFirst(dues) {
  return [...dues].sort((a, b) => {
    if (a.year !== b.year) return a.year - b.year;
    if (a.month !== b.month) return a.month - b.month;
    return String(a.id).localeCompare(String(b.id));
  });
}

/**
 * Toplam tutarı aidatlara FIFO dağıtır.
 * @returns {{ allocations: Array<{ due: object, amount: number }>, leftover: number }}
 */
export function allocateAmountFifo(dues, totalAmount) {
  let leftover = Number(totalAmount);
  if (!Number.isFinite(leftover) || leftover <= 0) {
    return { allocations: [], leftover: 0 };
  }

  const allocations = [];
  for (const due of sortDuesOldestFirst(dues)) {
    if (leftover <= REMAINING_EPS) break;
    const { remainingAmount } = computeDuePaymentTotals(due);
    if (remainingAmount <= REMAINING_EPS) continue;
    const slice = Math.min(remainingAmount, leftover);
    const rounded = Math.round(slice * 100) / 100;
    if (rounded <= 0) continue;
    allocations.push({ due, amount: rounded });
    leftover = Math.round((leftover - rounded) * 100) / 100;
  }

  return { allocations, leftover: Math.max(0, leftover) };
}

/** Multipart body'den dueIds / dueId çözümle. */
export function parseDueIdsFromBody(body = {}) {
  const ids = [];
  const raw = body.dueIds ?? body.dueId;

  if (raw == null || raw === "") {
    return ids;
  }

  if (Array.isArray(raw)) {
    for (const id of raw) {
      if (typeof id === "string" && id.trim()) ids.push(id.trim());
    }
    return [...new Set(ids)];
  }

  if (typeof raw === "string") {
    const trimmed = raw.trim();
    if (trimmed.startsWith("[")) {
      try {
        const parsed = JSON.parse(trimmed);
        if (Array.isArray(parsed)) {
          for (const id of parsed) {
            if (typeof id === "string" && id.trim()) ids.push(id.trim());
          }
          return [...new Set(ids)];
        }
      } catch {
        // tek uuid string
      }
    }
    if (trimmed) ids.push(trimmed);
  }

  return [...new Set(ids)];
}
