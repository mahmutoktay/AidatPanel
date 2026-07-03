import { buildNotificationCreatedEvent } from "../constants/realtimeEvents.js";
import { publishToUser, subscriberCount } from "../realtime/realtimeHub.js";
import { buildPushData } from "../utils/notificationPayload.js";
import { sendToToken } from "./pushService.js";
import { runPool } from "../utils/asyncPool.js";
import { logger } from "../config/logger.js";

const PUSH_CONCURRENCY = Math.max(
  1,
  Number(process.env.FCM_PUSH_CONCURRENCY) || 8
);

/**
 * DB'ye yazılmış bildirimleri cihaza iletir:
 * 1) Realtime hub (WebSocket hazır olunca anında in-app)
 * 2) FCM push (kapalı uygulama / tray)
 *
 * @param {import("@prisma/client").Notification[]} notifications
 * @param {Map<string, string | null>} tokenByUserId
 */
export async function deliverCreatedNotifications(notifications, tokenByUserId) {
  let realtimePublished = 0;
  const type = notifications[0]?.type ?? "UNKNOWN";

  for (const notification of notifications) {
    const realtimePayload = buildNotificationCreatedEvent(notification);
    publishToUser(notification.userId, realtimePayload);
    if (subscriberCount(notification.userId) > 0) {
      realtimePublished += 1;
    }
  }

  const pushOutcomes = await runPool(notifications, PUSH_CONCURRENCY, async (notification) => {
    const token = tokenByUserId.get(notification.userId);
    if (!token) {
<<<<<<< HEAD
      logger.warn({ type: "notification_push_skipped", reason: "no_fcm_token", userId: notification.userId, notificationType: type, notificationId: notification.id });
=======
      logger.warn({ type: "notification_push_skipped", reason: "no_fcm_token", userId: notification.userId, notificationType: notification.type, notificationId: notification.id });
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      return "skipped";
    }

    const result = await sendToToken(token, {
      title: notification.title,
      body: notification.body,
      data: buildPushData(notification),
    });

    if (result.sent) return "sent";
    if (result.skipped) {
<<<<<<< HEAD
      logger.warn({ type: "notification_push_skipped", reason: result.reason ?? "unknown", userId: notification.userId, notificationType: type });
      return "skipped";
    }
    logger.warn({ type: "notification_push_failed", code: result.code ?? result.error ?? "unknown", userId: notification.userId, notificationType: type, notificationId: notification.id });
=======
      logger.warn({ type: "notification_push_skipped", reason: result.reason ?? "unknown", userId: notification.userId, notificationType: notification.type });
      return "skipped";
    }
    logger.warn({ type: "notification_push_failed", code: result.code ?? result.error ?? "unknown", userId: notification.userId, notificationType: notification.type, notificationId: notification.id });
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    return "failed";
  });

  const pushSent = pushOutcomes.filter((o) => o === "sent").length;
  const pushSkipped = pushOutcomes.filter((o) => o === "skipped").length;
  const pushFailed = pushOutcomes.filter((o) => o === "failed").length;

  const logLine = {
    type,
    realtimeSubs: realtimePublished,
    pushSent,
    pushSkipped,
    pushFailed,
  };
  if (pushFailed > 0 || pushSkipped > 0) {
    logger.warn({ type: "notification_delivery_summary", ...logLine });
  } else {
    logger.info({ type: "notification_delivery_summary", ...logLine });
  }

  return { realtimePublished, pushSent, pushSkipped, pushFailed };
}
