import {
  getFirebaseProjectId,
  getMessaging,
  isFirebaseReady,
} from "../config/firebase.js";
import { clearFcmToken } from "../services/fcmTokenService.js";
import { logger } from "../config/logger.js";

const INVALID_TOKEN_CODES = new Set([
  "messaging/invalid-registration-token",
  "messaging/registration-token-not-registered",
]);

/** Flutter AndroidManifest + LocalNotificationService ile aynı kanal. */
const ANDROID_NOTIFICATION_CHANNEL_ID = "aidatpanel_high";

const debugPush = process.env.DEBUG_PUSH === "1";

/**
 * FCM data payload — tüm değerler string olmalı.
 * @param {Record<string, unknown>} data
 */
function toFcmData(data) {
  return Object.fromEntries(
    Object.entries(data).map(([key, value]) => [
      key,
      value === null || value === undefined ? "" : String(value),
    ])
  );
}

/**
 * Tek cihaza push gönderir.
 * @param {string} fcmToken
 * @param {{ title: string, body: string, data?: Record<string, unknown> }} payload
 */
export async function sendToToken(fcmToken, { title, body, data = {} }) {
  if (!isFirebaseReady()) {
    logger.warn({ type: "push_firebase_not_ready" });
    return { sent: false, skipped: true, reason: "firebase_not_ready" };
  }

  const messaging = getMessaging();
  if (!messaging) {
    return { sent: false, skipped: true, reason: "messaging_unavailable" };
  }

  const fcmData = toFcmData({
    ...data,
    title: title ?? "",
    body: body ?? "",
  });

  try {
    // Android kapalı: notification + kanal → sistem tray (emülatörde en güvenilir).
    // data → tap/deep-link + Flutter background yedek (data-only).
    await messaging.send({
      token: fcmToken,
      notification: { title, body },
      data: fcmData,
      android: {
        priority: "high",
        notification: {
          channelId: ANDROID_NOTIFICATION_CHANNEL_ID,
          priority: "high",
          defaultSound: true,
        },
      },
      apns: {
        headers: { "apns-priority": "10" },
        payload: {
          aps: {
            alert: { title: title ?? "", body: body ?? "" },
            sound: "default",
          },
        },
      },
    });
    if (debugPush) {
<<<<<<< HEAD
      logger.info({ type: "push_sent", eventType: fcmData.type ?? "?", tokenPrefix: fcmToken.slice(0, 12) });
=======
      logger.info({ type: "push_sent", eventType: fcmData.type ?? "?" });
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
    return { sent: true };
  } catch (err) {
    const code = err.code ?? err.errorInfo?.code;
    if (code && INVALID_TOKEN_CODES.has(code)) {
      await clearFcmToken(fcmToken);
      logger.warn({ type: "push_invalid_token", code });
    } else {
      logger.warn({
        type: "push_send_error",
        code: code || err.message,
        eventType: fcmData.type ?? "?",
<<<<<<< HEAD
        tokenPrefix: fcmToken.slice(0, 20),
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        adminProject: getFirebaseProjectId() ?? "?",
      });
      if (code === "messaging/mismatched-credential") {
        const detail = err.message ?? "";
        if (detail.includes("cloudmessaging.messages.create")) {
          logger.warn({ type: "push_fcm_iam_missing", detail });
        } else {
          logger.warn({ type: "push_mismatched_credential" });
        }
      }
    }
    return { sent: false, error: err.message, code };
  }
}
