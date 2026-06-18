import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationVisual {
  final IconData icon;
  final Color color;
  final Color background;

  const NotificationVisual({
    required this.icon,
    required this.color,
    required this.background,
  });
}

NotificationVisual notificationVisual(NotificationType type) {
  switch (type) {
    case NotificationType.dueReminder:
      return NotificationVisual(
        icon: Icons.schedule_rounded,
        color: AppColors.warning,
        background: AppColors.warningBg,
      );
    case NotificationType.duePaid:
      return NotificationVisual(
        icon: Icons.payments_rounded,
        color: AppColors.success,
        background: AppColors.successBg,
      );
    case NotificationType.ticketCreated:
    case NotificationType.ticketUpdate:
      return NotificationVisual(
        icon: Icons.support_agent_rounded,
        color: AppColors.info,
        background: AppColors.infoBg,
      );
    case NotificationType.announcement:
      return NotificationVisual(
        icon: Icons.campaign_rounded,
        color: AppColors.accent,
        background: AppColors.warningBg,
      );
    case NotificationType.dekontReceived:
      return NotificationVisual(
        icon: Icons.receipt_long_rounded,
        color: AppColors.info,
        background: AppColors.infoBg,
      );
    case NotificationType.dekontNeedsReview:
      return NotificationVisual(
        icon: Icons.rate_review_outlined,
        color: AppColors.warning,
        background: AppColors.warningBg,
      );
    case NotificationType.dekontMatched:
      return NotificationVisual(
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        background: AppColors.successBg,
      );
    case NotificationType.dekontPaymentApplied:
      return NotificationVisual(
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
        background: AppColors.successBg,
      );
    case NotificationType.expenseAdded:
      return NotificationVisual(
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.expenseAccent,
        background: AppColors.expenseAccentBg,
      );
    case NotificationType.system:
      return NotificationVisual(
        icon: Icons.sync_rounded,
        color: AppColors.systemMuted,
        background: AppColors.fill,
      );
    case NotificationType.other:
      return NotificationVisual(
        icon: Icons.notifications_rounded,
        color: AppColors.textSecondary,
        background: AppColors.fill,
      );
  }
}
