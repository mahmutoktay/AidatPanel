/// Bildirim iletim katmanı — FCM + poll bugün; WebSocket ileride tek bayrakla açılır.
abstract final class NotificationDeliveryConfig {
  /// `true` — canlı API + backend `REALTIME_WS_ENABLED=true` gerekir.
  static const bool webSocketEnabled = true;

  /// WebSocket yokken yedek poll (FCM gecikmesi / emülatör).
  static const Duration pollIntervalIdle = Duration(seconds: 90);
  static const Duration pollIntervalWhenUnread = Duration(seconds: 50);

  /// Backend: `wss://api.aidatpanel.com/api/v1/realtime` (planlanan).
  static const String webSocketPath = '/api/v1/realtime';
}
