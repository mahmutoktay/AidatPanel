import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../theme/dashboard_screen_style.dart';

/// Dairesel beyaz zemin üzerinde bildirim zili — dashboard üst şerit.
class DashboardNotificationButton extends ConsumerWidget {
  const DashboardNotificationButton({super.key});

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openNotifications(context, ref),
        customBorder: const CircleBorder(),
        child: Container(
          width: AppSizes.minTouchTarget,
          height: AppSizes.minTouchTarget,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: DashboardScreenStyle.cardShadow,
          ),
          alignment: Alignment.center,
          child: Badge(
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
            offset: const Offset(5, -5),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
