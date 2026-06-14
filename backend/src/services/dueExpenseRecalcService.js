import { prisma } from "../config/db.js";
import { bulkGenerateBuildingDuesService } from "./dueBulkService.js";
import { getIstanbulYearMonth } from "../utils/trDueDate.js";

export function roundMoney(value) {
  return Math.round(Number(value) * 100) / 100;
}

export function nextPeriod(month, year) {
  const m = parseInt(String(month), 10);
  const y = parseInt(String(year), 10);
  if (m === 12) return { month: 1, year: y + 1 };
  return { month: m + 1, year: y };
}

export function addMonthsFrom(month, year, offset) {
  let m = parseInt(String(month), 10);
  let y = parseInt(String(year), 10);
  for (let i = 0; i < offset; i += 1) {
    ({ month: m, year: y } = nextPeriod(m, y));
  }
  return { month: m, year: y };
}

/**
 * Toplam tutarı N aya eşit böler; kuruş farkı son aya eklenir.
 */
export function splitAmount(totalAmount, parts) {
  const n = Math.max(1, parseInt(String(parts), 10));
  const total = Number(totalAmount);
  if (n === 1) return [roundMoney(total)];

  const base = Math.floor((total / n) * 100) / 100;
  const amounts = Array.from({ length: n }, () => base);
  const sumExceptLast = base * (n - 1);
  amounts[n - 1] = roundMoney(total - sumExceptLast);
  return amounts;
}

export function computePerUnitAmount(totalAmount, apartmentCount) {
  if (!apartmentCount || apartmentCount <= 0) {
    return 0;
  }
  return roundMoney(Number(totalAmount) / apartmentCount);
}

export function isPastTargetMonth(targetMonth, targetYear, now = new Date()) {
  const { year, month } = getIstanbulYearMonth(now);
  const ty = parseInt(String(targetYear), 10);
  const tm = parseInt(String(targetMonth), 10);
  if (ty < year) return true;
  if (ty === year && tm < month) return true;
  return false;
}

function formatBreakdownMoney(value) {
  return roundMoney(value).toFixed(2);
}

async function loadBuildingExpensesForMonth(db, buildingId, month, year) {
  return db.expense.findMany({
    where: {
      buildingId,
      targetMonth: parseInt(String(month), 10),
      targetYear: parseInt(String(year), 10),
      perUnitAmount: { not: null },
    },
    orderBy: { createdAt: "asc" },
    select: {
      id: true,
      title: true,
      perUnitAmount: true,
    },
  });
}

async function loadCarryforwardsForApartment(db, apartmentId, month, year) {
  return db.dueExpenseCarryforward.findMany({
    where: {
      apartmentId,
      toMonth: parseInt(String(month), 10),
      toYear: parseInt(String(year), 10),
    },
    include: {
      expense: { select: { title: true } },
    },
    orderBy: { createdAt: "asc" },
  });
}

/**
 * Daire + ay için aidat breakdown (baz + gider payları + devreden).
 */
export async function computeDueBreakdown(apartmentId, month, year, buildingId, db = prisma) {
  const building = await db.building.findUnique({
    where: { id: buildingId },
    select: { dueAmount: true, currency: true },
  });

  const baseAmount = building?.dueAmount != null ? Number(building.dueAmount) : 0;
  const expenses = await loadBuildingExpensesForMonth(db, buildingId, month, year);
  const carryforwards = await loadCarryforwardsForApartment(db, apartmentId, month, year);

  const expenseLines = expenses.map((e) => ({
    title: e.title,
    amount: formatBreakdownMoney(e.perUnitAmount),
    kind: "EXPENSE",
  }));

  const carryLines = carryforwards.map((c) => ({
    title: `Önceki aydan devreden — ${c.expense.title}`,
    amount: formatBreakdownMoney(c.amount),
    kind: "CARRYFORWARD",
  }));

  const allLines = [...expenseLines, ...carryLines];
  const extras = allLines.reduce((sum, line) => sum + Number(line.amount), 0);
  const total = roundMoney(baseAmount + extras);

  return {
    baseAmount: formatBreakdownMoney(baseAmount),
    expenseLines: allLines,
    total: formatBreakdownMoney(total),
    currency: building?.currency ?? "TRY",
  };
}

export async function ensureDuesForMonth(buildingId, month, year, db = prisma) {
  await bulkGenerateBuildingDuesService(
    buildingId,
    {},
    { month: parseInt(String(month), 10), year: parseInt(String(year), 10) }
  );
}

/**
 * Binadaki PENDING/OVERDUE aidatları hedef ay için yeniden hesaplar.
 */
export async function recalculateBuildingDuesForMonth(buildingId, month, year, db = prisma) {
  const m = parseInt(String(month), 10);
  const y = parseInt(String(year), 10);

  const building = await db.building.findUnique({
    where: { id: buildingId },
    select: { dueAmount: true, currency: true },
  });

  if (building?.dueAmount == null) {
    return { updated: 0 };
  }

  await ensureDuesForMonth(buildingId, m, y, db);

  const apartments = await db.apartment.findMany({
    where: { buildingId },
    select: { id: true },
  });

  let updated = 0;

  for (const apt of apartments) {
    const due = await db.due.findFirst({
      where: { apartmentId: apt.id, month: m, year: y },
    });
    if (!due) continue;
    if (due.status === "PAID" || due.status === "WAIVED") continue;

    const breakdown = await computeDueBreakdown(apt.id, m, y, buildingId, db);

    await db.due.update({
      where: { id: due.id },
      data: {
        amount: breakdown.total,
        currency: building.currency ?? "TRY",
      },
    });
    updated += 1;
  }

  return { updated };
}

export async function getPaidApartmentsForMonth(buildingId, month, year, db = prisma) {
  const paidDues = await db.due.findMany({
    where: {
      apartment: { buildingId },
      month: parseInt(String(month), 10),
      year: parseInt(String(year), 10),
      status: "PAID",
    },
    select: { apartmentId: true },
  });
  return paidDues.map((d) => d.apartmentId);
}

/**
 * PAID daireler varsa yöneticiye gösterilecek önizleme.
 */
export async function previewPaidImpact(buildingId, targetMonth, targetYear, perUnitAmount) {
  const paidCount = (await getPaidApartmentsForMonth(buildingId, targetMonth, targetYear)).length;
  if (paidCount === 0) return null;

  const unit = roundMoney(perUnitAmount);
  const totalUnpaidShare = roundMoney(unit * paidCount);
  const next = nextPeriod(targetMonth, targetYear);

  return {
    requiresConfirmation: true,
    paidApartmentCount: paidCount,
    perUnitAmount: unit.toFixed(2),
    totalUnpaidShare: totalUnpaidShare.toFixed(2),
    message: `${paidCount} daire bu ay aidatını zaten ödedi. Bu daireler için ₺${totalUnpaidShare.toFixed(2)} fark, bir sonraki aya borç olarak eklensin mi?`,
    nextPeriod: next,
  };
}

/**
 * Tek gider için carry-forward uygular (CARRY_TO_NEXT_MONTH).
 */
export async function applyCarryForwardForExpense(expense, carryForwardPolicy, db = prisma) {
  if (carryForwardPolicy !== "CARRY_TO_NEXT_MONTH") {
    return { carryForwardCount: 0 };
  }

  const paidApartmentIds = await getPaidApartmentsForMonth(
    expense.buildingId,
    expense.targetMonth,
    expense.targetYear,
    db
  );

  if (paidApartmentIds.length === 0) {
    return { carryForwardCount: 0 };
  }

  const next = nextPeriod(expense.targetMonth, expense.targetYear);
  await ensureDuesForMonth(expense.buildingId, next.month, next.year, db);

  const perUnit = Number(expense.perUnitAmount);

  for (const apartmentId of paidApartmentIds) {
    await db.dueExpenseCarryforward.upsert({
      where: {
        expenseId_apartmentId: {
          expenseId: expense.id,
          apartmentId,
        },
      },
      create: {
        expenseId: expense.id,
        apartmentId,
        fromMonth: expense.targetMonth,
        fromYear: expense.targetYear,
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

  await recalculateBuildingDuesForMonth(expense.buildingId, next.month, next.year, db);

  return { carryForwardCount: paidApartmentIds.length };
}

export async function removeCarryforwardsForExpense(expenseId, db = prisma) {
  const rows = await db.dueExpenseCarryforward.findMany({
    where: { expenseId },
    select: { toMonth: true, toYear: true, apartment: { select: { buildingId: true } } },
  });

  await db.dueExpenseCarryforward.deleteMany({ where: { expenseId } });

  const periods = new Map();
  let buildingId = null;
  for (const row of rows) {
    buildingId = row.apartment.buildingId;
    periods.set(`${row.toYear}-${row.toMonth}`, { month: row.toMonth, year: row.toYear });
  }

  if (buildingId) {
    for (const { month, year } of periods.values()) {
      await recalculateBuildingDuesForMonth(buildingId, month, year, db);
    }
  }
}

export async function getApartmentCount(buildingId, db = prisma) {
  return db.apartment.count({ where: { buildingId } });
}

export function serializeBreakdownForDue(breakdown) {
  return {
    baseAmount: breakdown.baseAmount,
    expenseLines: breakdown.expenseLines,
    total: breakdown.total,
  };
}
