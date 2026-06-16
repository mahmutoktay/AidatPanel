import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../l10n/strings.g.dart';

/// AppBar sağ üst — çan ikonu + okunmamış sayı (sağ üst köşe rozeti).
class NotificationIconButton extends ConsumerWidget {
  const NotificationIconButton({super.key});

  Future<void> _openNotifications(BuildContext context, WidgetRef ref) async {
    await ref.read(notificationsNotifierProvider.notifier).load(refresh: true);
    if (!context.mounted) return;
    await context.push('/notifications');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(notificationsNotifierProvider).unreadCount;
    final showBadge = unread > 0;
    final badgeLabel = unread > 99 ? '99+' : unread.toString();

    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.spacingXS),
      child: IconButton(
        tooltip: context.t.common.notifications,
        onPressed: () => _openNotifications(context, ref),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: AppSizes.minTouchTarget,
          minHeight: AppSizes.minTouchTarget,
        ),
        icon: Badge(
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
          offset: const Offset(6, -6),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
            size: 26,
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
