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
import { userPublicSelect } from "./meService.js";

async function loadOccupiedApartments(buildingId, apartmentIds = null) {
  const where = {
    buildingId,
    resident: { isNot: null },
    ...(apartmentIds ? { id: { in: apartmentIds } } : {}),
  };

  return prisma.apartment.findMany({
    where,
    select: {
      id: true,
      resident: { select: userPublicSelect },
    },
  });
}

function toApartmentEntries(apartments) {
  return apartments.map((apartment) => ({
    id: apartment.id,
    residentName: apartment.resident?.name ?? null,
  }));
}

/**
 * Binadaki sakinli daireler için eksik aidatları oluşturur.
 *
 * @param {string} buildingId
 * @param {{ managerId?: string }} ctx — managerId verilirse sahiplik kontrolü
 * @param {{ month?: number, year?: number }} [period] — ikisi de verilirse yalnızca o ay; aksi halde bulunulan ay → yıl sonu
 * @param {{ apartmentIds?: string[] }} [options] — yalnızca belirtilen daireler
 */
export async function bulkGenerateBuildingDuesService(
  buildingId,
  ctx = {},
  period = {},
  options = {}
) {
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

  const apartments = await loadOccupiedApartments(buildingId, options.apartmentIds);

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

  const apartmentEntries = toApartmentEntries(apartments);
  const apartmentIds = apartmentEntries.map((entry) => entry.id);

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
    candidateRows = apartmentEntries.map((entry) =>
      buildSingleDueRow(entry.id, singleMonth, targetYear, {
        dueAmount: building.dueAmount,
        dueDay: building.dueDay,
        currency: building.currency,
        residentNameSnapshot: entry.residentName,
      })
    );
  } else {
    candidateRows = buildDueRowsFromMonth(apartmentEntries, fromMonth, targetYear, {
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
 * Sakin atandığında tek daire için eksik aidatları tamamlar.
 */
export async function ensureApartmentDuesService(apartmentId) {
  const apartment = await prisma.apartment.findUnique({
    where: { id: apartmentId },
    select: { buildingId: true, resident: { select: { id: true } } },
  });

  if (!apartment?.resident) {
    return { created: 0 };
  }

  const outcome = await bulkGenerateBuildingDuesService(
    apartment.buildingId,
    {},
    {},
    { apartmentIds: [apartmentId] }
  );

  return outcome ?? { created: 0 };
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
