import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { createForUsers } from "./notificationService.js";
import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { DEKONT_PAYMENT_APPLIED_RESIDENT } from "../constants/notificationTemplates.js";
import { dekontListSelect } from "../utils/dekontFormat.js";

export async function applyDekontPayment({ dekontId, managerId, dueId, note }) {
  const dekont = await prisma.dekont.findUnique({
    where: { id: dekontId },
    include: {
      building: { select: { managerId: true } },
      due: true,
      apartment: { select: { id: true } },
    },
  });

  if (!dekont || dekont.building.managerId !== managerId) {
    throw new HttpError(404, "Dekont bulunamadı.");
  }

  if (dekont.status === "PAYMENT_APPLIED") {
    throw new HttpError(409, "Bu dekont için ödeme zaten işlenmiş.");
  }
  if (dekont.status === "REJECTED") {
    throw new HttpError(409, "Reddedilmiş dekont onaylanamaz.");
  }

  const targetDueId = dueId || dekont.dueId;
  if (!targetDueId) {
    throw new HttpError(400, "Onay için dueId gereklidir.");
  }

  const due = await prisma.due.findUnique({
    where: { id: targetDueId },
    include: { apartment: { select: { id: true, buildingId: true } } },
  });
  if (!due) throw new HttpError(404, "Aidat kaydı bulunamadı.");
  if (due.apartment.buildingId !== dekont.buildingId) {
    throw new HttpError(403, "Bu aidat kaydı bu bina için geçerli değil.");
  }
  if (dekont.apartmentId && due.apartmentId !== dekont.apartmentId) {
    throw new HttpError(403, "Bu aidat kaydı bu daire için geçerli değil.");
  }

  const amount = dekont.parsedAmount ?? due.amount;
  const paidAt = new Date();

  const tx = await prisma.$transaction(async (p) => {
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

    const updatedDue = await p.due.update({
      where: { id: due.id },
      data: { status: "PAID", paidAt, overdueDays: 0 },
    });

    const updatedDekont = await p.dekont.update({
      where: { id: dekont.id },
      data: {
        dueId: due.id,
        status: "PAYMENT_APPLIED",
        reviewedById: managerId,
        reviewedAt: paidAt,
        ...(note !== undefined && note !== null ? { reviewNote: note } : {}),
      },
      select: dekontListSelect,
    });

    return { payment, updatedDue, updatedDekont };
  });

  const resident = await prisma.user.findFirst({
    where: {
      apartmentId: due.apartmentId,
      role: "RESIDENT",
      deletedAt: null,
    },
    select: { id: true },
  });

  if (resident) {
    await createForUsers([resident.id], {
      type: NOTIFICATION_TYPES.DEKONT_PAYMENT_APPLIED,
      title: DEKONT_PAYMENT_APPLIED_RESIDENT.title,
      body: DEKONT_PAYMENT_APPLIED_RESIDENT.body(due.month, due.year),
      data: {
        dekontId: dekont.id,
        dueId: due.id,
        buildingId: dekont.buildingId,
        apartmentId: due.apartmentId,
        month: String(due.month),
        year: String(due.year),
        route: "/resident-dashboard",
      },
    });
  }

  return tx;
}
