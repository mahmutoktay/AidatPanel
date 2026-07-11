import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { createForUsers } from "./notificationService.js";
import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { NOTIFICATION_CODES } from "../constants/notificationCatalog.js";
import { dekontListSelect } from "../utils/dekontFormat.js";
import {
  allocateAmountFifo,
  computeDuePaymentTotals,
  isDueFullyPaid,
  sortDuesOldestFirst,
} from "../utils/duePaymentTotals.js";
import { duePaymentsAmountInclude } from "../utils/dueQueryIncludes.js";

const TERMINAL_PAYMENT_STATUSES = new Set([
  "PAYMENT_APPLIED",
  "PAYMENT_PARTIAL",
]);

/**
 * Dekont tutarını seçili aidatlara FIFO dağıtır; kısmi ödemeyi destekler.
 * @param {{ dekontId: string, managerId: string, dueId?: string, dueIds?: string[], note?: string, amount?: number|string|null }} args
 */
export async function applyDekontPayment({
  dekontId,
  managerId,
  dueId,
  dueIds,
  note,
  amount: amountOverride,
}) {
  const dekont = await prisma.dekont.findUnique({
    where: { id: dekontId },
    include: {
      building: { select: { managerId: true } },
      due: true,
      apartment: { select: { id: true } },
      dueAllocations: { select: { dueId: true } },
    },
  });

  if (!dekont || dekont.building.managerId !== managerId) {
    throw new HttpError(404, "Dekont bulunamadı.");
  }

  if (TERMINAL_PAYMENT_STATUSES.has(dekont.status)) {
    throw new HttpError(409, "Bu dekont için ödeme zaten işlenmiş.");
  }

  if (dekont.status === "REJECTED") {
    throw new HttpError(409, "Reddedilmiş dekont onaylanamaz.");
  }

  const existingPayment = await prisma.duePayment.findFirst({
    where: { dekontId },
    select: { id: true },
  });
  if (existingPayment) {
    throw new HttpError(409, "Bu dekont için ödeme zaten işlenmiş.");
  }

  let targetIds = Array.isArray(dueIds) ? dueIds.filter(Boolean) : [];
  if (targetIds.length === 0 && dueId) targetIds = [dueId];
  if (targetIds.length === 0 && dekont.dueAllocations?.length) {
    targetIds = dekont.dueAllocations.map((a) => a.dueId);
  }
  if (targetIds.length === 0 && dekont.dueId) {
    targetIds = [dekont.dueId];
  }
  if (targetIds.length === 0) {
    throw new HttpError(400, "Onay için en az bir aidat seçilmelidir.");
  }

  const dues = await prisma.due.findMany({
    where: { id: { in: targetIds } },
    include: {
      apartment: { select: { id: true, buildingId: true } },
      ...duePaymentsAmountInclude,
    },
  });

  if (dues.length !== targetIds.length) {
    throw new HttpError(404, "Aidat kaydı bulunamadı.");
  }

  for (const due of dues) {
    if (due.apartment.buildingId !== dekont.buildingId) {
      throw new HttpError(403, "Bu aidat kaydı bu bina için geçerli değil.");
    }
    if (dekont.apartmentId && due.apartmentId !== dekont.apartmentId) {
      throw new HttpError(403, "Bu aidat kaydı bu daire için geçerli değil.");
    }
  }

  const openDues = dues.filter((d) => {
    if (d.status === "PAID" || d.status === "WAIVED") return false;
    return computeDuePaymentTotals(d).remainingAmount > 0.01;
  });

  if (openDues.length === 0) {
    throw new HttpError(409, "Seçilen aidatların tamamı zaten ödenmiş.");
  }

  const totalRemaining = openDues.reduce(
    (s, d) => s + computeDuePaymentTotals(d).remainingAmount,
    0
  );

  let applyAmount = null;
  if (amountOverride != null && amountOverride !== "") {
    applyAmount = Number(amountOverride);
  } else if (dekont.parsedAmount != null) {
    applyAmount = Number(dekont.parsedAmount);
  }

  if (!Number.isFinite(applyAmount) || applyAmount <= 0) {
    throw new HttpError(
      400,
      "Dekont tutarı okunamadı. Onaylamak için tutarı elle giriniz."
    );
  }

  // Kalan borcun üzerine çıkma
  applyAmount = Math.min(applyAmount, totalRemaining);
  if (applyAmount <= 0.01) {
    throw new HttpError(409, "Seçilen aidatların kalan borcu yok.");
  }

  const { allocations } = allocateAmountFifo(openDues, applyAmount);
  if (allocations.length === 0) {
    throw new HttpError(400, "Dağıtılacak açık borç bulunamadı.");
  }

  const paidAt = new Date();
  const primaryDueId = sortDuesOldestFirst(allocations.map((a) => a.due))[0].id;

  const allocationByDueId = new Map(
    allocations.map((a) => [a.due.id, a.amount])
  );
  const allFullyPaid = openDues.every((due) => {
    const slice = allocationByDueId.get(due.id);
    const nextPayments = [...(due.payments ?? [])];
    if (slice != null) nextPayments.push({ amount: slice });
    return isDueFullyPaid({ ...due, payments: nextPayments });
  });

  const tx = await prisma.$transaction(async (p) => {
    const payments = [];
    const updatedDues = [];

    for (const due of dues) {
      await p.dekontDueAllocation.upsert({
        where: {
          dekontId_dueId: { dekontId: dekont.id, dueId: due.id },
        },
        create: {
          dekontId: dekont.id,
          dueId: due.id,
          allocatedAmount: null,
        },
        update: {},
      });
    }

    for (const { due, amount } of allocations) {
      const payment = await p.duePayment.create({
        data: {
          dueId: due.id,
          dekontId: dekont.id,
          amount,
          paidAt,
          currency: due.currency,
          note: "Dekont onayı ile oluşturuldu",
        },
      });
      payments.push(payment);

      const nextPayments = [...(due.payments ?? []), { amount }];
      const fullyPaid = isDueFullyPaid({ ...due, payments: nextPayments });

      const updatedDue = await p.due.update({
        where: { id: due.id },
        data: fullyPaid
          ? { status: "PAID", paidAt, overdueDays: 0 }
          : {},
      });
      updatedDues.push(updatedDue);

      await p.dekontDueAllocation.update({
        where: {
          dekontId_dueId: { dekontId: dekont.id, dueId: due.id },
        },
        data: { allocatedAmount: amount },
      });
    }

    const dekontStatus = allFullyPaid ? "PAYMENT_APPLIED" : "PAYMENT_PARTIAL";

    const updatedDekont = await p.dekont.update({
      where: { id: dekont.id },
      data: {
        dueId: primaryDueId,
        status: dekontStatus,
        reviewedById: managerId,
        reviewedAt: paidAt,
        ...(note !== undefined && note !== null ? { reviewNote: note } : {}),
      },
      select: dekontListSelect,
    });

    return { payments, updatedDues, updatedDekont, allFullyPaid };
  });

  const notifyDue = allocations[allocations.length - 1]?.due ?? openDues[0];
  const resident = await prisma.user.findFirst({
    where: {
      apartmentId: notifyDue.apartmentId,
      role: "RESIDENT",
      deletedAt: null,
    },
    select: { id: true },
  });

  if (resident) {
    await createForUsers([resident.id], {
      type: NOTIFICATION_TYPES.DEKONT_PAYMENT_APPLIED,
      code: NOTIFICATION_CODES.DEKONT_PAYMENT_APPLIED_RESIDENT,
      params: { month: notifyDue.month, year: notifyDue.year },
      data: {
        dekontId: dekont.id,
        dueId: notifyDue.id,
        buildingId: dekont.buildingId,
        apartmentId: notifyDue.apartmentId,
        month: String(notifyDue.month),
        year: String(notifyDue.year),
        route: "/resident-dashboard",
      },
    });
  }

  return {
    payment: tx.payments[0],
    payments: tx.payments,
    updatedDue: tx.updatedDues[0],
    updatedDues: tx.updatedDues,
    updatedDekont: tx.updatedDekont,
  };
}
