import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { logger } from "../config/logger.js";
import { assertManagerOwnsSite } from "../utils/access.js";
import {
  collectionFieldsFromBody,
  createBuildingService,
  deleteBuildingService,
} from "./buildingService.js";
import {
  enrichBuildingWithEffective,
  resolveEffectiveBuildingConfig,
} from "./buildingConfigService.js";
import { assertCanAddBuilding } from "./buildingQuotaService.js";
import { getSiteAggregationService } from "./siteAggregationService.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";

export async function createSiteService(data, managerId) {
  const collectionData = collectionFieldsFromBody({
    collectionIban: data.collectionIban,
    collectionAccountTitle: data.collectionAccountTitle,
    paymentReferenceTemplate: data.paymentReferenceTemplate,
  });

  return prisma.site.create({
    data: {
      name: data.name,
      address: data.address,
      city: data.city,
      managerId,
      dueAmount: data.dueAmount ?? null,
      dueDay: data.dueDay ?? 1,
      currency: data.currency ?? "TRY",
      ...collectionData,
    },
  });
}

export async function getSitesService(managerId, filters = {}) {
  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
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
    orderBy: paginated ? [{ createdAt: "desc" }, { id: "desc" }] : [{ createdAt: "desc" }],
    take,
    include: {
      _count: { select: { buildings: true } },
      buildings: {
        include: {
          apartments: {
            where: { resident: { isNot: null } },
            select: { id: true },
          },
          _count: { select: { apartments: true } },
        },
      },
    },
  });

  const now = new Date();
  const month = now.getMonth() + 1;
  const year = now.getFullYear();

  const mapped = await Promise.all(
    sites.map(async (site) => {
      const buildingCount = site._count.buildings;
      let totalApartments = 0;
      let occupiedApartments = 0;
      for (const b of site.buildings) {
        totalApartments += b._count.apartments;
        occupiedApartments += b.apartments.length;
      }

      let collectedAmount = 0;
      let expectedAmount = 0;
      try {
        const agg = await getSiteAggregationService(site.id, managerId, { month, year });
        collectedAmount = agg.collectedAmount;
        expectedAmount = agg.expectedAmount;
      } catch (err) {
        logger.warn({ siteId: site.id, err: err.message }, "Site aggregation hesaplanamadi");
      }

      const { buildings, _count, ...rest } = site;
      return {
        ...rest,
        buildingCount,
        totalApartments,
        occupiedApartments,
        collectedAmount,
        expectedAmount,
      };
    })
  );

  return buildListResponse(filters, mapped, (s) => s);
}

export async function getSiteByIdService(id, managerId) {
  const site = await assertManagerOwnsSite(id, managerId);
  const buildings = await prisma.building.findMany({
    where: { siteId: id },
    include: {
      _count: { select: { apartments: true } },
      apartments: {
        where: { resident: { isNot: null } },
        select: { id: true },
      },
      site: true,
    },
    orderBy: { createdAt: "asc" },
  });

  const enrichedBuildings = await Promise.all(
    buildings.map(async (b) => {
      const { apartments, _count, site: siteRel, ...rest } = b;
      const effective = await resolveEffectiveBuildingConfig(b);
      return {
        ...rest,
        occupiedApartments: apartments.length,
        totalApartments: _count.apartments,
        ...effective,
        displayName: effective.displayName,
      };
    })
  );

  const now = new Date();
  const aggregation = await getSiteAggregationService(id, managerId, {
    month: now.getMonth() + 1,
    year: now.getFullYear(),
  });

  return {
    ...site,
    buildings: enrichedBuildings,
    aggregation,
  };
}

export async function updateSiteService(id, managerId, data) {
  await assertManagerOwnsSite(id, managerId);
  return prisma.site.update({ where: { id }, data });
}

export async function deleteSiteService(id, managerId) {
  await assertManagerOwnsSite(id, managerId);

  const buildings = await prisma.building.findMany({
    where: { siteId: id },
    select: { id: true },
  });

  await Promise.all(
    buildings.map((b) => deleteBuildingService(b.id, managerId))
  );

  await prisma.siteExpense.deleteMany({ where: { siteId: id } });

  return prisma.site.delete({ where: { id } });
}

export async function updateSiteCollectionService(id, managerId, body) {
  await assertManagerOwnsSite(id, managerId);
  const data = collectionFieldsFromBody(body);
  return prisma.site.update({ where: { id }, data });
}

export async function createSiteBuildingService(siteId, managerId, body) {
  const site = await assertManagerOwnsSite(siteId, managerId);
  await assertCanAddBuilding(managerId);

  const blockLabel = String(body.blockLabel).trim();
  const name = body.name?.trim() ? body.name.trim() : blockLabel;

  const address = site.address;
  const city = site.city;

  const building = await createBuildingService({
    name,
    address,
    city,
    totalFloors: body.totalFloors,
    apartmentsPerFloor: body.apartmentsPerFloor,
    dueAmount: body.dueAmount ?? undefined,
    dueDay: body.dueDay ?? site.dueDay,
    currency: body.currency ?? site.currency,
    managerId,
    siteId,
    blockLabel,
    addressExtra: body.addressExtra ?? null,
    collectionIban: body.collectionIban ?? undefined,
    collectionAccountTitle: body.collectionAccountTitle ?? undefined,
    paymentReferenceTemplate: body.paymentReferenceTemplate ?? undefined,
    inheritFromSite: true,
    siteDefaults: site,
  });

  return enrichBuildingWithEffective(building);
}

export async function getSiteBuildingsService(siteId, managerId) {
  await assertManagerOwnsSite(siteId, managerId);
  const buildings = await prisma.building.findMany({
    where: { siteId },
    include: {
      _count: { select: { apartments: true } },
      apartments: {
        where: { resident: { isNot: null } },
        select: { id: true },
      },
      site: true,
    },
    orderBy: { createdAt: "asc" },
  });

  return Promise.all(
    buildings.map(async (b) => {
      const { apartments, _count, site, ...rest } = b;
      return enrichBuildingWithEffective({
        ...rest,
        site,
        occupiedApartments: apartments.length,
        totalApartments: _count.apartments,
      });
    })
  );
}
