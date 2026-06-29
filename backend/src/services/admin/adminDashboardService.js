import { prisma } from "../../config/db.js";

const PLAN_MRR_TRY = { monthly: 99, annual: 799 / 12 };

function pctChange(current, previous) {
  if (previous === 0) return current > 0 ? 100 : 0;
  return Math.round(((current - previous) / previous) * 100);
}

function trendDir(change) {
  if (change > 0) return "up";
  if (change < 0) return "down";
  return "flat";
}

export async function getDashboardAlertsService() {
  const now = new Date();
  const in7d = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
  const last24h = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const last7d = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

  const [pendingDekonts, expiringSoon, ocrFailed24h, newManagersNoSub] = await Promise.all([
    prisma.dekont.count({
      where: { status: { in: ["NEEDS_MANAGER_REVIEW", "UNMATCHED", "PARSE_LOW_CONFIDENCE"] } },
    }),
    prisma.subscription.count({
      where: { status: "ACTIVE", currentPeriodEnd: { lte: in7d, gte: now } },
    }),
    prisma.dekont.count({
      where: { status: "EXTRACT_FAILED", createdAt: { gte: last24h } },
    }),
    prisma.user.count({
      where: {
        role: "MANAGER",
        deletedAt: null,
        createdAt: { gte: last7d },
        subscription: null,
      },
    }),
  ]);

  const alerts = [];
  if (pendingDekonts > 0) {
    alerts.push({
      severity: "danger",
      label: "İnceleme bekleyen dekont",
      count: pendingDekonts,
      href: "/ops/dekonts?status=NEEDS_MANAGER_REVIEW",
    });
  }
  if (expiringSoon > 0) {
    alerts.push({
      severity: "warning",
      label: "7 gün içinde bitecek abonelik",
      count: expiringSoon,
      href: "/growth?expiringWithinDays=7",
    });
  }
  if (ocrFailed24h > 0) {
    alerts.push({
      severity: "warning",
      label: "Son 24s OCR başarısız",
      count: ocrFailed24h,
      href: "/ops/dekonts?status=EXTRACT_FAILED",
    });
  }
  if (newManagersNoSub > 0) {
    alerts.push({
      severity: "info",
      label: "Yeni yönetici, abonesiz (7g)",
      count: newManagersNoSub,
      href: "/search?role=MANAGER&hasSubscription=false",
    });
  }

  return alerts;
}

export async function getDashboardInsightsService() {
  const d7 = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const d14 = new Date(Date.now() - 14 * 24 * 60 * 60 * 1000);
  const d30 = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const d37 = new Date(Date.now() - 37 * 24 * 60 * 60 * 1000);
  const d60 = new Date(Date.now() - 60 * 24 * 60 * 60 * 1000);

  const [
    activeSubs,
    prevActiveSubs,
    newSignups7d,
    prevNewSignups7d,
    activeSubsList,
    churned30d,
    prevChurned30d,
    managerDauToday,
    managerDau30dAgo,
    dekontTotal,
    dekontSuccess,
    platformGroups,
  ] = await Promise.all([
    prisma.subscription.count({ where: { status: "ACTIVE" } }),
    prisma.subscription.count({
      where: {
        status: "ACTIVE",
        currentPeriodStart: { lte: d7 },
      },
    }),
    prisma.user.count({ where: { deletedAt: null, createdAt: { gte: d7 } } }),
    prisma.user.count({
      where: { deletedAt: null, createdAt: { gte: d14, lt: d7 } },
    }),
    prisma.subscription.findMany({
      where: { status: "ACTIVE" },
      select: { plan: true },
    }),
    prisma.subscription.count({
      where: {
        status: { in: ["EXPIRED", "CANCELLED"] },
        updatedAt: { gte: d30 },
      },
    }),
    prisma.subscription.count({
      where: {
        status: { in: ["EXPIRED", "CANCELLED"] },
        updatedAt: { gte: d60, lt: d30 },
      },
    }),
    prisma.userActivityDaily.findFirst({
      where: {
        role: "MANAGER",
        date: { gte: new Date(new Date().setHours(0, 0, 0, 0)) },
      },
      orderBy: { date: "desc" },
    }),
    prisma.userActivityDaily.findFirst({
      where: { role: "MANAGER", date: { lte: d30 } },
      orderBy: { date: "desc" },
    }),
    prisma.dekont.count(),
    prisma.dekont.count({
      where: { status: { in: ["MATCHED", "PAYMENT_APPLIED", "PAYMENT_PARTIAL"] } },
    }),
    prisma.subscription.groupBy({
      by: ["platform"],
      where: { status: "ACTIVE" },
      _count: { id: true },
    }),
  ]);

  const estimatedMrr = activeSubsList.reduce((sum, s) => {
    return sum + (PLAN_MRR_TRY[s.plan] ?? 99);
  }, 0);

  const dauManager = managerDauToday?.activeUsers ?? 0;
  const mauManager = managerDau30dAgo?.activeUsers ?? 1;
  const stickiness = mauManager > 0 ? Math.round((dauManager / mauManager) * 100) : 0;

  const ocrSuccessRate = dekontTotal > 0 ? Math.round((dekontSuccess / dekontTotal) * 100) : 0;

  const signupChange = pctChange(newSignups7d, prevNewSignups7d);
  const churnChange = pctChange(churned30d, prevChurned30d);
  const subsChange = pctChange(activeSubs, prevActiveSubs);

  return {
    activeSubs: { value: activeSubs, change: subsChange, trend: trendDir(subsChange) },
    estimatedMrr: { value: Math.round(estimatedMrr), change: subsChange, trend: trendDir(subsChange), unit: "TRY" },
    newSignups7d: { value: newSignups7d, change: signupChange, trend: trendDir(signupChange) },
    managerDau: { value: dauManager, change: 0, trend: "flat" },
    stickiness: { value: stickiness, change: 0, trend: "flat", unit: "%" },
    ocrSuccessRate: { value: ocrSuccessRate, change: 0, trend: "flat", unit: "%" },
    churn30d: { value: churned30d, change: churnChange, trend: trendDir(-churnChange) },
    platforms: platformGroups.map((p) => ({
      platform: p.platform || "unknown",
      count: p._count.id,
    })),
  };
}

export async function getDashboardSegmentsService() {
  const cities = await prisma.building.groupBy({
    by: ["city"],
    _count: { id: true },
    orderBy: { _count: { id: "desc" } },
    take: 5,
  });

  const citySubs = await Promise.all(
    cities.map(async (c) => {
      const count = await prisma.subscription.count({
        where: {
          status: "ACTIVE",
          user: {
            managedBuildings: { some: { city: c.city } },
          },
        },
      });
      return { city: c.city, buildingCount: c._count.id, activeSubs: count };
    })
  );

  const planGroups = await prisma.subscription.groupBy({
    by: ["plan"],
    where: { status: "ACTIVE" },
    _count: { id: true },
  });

  const weeklySignups = [];
  for (let i = 6; i >= 0; i--) {
    const start = new Date();
    start.setDate(start.getDate() - i);
    start.setHours(0, 0, 0, 0);
    const end = new Date(start);
    end.setDate(end.getDate() + 1);

    const [signups, newSubs] = await Promise.all([
      prisma.user.count({ where: { createdAt: { gte: start, lt: end }, deletedAt: null } }),
      prisma.subscription.count({
        where: { createdAt: { gte: start, lt: end }, status: "ACTIVE" },
      }),
    ]);
    weeklySignups.push({
      week: start.toISOString().slice(0, 10),
      signups,
      newSubs,
    });
  }

  return {
    topCities: citySubs,
    planDistribution: planGroups.map((p) => ({ plan: p.plan, count: p._count.id })),
    weeklySignups,
  };
}

export async function previewBroadcastSegmentService(segment = {}) {
  const where = { deletedAt: null };
  if (segment.role) where.role = segment.role;
  if (segment.plan) {
    where.subscription = { plan: segment.plan, status: "ACTIVE" };
  }
  if (segment.city) {
    where.OR = [
      { managedBuildings: { some: { city: { contains: segment.city, mode: "insensitive" } } } },
      { apartment: { building: { city: { contains: segment.city, mode: "insensitive" } } } },
    ];
  }
  if (segment.expiringWithinDays) {
    const until = new Date(Date.now() + Number(segment.expiringWithinDays) * 24 * 60 * 60 * 1000);
    where.subscription = {
      ...(where.subscription || {}),
      status: "ACTIVE",
      currentPeriodEnd: { lte: until, gte: new Date() },
    };
  }

  const count = await prisma.user.count({ where });
  return { recipientCount: count };
}
