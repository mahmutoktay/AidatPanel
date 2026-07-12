import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/notification_entity.dart';
import '../utils/notification_labels.dart';
import '../utils/notification_style.dart';
import '../utils/notification_tile_extractors.dart';
import '../utils/notification_time.dart';

/// Tek bildirim kartı — lüks ve premium kart tasarımı.
class NotificationListTile extends ConsumerWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationListTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final role = ref.watch(authStateProvider.select((s) => s.user?.role));
    final visual = notificationVisual(n.type);
    final unread = !n.isRead;
    final timeStr = notificationRelativeTime(context, n.createdAt);
    final typeLabel = n.senderLabel(context, role: role).trim();
    final title = n.title.trim();
    final apt = notificationTileApartmentLabel(n);
    final amount = notificationTileAmount(n);
    final t = context.t.features.notifications;

    final badges = <Widget>[];

    if (n.type == NotificationType.ticketCreated ||
        n.type == NotificationType.ticketUpdate) {
      if (apt != null && apt.isNotEmpty) {
        badges.add(_BadgeChip(
          label: apt,
          icon: Icons.business_rounded,
        ));
      }
      badges.add(_BadgeChip(
        label: AppDateFormat.dateShortNoYear(n.createdAt),
        icon: Icons.schedule_rounded,
      ));
    } else if (n.type == NotificationType.duePaid ||
        n.type == NotificationType.dekontPaymentApplied ||
        n.type == NotificationType.dueReminder) {
      if (amount != null) {
        badges.add(_BadgeChip(
          label: '+$amount',
          color: AppColors.success,
          background: AppColors.successBg,
        ));
      }
    } else if (n.type == NotificationType.expenseAdded) {
      if (amount != null) {
        badges.add(_BadgeChip(
          label: '-$amount',
          color: AppColors.expenseAccent,
          background: AppColors.expenseAccentBg,
        ));
      }
    } else if (n.type == NotificationType.announcement) {
      badges.add(_BadgeChip(
        label: role == UserRole.resident
            ? t.resident.allApartmentsTag
            : t.allApartmentsTag,
      ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: unread
                  ? visual.color.withValues(alpha: 0.15)
                  : AppColors.border.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: const [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  if (unread)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 4,
                      child: Container(color: visual.color),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _IconBadge(visual: visual),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      typeLabel,
                                      style: AppTypography.caption.copyWith(
                                        color: visual.color,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    timeStr,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (unread) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: visual.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                title,
                                style: AppTypography.body1.copyWith(
                                  fontWeight: unread
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                n.body,
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                              if (badges.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: badges,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final NotificationVisual visual;

  const _IconBadge({required this.visual});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(visual.icon, color: visual.color, size: 24),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? background;

  const _BadgeChip({
    required this.label,
    this.icon,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.textSecondary;
    final bgColor = background ?? AppColors.fill;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color?.withValues(alpha: 0.15) ??
              AppColors.border.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTypography.body2.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
