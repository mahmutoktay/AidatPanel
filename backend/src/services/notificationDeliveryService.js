import { buildNotificationCreatedEvent } from "../constants/realtimeEvents.js";
import { publishToUser, subscriberCount } from "../realtime/realtimeHub.js";
import { buildPushData } from "../utils/notificationPayload.js";
import { sendToToken } from "./pushService.js";
import { runPool } from "../utils/asyncPool.js";

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
 * @param {{ title: string, body: string, type: string }} meta
 * @param {Map<string, string | null>} tokenByUserId
 */
export async function deliverCreatedNotifications(
  notifications,
  { title, body, type },
  tokenByUserId
) {
  let realtimePublished = 0;

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
      console.warn(
        "[notification] push atlandı — fcmToken yok:",
        "userId=",
        notification.userId,
        "type=",
        type,
        "notificationId=",
        notification.id
      );
      return "skipped";
    }

    const result = await sendToToken(token, {
      title,
      body,
      data: buildPushData(notification),
    });

    if (result.sent) return "sent";
    if (result.skipped) {
      console.warn(
        "[notification] push atlandı:",
        result.reason ?? "unknown",
        "userId=",
        notification.userId,
        "type=",
        type
      );
      return "skipped";
    }
    console.warn(
      "[notification] push başarısız:",
      result.code ?? result.error ?? "unknown",
      "userId=",
      notification.userId,
      "type=",
      type,
      "notificationId=",
      notification.id
    );
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
    console.warn("[notification] iletim özeti:", logLine);
  } else {
    console.log("[notification] iletim özeti:", logLine);
  }

  return { realtimePublished, pushSent, pushSkipped, pushFailed };
}
