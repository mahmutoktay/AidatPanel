import { prisma } from "../config/db.js";
import {
  computePerUnitAmount,
  ensureDuesForMonth,
  getPaidApartmentsForMonth,
  nextPeriod,
  recalculateBuildingDuesForMonth,
  roundMoney,
} from "./dueExpenseRecalcService.js";

/**
 * Sitedeki tüm daire ID'leri (tüm bloklar).
 */
export async function getSiteApartmentIds(siteId, db = prisma) {
  const rows = await prisma.apartment.findMany({
    where: { building: { siteId } },
    select: { id: true, buildingId: true },
  });
  return rows;
}

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

/**
 * Site genelinde belirli ayda PAID olan daireler.
 */
export async function getSitePaidApartmentsForMonth(siteId, month, year, db = prisma) {
  const m = parseInt(String(month), 10);
  const y = parseInt(String(year), 10);

  const paidDues = await db.due.findMany({
    where: {
      status: "PAID",
      month: m,
      year: y,
      apartment: { building: { siteId } },
    },
    select: { apartmentId: true },
  });

  return paidDues.map((d) => d.apartmentId);
}

/**
 * Site gideri eklendikten / güncellendikten sonra tüm blokların açık aidatlarını yeniler.
 */
export async function recalculateSiteDuesForMonth(siteId, month, year, db = prisma) {
  const buildingIds = await getSiteBuildingIds(siteId, db);
  let totalUpdated = 0;

  for (const buildingId of buildingIds) {
    const result = await recalculateBuildingDuesForMonth(buildingId, month, year, db);
    totalUpdated += result.updated ?? 0;
  }

  return { updated: totalUpdated, buildingCount: buildingIds.length };
}

/**
 * Site gideri için carry-forward (site genelinde ödemiş dairelere).
 */
export async function applyCarryForwardForSiteExpense(
  siteExpense,
  carryForwardPolicy,
  db = prisma
) {
  if (carryForwardPolicy !== "CARRY_TO_NEXT_MONTH") {
    return { carryForwardCount: 0 };
  }

  const paidApartmentIds = await getSitePaidApartmentsForMonth(
    siteExpense.siteId,
    siteExpense.targetMonth,
    siteExpense.targetYear,
    db
  );

  if (paidApartmentIds.length === 0) {
    return { carryForwardCount: 0 };
  }

  const next = nextPeriod(siteExpense.targetMonth, siteExpense.targetYear);
  const buildingIds = await getSiteBuildingIds(siteExpense.siteId, db);

  for (const buildingId of buildingIds) {
    await ensureDuesForMonth(buildingId, next.month, next.year, db);
  }

  const perUnit = Number(siteExpense.perUnitAmount);

  for (const apartmentId of paidApartmentIds) {
    await db.dueExpenseCarryforward.upsert({
      where: {
        siteExpenseId_apartmentId: {
          siteExpenseId: siteExpense.id,
          apartmentId,
        },
      },
      create: {
        siteExpenseId: siteExpense.id,
        apartmentId,
        fromMonth: siteExpense.targetMonth,
        fromYear: siteExpense.targetYear,
        toMonth: next.month,
        toYear: next.year,
        amount: perUnit,
      },
      update: {
        amount: perUnit,
        toMonth: next.month,
        toYear: next.year,
      },
    });
  }

  await recalculateSiteDuesForMonth(siteExpense.siteId, next.month, next.year, db);

  return { carryForwardCount: paidApartmentIds.length };
}

export async function removeCarryforwardsForSiteExpense(siteExpenseId, db = prisma) {
  const rows = await db.dueExpenseCarryforward.findMany({
    where: { siteExpenseId },
    select: {
      toMonth: true,
      toYear: true,
      apartment: { select: { building: { select: { siteId: true } } } },
    },
  });

  await db.dueExpenseCarryforward.deleteMany({ where: { siteExpenseId } });

  const periods = new Map();
  let siteId = null;
  for (const row of rows) {
    siteId = row.apartment.building.siteId;
    periods.set(`${row.toYear}-${row.toMonth}`, { month: row.toMonth, year: row.toYear });
  }

  if (siteId) {
    for (const { month, year } of periods.values()) {
      await recalculateSiteDuesForMonth(siteId, month, year, db);
    }
  }
}

export async function previewSitePaidImpact(siteId, targetMonth, targetYear, perUnitAmount) {
  const paidCount = (
    await getSitePaidApartmentsForMonth(siteId, targetMonth, targetYear)
  ).length;
  if (paidCount === 0) return null;

  const unit = roundMoney(perUnitAmount);
  const totalUnpaidShare = roundMoney(unit * paidCount);
  const next = nextPeriod(targetMonth, targetYear);

  return {
    requiresConfirmation: true,
    paidApartmentCount: paidCount,
    perUnitAmount: unit.toFixed(2),
    totalUnpaidShare: totalUnpaidShare.toFixed(2),
    message: `${paidCount} daire bu ay aidatını zaten ödedi. Site gideri payı (₺${totalUnpaidShare.toFixed(2)}) bir sonraki aya borç olarak eklensin mi?`,
    nextPeriod: next,
  };
}

export function computeSitePerUnitAmount(totalAmount, apartmentCount) {
  return computePerUnitAmount(totalAmount, apartmentCount);
}
