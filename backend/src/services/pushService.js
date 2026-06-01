import {
  getFirebaseProjectId,
  getMessaging,
  isFirebaseReady,
} from "../config/firebase.js";
import { clearFcmToken } from "../services/fcmTokenService.js";

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
    console.warn("[push] Firebase hazır değil — gönderim atlandı.");
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
      console.log(
        "[push] gönderildi type=",
        fcmData.type ?? "?",
        "token=",
        fcmToken.slice(0, 12) + "…"
      );
    }
    return { sent: true };
  } catch (err) {
    const code = err.code ?? err.errorInfo?.code;
    if (code && INVALID_TOKEN_CODES.has(code)) {
      await clearFcmToken(fcmToken);
      console.warn("[push] Geçersiz token temizlendi:", code);
    } else {
      console.warn(
        "[push] Gönderim hatası:",
        code || err.message,
        "type=",
        fcmData.type ?? "?",
        "tokenPrefix=",
        fcmToken.slice(0, 20) + "…",
        "adminProject=",
        getFirebaseProjectId() ?? "?"
      );
      if (code === "messaging/mismatched-credential") {
        const detail = err.message ?? "";
        if (detail.includes("cloudmessaging.messages.create")) {
          console.warn(
            "[push] FCM API / IAM izni eksik (proje aidatpanel). "
              + "Google Cloud → Firebase Cloud Messaging API etkinleştir; "
              + "service account'a Firebase Admin veya Cloud Messaging Admin rolü ver. "
              + "Detay:",
            detail
          );
        } else {
          console.warn(
            "[push] mismatched-credential: credential ile cihaz token farklı projeden olabilir. "
              + "pm2 env | grep FIREBASE — eski deneme JSON silinsin."
          );
        }
      }
    }
    return { sent: false, error: err.message, code };
  }
}
