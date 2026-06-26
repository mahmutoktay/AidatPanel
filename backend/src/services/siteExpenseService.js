import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { assertManagerOwnsSite, assertManagerOwnsSiteExpense } from "../utils/access.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";
import {
  computePerUnitAmount,
  previewPaidImpactForSite,
  applyCarryForwardForSiteExpense,
  removeCarryforwardsForSiteExpense,
  isPastTargetMonth,
} from "./dueExpenseRecalcService.js";
import { getSiteApartmentCount, recalculateAllSiteBuildingsForMonth } from "./siteExpenseAllocationService.js";

function serializeSiteExpense(expense) {
  return {
    ...expense,
    amount: expense.amount != null ? Number(expense.amount) : null,
    perUnitAmount: expense.perUnitAmount != null ? Number(expense.perUnitAmount) : null,
    parsedAmount: expense.parsedAmount != null ? Number(expense.parsedAmount) : null,
  };
}

function buildListWhere(siteId, filters) {
  const where = { siteId };
  const { month, year, category } = filters;
  if (month && year) {
    where.targetMonth = parseInt(String(month), 10);
    where.targetYear = parseInt(String(year), 10);
  } else if (year) {
    where.targetYear = parseInt(String(year), 10);
  }
  if (category) where.category = category;
  return where;
}

export async function listSiteExpensesService(siteId, managerId, filters = {}) {
  await assertManagerOwnsSite(siteId, managerId);

  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = buildListWhere(siteId, filters);

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.siteExpense.findFirst({
        where: { id, siteId },
        select: { id: true, createdAt: true },
      })
    );
  }

  const expenses = await prisma.siteExpense.findMany({
    where,
    orderBy: paginated
      ? [{ createdAt: "desc" }, { id: "desc" }]
      : [{ targetYear: "desc" }, { targetMonth: "desc" }],
    take,
  });

  return buildListResponse(filters, expenses, serializeSiteExpense);
}

export async function getSiteExpenseSummaryService(siteId, managerId, { month, year }) {
  const site = await assertManagerOwnsSite(siteId, managerId);
  const m = parseInt(String(month), 10);
  const y = parseInt(String(year), 10);

  const groups = await prisma.siteExpense.groupBy({
    by: ["category"],
    where: { siteId, targetMonth: m, targetYear: y },
    _sum: { amount: true },
    _count: { _all: true },
  });

  let total = 0;
  const byCategory = groups.map((g) => {
    const amount = g._sum.amount ? Number(g._sum.amount) : 0;
    total += amount;
    return {
      category: g.category,
      amount: Number(amount.toFixed(2)),
      count: g._count._all,
    };
  });

  return {
    siteId: site.id,
    month: m,
    year: y,
    currency: site.currency ?? "TRY",
    totalAmount: Number(total.toFixed(2)),
    byCategory,
  };
}

export async function createSiteExpenseService(
  siteId,
  managerId,
  body,
  { carryForwardPolicy = "NONE", confirmPaidImpact = false } = {}
) {
  await assertManagerOwnsSite(siteId, managerId);

  const apartmentCount = await getSiteApartmentCount(siteId);
  if (apartmentCount <= 0) {
    throw new HttpError(400, "Site altında daire bulunamadı. Önce blok ekleyin.");
  }

  const {
    title,
    amount,
    category,
    date,
    note,
    targetMonth,
    targetYear,
  } = body;

  const perUnitAmount = computePerUnitAmount(amount, apartmentCount);

  if (!confirmPaidImpact) {
    const preview = await previewPaidImpactForSite(
      siteId,
      targetMonth,
      targetYear,
      perUnitAmount
    );
    if (preview) {
      return {
        preview: {
          ...preview,
          pastMonthWarning: isPastTargetMonth(targetMonth, targetYear),
        },
      };
    }
  }

  const expense = await prisma.siteExpense.create({
    data: {
      siteId,
      title,
      amount,
      category,
      date: new Date(date),
      note: note ?? null,
      targetMonth,
      targetYear,
      perUnitAmount,
      storedPaths: [],
    },
  });

  await recalculateAllSiteBuildingsForMonth(siteId, targetMonth, targetYear);

  const carryResult = await applyCarryForwardForSiteExpense(
    expense,
    carryForwardPolicy
  );

  return {
    expense: serializeSiteExpense(expense),
    warnings: isPastTargetMonth(targetMonth, targetYear)
      ? ["Geçmiş bir aya site gideri eklendi. Aidat tutarları güncellendi."]
      : [],
    carryForwardCount: carryResult.carryForwardCount,
  };
}

export async function updateSiteExpenseService(expenseId, managerId, body) {
  const existing = await assertManagerOwnsSiteExpense(expenseId, managerId);
  const apartmentCount = await getSiteApartmentCount(existing.siteId);
  const amount = body.amount != null ? body.amount : existing.amount;
  const perUnitAmount =
    amount != null ? computePerUnitAmount(Number(amount), apartmentCount) : null;

  const expense = await prisma.siteExpense.update({
    where: { id: expenseId },
    data: {
      ...body,
      amount: amount != null ? amount : undefined,
      perUnitAmount,
      date: body.date ? new Date(body.date) : undefined,
    },
  });

  await removeCarryforwardsForSiteExpense(expenseId);
  await recalculateAllSiteBuildingsForMonth(
    existing.siteId,
    existing.targetMonth,
    existing.targetYear
  );

  return serializeSiteExpense(expense);
}

export async function deleteSiteExpenseService(expenseId, managerId) {
  const existing = await assertManagerOwnsSiteExpense(expenseId, managerId);
  await removeCarryforwardsForSiteExpense(expenseId);
  await prisma.siteExpense.delete({ where: { id: expenseId } });
  await recalculateAllSiteBuildingsForMonth(
    existing.siteId,
    existing.targetMonth,
    existing.targetYear
  );
}
