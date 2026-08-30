import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { sortByNatural } from "../utils/naturalCompare.js";
import { userPublicSelect } from "./meService.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";

// GET apartments (sayfalama destekli)
export const getApartmentsService = async (buildingId, managerId, filters = {}) => {
  // önce bina kontrol
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    throw new HttpError(403, "Bu binanın dairelerini görüntüleme yetkiniz yok.");
  }

  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = { buildingId };

  if (filters.search) {
    where.number = { contains: filters.search, mode: "insensitive" };
  }

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.apartment.findFirst({
        where: { id, buildingId },
        select: { id: true, createdAt: true },
      })
    );
  }

  const apartments = await prisma.apartment.findMany({
    where,
    include: { resident: { select: userPublicSelect } },
    orderBy: paginated
      ? [{ createdAt: "desc" }, { id: "desc" }]
      : [{ number: "asc" }],
    take,
  });

  const sorted = paginated
    ? apartments
    : sortByNatural(apartments, (apt) => apt.number);

  return buildListResponse(filters, sorted, (apt) => apt);
};

/**
 * Yönetici: dairedeki sakini ayırır (`User.apartmentId = null`). Hesap silinmez; geçmiş aidatlar kalır.
 */
export const removeResidentFromApartmentService = async (apartmentId, buildingId, managerId) => {
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    throw new HttpError(403, "Bu işlem için yetkiniz yok.");
  }

  const apartment = await prisma.apartment.findFirst({
    where: { id: apartmentId, buildingId },
  });

  if (!apartment) {
    throw new HttpError(404, "Daire bulunamadı.");
  }

  const resident = await prisma.user.findFirst({
    where: { apartmentId: apartment.id, deletedAt: null, role: "RESIDENT" },
  });

  if (!resident) {
    throw new HttpError(404, "Bu dairede kayıtlı sakin yok.");
  }

  await prisma.$transaction(async (tx) => {
    await tx.due.updateMany({
      where: {
        apartmentId: apartment.id,
        status: { in: ["PENDING", "OVERDUE"] },
        residentNameSnapshot: null,
      },
      data: { residentNameSnapshot: resident.name },
    });

    await tx.user.update({
      where: { id: resident.id },
      data: { apartmentId: null },
    });
  });

  return await prisma.apartment.findUnique({
    where: { id: apartmentId },
    include: { resident: { select: userPublicSelect } },
  });
};

// CREATE apartment
export const createApartmentService = async ({ buildingId, number, floor, managerId }) => {
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    throw new HttpError(403, "Bu binaya daire ekleme yetkiniz yok.");
  }

  return await prisma.$transaction(async (tx) => {
    const apartment = await tx.apartment.create({
      data: {
        buildingId,
        number,
        floor,
      },
    });

    return apartment;
  });
};

// DELETE apartment
export const deleteApartmentService = async (id, buildingId, managerId) => {
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    throw new HttpError(403, "Bu daireyi silme yetkiniz yok.");
  }

  return await prisma.apartment.delete({
    where: { id },
  });
};

// UPDATE apartment
export const updateApartmentService = async (id, buildingId, managerId, data) => {
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    throw new HttpError(403, "Bu daireyi güncelleme yetkiniz yok.");
  }

  const apartment = await prisma.apartment.findFirst({
    where: { id, buildingId },
  });

  if (!apartment) {
    throw new HttpError(404, "Daire bulunamadı.");
  }

  return await prisma.apartment.update({
    where: { id },
    data,
  });
};