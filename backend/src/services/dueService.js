import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { DUE_PAID_RESIDENT } from "../constants/notificationTemplates.js";
import { prisma } from "../config/db.js";
import { userPublicSelect } from "./meService.js";
import { createForUsers } from "./notificationService.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";

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

/**
 * Binadaki tüm aidatları listele (yönetici için)
 * Filtreleme: month, year, status
 */
export const getDuesByBuildingService = async (buildingId, managerId, filters = {}) => {
  // Önce binanın yöneticiye ait olduğunu kontrol et
  const building = await prisma.building.findFirst({
    where: { id: buildingId, managerId },
  });

  if (!building) return null;

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

  return buildListResponse(filters, dues, mapDueRow);
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

  if (!due) return null;

  if (due.apartment.building.managerId !== managerId) {
    return { forbidden: true };
  }

  if (buildingId && due.apartment.buildingId !== buildingId) {
    return { forbidden: true };
  }

  const previousStatus = due.status;

  // Güncelleme verisi
  const updateData = { status };

  if (status === "PAID") {
    updateData.paidAt = paidAt ? new Date(paidAt) : new Date();
    updateData.overdueDays = 0;
  } else if (status === "WAIVED") {
    updateData.paidAt = null;
    updateData.overdueDays = 0;
  } else if (status === "OVERDUE") {
    // Gecikme gün sayısını hesapla
    const today = new Date();
    const dueDate = new Date(due.dueDate);
    const diffTime = today.getTime() - dueDate.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    updateData.overdueDays = Math.max(0, diffDays);
  }

  if (note !== undefined) {
    updateData.note = note;
  }

  const updated = await prisma.due.update({
    where: { id: dueId },
    data: updateData,
    include: {
      apartment: {
        select: { id: true, number: true },
      },
    },
  });

  if (status === "PAID" && previousStatus !== "PAID") {
    const resident = await prisma.user.findFirst({
      where: {
        apartmentId: due.apartmentId,
        deletedAt: null,
        role: "RESIDENT",
      },
      select: { id: true },
    });

    if (resident) {
      await createForUsers([resident.id], {
        type: NOTIFICATION_TYPES.DUE_PAID,
        title: DUE_PAID_RESIDENT.title,
        body: DUE_PAID_RESIDENT.body(due.month, due.year),
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
  }

  return {
    ...updated,
    apartmentNumber: updated.apartment?.number ?? null,
  };
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

  return buildListResponse(filters, dues, (due) => ({
    ...due,
    apartmentId: user.apartment.id,
    apartmentNumber: user.apartment.number,
    apartment: {
      id: user.apartment.id,
      number: user.apartment.number,
    },
    building,
  }));
};

/**
 * Bina aidat bedelini güncelle
 * affectCurrent: true ise mevcut PENDING aidatları da güncelle
 */
export const updateBuildingDueAmountService = async (buildingId, managerId, { dueAmount, dueDay, currency, affectCurrent = false }) => {
  // Binanın yöneticiye ait olduğunu kontrol et
  const building = await prisma.building.findFirst({
    where: { id: buildingId, managerId },
  });

  if (!building) return null;

  return await prisma.$transaction(async (tx) => {
    // Building'i güncelle
    const updated = await tx.building.update({
      where: { id: buildingId },
      data: {
        dueAmount,
        ...(dueDay && { dueDay }),
        ...(currency && { currency }),
      },
    });

    // Mevcut PENDING aidatları da güncelle (isteğe bağlı)
    if (affectCurrent && dueAmount) {
      await tx.due.updateMany({
        where: {
          apartment: { buildingId },
          status: "PENDING",
        },
        data: {
          amount: dueAmount,
          ...(currency && { currency }),
        },
      });
    }

    return updated;
  });
};
