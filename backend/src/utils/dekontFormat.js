/** Dekont API yanıt alanları — servisler arası paylaşım (döngüsel import önleme). */

import { computeDuePaymentTotals } from "./duePaymentTotals.js";

export const dekontListSelect = {
  id: true,
  buildingId: true,
  apartmentId: true,
  uploadedById: true,
  dueId: true,
  status: true,
  source: true,
  originalFilename: true,
  mimeType: true,
  sizeBytes: true,
  recipientVerified: true,
  referenceNumber: true,
  parsedAmount: true,
  transactionDate: true,
  aiConfidence: true,
  reviewedAt: true,
  reviewNote: true,
  rejectionReason: true,
  createdAt: true,
  updatedAt: true,
};

/** Detay sorgusu için allocation + due özeti. */
export const dekontAllocationWithDueSelect = {
  dueId: true,
  allocatedAmount: true,
  due: {
    select: {
      id: true,
      month: true,
      year: true,
      amount: true,
      status: true,
      apartment: { select: { number: true } },
      payments: { select: { amount: true } },
    },
  },
};

export function formatDekont(row) {
  if (!row) return null;
  const {
    storedPath: _storedPath,
    rawText: _rawText,
    verificationJson: _v,
    dueAllocations,
    ...rest
  } = row;
  return {
    ...rest,
    parsedAmount: row.parsedAmount != null ? String(row.parsedAmount) : null,
    dueIds: Array.isArray(dueAllocations)
      ? dueAllocations.map((a) => a.dueId)
      : undefined,
    allocations: Array.isArray(dueAllocations)
      ? dueAllocations.map((a) => {
          const due = a.due;
          let remainingAmount = null;
          let amount = null;
          if (due) {
            amount = due.amount != null ? String(due.amount) : null;
            const totals = computeDuePaymentTotals(due);
            remainingAmount = String(totals.remainingAmount);
          }
          return {
            dueId: a.dueId,
            allocatedAmount:
              a.allocatedAmount != null ? String(a.allocatedAmount) : null,
            month: due?.month ?? null,
            year: due?.year ?? null,
            amount,
            remainingAmount,
            apartmentNumber: due?.apartment?.number ?? null,
            status: due?.status ?? null,
          };
        })
      : undefined,
  };
}
