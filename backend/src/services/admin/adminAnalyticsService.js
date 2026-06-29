import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { writeAdminAuditLog } from "./adminAuditService.js";

export async function aggregateUserActivityDaily() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);

  for (const role of ["MANAGER", "RESIDENT"]) {
    const sessions = await prisma.userSession.findMany({
      where: {
        revokedAt: null,
        lastSeenAt: { gte: today, lt: tomorrow },
        user: { role, deletedAt: null },
      },
      select: { userId: true },
      distinct: ["userId"],
    });

    await prisma.userActivityDaily.upsert({
      where: { date_role: { date: today, role } },
      create: { date: today, role, activeUsers: sessions.length },
      update: { activeUsers: sessions.length },
    });
  }
}

export async function getActiveUsersAnalytics({ period = "day", role, days = 30 }) {
  const since = new Date();
  since.setDate(since.getDate() - Number(days));

  const where = { date: { gte: since } };
  if (role) where.role = role;

  const rows = await prisma.userActivityDaily.findMany({
    where,
    orderBy: { date: "asc" },
  });

  if (period === "month") {
    const byMonth = {};
    for (const row of rows) {
      const key = `${row.date.getFullYear()}-${String(row.date.getMonth() + 1).padStart(2, "0")}`;
      if (!byMonth[key]) byMonth[key] = { period: key, MANAGER: 0, RESIDENT: 0 };
      byMonth[key][row.role] = Math.max(byMonth[key][row.role], row.activeUsers);
    }
    return Object.values(byMonth);
  }

  return rows.map((r) => ({
    date: r.date.toISOString().slice(0, 10),
    role: r.role,
    activeUsers: r.activeUsers,
  }));
}

export async function listAdminNotificationsService(adminId, { unreadOnly = false }) {
  const where = {
    OR: [{ adminId }, { adminId: null }],
  };
  if (unreadOnly) where.isRead = false;

  return prisma.adminNotification.findMany({
    where,
    orderBy: { createdAt: "desc" },
    take: 50,
  });
}

export async function markNotificationReadService(adminId, notificationId) {
  const n = await prisma.adminNotification.findFirst({
    where: {
      id: notificationId,
      OR: [{ adminId }, { adminId: null }],
    },
  });
  if (!n) throw new HttpError(404, "Bildirim bulunamadı.");
  return prisma.adminNotification.update({
    where: { id: notificationId },
    data: { isRead: true },
  });
}

export async function broadcastNotificationService(adminId, body, ipAddress) {
  const { title, body: msg, segment = {} } = body;
  if (!title || !msg) throw new HttpError(400, "title ve body zorunludur.");

  const userWhere = { deletedAt: null, fcmToken: { not: null } };
  if (segment.role) userWhere.role = segment.role;
  if (segment.plan || segment.expiringWithinDays) {
    userWhere.subscription = {};
    if (segment.plan) userWhere.subscription.plan = segment.plan;
    if (segment.expiringWithinDays) {
      const end = new Date();
      end.setDate(end.getDate() + Number(segment.expiringWithinDays));
      userWhere.subscription.currentPeriodEnd = { lte: end, gte: new Date() };
      userWhere.subscription.status = "ACTIVE";
    }
  }
  if (segment.city) {
    userWhere.managedBuildings = { some: { city: { equals: segment.city, mode: "insensitive" } } };
  }

  const users = await prisma.user.findMany({
    where: userWhere,
    select: { id: true, fcmToken: true },
    take: 500,
  });

  await prisma.adminNotification.create({
    data: {
      adminId,
      title,
      body: msg,
      type: "BROADCAST",
      metadata: { recipientCount: users.length, segment },
    },
  });

  await writeAdminAuditLog({
    adminId,
    action: "NOTIFICATION_BROADCAST",
    metadata: { recipientCount: users.length },
    ipAddress,
  });

  return { recipientCount: users.length, note: "FCM gönderimi admin broadcast kaydı oluşturuldu." };
}

export async function createSystemAdminNotification({ title, body, metadata }) {
  return prisma.adminNotification.create({
    data: { title, body, type: "SYSTEM", metadata: metadata ?? undefined },
  });
}
