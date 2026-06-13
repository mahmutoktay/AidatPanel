import { prisma } from "../config/db.js";
import { buildDueRowsForApartments } from "../utils/dueGeneration.js";
import { userPublicSelect } from "./meService.js";

// GET apartments
export const getApartmentsService = async (buildingId, managerId) => {
  // önce bina kontrol
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    return null;
  }

  return await prisma.apartment.findMany({
    where: { buildingId },
    include: { resident: { select: userPublicSelect } },
    orderBy: { number: "asc" },
  });
};

/**
 * Yönetici: dairedeki sakini ayırır (`User.apartmentId = null`). Hesap silinmez; geçmiş aidatlar kalır.
 */
export const removeResidentFromApartmentService = async (apartmentId, buildingId, managerId) => {
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    return { forbidden: true };
  }

  const apartment = await prisma.apartment.findFirst({
    where: { id: apartmentId, buildingId },
  });

  if (!apartment) {
    return { notFound: true };
  }

  const resident = await prisma.user.findFirst({
    where: { apartmentId: apartment.id, deletedAt: null, role: "RESIDENT" },
  });

  if (!resident) {
    return { noResident: true };
  }

  await prisma.user.update({
    where: { id: resident.id },
    data: { apartmentId: null },
  });

  const updated = await prisma.apartment.findUnique({
    where: { id: apartmentId },
    include: { resident: { select: userPublicSelect } },
  });

  return { apartment: updated };
};

// CREATE apartment
export const createApartmentService = async ({ buildingId, number, floor, managerId }) => {
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    return null;
  }

  return await prisma.$transaction(async (tx) => {
    const apartment = await tx.apartment.create({
      data: {
        buildingId,
        number,
        floor,
      },
    });

    const dueRows = buildDueRowsForApartments([apartment.id], {
      dueAmount: building.dueAmount,
      dueDay: building.dueDay,
      currency: building.currency,
    });

    if (dueRows.length > 0) {
      await tx.due.createMany({ data: dueRows });
    }

    return apartment;
  });
};

// DELETE apartment
export const deleteApartmentService = async (id, buildingId, managerId) => {
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    return null;
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
    return null;
  }

  const apartment = await prisma.apartment.findFirst({
    where: { id, buildingId },
  });

  if (!apartment) {
    return null;
  }

  return await prisma.apartment.update({
    where: { id },
    data,
  });
};