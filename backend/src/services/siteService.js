import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { assertManagerOwnsSite } from "../utils/access.js";
import { collectionFieldsFromBody } from "./buildingService.js";
import { createBuildingService, deleteBuildingService } from "./buildingService.js";
import { assertCanAddManagementUnit } from "./managementQuotaService.js";
import { resolveEffectiveBuildingConfig } from "../utils/effectiveBuildingConfig.js";
import {
  wantsPaginatedList,
  resolvePageLimit,
  resolveListTake,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";

function getCurrentPeriod() {
  const now = new Date();
  return { month: now.getMonth() + 1, year: now.getFullYear() };
}

async function aggregateSiteDues(siteId, month, year) {
  const dues = await prisma.due.findMany({
    where: {
      apartment: { building: { siteId } },
      month,
      year,
    },
    select: { amount: true, status: true },
  });

  let expectedAmount = 0;
  let collectedAmount = 0;
  for (const due of dues) {
    const amount = Number(due.amount);
    expectedAmount += amount;
    if (due.status === "PAID") {
      collectedAmount += amount;
    }
  }

  return {
    expectedAmount: Math.round(expectedAmount * 100) / 100,
    collectedAmount: Math.round(collectedAmount * 100) / 100,
  };
}

function mapSiteRow(site, extra = {}) {
  const { buildings, _count, ...rest } = site;
  return {
    ...rest,
    buildingCount: _count?.buildings ?? buildings?.length ?? 0,
    ...extra,
  };
}

export const createSiteService = async ({
  name,
  address,
  city,
  dueAmount,
  dueDay = 1,
  currency = "TRY",
  managerId,
  collectionIban,
  collectionAccountTitle,
  paymentReferenceTemplate,
}) => {
  await assertCanAddManagementUnit(managerId);

  const collectionData = collectionFieldsFromBody({
    collectionIban,
    collectionAccountTitle,
    paymentReferenceTemplate,
  });

  return prisma.site.create({
    data: {
      name,
      address,
      city,
      dueAmount,
      dueDay,
      currency,
      managerId,
      ...collectionData,
    },
  });
};

export const getSitesService = async (managerId, filters = {}) => {
  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated
    ? resolvePageLimit(filters.limit)
    : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = { managerId };

  if (filters.search) {
    where.OR = [
      { name: { contains: filters.search, mode: "insensitive" } },
      { city: { contains: filters.search, mode: "insensitive" } },
    ];
  }

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.site.findFirst({
        where: { id, managerId },
        select: { id: true, createdAt: true },
      })
    );
  }

  const sites = await prisma.site.findMany({
    where,
    orderBy: paginated
      ? [{ createdAt: "desc" }, { id: "desc" }]
      : [{ createdAt: "desc" }],
    take,
    include: {
      _count: { select: { buildings: true } },
    },
  });

  const { month, year } = getCurrentPeriod();
  const mapped = await Promise.all(
    sites.map(async (site) => {
      const dues = await aggregateSiteDues(site.id, month, year);
      return mapSiteRow(site, dues);
    })
  );

  return buildListResponse(filters, mapped, (s) => s);
};

export const getSiteByIdService = async (id, managerId) => {
  const site = await prisma.site.findFirst({
    where: { id, managerId },
    include: {
      _count: { select: { buildings: true } },
      buildings: {
        orderBy: { createdAt: "asc" },
        include: {
          _count: { select: { apartments: true } },
          apartments: {
            where: { resident: { isNot: null } },
            select: { id: true },
          },
          site: true,
        },
      },
    },
  });

  if (!site) return null;

  const { month, year } = getCurrentPeriod();
  const dues = await aggregateSiteDues(site.id, month, year);

  const buildings = site.buildings.map((building) => {
    const { apartments, site: siteRow, ...rest } = building;
    return resolveEffectiveBuildingConfig({
      ...rest,
      site: siteRow,
      occupiedApartments: apartments.length,
    });
  });

  return {
    ...mapSiteRow(site, dues),
    buildings,
  };
};

export const updateSiteService = async (id, managerId, data) => {
  await assertManagerOwnsSite(id, managerId);
  return prisma.site.update({ where: { id }, data });
};

export const updateSiteCollectionService = async (id, managerId, body) => {
  await assertManagerOwnsSite(id, managerId);
  const data = collectionFieldsFromBody(body);
  return prisma.site.update({ where: { id }, data });
};

export const deleteSiteService = async (id, managerId) => {
  const site = await assertManagerOwnsSite(id, managerId);

  const buildings = await prisma.building.findMany({
    where: { siteId: id },
    select: { id: true },
  });

  for (const building of buildings) {
    await deleteBuildingService(building.id, managerId);
  }

  return prisma.site.delete({ where: { id: site.id } });
};

/**
 * Site altına bina ekler. Kota tüketmez; site varsayılanlarını inherit eder.
 */
export const createSiteBuildingService = async (siteId, managerId, body) => {
  const site = await assertManagerOwnsSite(siteId, managerId);

  const dueAmount =
    body.dueAmount !== undefined ? body.dueAmount : site.dueAmount
      ? Number(site.dueAmount)
      : undefined;
  const dueDay = body.dueDay ?? site.dueDay;
  const currency = body.currency ?? site.currency;

  const collectionIban =
    body.collectionIban !== undefined
      ? body.collectionIban
      : site.collectionIban;
  const collectionAccountTitle =
    body.collectionAccountTitle !== undefined
      ? body.collectionAccountTitle
      : site.collectionAccountTitle;
  const paymentReferenceTemplate =
    body.paymentReferenceTemplate !== undefined
      ? body.paymentReferenceTemplate
      : site.paymentReferenceTemplate;

  const building = await createBuildingService({
    name: body.name,
    address: body.address?.trim() ? body.address : site.address,
    city: body.city?.trim() ? body.city : site.city,
    totalFloors: body.totalFloors,
    apartmentsPerFloor: body.apartmentsPerFloor,
    dueAmount,
    dueDay,
    currency,
    managerId,
    collectionIban,
    collectionAccountTitle,
    paymentReferenceTemplate,
    skipQuotaCheck: true,
    siteId,
    blockLabel: body.blockLabel ?? null,
    addressExtra: body.addressExtra ?? null,
  });

  return prisma.building.findUnique({
    where: { id: building.id },
    include: {
      _count: { select: { apartments: true } },
      site: true,
    },
  });
};

export const getSiteBuildingsService = async (siteId, managerId) => {
  await assertManagerOwnsSite(siteId, managerId);

  const buildings = await prisma.building.findMany({
    where: { siteId },
    orderBy: { createdAt: "asc" },
    include: {
      _count: { select: { apartments: true } },
      apartments: {
        where: { resident: { isNot: null } },
        select: { id: true },
      },
      site: true,
    },
  });

  return buildings.map((building) => {
    const { apartments, ...rest } = building;
    return resolveEffectiveBuildingConfig({
      ...rest,
      occupiedApartments: apartments.length,
    });
  });
};
