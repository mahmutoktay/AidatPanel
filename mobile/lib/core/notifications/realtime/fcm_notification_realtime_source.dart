import 'package:firebase_messaging/firebase_messaging.dart';

import '../fcm_service.dart';
import '../notification_payload.dart';
import 'notification_realtime_event.dart';
import 'notification_realtime_source.dart';

/// Push (FCM) — kapalı uygulama tray + açık uygulama anlık olay.
class FcmNotificationRealtimeSource implements NotificationRealtimeSource {
  FcmNotificationRealtimeSource({required FcmService fcmService})
      : _fcmService = fcmService;

  final FcmService _fcmService;
  NotificationRealtimeCallback? _onEvent;
  void Function(NotificationPayload payload)? _onOpenFromNotification;

  void setNavigationHandler(
    void Function(NotificationPayload payload) onOpenFromNotification,
  ) {
    _onOpenFromNotification = onOpenFromNotification;
  }

  @override
  String get name => 'fcm';

  @override
  Future<void> start(NotificationRealtimeCallback onEvent) async {
    _onEvent = onEvent;
    await _fcmService.attachListeners(
      onOpenFromNotification: (payload) {
        _onOpenFromNotification?.call(payload);
      },
      onForegroundMessage: _emitFromRemoteMessage,
    );
  }

  @override
  Future<void> stop() async {
    _onEvent = null;
  }

  @override
  Future<void> onAuthenticated() async {
    await _fcmService.syncTokenToBackend();
  }

  @override
  Future<void> onForegroundResumed() async {
    await _fcmService.syncTokenToBackend();
  }

  void _emitFromRemoteMessage(RemoteMessage message) {
    _onEvent?.call(NotificationRealtimeEvent.fromFcmData(message.data));
  }
}
