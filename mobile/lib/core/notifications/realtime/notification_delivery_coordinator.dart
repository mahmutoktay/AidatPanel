import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/notifications/domain/entities/notification_entity.dart';
import '../../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../router/app_router.dart';
import '../notification_navigation.dart';
import '../notification_payload.dart';
import '../notification_toast.dart';
import '../../../shared/widgets/toast_overlay.dart';
import 'fcm_notification_realtime_source.dart';
import 'notification_delivery_config.dart';
import 'notification_realtime_event.dart';
import 'notification_realtime_source.dart';
import 'polling_notification_realtime_source.dart';
import 'websocket_notification_realtime_source.dart';

/// Tüm bildirim kanallarını (FCM + poll + ileride WS) tek yerden yönetir.
class NotificationDeliveryCoordinator {
  NotificationDeliveryCoordinator({
    required FcmNotificationRealtimeSource fcmSource,
    required PollingNotificationRealtimeSource pollingSource,
    WebSocketNotificationRealtimeSource? webSocketSource,
  })  : _fcmSource = fcmSource,
        _pollingSource = pollingSource,
        _webSocketSource = webSocketSource;

  final FcmNotificationRealtimeSource _fcmSource;
  final PollingNotificationRealtimeSource _pollingSource;
  final WebSocketNotificationRealtimeSource? _webSocketSource;

  WidgetRef? _ref;
  bool _started = false;

  List<NotificationRealtimeSource> get _sources => [
        _fcmSource,
        if (NotificationDeliveryConfig.webSocketEnabled &&
            _webSocketSource != null)
          _webSocketSource,
        _pollingSource,
      ];

  void attach(WidgetRef ref) {
    _ref = ref;
    _fcmSource.setNavigationHandler(_navigateFromPayload);
  }

  void detach() {
    _ref = null;
    unawaited(stop());
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    for (final source in _sources) {
      await source.start(_onRealtimeEvent);
    }
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    for (final source in _sources) {
      await source.stop();
    }
  }

  Future<void> onAuthenticated({bool force = false}) async {
    if (_ref == null) return;
    final notifier = _ref!.read(notificationsNotifierProvider.notifier);
    if (force) notifier.resetToastTracking();
    await _fcmSource.onAuthenticated();
    if (_webSocketSource != null) {
      await _webSocketSource.onAuthenticated();
    }
    await notifier.syncUnreadBadge(force: force);
    if (force) {
      final newOnes = await notifier.pollForNewNotifications(force: true);
      _showPollingToasts(newOnes);
    }
  }

  Future<void> onForegroundResumed() async {
    if (_ref == null) return;
    await _fcmSource.onForegroundResumed();
    if (_webSocketSource != null) {
      await _webSocketSource.onForegroundResumed();
    }
    final notifier = _ref!.read(notificationsNotifierProvider.notifier);
    await notifier.syncUnreadBadge(force: true);
    final newOnes = await notifier.pollForNewNotifications(force: true);
    _showPollingToasts(newOnes);
  }

  Future<void> onLoggedOut() async {
    _ref?.read(notificationsNotifierProvider.notifier).resetToastTracking();
    await stop();
  }

  void _onRealtimeEvent(NotificationRealtimeEvent event) {
    final ref = _ref;
    if (ref == null) return;
    if (!ref.read(authStateProvider).isAuthenticated) return;

    final notifier = ref.read(notificationsNotifierProvider.notifier);
    final notificationId = event.payload.notificationId;
    if (notificationId != null && notificationId.isNotEmpty) {
      notifier.markNotificationToasted(notificationId);
    }

    if (event.showToast) {
      final title = event.title?.trim() ?? '';
      if (title.isNotEmpty) {
        ref.read(toastProvider.notifier).showNotification(
              notificationToastMessage(title: title, body: event.body),
            );
      }
    }

    if (event.syncBadge) {
      notifier.onPushReceived();
    }
  }

  void _showPollingToasts(List<NotificationEntity> items) {
    final ref = _ref;
    if (ref == null || items.isEmpty) return;
    enqueueNotificationToasts(ref, items);
  }

  void _navigateFromPayload(NotificationPayload payload) {
    final ref = _ref;
    if (ref == null) return;
    final role = ref.read(authStateProvider).user?.role;
    final path = payload.resolveNavigationPath(role: role);
    if (path == null) return;
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    navigateFromNotificationPath(ctx, ref, path);
  }
}

/// Poll sonucunu kanal olaylarına çevirir (toast coordinator'da).
List<NotificationRealtimeEvent> mapEntitiesToPollingEvents(
  List<NotificationEntity> items,
) {
  return items
      .map(
        (n) => NotificationRealtimeEvent(
          channel: NotificationRealtimeChannel.polling,
          payload: NotificationPayload(
            type: notificationTypeToApiString(n.type),
            notificationId: n.id,
            ticketId: n.data?['ticketId']?.toString(),
            dekontId: n.data?['dekontId']?.toString(),
            buildingId: n.data?['buildingId']?.toString(),
            route: n.data?['route']?.toString(),
          ),
          title: n.title,
          body: n.body,
          showToast: true,
          syncBadge: false,
        ),
      )
      .toList();
}

String? notificationTypeToApiString(NotificationType type) {
  return switch (type) {
    NotificationType.dueReminder => 'DUE_REMINDER',
    NotificationType.duePaid => 'DUE_PAID',
    NotificationType.ticketCreated => 'TICKET_CREATED',
    NotificationType.ticketUpdate => 'TICKET_UPDATE',
    NotificationType.announcement => 'ANNOUNCEMENT',
    NotificationType.dekontReceived => 'DEKONT_RECEIVED',
    NotificationType.dekontNeedsReview => 'DEKONT_NEEDS_REVIEW',
    NotificationType.dekontMatched => 'DEKONT_MATCHED',
    NotificationType.dekontPaymentApplied => 'DEKONT_PAYMENT_APPLIED',
    NotificationType.system => 'SYSTEM',
    NotificationType.other => 'SYSTEM',
  };
}
