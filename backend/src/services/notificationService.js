import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { NOTIFICATION_MESSAGES } from "../constants/notificationConstants.js";
import {
  formatNotificationListPage,
  formatNotificationRow,
} from "../utils/notificationPayload.js";
import { deliverCreatedNotifications } from "./notificationDeliveryService.js";
import { renderNotification } from "./notificationRenderer.js";

/**
 * Birden fazla kullanıcıya in-app bildirim + FCM push.
 * @param {string[]} userIds
 * @param {{ type: import("@prisma/client").NotificationType, code: string, params?: object, data?: object }} payload
 */
export async function createForUsers(userIds, { type, code, params, data }) {
  const uniqueIds = [...new Set(userIds.filter(Boolean))];
  if (uniqueIds.length === 0) {
    return { dbCount: 0, pushSent: 0, pushFailed: 0, pushSkipped: 0, notifications: [] };
  }

  const users = await prisma.user.findMany({
    where: { id: { in: uniqueIds }, deletedAt: null },
    select: { id: true, language: true, fcmToken: true },
  });

  if (users.length === 0) {
    return { dbCount: 0, pushSent: 0, pushFailed: 0, pushSkipped: 0, notifications: [] };
  }

  const inputByUserId = new Map(
    users.map((user) => {
      const rendered = renderNotification(code, params ?? {}, user.language);
      return [
        user.id,
        {
          userId: user.id,
          type,
          code,
          params: params ?? {},
          title: rendered.title,
          body: rendered.body,
          data: data ?? undefined,
        },
      ];
    })
  );

  const notifications = await prisma.$transaction(
    uniqueIds
      .map((userId) => inputByUserId.get(userId))
      .filter(Boolean)
      .map((row) => prisma.notification.create({ data: row }))
  );

  const tokenByUserId = new Map(users.map((u) => [u.id, u.fcmToken]));
  const delivery = await deliverCreatedNotifications(notifications, tokenByUserId);

  return {
    dbCount: notifications.length,
    pushSent: delivery.pushSent,
    pushFailed: delivery.pushFailed,
    pushSkipped: delivery.pushSkipped,
    realtimeDelivered: delivery.realtimePublished,
    notifications: notifications.map(formatNotificationRow),
  };
}

/**
 * Rozet / hafif poll — yalnızca okunmamış sayısı (liste çekmez).
 * GET /api/v1/notifications/unread-count
 */
export async function unreadCountForUser(userId) {
  const unreadCount = await prisma.notification.count({
    where: { userId, isRead: false },
  });
  return { unreadCount };
}

/**
 * Giriş yapmış kullanıcının bildirim kutusu.
 * GET /api/v1/notifications
 */
export async function listForUser(userId, { unreadOnly, limit = 20, cursor } = {}) {
  const where = { userId };

  if (unreadOnly === true) {
    where.isRead = false;
  }

  if (cursor) {
    const cursorRow = await prisma.notification.findFirst({
      where: { id: cursor, userId },
    });
    if (!cursorRow) {
      throw new HttpError(400, NOTIFICATION_MESSAGES.INVALID_CURSOR);
    }
    where.AND = [
      {
        OR: [
          { createdAt: { lt: cursorRow.createdAt } },
          {
            createdAt: cursorRow.createdAt,
            id: { lt: cursorRow.id },
          },
        ],
      },
    ];
  }

  const take = limit + 1;
  const rows = await prisma.notification.findMany({
    where,
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    take,
  });

  const hasMore = rows.length > limit;
  const items = hasMore ? rows.slice(0, limit) : rows;
  const nextCursor = hasMore && items.length > 0 ? items[items.length - 1].id : null;

  const unreadCount = await prisma.notification.count({
    where: { userId, isRead: false },
  });

  return formatNotificationListPage({ items, nextCursor, unreadCount });
}

/** PATCH /api/v1/notifications/:id/read */
export async function markRead(userId, notificationId) {
  const result = await prisma.notification.updateMany({
    where: { id: notificationId, userId },
    data: { isRead: true },
  });

  if (result.count === 0) {
    throw new HttpError(404, NOTIFICATION_MESSAGES.NOT_FOUND);
  }

  const updated = await prisma.notification.findUnique({
    where: { id: notificationId },
  });

  return formatNotificationRow(updated);
}

/** PATCH /api/v1/notifications/read-all */
export async function markAllRead(userId) {
  const result = await prisma.notification.updateMany({
    where: { userId, isRead: false },
    data: { isRead: true },
  });

  return { updated: result.count };
}

/**
 * Development / E2E — giriş yapmış kullanıcıya test bildirimi.
 * POST /api/v1/notifications/dev/seed
 */
export async function seedDevNotification(userId, payload) {
  return createForUsers([userId], payload);
}
