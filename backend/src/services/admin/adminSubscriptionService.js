import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { writeAdminAuditLog } from "./adminAuditService.js";

export async function listAdminSubscriptionsService({
  plan,
  status,
  platform,
  city,
  expiringWithinDays,
  page = 1,
  limit = 25,
}) {
  const where = {};
  if (plan) where.plan = plan;
  if (status) where.status = status;
  if (platform) where.platform = platform;

  if (expiringWithinDays) {
    const days = Number(expiringWithinDays);
    const end = new Date();
    end.setDate(end.getDate() + days);
    where.currentPeriodEnd = { lte: end, gte: new Date() };
    where.status = "ACTIVE";
  }

  const userWhere = {};
  if (city) {
    userWhere.managedBuildings = { some: { city: { equals: city, mode: "insensitive" } } };
  }

  if (Object.keys(userWhere).length > 0) {
    where.user = userWhere;
  }

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    prisma.subscription.findMany({
      where,
      skip,
      take: limit,
      orderBy: { currentPeriodEnd: "asc" },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            managedBuildings: { select: { city: true, district: true }, take: 1 },
          },
        },
      },
    }),
    prisma.subscription.count({ where }),
  ]);

  return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function grantSubscriptionService(adminId, userId, body, ipAddress) {
  const { durationDays = 30, plan = "monthly", reason } = body;
  if (!reason || reason.trim().length < 3) {
    throw new HttpError(400, "Grant gerekçesi zorunludur.");
  }

  const user = await prisma.user.findFirst({
    where: { id: userId, role: "MANAGER", deletedAt: null },
  });
  if (!user) {
    throw new HttpError(404, "Aktif yönetici bulunamadı.");
  }

  const now = new Date();
  const end = new Date(now);
  end.setDate(end.getDate() + Number(durationDays));

  const existing = await prisma.subscription.findUnique({ where: { userId } });
  let subscription;

  if (existing) {
    const base = existing.currentPeriodEnd > now ? existing.currentPeriodEnd : now;
    const newEnd = new Date(base);
    newEnd.setDate(newEnd.getDate() + Number(durationDays));
    subscription = await prisma.subscription.update({
      where: { userId },
      data: {
        status: "ACTIVE",
        plan,
        currentPeriodStart: now,
        currentPeriodEnd: newEnd,
      },
    });
  } else {
    subscription = await prisma.subscription.create({
      data: {
        userId,
        status: "ACTIVE",
        plan,
        platform: "admin_grant",
        currentPeriodStart: now,
        currentPeriodEnd: end,
      },
    });
  }

  await prisma.promoGrant.create({
    data: {
      userId,
      grantedById: adminId,
      type: "FREE_PERIOD",
      plan,
      durationDays: Number(durationDays),
      reason: reason.trim(),
      expiresAt: subscription.currentPeriodEnd,
    },
  });

  await writeAdminAuditLog({
    adminId,
    action: "SUBSCRIPTION_GRANT",
    targetType: "User",
    targetId: userId,
    metadata: { durationDays: Number(durationDays), plan },
    ipAddress,
  });

  return subscription;
}

export async function listPromoGrantsService({ page = 1, limit = 25 }) {
  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    prisma.promoGrant.findMany({
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
      include: {
        user: { select: { id: true, name: true, email: true } },
        grantedBy: { select: { id: true, name: true } },
      },
    }),
    prisma.promoGrant.count(),
  ]);
  return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function createPromoGrantService(adminId, body, ipAddress) {
  const { userId, type, plan, durationDays, discountPercent, reason, expiresAt } = body;
  if (!userId || !type || !reason) {
    throw new HttpError(400, "userId, type ve reason zorunludur.");
  }

  if (type === "FREE_PERIOD" && durationDays) {
    return grantSubscriptionService(
      adminId,
      userId,
      { durationDays, plan, reason },
      ipAddress
    );
  }

  const user = await prisma.user.findFirst({ where: { id: userId, deletedAt: null } });
  if (!user) throw new HttpError(404, "Kullanıcı bulunamadı.");

  const grant = await prisma.promoGrant.create({
    data: {
      userId,
      grantedById: adminId,
      type,
      plan: plan ?? null,
      durationDays: durationDays ?? null,
      discountPercent: discountPercent ?? null,
      reason: reason.trim(),
      expiresAt: expiresAt ? new Date(expiresAt) : null,
    },
  });

  await writeAdminAuditLog({
    adminId,
    action: "PROMO_CREATE",
    targetType: "User",
    targetId: userId,
    metadata: { type, durationDays, discountPercent },
    ipAddress,
  });

  return grant;
}
