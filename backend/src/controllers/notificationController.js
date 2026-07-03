import {
  listForUser,
  unreadCountForUser,
  markRead,
  markAllRead,
  seedDevNotification,
} from "../services/notificationService.js";
import {
  NOTIFICATION_MESSAGES,
  DEV_SEED_NOTIFICATION,
} from "../constants/notificationConstants.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * GET /api/v1/notifications/unread-count
 * Rozet senkronu — mobil poll için hafif uç.
 */
export const getUnreadCount = asyncHandler(async (req, res) => {
  const data = await unreadCountForUser(req.user.id);
  res.status(200).json({ success: true, data });
});

/**
 * GET /api/v1/notifications
 * Query: unreadOnly, limit (1-50), cursor (uuid)
 */
export const listNotifications = asyncHandler(async (req, res) => {
  const { unreadOnly, limit, cursor } = req.query;
  const data = await listForUser(req.user.id, {
    unreadOnly,
    limit,
    cursor,
  });
  res.status(200).json({ success: true, data });
});

/**
 * PATCH /api/v1/notifications/:id/read
 */
export const markNotificationRead = asyncHandler(async (req, res) => {
  const data = await markRead(req.user.id, req.params.id);
  res.status(200).json({
    success: true,
    message: NOTIFICATION_MESSAGES.MARK_READ,
    data,
  });
});

/**
 * PATCH /api/v1/notifications/read-all
 */
export const markAllNotificationsRead = asyncHandler(async (req, res) => {
  const data = await markAllRead(req.user.id);
  res.status(200).json({
    success: true,
    message: NOTIFICATION_MESSAGES.MARK_ALL_READ,
    data,
  });
});

/**
 * POST /api/v1/notifications/dev/seed
 * Yalnızca development veya AIDATPANEL_E2E=1
 */
export const createDevSeedNotification = asyncHandler(async (req, res) => {
  const data = await seedDevNotification(req.user.id, DEV_SEED_NOTIFICATION);
  res.status(201).json({
    success: true,
    message: NOTIFICATION_MESSAGES.DEV_SEED_OK,
    data,
  });
});
