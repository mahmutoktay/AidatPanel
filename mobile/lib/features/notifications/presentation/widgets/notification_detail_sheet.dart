import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/notification_entity.dart';
import '../utils/notification_labels.dart';
import '../utils/notification_style.dart';

/// Bildirim detayı — yalnızca başlık + metin; ilgili kayıt butonla açılır.
class NotificationDetailSheet {
  NotificationDetailSheet._();

  static Future<void> show(
    BuildContext context, {
    required NotificationEntity notification,
    required VoidCallback onMarkRead,
    VoidCallback? onNavigate,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (ctx) => _NotificationDetailSheetBody(
        notification: notification,
        onMarkRead: onMarkRead,
        onNavigate: onNavigate,
      ),
    );
  }
}

class _NotificationDetailSheetBody extends ConsumerWidget {
  final NotificationEntity notification;
  final VoidCallback onMarkRead;
  final VoidCallback? onNavigate;

  const _NotificationDetailSheetBody({
    required this.notification,
    required this.onMarkRead,
    this.onNavigate,
  });

  String _actionLabel(BuildContext context) {
    final t = context.t.features.notifications;
    switch (notification.type) {
      case NotificationType.ticketCreated:
      case NotificationType.ticketUpdate:
        return t.actionViewTicket;
      case NotificationType.dekontReceived:
      case NotificationType.dekontNeedsReview:
      case NotificationType.dekontMatched:
      case NotificationType.dekontPaymentApplied:
        return t.actionViewDekont;
      case NotificationType.dueReminder:
      case NotificationType.duePaid:
      case NotificationType.expenseAdded:
        return t.actionViewDue;
      default:
        return t.viewRelated;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final visual = notificationVisual(n.type);
    final dateStr = AppDateFormat.dateTimeMedium(n.createdAt);
    final t = context.t.features.notifications;
    final role = ref.read(authStateProvider).user?.role;
    final path = n.toPayload().resolveNavigationPath(role: role);
    final canNavigate = path != null && onNavigate != null;

    return PremiumBottomSheetScaffold(
      maxHeightFactor: 0.72,
      scrollable: true,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingM,
        0,
        AppSizes.spacingM,
        AppSizes.spacingM,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      visual.color.withValues(alpha: 0.16),
                      visual.color.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: visual.color.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(visual.icon, color: visual.color, size: 28),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.senderLabel(context, role: role),
                      style: AppTypography.caption.copyWith(
                        color: visual.color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!n.isRead) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      t.unreadBadge,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            n.title,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
          if (n.body.trim().isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingM),
            Text(
              n.body.trim(),
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spacingXL),
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: canNavigate
            ? _actionLabel(context)
            : context.t.common.close,
        onPrimary: () {
          if (!n.isRead) onMarkRead();
          if (canNavigate) {
            Navigator.of(context).pop();
            onNavigate!();
          } else {
            Navigator.of(context).pop();
          }
        },
        secondaryLabel: canNavigate ? context.t.common.close : null,
        onSecondary: canNavigate
            ? () {
                if (!n.isRead) onMarkRead();
                Navigator.of(context).pop();
              }
            : null,
      ),
    );
  }
}
