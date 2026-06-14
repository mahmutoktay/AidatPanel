import { prisma } from "../config/db.js";
import { assertManagerOwnsBuilding } from "../utils/access.js";
import { monthYearRange, yearRange } from "../utils/reportPeriod.js";
import {
  summarizeDues,
  computeNet,
  resolveExpenseAmount,
  toMoneyDecimal,
} from "../utils/reportAggregation.js";
import { EXPENSE_CATEGORY_LABELS } from "../constants/reportLabels.js";
import { formatMoney } from "../utils/reportFormat.js";

async function loadBuildingContext(buildingId, managerId) {
  const building = await assertManagerOwnsBuilding(buildingId, managerId);
  const manager = await prisma.user.findFirst({
    where: { id: managerId, deletedAt: null },
    select: { name: true },
  });

  const apartments = await prisma.apartment.findMany({
    where: { buildingId },
    include: {
      resident: {
        select: { name: true, deletedAt: true },
      },
    },
    orderBy: [{ floor: "asc" }, { number: "asc" }],
  });

  const occupied = apartments.filter(
    (a) => a.resident != null && a.resident.deletedAt == null
  ).length;

  return {
    building,
    managerName: manager?.name ?? "Yonetici",
    apartments,
    occupancy: {
      total: apartments.length,
      occupied,
    },
    currency: building.currency ?? "TRY",
  };
}

async function loadDuesForPeriod(buildingId, month, year) {
  return prisma.due.findMany({
    where: {
      apartment: { buildingId },
      month: parseInt(String(month), 10),
      year: parseInt(String(year), 10),
    },
    include: {
      apartment: {
        select: {
          id: true,
          number: true,
          resident: {
            select: { name: true, deletedAt: true },
          },
        },
      },
    },
    orderBy: { apartment: { number: "asc" } },
  });
}

async function loadExpenseSummary(buildingId, month, year, currency) {
  const y = parseInt(String(year), 10);
  const where = { buildingId, targetYear: y };
  if (month != null) {
    where.targetMonth = parseInt(String(month), 10);
  }

  const expenses = await prisma.expense.findMany({
    where,
    orderBy: { date: "desc" },
  });

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
    byCategoryMap.set(cat, {
      amount: prev.amount + amount,
      count: prev.count + 1,
    });
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

async function loadOperationalSummary(buildingId, start, end) {
  const apartmentIds = await prisma.apartment.findMany({
    where: { buildingId },
    select: { id: true },
  });
  const ids = apartmentIds.map((a) => a.id);

  const [
    ticketsOpened,
    ticketsResolved,
    ticketsOpen,
    dekontUploaded,
    dekontApproved,
    dekontPending,
    announcements,
  ] = await Promise.all([
    prisma.ticket.count({
      where: { apartmentId: { in: ids }, createdAt: { gte: start, lte: end } },
    }),
    prisma.ticket.count({
      where: {
        apartmentId: { in: ids },
        status: { in: ["RESOLVED", "CLOSED"] },
        updatedAt: { gte: start, lte: end },
      },
    }),
    prisma.ticket.count({
      where: {
        apartmentId: { in: ids },
        status: { in: ["OPEN", "IN_PROGRESS"] },
      },
    }),
    prisma.dekont.count({
      where: { buildingId, createdAt: { gte: start, lte: end } },
    }),
    prisma.dekont.count({
      where: {
        buildingId,
        status: "PAYMENT_APPLIED",
        reviewedAt: { gte: start, lte: end },
      },
    }),
    prisma.dekont.count({
      where: {
        buildingId,
        status: {
          in: [
            "NEEDS_MANAGER_REVIEW",
            "MATCH_AMBIGUOUS",
            "UNMATCHED",
            "PARSE_LOW_CONFIDENCE",
          ],
        },
      },
    }),
    prisma.notification.count({
      where: {
        type: "ANNOUNCEMENT",
        createdAt: { gte: start, lte: end },
        data: {
          path: ["buildingId"],
          equals: buildingId,
        },
      },
    }),
  ]);

  return {
    ticketsOpened,
    ticketsResolved,
    ticketsOpen,
    dekontUploaded,
    dekontApproved,
    dekontPending,
    announcements,
  };
}

function mapDueRows(dues, currency) {
  return dues.map((due) => ({
    apartmentNumber: due.apartment.number,
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

export async function getMonthlyReportData(buildingId, managerId, { month, year }) {
  const ctx = await loadBuildingContext(buildingId, managerId);
  const { start, end } = monthYearRange(year, month);

  const [dues, expenses, operational] = await Promise.all([
    loadDuesForPeriod(buildingId, month, year),
    loadExpenseSummary(buildingId, month, year, ctx.currency),
    loadOperationalSummary(buildingId, start, end),
  ]);

  const dueSummary = summarizeDues(dues);
  const net = computeNet(dueSummary.collected, expenses.totalAmount);

  return {
    type: "monthly",
    generatedAt: new Date().toISOString(),
    period: {
      month: parseInt(String(month), 10),
      year: parseInt(String(year), 10),
    },
    building: {
      id: ctx.building.id,
      name: ctx.building.name,
      address: ctx.building.address,
      city: ctx.building.city,
    },
    managerName: ctx.managerName,
    currency: ctx.currency,
    occupancy: ctx.occupancy,
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
      note: "Net tutar = tahsil edilen aidat - giderler (bina kasa bakiyesi degildir).",
    },
    operational,
  };
}

export async function getAnnualReportData(buildingId, managerId, { year }) {
  const ctx = await loadBuildingContext(buildingId, managerId);
  const y = parseInt(String(year), 10);
  const { start, end } = yearRange(year);

  const monthlyRows = [];
  let yearExpected = 0;
  let yearCollected = 0;
  let yearExpenses = 0;

  for (let m = 1; m <= 12; m += 1) {
    const [dues, expenseBlock] = await Promise.all([
      loadDuesForPeriod(buildingId, m, y),
      loadExpenseSummary(buildingId, m, y, ctx.currency),
    ]);
    const dueSummary = summarizeDues(dues);
    const net = computeNet(dueSummary.collected, expenseBlock.totalAmount);

    yearExpected += dueSummary.expected;
    yearCollected += dueSummary.collected;
    yearExpenses += expenseBlock.totalAmount;

    monthlyRows.push({
      month: m,
      expected: dueSummary.expected,
      collected: dueSummary.collected,
      expenses: expenseBlock.totalAmount,
      net,
      collectionRateRounded: Math.round(dueSummary.collectionRate),
      expectedFormatted: formatMoney(dueSummary.expected, ctx.currency),
      collectedFormatted: formatMoney(dueSummary.collected, ctx.currency),
      expensesFormatted: formatMoney(expenseBlock.totalAmount, ctx.currency),
      netFormatted: formatMoney(net, ctx.currency),
    });
  }

  const [yearExpenseSummary, operational] = await Promise.all([
    loadExpenseSummary(buildingId, null, y, ctx.currency),
    loadOperationalSummary(buildingId, start, end),
  ]);

  const yearNet = computeNet(yearCollected, yearExpenses);

  return {
    type: "annual",
    generatedAt: new Date().toISOString(),
    period: { year: y },
    building: {
      id: ctx.building.id,
      name: ctx.building.name,
      address: ctx.building.address,
      city: ctx.building.city,
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
      note: "Net tutar = yillik tahsil - yillik giderler (bina kasa bakiyesi degildir).",
    },
    operational,
  };
}
