import { randomUUID } from "node:crypto";
import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { assertManagerOwnsSite } from "../utils/access.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";
import {
  addMonthsFrom,
  isPastTargetMonth,
  splitAmount,
} from "./dueExpenseRecalcService.js";
import {
  applyCarryForwardForSiteExpense,
  computeSitePerUnitAmount,
  getSiteApartmentCount,
  previewSitePaidImpact,
  recalculateSiteDuesForMonth,
  removeCarryforwardsForSiteExpense,
} from "./siteExpenseAllocationService.js";

function serializeSiteExpense(expense) {
  return {
    ...expense,
    amount:
      expense.amount != null
        ? (expense.amount?.toString?.() ?? String(expense.amount))
        : null,
    perUnitAmount:
      expense.perUnitAmount != null
        ? (expense.perUnitAmount?.toString?.() ?? String(expense.perUnitAmount))
        : null,
    parsedAmount:
      expense.parsedAmount != null
        ? (expense.parsedAmount?.toString?.() ?? String(expense.parsedAmount))
        : null,
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

  if (category) {
    where.category = category;
  }

  return where;
}

function buildSplitTargets(targetMonth, targetYear, splitMonths) {
  const parts = Math.max(1, Math.min(12, parseInt(String(splitMonths), 10) || 1));
  const targets = [];
  for (let i = 0; i < parts; i += 1) {
    targets.push(addMonthsFrom(targetMonth, targetYear, i));
  }
  return targets;
}

async function createSingleSiteExpenseWithRecalc(
  siteId,
  payload,
  { carryForwardPolicy, confirmPaidImpact, apartmentCount, splitGroupId, sourceExpenseId }
) {
  const { title, amount, category, date, note, targetMonth, targetYear } = payload;

  const hasAmount =
    amount != null && !Number.isNaN(Number(amount)) && Number(amount) > 0;
  const perUnitAmount = hasAmount
    ? computeSitePerUnitAmount(amount, apartmentCount)
    : null;

  if (!confirmPaidImpact && hasAmount) {
    const preview = await previewSitePaidImpact(
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
      amount: hasAmount ? amount : null,
      category,
      date: new Date(date),
      note: note ?? null,
      targetMonth,
      targetYear,
      perUnitAmount,
      splitGroupId: splitGroupId ?? null,
      sourceExpenseId: sourceExpenseId ?? null,
      storedPaths: [],
    },
  });

  if (hasAmount) {
    await recalculateSiteDuesForMonth(siteId, targetMonth, targetYear);
  }

  const carryResult = hasAmount
    ? await applyCarryForwardForSiteExpense(expense, carryForwardPolicy)
    : { carryForwardCount: 0 };

  const warnings = [];
  if (hasAmount && isPastTargetMonth(targetMonth, targetYear)) {
    warnings.push("Geçmiş bir aya site gideri eklendi. Aidat tutarları güncellendi.");
  }
  if (
    hasAmount &&
    carryForwardPolicy === "WARN_ONLY" &&
    carryResult.carryForwardCount === 0
  ) {
    const paidPreview = await previewSitePaidImpact(
      siteId,
      targetMonth,
      targetYear,
      perUnitAmount
    );
    if (paidPreview) {
      warnings.push(paidPreview.message);
    }
  }

  return {
    expense: serializeSiteExpense(expense),
    warnings,
    carryForwardCount: carryResult.carryForwardCount,
    pastMonthWarning: isPastTargetMonth(targetMonth, targetYear),
  };
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

  const orderBy = paginated
    ? [{ createdAt: "desc" }, { id: "desc" }]
    : [{ targetYear: "desc" }, { targetMonth: "desc" }];

  const expenses = await prisma.siteExpense.findMany({
    where,
    orderBy,
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
      amount: amount.toFixed(2),
      count: g._count._all,
    };
  });

  return {
    month: m,
    year: y,
    totalAmount: total.toFixed(2),
    currency: site.currency ?? "TRY",
    byCategory,
    apartmentCount: await getSiteApartmentCount(siteId),
  };
}

export async function createSiteExpenseService(siteId, managerId, body) {
  await assertManagerOwnsSite(siteId, managerId);

  const {
    title,
    amount,
    category,
    date,
    note,
    targetMonth,
    targetYear,
    splitMonths = 1,
    carryForwardPolicy = "WARN_ONLY",
    confirmPaidImpact = false,
  } = body;

  const apartmentCount = await getSiteApartmentCount(siteId);
  if (apartmentCount === 0) {
    throw new HttpError(400, "Sitede daire bulunmuyor. Önce blok ve daire ekleyin.");
  }

  const hasAmount =
    amount != null && !Number.isNaN(Number(amount)) && Number(amount) > 0;

  const targets = buildSplitTargets(targetMonth, targetYear, splitMonths);
  if (targets.length > 1 && !hasAmount) {
    throw new HttpError(400, "Tutar olmadan site gideri aylara bölünemez.");
  }

  const splitAmounts = hasAmount ? splitAmount(amount, targets.length) : [null];
  const splitGroupId = targets.length > 1 ? randomUUID() : null;

  if (!confirmPaidImpact && targets.length === 1 && hasAmount) {
    const perUnit = computeSitePerUnitAmount(amount, apartmentCount);
    const preview = await previewSitePaidImpact(
      siteId,
      targetMonth,
      targetYear,
      perUnit
    );
    if (preview) {
      return { preview: { ...preview, pastMonthWarning: isPastTargetMonth(targetMonth, targetYear) } };
    }
  }

  const created = [];
  const allWarnings = [];

  for (let i = 0; i < targets.length; i += 1) {
    const target = targets[i];
    const partAmount = splitAmounts[i];
    const partTitle =
      targets.length > 1 ? `${title} (${i + 1}/${targets.length})` : title;

    const result = await createSingleSiteExpenseWithRecalc(
      siteId,
      {
        title: partTitle,
        amount: partAmount,
        category,
        date,
        note,
        targetMonth: target.month,
        targetYear: target.year,
      },
      {
        carryForwardPolicy,
        confirmPaidImpact: true,
        apartmentCount,
        splitGroupId,
        sourceExpenseId: i === 0 ? null : created[0]?.id,
      }
    );

    if (result.preview) {
      return result;
    }

    created.push(result.expense);
    if (result.warnings?.length) {
      allWarnings.push(...result.warnings);
    }
  }

  return {
    expenses: created,
    expense: created[0],
    warnings: allWarnings,
    pastMonthWarning: isPastTargetMonth(targetMonth, targetYear),
    splitGroupId,
  };
}

export async function updateSiteExpenseService(expenseId, managerId, data) {
  const existing = await prisma.siteExpense.findFirst({
    where: { id: expenseId, site: { managerId } },
  });
  if (!existing) {
    throw new HttpError(404, "Site gideri bulunamadı.");
  }

  const updateData = {};
  if (data.title !== undefined) updateData.title = data.title;
  if (data.amount !== undefined) updateData.amount = data.amount;
  if (data.category !== undefined) updateData.category = data.category;
  if (data.date !== undefined) updateData.date = new Date(data.date);
  if (data.note !== undefined) updateData.note = data.note;
  if (data.targetMonth !== undefined) updateData.targetMonth = data.targetMonth;
  if (data.targetYear !== undefined) updateData.targetYear = data.targetYear;

  const apartmentCount = await getSiteApartmentCount(existing.siteId);
  const nextAmount =
    data.amount !== undefined ? data.amount : Number(existing.amount);
  if (nextAmount != null && !Number.isNaN(nextAmount)) {
    updateData.perUnitAmount = computeSitePerUnitAmount(nextAmount, apartmentCount);
  }

  const oldMonth = existing.targetMonth;
  const oldYear = existing.targetYear;

  const expense = await prisma.siteExpense.update({
    where: { id: expenseId },
    data: updateData,
  });

  await recalculateSiteDuesForMonth(expense.siteId, expense.targetMonth, expense.targetYear);
  if (expense.targetMonth !== oldMonth || expense.targetYear !== oldYear) {
    await recalculateSiteDuesForMonth(existing.siteId, oldMonth, oldYear);
  }

  return serializeSiteExpense(expense);
}

export async function deleteSiteExpenseService(expenseId, managerId) {
  const expense = await prisma.siteExpense.findFirst({
    where: { id: expenseId, site: { managerId } },
  });
  if (!expense) {
    throw new HttpError(404, "Site gideri bulunamadı.");
  }

  const { targetMonth, targetYear, siteId } = expense;

  await removeCarryforwardsForSiteExpense(expenseId);
  await prisma.siteExpense.delete({ where: { id: expenseId } });
  await recalculateSiteDuesForMonth(siteId, targetMonth, targetYear);

  return { id: expenseId };
}
