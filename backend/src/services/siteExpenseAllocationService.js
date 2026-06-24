import { prisma } from "../config/db.js";

export async function getSiteApartmentCount(siteId, db = prisma) {
  return db.apartment.count({
    where: { building: { siteId } },
  });
}

export async function getSiteBuildingIds(siteId, db = prisma) {
  const buildings = await db.building.findMany({
    where: { siteId },
    select: { id: true },
  });
  return buildings.map((b) => b.id);
}

export async function recalculateAllSiteBuildingsForMonth(siteId, month, year, db = prisma) {
  const { recalculateBuildingDuesForMonth } = await import("./dueExpenseRecalcService.js");
  const buildingIds = await getSiteBuildingIds(siteId, db);
  let total = 0;
  for (const buildingId of buildingIds) {
    const result = await recalculateBuildingDuesForMonth(buildingId, month, year, db);
    total += result.updated;
  }
  return { updated: total, buildingCount: buildingIds.length };
}
