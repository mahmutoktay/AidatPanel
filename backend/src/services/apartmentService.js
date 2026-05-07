import { prisma } from "../config/db.js";

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
    include: { resident: true },
    orderBy: { number: "asc" },
  });
};

// CREATE apartment
export const createApartmentService = async ({ buildingId, number, floor, managerId }) => {
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
  });

  if (!building || building.managerId !== managerId) {
    return null;
  }

  return await prisma.apartment.create({
    data: {
      buildingId,
      number,
      floor,
    },
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