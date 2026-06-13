import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { getIstanbulYearMonth } from "../utils/trDueDate.js";
import {
  buildDueRowsFromMonth,
  buildSingleDueRow,
  dueLookupKeys,
  filterNewDueRows,
} from "../utils/dueGeneration.js";
import { assertManagerOwnsBuilding } from "../utils/access.js";

/**
 * Binadaki daireler için eksik aidatları oluşturur (mevcut ay/yıl kombinasyonlarını atlar).
 *
 * @param {string} buildingId
 * @param {{ managerId?: string }} ctx — managerId verilirse sahiplik kontrolü
 * @param {{ month?: number, year?: number }} [period] — ikisi de verilirse yalnızca o ay; aksi halde bulunulan ay → yıl sonu
 */
export async function bulkGenerateBuildingDuesService(buildingId, ctx = {}, period = {}) {
  const building = ctx.managerId
    ? await assertManagerOwnsBuilding(buildingId, ctx.managerId)
    : await prisma.building.findUnique({ where: { id: buildingId } });

  if (!building) {
    if (ctx.managerId) {
      throw new HttpError(404, "Bina bulunamadı veya erişim yetkiniz yok.");
    }
    return null;
  }

  if (!building.dueAmount) {
    return {
      buildingId,
      created: 0,
      skipped: 0,
      message: "Binada aidat tutarı tanımlı değil.",
    };
  }

  const istanbul = getIstanbulYearMonth();
  const targetYear = period.year ?? istanbul.year;
  const singleMonth =
    period.month != null && period.year != null ? period.month : null;
  const fromMonth = singleMonth ?? istanbul.month;

  const apartments = await prisma.apartment.findMany({
    where: { buildingId },
    select: { id: true },
  });

  if (apartments.length === 0) {
    return {
      buildingId,
      created: 0,
      skipped: 0,
      year: targetYear,
      fromMonth: singleMonth ?? fromMonth,
      toMonth: singleMonth ?? 12,
    };
  }

  const apartmentIds = apartments.map((a) => a.id);

  const existing = await prisma.due.findMany({
    where: {
      apartmentId: { in: apartmentIds },
      year: targetYear,
      month: singleMonth != null ? singleMonth : { gte: fromMonth, lte: 12 },
    },
    select: { apartmentId: true, month: true },
  });

  const existingKeys = dueLookupKeys(existing);

  let candidateRows;
  if (singleMonth != null) {
    candidateRows = apartmentIds.map((apartmentId) =>
      buildSingleDueRow(apartmentId, singleMonth, targetYear, {
        dueAmount: building.dueAmount,
        dueDay: building.dueDay,
        currency: building.currency,
      })
    );
  } else {
    candidateRows = buildDueRowsFromMonth(apartmentIds, fromMonth, targetYear, {
      dueAmount: building.dueAmount,
      dueDay: building.dueDay,
      currency: building.currency,
    });
  }

  const newRows = filterNewDueRows(candidateRows, existingKeys);

  if (newRows.length > 0) {
    await prisma.due.createMany({ data: newRows });
  }

  return {
    buildingId,
    created: newRows.length,
    skipped: existing.length,
    year: targetYear,
    fromMonth: singleMonth ?? fromMonth,
    toMonth: singleMonth ?? 12,
  };
}

/**
 * Aidat tutarı tanımlı tüm binalar için otomatik eksik aidat tamamlama (cron/job).
 */
export async function autoGenerateAllBuildingDuesService() {
  const buildings = await prisma.building.findMany({
    where: { dueAmount: { not: null } },
    select: { id: true },
  });

  let totalCreated = 0;
  const results = [];

  for (const { id } of buildings) {
    const outcome = await bulkGenerateBuildingDuesService(id);
    if (!outcome) continue;
    totalCreated += outcome.created;
    if (outcome.created > 0) {
      results.push(outcome);
    }
  }

  return { totalCreated, buildingsProcessed: buildings.length, results };
}
