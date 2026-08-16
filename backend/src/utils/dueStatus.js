import { computeOverdueDays } from "./trDueDate.js";
import { computeDuePaymentTotals } from "./duePaymentTotals.js";

/**
 * Sakinli daire aidatları veya sakin çıkmış açık borçlar (snapshot ile).
 */
export function buildManagerDueVisibilityWhere(buildingId) {
  return {
    AND: [
      { apartment: { buildingId } },
      {
        OR: [
          { apartment: { resident: { isNot: null } } },
          {
            residentNameSnapshot: { not: null },
            status: { in: ["PENDING", "OVERDUE"] },
          },
        ],
      },
    ],
  };
}

/**
 * Durum filtresi parçası (AND içine eklenir).
 */
export function buildDueStatusFilterClause(status) {
  if (!status) return null;

  if (status === "OVERDUE") {
    return {
      OR: [
        { status: "OVERDUE" },
        { status: "PENDING", dueDate: { lt: new Date() } },
      ],
    };
  }

  if (status === "PENDING") {
    return {
      status: "PENDING",
      dueDate: { gte: new Date() },
    };
  }

  return { status };
}

/**
 * API yanıtı için etkin aidat durumu (gecikme sorgu anında hesaplanır).
 */
export function resolveEffectiveDueStatus(due) {
  const stored = due.status;
  if (stored === "PAID" || stored === "WAIVED") return stored;
  if (new Date(due.dueDate) < new Date()) return "OVERDUE";
  return stored === "OVERDUE" ? "OVERDUE" : "PENDING";
}

export function resolveEffectiveOverdueDays(due) {
  const effective = resolveEffectiveDueStatus(due);
  if (effective !== "OVERDUE") return 0;
  return computeOverdueDays(due.dueDate);
}

export function serializeDueForApi(due, apartment) {
  const { payments, ...rest } = due;
  let { paidAmount, remainingAmount } = computeDuePaymentTotals({
    ...due,
    payments,
  });
  const effectiveStatus = resolveEffectiveDueStatus(due);
  // Manuel / seed PAID: DuePayment yoksa tahsilat tutarı 0 görünmesin.
  const amountNum = Number(due.amount ?? 0);
  if (
    (effectiveStatus === "PAID" || due.status === "PAID") &&
    amountNum > 0 &&
    paidAmount < amountNum - 0.01
  ) {
    paidAmount = amountNum;
    remainingAmount = 0;
  }
  const resident =
    apartment?.resident ??
    (due.residentNameSnapshot
      ? { id: "", name: due.residentNameSnapshot, email: null, phone: null }
      : null);

  return {
    ...rest,
    paidAmount,
    remainingAmount,
    status: effectiveStatus,
    overdueDays: resolveEffectiveOverdueDays(due),
    apartmentNumber: apartment?.number ?? due.apartmentNumber,
    apartment: apartment
      ? {
          id: apartment.id,
          number: apartment.number,
          floor: apartment.floor ?? null,
        }
      : due.apartment,
    resident,
  };
}
