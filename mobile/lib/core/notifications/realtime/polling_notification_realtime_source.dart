import 'dart:async';

import 'notification_delivery_config.dart';
import 'notification_realtime_event.dart';
import 'notification_realtime_source.dart';

/// FCM/WebSocket yokken yedek — periyodik sunucu kontrolü (seyrek).
class PollingNotificationRealtimeSource implements NotificationRealtimeSource {
  PollingNotificationRealtimeSource({
    required Future<List<NotificationRealtimeEvent>> Function() poll,
    required int Function() unreadCount,
  })  : _poll = poll,
        _unreadCount = unreadCount;

  final Future<List<NotificationRealtimeEvent>> Function() _poll;
  final int Function() _unreadCount;

  NotificationRealtimeCallback? _onEvent;
  Timer? _timer;
  bool _running = false;

  @override
  String get name => 'polling';

  @override
  Future<void> start(NotificationRealtimeCallback onEvent) async {
    _onEvent = onEvent;
    _scheduleNext();
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _onEvent = null;
  }

  void _scheduleNext() {
    _timer?.cancel();
    final unread = _unreadCount();
    final delay = unread > 0
        ? NotificationDeliveryConfig.pollIntervalWhenUnread
        : NotificationDeliveryConfig.pollIntervalIdle;
    _timer = Timer(delay, () async {
      await _tick();
      if (_onEvent != null) _scheduleNext();
    });
  }

  Future<void> _tick() async {
    if (_running || _onEvent == null) return;
    _running = true;
    try {
      final events = await _poll();
      final handler = _onEvent;
      if (handler == null) return;
      for (final e in events) {
        handler(e);
      }
    } finally {
      _running = false;
    }
  }

  @override
  Future<void> onAuthenticated() async {}

  @override
  Future<void> onForegroundResumed() async {}
}
