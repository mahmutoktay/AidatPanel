import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/theme_mode_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../l10n/strings.g.dart';

/// Bildirim listesine git (her iki buton için ortak).
Future<void> openNotificationList(BuildContext context, WidgetRef ref) async {
  await ref.read(notificationsNotifierProvider.notifier).load(refresh: true);
  if (!context.mounted) return;
  await context.push('/notifications');
}

/// Badge + zil ikonu gövdesi (her iki buton için ortak).
class NotificationIconBody extends ConsumerWidget {
  final double size;
  final Offset badgeOffset;

  const NotificationIconBody({
    super.key,
    this.size = 26,
    this.badgeOffset = const Offset(6, -6),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final unread = ref.watch(notificationsNotifierProvider).unreadCount;
    final showBadge = unread > 0;
    final badgeLabel = unread > 99 ? '99+' : unread.toString();

    return Badge(
      isLabelVisible: showBadge,
      label: Text(
        badgeLabel,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          height: 1.1,
        ),
      ),
      backgroundColor: AppColors.error,
      offset: badgeOffset,
      child: Icon(
        Icons.notifications_outlined,
        color: AppColors.textPrimary,
        size: size,
      ),
    );
  }
}

/// AppBar sağ üst — çan ikonu + okunmamış sayı (sağ üst köşe rozeti).
class NotificationIconButton extends ConsumerWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.spacingXS),
      child: Tooltip(
        message: context.t.common.notifications,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => openNotificationList(context, ref),
            customBorder: const CircleBorder(),
            child: Container(
              width: AppSizes.minTouchTarget,
              height: AppSizes.minTouchTarget,
              alignment: Alignment.center,
              child: const NotificationIconBody(
                size: 26,
                badgeOffset: Offset(6, -6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rozet — `GET /notifications/unread-count` (45 sn throttle).
void prefetchNotifications(WidgetRef ref) {
  ref.read(notificationsNotifierProvider.notifier).syncUnreadBadge();
}
