import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/domain/entities/notification_entity.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../shared/widgets/toast_overlay.dart';

String notificationToastMessage({required String title, String? body}) {
  final trimmedTitle = title.trim();
  final trimmedBody = body?.trim() ?? '';
  if (trimmedTitle.isEmpty) return trimmedBody;
  if (trimmedBody.isEmpty) return trimmedTitle;
  return '$trimmedTitle\n$trimmedBody';
}

void enqueueNotificationToasts(
  WidgetRef ref,
  List<NotificationEntity> notifications,
) {
  final notifier = ref.read(toastProvider.notifier);
  for (final n in notifications) {
    final message = notificationToastMessage(title: n.title, body: n.body);
    if (message.isNotEmpty) notifier.showNotification(message);
  }
}

/// Sunucudan yeni bildirimleri çeker; varsa toast kuyruğuna ekler.
Future<void> pollAndShowNotificationToasts(WidgetRef ref) async {
  final newOnes =
      await ref.read(notificationsNotifierProvider.notifier).pollForNewNotifications();
  if (newOnes.isNotEmpty) {
    enqueueNotificationToasts(ref, newOnes);
  }
}

void showNotificationToastFromRemote(
  WidgetRef ref,
  RemoteMessage message,
) {
  final title = message.notification?.title?.trim() ??
      message.data['title']?.toString().trim();
  if (title == null || title.isEmpty) return;

  final body = message.notification?.body?.trim() ??
      message.data['body']?.toString().trim();

  ref.read(toastProvider.notifier).showNotification(
        notificationToastMessage(title: title, body: body),
      );
}
