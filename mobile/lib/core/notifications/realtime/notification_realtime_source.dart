import 'notification_realtime_event.dart';

typedef NotificationRealtimeCallback = void Function(
  NotificationRealtimeEvent event,
);

/// FCM / WebSocket / poll — tek arayüz (yeni kanal = yeni implementasyon).
abstract class NotificationRealtimeSource {
  String get name;

  Future<void> start(NotificationRealtimeCallback onEvent);

  Future<void> stop();

  /// Giriş veya kullanıcı değişimi. [force] → FCM token sunucuya yeniden yüklenir.
  Future<void> onAuthenticated({bool force = false});

  /// Uygulama ön plana geldi.
  Future<void> onForegroundResumed();
}
