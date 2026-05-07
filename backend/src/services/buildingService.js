import { prisma } from "../config/db.js";

/**
 * Bina oluştur (transaction: Building + Apartments + Dues)
 * Daireler: 1A, 1B, 2A, 2B... şeklinde isimlendirilir
 * Aidatlar: Bulunulan aydan yıl sonuna kadar tüm daireler için oluşturulur
 */
export const createBuildingService = async ({
  name,
  address,
  city,
  totalFloors,
  apartmentsPerFloor,
  dueAmount,
  dueDay = 1,
  currency = "TRY",
  managerId,
}) => {
  return await prisma.$transaction(async (tx) => {
    // 1. Building oluştur
    const building = await tx.building.create({
      data: {
        name,
        address,
        city,
        totalFloors,
        apartmentsPerFloor,
        dueAmount,
        dueDay,
        currency,
        managerId,
      },
    });

    // 2. Apartments oluştur (1A, 1B, 1C, 2A, 2B, 2C...)
    const apartmentPromises = [];
    const totalFloorsNum = totalFloors || 1;
    const apartmentsPerFloorNum = apartmentsPerFloor || 2;

    for (let floor = 1; floor <= totalFloorsNum; floor++) {
      for (let unit = 0; unit < apartmentsPerFloorNum; unit++) {
        const letter = String.fromCharCode(65 + unit); // A, B, C...
        const number = `${floor}${letter}`;
        apartmentPromises.push(
          tx.apartment.create({
            data: {
              number,
              floor,
              buildingId: building.id,
            },
          })
        );
      }
    }

    const apartments = await Promise.all(apartmentPromises);

    // 3. Dues oluştur (bulunulan aydan yıl sonuna kadar)
    if (dueAmount) {
      const now = new Date();
      const currentYear = now.getFullYear();
      const currentMonth = now.getMonth() + 1; // 1-12

      const duePromises = [];
      for (const apartment of apartments) {
        for (let month = currentMonth; month <= 12; month++) {
          const dueDate = new Date(currentYear, month - 1, dueDay, 23, 59, 59);
          duePromises.push(
            tx.due.create({
              data: {
                apartmentId: apartment.id,
                amount: dueAmount,
                currency,
                month,
                year: currentYear,
                dueDate,
                status: "PENDING",
              },
            })
          );
        }
      }

      await Promise.all(duePromises);
    }

    // Building'i apartments ile birlikte döndür
    return await tx.building.findUnique({
      where: { id: building.id },
      include: {
        apartments: {
          orderBy: { number: "asc" },
        },
      },
    });
  });
};

export const getBuildingsService = async (managerId) => {
  return await prisma.building.findMany({
    where: { managerId },
    orderBy: { createdAt: "desc" },
  });
};

export const getBuildingByIdService = async (id, managerId) => {
  return await prisma.building.findFirst({
    where: { id, managerId },
  });
};

export const updateBuildingService = async (id, managerId, data) => {
  const building = await prisma.building.findFirst({
    where: { id, managerId },
  });

  if (!building) return null;

  return await prisma.building.update({
    where: { id },
    data,
  });
};

export const deleteBuildingService = async (id, managerId) => {
  const building = await prisma.building.findFirst({
    where: { id, managerId },
  });

  if (!building) return null;

  return await prisma.building.delete({
    where: { id },
  });
};