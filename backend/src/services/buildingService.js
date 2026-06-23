import { prisma } from "../config/db.js";
import { buildDueRowsForApartments } from "../utils/dueGeneration.js";
import { isValidTrIban, normalizeIban } from "../utils/iban.js";
import { HttpError } from "../utils/httpError.js";
import { assertManagerOwnsBuilding } from "../utils/access.js";
import { assertCanAddManagementUnit } from "./managementQuotaService.js";
import { resolveEffectiveBuildingConfig } from "../utils/effectiveBuildingConfig.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";

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
  skipQuotaCheck = false,
  siteId = null,
  blockLabel = null,
  addressExtra = null,
}) => {
  if (!skipQuotaCheck) {
    await assertCanAddManagementUnit(managerId);
  }

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
          siteId,
          blockLabel,
          addressExtra,
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
      const dueRows = buildDueRowsForApartments(
        apartments.map((a) => a.id),
        { dueAmount, dueDay, currency }
      );
      if (dueRows.length > 0) {
        await tx.due.createMany({ data: dueRows });
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

export const getBuildingsService = async (managerId, filters = {}) => {
  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = { managerId };

  if (filters.standalone === true || filters.standalone === "true") {
    where.siteId = null;
  }

  if (filters.search) {
    where.OR = [
      { name: { contains: filters.search, mode: "insensitive" } },
      { city: { contains: filters.search, mode: "insensitive" } },
    ];
  }

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.building.findFirst({
        where: { id, managerId },
        select: { id: true, createdAt: true },
      })
    );
  }

  const buildings = await prisma.building.findMany({
    where,
    orderBy: paginated
      ? [{ createdAt: "desc" }, { id: "desc" }]
      : [{ createdAt: "desc" }],
    take,
    include: {
      _count: {
        select: { apartments: true },
      },
      apartments: {
        where: { resident: { isNot: null } },
        select: { id: true },
      },
      site: true,
    },
  });

  const mapped = buildings.map((b) => {
    const { apartments, site, ...rest } = b;
    return resolveEffectiveBuildingConfig({
      ...rest,
      site,
      occupiedApartments: apartments.length,
    });
  });

  return buildListResponse(filters, mapped, (b) => b);
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
      site: true,
    },
  });

  if (!building) return null;

  const { apartments, site, ...rest } = building;
  return resolveEffectiveBuildingConfig({
    ...rest,
    site,
    occupiedApartments: apartments.length,
  });
};

export const updateBuildingService = async (id, managerId, data) => {
  await assertManagerOwnsBuilding(id, managerId);

  return await prisma.building.update({
    where: { id },
    data,
  });
};

export const deleteBuildingService = async (id, managerId) => {
  await assertManagerOwnsBuilding(id, managerId);

  return await prisma.$transaction(async (tx) => {
    // 1. Delete all DuePayments for dues of this building
    await tx.duePayment.deleteMany({
      where: {
        due: {
          apartment: {
            buildingId: id,
          },
        },
      },
    });

    // 2. Delete all DueExpenseCarryforwards for this building
    await tx.dueExpenseCarryforward.deleteMany({
      where: {
        OR: [
          {
            expense: {
              buildingId: id,
            },
          },
          {
            apartment: {
              buildingId: id,
            },
          },
        ],
      },
    });

    // 3. Delete all Dekonts of this building
    await tx.dekont.deleteMany({
      where: {
        buildingId: id,
      },
    });

    // 4. Delete all Dues of this building's apartments
    await tx.due.deleteMany({
      where: {
        apartment: {
          buildingId: id,
        },
      },
    });

    // 5. Delete all InviteCodes of this building's apartments
    await tx.inviteCode.deleteMany({
      where: {
        apartment: {
          buildingId: id,
        },
      },
    });

    // 6. Delete all TicketUpdates of this building's tickets
    await tx.ticketUpdate.deleteMany({
      where: {
        ticket: {
          apartment: {
            buildingId: id,
          },
        },
      },
    });

    // 7. Delete all Tickets of this building's apartments
    await tx.ticket.deleteMany({
      where: {
        apartment: {
          buildingId: id,
        },
      },
    });

    // 8. Delete all Expenses of this building
    await tx.expense.deleteMany({
      where: {
        buildingId: id,
      },
    });

    // 9. Unlink any users (residents) from this building's apartments
    await tx.user.updateMany({
      where: {
        apartment: {
          buildingId: id,
        },
      },
      data: {
        apartmentId: null,
      },
    });

    // 10. Delete all Apartments of this building
    await tx.apartment.deleteMany({
      where: {
        buildingId: id,
      },
    });

    // 11. Finally, delete the Building itself
    return await tx.building.delete({
      where: { id },
    });
  });
};

/**
 * Tahsilat hesabı (dekont alıcı IBAN doğrulaması).
 */
export const updateBuildingCollectionService = async (id, managerId, body) => {
  await assertManagerOwnsBuilding(id, managerId);

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