import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/notifications/presentation/providers/notifications_provider.dart';
import '../fcm_provider.dart';
import 'fcm_notification_realtime_source.dart';
import 'notification_delivery_coordinator.dart';
import 'notification_delivery_config.dart';
import 'polling_notification_realtime_source.dart';
import 'websocket_notification_realtime_source.dart';

final fcmNotificationRealtimeSourceProvider =
    Provider<FcmNotificationRealtimeSource>((ref) {
  return FcmNotificationRealtimeSource(
    fcmService: ref.watch(fcmServiceProvider),
  );
});

final notificationDeliveryCoordinatorProvider =
    Provider<NotificationDeliveryCoordinator>((ref) {
  final fcmSource = ref.watch(fcmNotificationRealtimeSourceProvider);

  final pollingSource = PollingNotificationRealtimeSource(
    poll: () async {
      final newOnes = await ref
          .read(notificationsNotifierProvider.notifier)
          .pollForNewNotifications();
      return mapEntitiesToPollingEvents(newOnes);
    },
    unreadCount: () => ref.read(notificationsNotifierProvider).unreadCount,
  );

  final coordinator = NotificationDeliveryCoordinator(
    fcmSource: fcmSource,
    pollingSource: pollingSource,
    webSocketSource: NotificationDeliveryConfig.webSocketEnabled
        ? WebSocketNotificationRealtimeSource(
            secureStorage: ref.watch(secureStorageProvider),
          )
        : null,
  );

  ref.onDispose(() {
    coordinator.detach();
  });

  return coordinator;
});
