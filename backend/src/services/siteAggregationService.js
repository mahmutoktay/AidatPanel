import { prisma } from "../config/db.js";
import { assertManagerOwnsSite } from "../utils/access.js";
import { summarizeDues } from "../utils/reportAggregation.js";

export async function getSiteAggregationService(siteId, managerId, { month, year }) {
  await assertManagerOwnsSite(siteId, managerId);

  const m = parseInt(String(month), 10);
  const y = parseInt(String(year), 10);

  const buildingIds = (
    await prisma.building.findMany({
      where: { siteId },
      select: { id: true },
    })
  ).map((b) => b.id);

  if (buildingIds.length === 0) {
    return {
      month: m,
      year: y,
      collectedAmount: 0,
      expectedAmount: 0,
      currency: "TRY",
    };
  }

  const dues = await prisma.due.findMany({
    where: {
      apartment: { buildingId: { in: buildingIds } },
      month: m,
      year: y,
    },
    select: { amount: true, status: true, currency: true },
  });

  const summary = summarizeDues(dues);
  const currency = dues[0]?.currency ?? "TRY";

  return {
    month: m,
    year: y,
    collectedAmount: summary.collected,
    expectedAmount: summary.expected,
    currency,
  };
}
