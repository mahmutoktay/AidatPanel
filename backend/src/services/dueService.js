import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { NOTIFICATION_CODES } from "../constants/notificationCatalog.js";
import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { userPublicSelect } from "./meService.js";
import { createForUsers } from "./notificationService.js";
import { computeOverdueDays } from "../utils/trDueDate.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";
import {
  computeDueBreakdown,
  computeDueBreakdownsBatch,
  serializeBreakdownForDue,
  syncOpenBuildingDues,
} from "./dueExpenseRecalcService.js";

function mapDueRow(due) {
  const { apartment, ...rest } = due;
  return {
    ...rest,
    apartmentNumber: apartment.number,
    apartment: {
      id: apartment.id,
      number: apartment.number,
      floor: apartment.floor,
    },
    resident: apartment.resident ?? null,
  };
}

async function attachBreakdownToDue(due, buildingId) {
  const row = (due.apartment && !due.apartmentNumber) ? mapDueRow(due) : due;
  const apartmentId = due.apartmentId ?? due.apartment?.id;
  if (!apartmentId || !buildingId) return row;

  const breakdown = await computeDueBreakdown(
    apartmentId,
    due.month,
    due.year,
    buildingId
  );

  return {
    ...row,
    breakdown: serializeBreakdownForDue(breakdown),
  };
}

/**
 * Toplu breakdown ekleme - N+1 sorununu çözer.
 * Aynı buildingId altındaki tüm due'lar için tek seferde breakdown hesaplar.
 */
async function attachBreakdownToDuesBatch(dues, buildingId) {
  if (!dues.length) return dues;

  const items = dues.map((due) => ({
    apartmentId: due.apartmentId ?? due.apartment?.id,
    month: due.month,
    year: due.year,
  }));

  const validItems = items.filter((i) => i.apartmentId);
  if (!validItems.length) return dues;

  const breakdownMap = await computeDueBreakdownsBatch(validItems, buildingId);

  return dues.map((due) => {
    const row = (due.apartment && !due.apartmentNumber) ? mapDueRow(due) : due;
    const apartmentId = due.apartmentId ?? due.apartment?.id;
    const breakdown = apartmentId ? breakdownMap.get(apartmentId) : undefined;

    return breakdown
      ? { ...row, breakdown: serializeBreakdownForDue(breakdown) }
      : row;
  });
}

/**
 * Binadaki tüm aidatları listele (yönetici için)
 * Filtreleme: month, year, status
 */
export const getDuesByBuildingService = async (buildingId, managerId, filters = {}) => {
  // Önce binanın yöneticiye ait olduğunu kontrol et
  const building = await prisma.building.findFirst({
    where: { id: buildingId, managerId },
  });

  if (!building) {
    throw new HttpError(404, "Bina bulunamadı veya erişim yetkiniz yok.");
  }

  const { month, year, status } = filters;
  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let whereClause = {
    apartment: { buildingId },
  };

  if (month) whereClause.month = parseInt(String(month), 10);
  if (year) whereClause.year = parseInt(String(year), 10);
  if (status) whereClause.status = status;

  if (paginated && filters.cursor) {
    whereClause = await mergeCreatedAtCursorWhere(
      whereClause,
      filters.cursor,
      (id) =>
        prisma.due.findFirst({
          where: { id, apartment: { buildingId } },
          select: { id: true, createdAt: true },
        })
    );
  }

  const orderBy = paginated
    ? [{ createdAt: "desc" }, { id: "desc" }]
    : [{ year: "desc" }, { month: "desc" }, { apartment: { number: "asc" } }];

  const dues = await prisma.due.findMany({
    where: whereClause,
    include: {
      apartment: {
        select: {
          id: true,
          number: true,
          floor: true,
          resident: { select: userPublicSelect },
        },
      },
    },
    orderBy,
    take,
  });

  const mapped = buildListResponse(filters, dues, mapDueRow);
  if (paginated) {
    const items = await attachBreakdownToDuesBatch(mapped.items, buildingId);
    return { ...mapped, items };
  }
  return attachBreakdownToDuesBatch(mapped, buildingId);
};

/**
 * Aidat durumunu güncelle (yönetici için)
 */
export const updateDueStatusService = async (dueId, managerId, { status, paidAt, note, buildingId }) => {
  // Due'nun yöneticinin binasına ait olduğunu kontrol et
  const due = await prisma.due.findUnique({
    where: { id: dueId },
    include: {
      apartment: {
        include: { building: true },
      },
    },
  });

  if (!due) {
    throw new HttpError(404, "Aidat kaydı bulunamadı.");
  }

  if (due.apartment.building.managerId !== managerId) {
    throw new HttpError(403, "Bu aidat kaydını güncelleme yetkiniz yok.");
  }

  if (buildingId && due.apartment.buildingId !== buildingId) {
    throw new HttpError(403, "Bu aidat kaydını güncelleme yetkiniz yok.");
  }

  const previousStatus = due.status;

  // Güncelleme verisi
  const updateData = { status };

  let resident = null;

  if (status === "PAID") {
    resident = await prisma.user.findFirst({
      where: {
        apartmentId: due.apartmentId,
        deletedAt: null,
        role: "RESIDENT",
      },
      select: { id: true },
    });
    if (!resident) {
      throw new HttpError(400, "Sakin atanmamış dairelerin aidatları 'Ödendi' yapılamaz.");
    }
    updateData.paidAt = (paidAt && !isNaN(Date.parse(paidAt))) ? new Date(paidAt) : new Date();
    updateData.overdueDays = 0;
  } else if (status === "WAIVED") {
    updateData.paidAt = null;
    updateData.overdueDays = 0;
  } else if (status === "OVERDUE") {
    updateData.overdueDays = computeOverdueDays(due.dueDate);
  }

  if (note !== undefined) {
    updateData.note = note;
  }

  const updated = await prisma.$transaction(async (tx) => {
    const row = await tx.due.update({
      where: { id: dueId },
      data: updateData,
      include: {
        apartment: {
          select: { id: true, number: true },
        },
      },
    });

    if (status === "PAID" && previousStatus !== "PAID") {
      const existingPayment = await tx.duePayment.findFirst({
        where: { dueId },
      });
      if (!existingPayment) {
        await tx.duePayment.create({
          data: {
            dueId,
            amount: due.amount,
            paidAt: updateData.paidAt ?? new Date(),
            currency: due.currency,
            note: note ?? "Manuel ödeme",
          },
        });
      }
    }

    return row;
  });

  if (status === "PAID" && previousStatus !== "PAID" && resident) {
    await createForUsers([resident.id], {
      type: NOTIFICATION_TYPES.DUE_PAID,
      code: NOTIFICATION_CODES.DUE_PAID_RESIDENT,
      params: { month: due.month, year: due.year },
      data: {
        dueId: due.id,
        buildingId: due.apartment.buildingId,
        apartmentId: due.apartmentId,
        month: String(due.month),
        year: String(due.year),
        route: "/resident-dashboard",
      },
    });
  }

  return {
    ...updated,
    apartmentNumber: updated.apartment?.number ?? null,
  };
};

const PENDING_DEKONT_STATUSES = [
  "RECEIVED",
  "EXTRACTING",
  "PARSED",
  "PARSE_LOW_CONFIDENCE",
  "MATCHING",
  "MATCHED",
  "MATCH_AMBIGUOUS",
  "UNMATCHED",
  "NEEDS_MANAGER_REVIEW",
  "RECIPIENT_MISMATCH",
];

function mapDueTransactionRow(row) {
  return {
    id: row.id,
    kind: row.kind,
    source: row.source,
    amount: row.amount,
    currency: row.currency,
    occurredAt: row.occurredAt,
    apartmentNumber: row.apartmentNumber,
    residentName: row.residentName,
    status: row.status,
    dekontId: row.dekontId ?? null,
    dueId: row.dueId ?? null,
  };
}

/**
 * Bina aidat işlem geçmişi — onaylı ödemeler + bekleyen/reddedilmiş dekontlar.
 */
export const getDueTransactionsService = async (buildingId, managerId, filters = {}) => {
  const building = await prisma.building.findFirst({
    where: { id: buildingId, managerId },
  });
  if (!building) {
    throw new HttpError(404, "Bina bulunamadı.");
  }

  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  const [payments, dekonts] = await Promise.all([
    prisma.duePayment.findMany({
      where: {
        due: { apartment: { buildingId } },
      },
      include: {
        due: {
          include: {
            apartment: {
              select: {
                number: true,
                resident: { select: userPublicSelect },
              },
            },
          },
        },
        dekont: { select: { id: true, status: true } },
      },
      orderBy: [{ paidAt: "desc" }, { id: "desc" }],
    }),
    prisma.dekont.findMany({
      where: {
        buildingId,
        status: { in: [...PENDING_DEKONT_STATUSES, "REJECTED"] },
      },
      include: {
        apartment: { select: { number: true } },
        uploadedBy: { select: { id: true, name: true } },
      },
      orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    }),
  ]);

  const paymentRows = payments.map((payment) => ({
    id: payment.id,
    kind: "PAYMENT",
    source: payment.dekontId ? "RECEIPT" : "MANUAL",
    amount: Number(payment.amount),
    currency: payment.currency,
    occurredAt: payment.paidAt,
    apartmentNumber: payment.due.apartment.number,
    residentName: payment.due.apartment.resident?.name ?? null,
    status: "APPROVED",
    dekontId: payment.dekontId,
    dueId: payment.dueId,
  }));

  const dekontRows = dekonts.map((dekont) => ({
    id: dekont.id,
    kind: "DEKONT",
    source: "RECEIPT",
    amount: dekont.parsedAmount != null ? Number(dekont.parsedAmount) : null,
    currency: "TRY",
    occurredAt: dekont.transactionDate ?? dekont.createdAt,
    apartmentNumber: dekont.apartment?.number ?? null,
    residentName: dekont.uploadedBy?.name ?? null,
    status: dekont.status === "REJECTED" ? "REJECTED" : "PENDING",
    dekontId: dekont.id,
    dueId: dekont.dueId,
  }));

  const merged = [...paymentRows, ...dekontRows].sort((a, b) => {
    const diff = new Date(b.occurredAt).getTime() - new Date(a.occurredAt).getTime();
    if (diff !== 0) return diff;
    return String(b.id).localeCompare(String(a.id));
  });

  const sliced = merged.slice(0, take);
  return buildListResponse(filters, sliced, mapDueTransactionRow);
};

/**
 * Sakinin kendi aidatlarını listele
 */
export const getMyDuesService = async (userId, filters = {}) => {
  const user = await prisma.user.findFirst({
    where: { id: userId, deletedAt: null },
    select: {
      apartment: {
        select: {
          id: true,
          number: true,
          buildingId: true,
          building: { select: { id: true, name: true, address: true } },
        },
      },
    },
  });

  if (!user?.apartment) {
    return wantsPaginatedList(filters) ? { items: [], nextCursor: null } : [];
  }

  const { status, year, month } = filters;
  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let whereClause = { apartmentId: user.apartment.id };

  if (status) whereClause.status = status;
  if (year) whereClause.year = parseInt(String(year), 10);
  if (month) whereClause.month = parseInt(String(month), 10);

  if (paginated && filters.cursor) {
    whereClause = await mergeCreatedAtCursorWhere(whereClause, filters.cursor, (id) =>
      prisma.due.findFirst({
        where: { id, apartmentId: user.apartment.id },
        select: { id: true, createdAt: true },
      })
    );
  }

  const orderBy = paginated
    ? [{ createdAt: "desc" }, { id: "desc" }]
    : [{ year: "desc" }, { month: "desc" }];

  const dues = await prisma.due.findMany({
    where: whereClause,
    orderBy,
    take,
  });

  const building = user.apartment.building;
  const buildingId = user.apartment.buildingId;

  const mapped = buildListResponse(filters, dues, (due) => ({
    ...due,
    apartmentId: user.apartment.id,
    apartmentNumber: user.apartment.number,
    apartment: {
      id: user.apartment.id,
      number: user.apartment.number,
    },
    building,
  }));

  if (paginated) {
    const items = await attachBreakdownToDuesBatch(mapped.items, buildingId);
    return { ...mapped, items };
  }
  return attachBreakdownToDuesBatch(mapped, buildingId);
};

/**
 * Bina aidat bedelini güncelle
 * affectCurrent: true ise açık (PENDING/OVERDUE) aidatların tutarı, vadesi ve durumu güncellenir
 */
export const updateBuildingDueAmountService = async (buildingId, managerId, { dueAmount, dueDay, currency, affectCurrent = false }) => {
  // Binanın yöneticiye ait olduğunu kontrol et
  const building = await prisma.building.findFirst({
    where: { id: buildingId, managerId },
  });

  if (!building) {
    throw new HttpError(404, "Bina bulunamadı veya erişim yetkiniz yok.");
  }

  return await prisma.$transaction(async (tx) => {
    const updated = await tx.building.update({
      where: { id: buildingId },
      data: {
        ...(dueAmount != null && { dueAmount }),
        ...(dueDay != null && { dueDay }),
        ...(currency && { currency }),
      },
    });

    return updated;
  }).then(async (updated) => {
    if (affectCurrent && (dueAmount != null || dueDay != null)) {
      await syncOpenBuildingDues(buildingId, {
        dueDay: updated.dueDay,
        currency: updated.currency,
      });
    }

    return updated;
  });
};
