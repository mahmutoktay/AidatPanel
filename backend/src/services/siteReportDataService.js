import { prisma } from "../config/db.js";
import { assertManagerOwnsSite } from "../utils/access.js";
import { monthYearRange, yearRange } from "../utils/reportPeriod.js";
import {
  summarizeDues,
  computeNet,
  resolveExpenseAmount,
  toMoneyDecimal,
} from "../utils/reportAggregation.js";
import { EXPENSE_CATEGORY_LABELS } from "../constants/reportLabels.js";
import { formatMoney } from "../utils/reportFormat.js";

function computeExpenseSummary(expenses, currency) {
  const byCategoryMap = new Map();
  let totalKnown = 0;
  let uncalculatedCount = 0;

  for (const expense of expenses) {
    const amount = resolveExpenseAmount(expense);
    if (amount == null) {
      uncalculatedCount += 1;
      continue;
    }
    totalKnown += amount;
    const cat = expense.category;
    const prev = byCategoryMap.get(cat) ?? { amount: 0, count: 0 };
    byCategoryMap.set(cat, { amount: prev.amount + amount, count: prev.count + 1 });
  }

  const byCategory = [...byCategoryMap.entries()]
    .map(([category, v]) => ({
      category,
      label: EXPENSE_CATEGORY_LABELS[category] ?? category,
      amount: v.amount,
      amountFormatted: formatMoney(v.amount, currency),
      count: v.count,
    }))
    .sort((a, b) => b.amount - a.amount);

  const items = expenses.slice(0, 25).map((e) => {
    const amount = resolveExpenseAmount(e);
    return {
      id: e.id,
      title: e.title,
      category: e.category,
      categoryLabel: EXPENSE_CATEGORY_LABELS[e.category] ?? e.category,
      date: e.date.toISOString(),
      amount,
      amountFormatted:
        amount != null ? formatMoney(amount, currency) : "Hesaplanmadi",
      scope: e.siteId ? "site" : "building",
    };
  });

  return {
    totalAmount: totalKnown,
    totalAmountFormatted: formatMoney(totalKnown, currency),
    uncalculatedCount,
    byCategory,
    items,
    totalCount: expenses.length,
  };
}

async function loadSiteContext(siteId, managerId) {
  const site = await assertManagerOwnsSite(siteId, managerId);
  const manager = await prisma.user.findFirst({
    where: { id: managerId, deletedAt: null },
    select: { name: true },
  });

  const buildings = await prisma.building.findMany({
    where: { siteId },
    select: { id: true, name: true, blockLabel: true },
    orderBy: { createdAt: "asc" },
  });

  const apartments = await prisma.apartment.findMany({
    where: { building: { siteId } },
    include: {
      resident: { select: { name: true, deletedAt: true } },
      building: { select: { name: true, blockLabel: true } },
    },
    orderBy: [{ building: { createdAt: "asc" } }, { number: "asc" }],
  });

  const occupied = apartments.filter(
    (a) => a.resident != null && a.resident.deletedAt == null
  ).length;

  return {
    site,
    managerName: manager?.name ?? "Yonetici",
    buildings,
    apartments,
    occupancy: {
      total: apartments.length,
      occupied,
      buildingCount: buildings.length,
    },
    currency: site.currency ?? "TRY",
  };
}

async function loadSiteDuesForPeriod(siteId, month, year) {
  return prisma.due.findMany({
    where: {
      apartment: { building: { siteId } },
      month: parseInt(String(month), 10),
      year: parseInt(String(year), 10),
    },
    include: {
      apartment: {
        select: {
          id: true,
          number: true,
          building: { select: { name: true, blockLabel: true } },
          resident: { select: { name: true, deletedAt: true } },
        },
      },
    },
    orderBy: [{ apartment: { building: { name: "asc" } } }, { apartment: { number: "asc" } }],
  });
}

async function loadSiteExpenseRows(siteId, month, year, currency) {
  const m = parseInt(String(month), 10);
  const y = parseInt(String(year), 10);

  const [siteExpenses, buildingExpenses] = await Promise.all([
    prisma.siteExpense.findMany({
      where: { siteId, targetMonth: m, targetYear: y },
      orderBy: { date: "desc" },
    }),
    prisma.expense.findMany({
      where: {
        building: { siteId },
        targetMonth: m,
        targetYear: y,
      },
      orderBy: { date: "desc" },
    }),
  ]);

  const tagged = [
    ...siteExpenses.map((e) => ({ ...e, siteId, scope: "site" })),
    ...buildingExpenses.map((e) => ({ ...e, scope: "building" })),
  ];

  return computeExpenseSummary(tagged, currency);
}

function mapDueRows(dues, currency) {
  return dues.map((due) => ({
    apartmentNumber: due.apartment.number,
    buildingName: due.apartment.building.blockLabel || due.apartment.building.name,
    residentName:
      due.apartment.resident && due.apartment.resident.deletedAt == null
        ? due.apartment.resident.name
        : "-",
    amount: toMoneyDecimal(due.amount),
    amountFormatted: formatMoney(toMoneyDecimal(due.amount), currency),
    status: due.status,
    paidAt: due.paidAt?.toISOString() ?? null,
    overdueDays: due.overdueDays ?? 0,
  }));
}

export async function getSiteMonthlyReportData(siteId, managerId, { month, year }) {
  const ctx = await loadSiteContext(siteId, managerId);
  const { start, end } = monthYearRange(year, month);

  const [dues, expenses] = await Promise.all([
    loadSiteDuesForPeriod(siteId, month, year),
    loadSiteExpenseRows(siteId, month, year, ctx.currency),
  ]);

  const dueSummary = summarizeDues(dues);
  const net = computeNet(dueSummary.collected, expenses.totalAmount);

  const buildingRows = await Promise.all(
    ctx.buildings.map(async (b) => {
      const bDues = dues.filter((d) => d.apartment.building.name === b.name);
      const summary = summarizeDues(bDues);
      return {
        id: b.id,
        name: b.blockLabel || b.name,
        expected: summary.expected,
        collected: summary.collected,
        collectionRateRounded: Math.round(summary.collectionRate),
      };
    })
  );

  return {
    type: "monthly",
    scope: "site",
    generatedAt: new Date().toISOString(),
    period: {
      month: parseInt(String(month), 10),
      year: parseInt(String(year), 10),
    },
    building: {
      id: ctx.site.id,
      name: ctx.site.name,
      address: ctx.site.address,
      city: ctx.site.city,
    },
    managerName: ctx.managerName,
    currency: ctx.currency,
    occupancy: ctx.occupancy,
    buildings: buildingRows,
    dues: {
      summary: {
        ...dueSummary,
        expectedFormatted: formatMoney(dueSummary.expected, ctx.currency),
        collectedFormatted: formatMoney(dueSummary.collected, ctx.currency),
        overdueAmountFormatted: formatMoney(dueSummary.overdueAmount, ctx.currency),
        pendingAmountFormatted: formatMoney(dueSummary.pendingAmount, ctx.currency),
        waivedAmountFormatted: formatMoney(dueSummary.waivedAmount, ctx.currency),
        collectionRateRounded: Math.round(dueSummary.collectionRate),
      },
      rows: mapDueRows(dues, ctx.currency),
    },
    expenses,
    financial: {
      net,
      netFormatted: formatMoney(net, ctx.currency),
      note: "Net tutar = site geneli tahsil - site ve blok giderleri (kasa bakiyesi degildir).",
    },
    periodRange: { start: start.toISOString(), end: end.toISOString() },
  };
}

export async function getSiteAnnualReportData(siteId, managerId, { year }) {
  const ctx = await loadSiteContext(siteId, managerId);
  const y = parseInt(String(year), 10);
  const { start, end } = yearRange(year);

  const [allDues, siteExpenses, buildingExpenses] = await Promise.all([
    prisma.due.findMany({
      where: { apartment: { building: { siteId } }, year: y },
      include: {
        apartment: {
          select: {
            number: true,
            building: { select: { name: true, blockLabel: true } },
            resident: { select: { name: true, deletedAt: true } },
          },
        },
      },
    }),
    prisma.siteExpense.findMany({
      where: { siteId, targetYear: y },
      orderBy: { date: "desc" },
    }),
    prisma.expense.findMany({
      where: { building: { siteId }, targetYear: y },
      orderBy: { date: "desc" },
    }),
  ]);

  const allExpenses = [
    ...siteExpenses.map((e) => ({ ...e, scope: "site" })),
    ...buildingExpenses.map((e) => ({ ...e, scope: "building" })),
  ];

  const duesByMonth = new Map();
  for (const due of allDues) {
    if (!duesByMonth.has(due.month)) duesByMonth.set(due.month, []);
    duesByMonth.get(due.month).push(due);
  }

  const expensesByMonth = new Map();
  for (const expense of allExpenses) {
    if (!expensesByMonth.has(expense.targetMonth)) {
      expensesByMonth.set(expense.targetMonth, []);
    }
    expensesByMonth.get(expense.targetMonth).push(expense);
  }

  const monthlyRows = [];
  let yearExpected = 0;
  let yearCollected = 0;
  let yearExpenses = 0;

  for (let m = 1; m <= 12; m += 1) {
    const monthDues = duesByMonth.get(m) ?? [];
    const monthExpenses = expensesByMonth.get(m) ?? [];
    const dueSummary = summarizeDues(monthDues);
    const expenseTotal = monthExpenses.reduce((sum, e) => {
      const amt = resolveExpenseAmount(e);
      return amt != null ? sum + amt : sum;
    }, 0);
    const net = computeNet(dueSummary.collected, expenseTotal);

    yearExpected += dueSummary.expected;
    yearCollected += dueSummary.collected;
    yearExpenses += expenseTotal;

    monthlyRows.push({
      month: m,
      expected: dueSummary.expected,
      collected: dueSummary.collected,
      expenses: expenseTotal,
      net,
      collectionRateRounded: Math.round(dueSummary.collectionRate),
      expectedFormatted: formatMoney(dueSummary.expected, ctx.currency),
      collectedFormatted: formatMoney(dueSummary.collected, ctx.currency),
      expensesFormatted: formatMoney(expenseTotal, ctx.currency),
      netFormatted: formatMoney(net, ctx.currency),
    });
  }

  const yearExpenseSummary = computeExpenseSummary(allExpenses, ctx.currency);
  const yearNet = computeNet(yearCollected, yearExpenses);

  return {
    type: "annual",
    scope: "site",
    generatedAt: new Date().toISOString(),
    period: { year: y },
    building: {
      id: ctx.site.id,
      name: ctx.site.name,
      address: ctx.site.address,
      city: ctx.site.city,
    },
    managerName: ctx.managerName,
    currency: ctx.currency,
    occupancy: ctx.occupancy,
    monthlyRows,
    yearSummary: {
      expected: yearExpected,
      collected: yearCollected,
      expenses: yearExpenses,
      net: yearNet,
      collectionRateRounded:
        yearExpected > 0 ? Math.round((yearCollected / yearExpected) * 100) : 0,
      expectedFormatted: formatMoney(yearExpected, ctx.currency),
      collectedFormatted: formatMoney(yearCollected, ctx.currency),
      expensesFormatted: formatMoney(yearExpenses, ctx.currency),
      netFormatted: formatMoney(yearNet, ctx.currency),
    },
    expenses: yearExpenseSummary,
    financial: {
      net: yearNet,
      netFormatted: formatMoney(yearNet, ctx.currency),
      note: "Net tutar = yillik site tahsil - yillik site/blok giderleri.",
    },
    periodRange: { start: start.toISOString(), end: end.toISOString() },
  };
}
