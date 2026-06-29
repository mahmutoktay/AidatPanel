import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";

export async function getDekontSummaryService() {
  const statusGroups = await prisma.dekont.groupBy({
    by: ["status"],
    _count: { id: true },
  });

  const failed = await prisma.dekont.count({
    where: {
      status: { in: ["EXTRACT_FAILED", "UNMATCHED", "REJECTED", "RECIPIENT_MISMATCH", "PARSE_LOW_CONFIDENCE"] },
    },
  });

  const avgConfidence = await prisma.dekont.aggregate({
    _avg: { aiConfidence: true },
    where: { aiConfidence: { not: null } },
  });

  const topErrors = await prisma.dekont.groupBy({
    by: ["parseError"],
    where: { parseError: { not: null } },
    _count: { id: true },
    orderBy: { _count: { id: "desc" } },
    take: 10,
  });

  return {
    byStatus: statusGroups.map((g) => ({ status: g.status, count: g._count.id })),
    failedCount: failed,
    avgConfidence: avgConfidence._avg.aiConfidence,
    topErrors: topErrors
      .filter((e) => e.parseError)
      .map((e) => ({ error: e.parseError, count: e._count.id })),
  };
}

export async function listAdminDekontsService({ status, lowConfidence, page = 1, limit = 25 }) {
  const where = {};
  if (status) where.status = status;
  if (lowConfidence === "true") {
    where.aiConfidence = { lt: 0.6 };
  }

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    prisma.dekont.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        status: true,
        parsedAmount: true,
        aiConfidence: true,
        parseError: true,
        rejectionReason: true,
        createdAt: true,
        building: { select: { name: true, city: true } },
        uploadedBy: { select: { name: true } },
      },
    }),
    prisma.dekont.count({ where }),
  ]);

  return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function listAdminResidentsService({ page = 1, limit = 25, q }) {
  const where = { role: "RESIDENT", deletedAt: null };
  if (q) {
    where.OR = [
      { name: { contains: q, mode: "insensitive" } },
      { email: { contains: q, mode: "insensitive" } },
    ];
  }

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        apartment: {
          select: {
            number: true,
            building: { select: { name: true, manager: { select: { id: true, name: true } } } },
          },
        },
      },
    }),
    prisma.user.count({ where }),
  ]);

  return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getPaymentHabitsService(userId) {
  const user = await prisma.user.findFirst({
    where: { id: userId, role: "RESIDENT" },
    select: {
      id: true,
      name: true,
      apartment: { select: { id: true } },
    },
  });
  if (!user?.apartment?.id) {
    throw new HttpError(404, "Sakin veya daire bilgisi bulunamadı.");
  }

  const dues = await prisma.due.findMany({
    where: {
      apartmentId: user.apartment.id,
      status: { in: ["PAID", "OVERDUE"] },
    },
    select: { dueDate: true, paidAt: true, status: true },
  });

  const paid = dues.filter((d) => d.status === "PAID" && d.paidAt);
  const onTime = paid.filter((d) => d.paidAt <= d.dueDate).length;
  const late = paid.filter((d) => d.paidAt > d.dueDate);

  const avgDelayDays =
    late.length > 0
      ? late.reduce((sum, d) => {
          const diff = (d.paidAt - d.dueDate) / (1000 * 60 * 60 * 24);
          return sum + Math.max(0, diff);
        }, 0) / late.length
      : 0;

  return {
    userId: user.id,
    name: user.name,
    totalDues: dues.length,
    paidCount: paid.length,
    onTimeRate: paid.length > 0 ? Math.round((onTime / paid.length) * 100) : null,
    avgDelayDays: Math.round(avgDelayDays * 10) / 10,
    overdueCount: dues.filter((d) => d.status === "OVERDUE").length,
  };
}

export async function getDashboardKpisService() {
  const [userCount, managerCount, activeSubs, pendingDekonts, expiringSoon] = await Promise.all([
    prisma.user.count({ where: { deletedAt: null } }),
    prisma.user.count({ where: { role: "MANAGER", deletedAt: null } }),
    prisma.subscription.count({ where: { status: "ACTIVE" } }),
    prisma.dekont.count({
      where: { status: { in: ["NEEDS_MANAGER_REVIEW", "UNMATCHED", "PARSE_LOW_CONFIDENCE"] } },
    }),
    prisma.subscription.count({
      where: {
        status: "ACTIVE",
        currentPeriodEnd: {
          lte: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
          gte: new Date(),
        },
      },
    }),
  ]);

  return { userCount, managerCount, activeSubs, pendingDekonts, expiringSoon };
}
