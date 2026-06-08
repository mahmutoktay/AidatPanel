import { prisma } from "../config/db.js";
import { endOfDueDayIstanbul, getIstanbulYearMonth } from "../utils/trDueDate.js";
import { isValidTrIban, normalizeIban } from "../utils/iban.js";
import { HttpError } from "../utils/httpError.js";

/**
 * Tahsilat alanlarını create/update body'den Prisma data'ya çevirir.
 * @param {object} body
 * @returns {object}
 */
export function collectionFieldsFromBody(body) {
  const data = {};

  if (body.collectionIban !== undefined) {
    if (body.collectionIban === null || body.collectionIban === "") {
      data.collectionIban = null;
      data.collectionVerifiedAt = null;
    } else {
      const iban = normalizeIban(body.collectionIban);
      if (!isValidTrIban(iban)) {
        throw new HttpError(400, "Geçersiz TR IBAN.");
      }
      data.collectionIban = iban;
      data.collectionVerifiedAt = new Date();
    }
  }

  if (body.collectionAccountTitle !== undefined) {
    data.collectionAccountTitle = body.collectionAccountTitle;
  }

  if (body.paymentReferenceTemplate !== undefined) {
    data.paymentReferenceTemplate = body.paymentReferenceTemplate;
  }

  return data;
}

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
  collectionIban,
  collectionAccountTitle,
  paymentReferenceTemplate,
}) => {
  const collectionData = collectionFieldsFromBody({
    collectionIban,
    collectionAccountTitle,
    paymentReferenceTemplate,
  });

  return await prisma.$transaction(
    async (tx) => {
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
          ...collectionData,
        },
      });

      // 2. Daireler — toplu INSERT
      const totalFloorsNum = totalFloors || 1;
      const apartmentsPerFloorNum = apartmentsPerFloor || 2;
      const apartmentRows = [];

      for (let floor = 1; floor <= totalFloorsNum; floor++) {
        for (let unit = 0; unit < apartmentsPerFloorNum; unit++) {
          const letter = String.fromCharCode(65 + unit);
          apartmentRows.push({
            number: `${floor}${letter}`,
            floor,
            buildingId: building.id,
          });
        }
      }

      const apartments =
        apartmentRows.length > 0
          ? await tx.apartment.createManyAndReturn({ data: apartmentRows })
          : [];

      // 3. Aidatlar — bulunulan aydan yıl sonuna (toplu INSERT)
      if (dueAmount && apartments.length > 0) {
        const { year: currentYear, month: currentMonth } = getIstanbulYearMonth();
        const dueRows = [];

        for (const apartment of apartments) {
          for (let month = currentMonth; month <= 12; month++) {
            dueRows.push({
              apartmentId: apartment.id,
              amount: dueAmount,
              currency,
              month,
              year: currentYear,
              dueDate: endOfDueDayIstanbul(currentYear, month, dueDay),
              status: "PENDING",
            });
          }
        }

        if (dueRows.length > 0) {
          await tx.due.createMany({ data: dueRows });
        }
      }

      return await tx.building.findUnique({
        where: { id: building.id },
        include: {
          apartments: {
            orderBy: { number: "asc" },
          },
        },
      });
    },
    {
      maxWait: 10_000,
      timeout: 60_000,
    }
  );
};

export const getBuildingsService = async (managerId) => {
  const buildings = await prisma.building.findMany({
    where: { managerId },
    orderBy: { createdAt: "desc" },
    include: {
      _count: {
        select: { apartments: true },
      },
      apartments: {
        where: { resident: { isNot: null } },
        select: { id: true },
      },
    },
  });

  return buildings.map(b => {
    const { apartments, ...rest } = b;
    return {
      ...rest,
      occupiedApartments: apartments.length,
    };
  });
};

export const getBuildingByIdService = async (id, managerId) => {
  const building = await prisma.building.findFirst({
    where: { id, managerId },
    include: {
      _count: {
        select: { apartments: true },
      },
      apartments: {
        where: { resident: { isNot: null } },
        select: { id: true },
      },
    },
  });

  if (!building) return null;

  const { apartments, ...rest } = building;
  return {
    ...rest,
    occupiedApartments: apartments.length,
  };
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

/**
 * Tahsilat hesabı (dekont alıcı IBAN doğrulaması).
 */
export const updateBuildingCollectionService = async (id, managerId, body) => {
  const building = await prisma.building.findFirst({
    where: { id, managerId },
  });

  if (!building) return null;

  const data = collectionFieldsFromBody(body);

  return await prisma.building.update({
    where: { id },
    data,
  });
};

/**
 * Yöneticinin mevcut binalarından benzersiz tahsilat şablonları (yeni bina formu önerileri).
 */
export const getCollectionPresetsService = async (managerId) => {
  const buildings = await prisma.building.findMany({
    where: {
      managerId,
      collectionIban: { not: null },
    },
    select: {
      collectionIban: true,
      collectionAccountTitle: true,
      paymentReferenceTemplate: true,
      updatedAt: true,
    },
    orderBy: { updatedAt: "desc" },
  });

  const byKey = new Map();

  for (const b of buildings) {
    const key = [
      b.collectionIban,
      b.collectionAccountTitle ?? "",
      b.paymentReferenceTemplate ?? "",
    ].join("\0");

    const existing = byKey.get(key);
    if (!existing) {
      byKey.set(key, {
        collectionIban: b.collectionIban,
        collectionAccountTitle: b.collectionAccountTitle,
        paymentReferenceTemplate: b.paymentReferenceTemplate,
        lastUsedAt: b.updatedAt,
        buildingCount: 1,
      });
    } else {
      existing.buildingCount += 1;
      if (b.updatedAt > existing.lastUsedAt) {
        existing.lastUsedAt = b.updatedAt;
      }
    }
  }

  return [...byKey.values()].sort(
    (a, b) => b.lastUsedAt.getTime() - a.lastUsedAt.getTime()
  );
};