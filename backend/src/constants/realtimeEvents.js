/**
 * Canlı bildirim olayları — WebSocket / SSE ile mobil aynı sözleşmeyi kullanır.
 * @see resources/bildirim/REALTIME_NOTIFICATIONS.md
 */
export const REALTIME_EVENTS = {
  /** Yeni in-app bildirim + (opsiyonel) FCM zaten gitti */
  NOTIFICATION_CREATED: "notification.created",
  /** Rozet sayısı değişti (ileride sunucu itebilir) */
  UNREAD_COUNT_CHANGED: "notification.unread_count_changed",
};

/** Mobil + push data ile uyumlu realtime gövdesi */
export function buildNotificationCreatedEvent(notification) {
  return {
    event: REALTIME_EVENTS.NOTIFICATION_CREATED,
    notificationId: notification.id,
    userId: notification.userId,
    type: String(notification.type),
    title: notification.title ?? "",
    body: notification.body ?? "",
    createdAt: notification.createdAt?.toISOString?.() ?? new Date().toISOString(),
    data:
      notification.data &&
      typeof notification.data === "object" &&
      !Array.isArray(notification.data)
        ? notification.data
        : {},
  };
}
