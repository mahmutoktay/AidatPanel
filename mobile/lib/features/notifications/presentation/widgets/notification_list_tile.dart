import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/notification_entity.dart';
import '../utils/notification_labels.dart';
import '../utils/notification_style.dart';
import '../utils/notification_time.dart';

/// Tek bildirim kartı — sade, yüksek kontrastlı, 50+ kullanıcı dostu.
class NotificationListTile extends StatelessWidget {
  final NotificationEntity notification;
  final String locale;
  final VoidCallback onTap;

  const NotificationListTile({
    super.key,
    required this.notification,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final visual = notificationVisual(n.type);
    final unread = !n.isRead;
    final timeStr = notificationRelativeTime(context, n.createdAt, locale: locale);
    final typeLabel = n.type.label(context).trim();
    final title = n.title.trim();
    final showTypeLabel =
        typeLabel.isNotEmpty &&
        title.isNotEmpty &&
        typeLabel.toLowerCase() != title.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
      child: Material(
        color: unread ? visual.background.withValues(alpha: 0.5) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(
                color: unread
                    ? visual.color.withValues(alpha: 0.5)
                    : AppColors.border,
                width: unread ? 1.5 : AppSizes.cardBorderWidth,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBadge(visual: visual),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showTypeLabel) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  typeLabel,
                                  style: AppTypography.caption.copyWith(
                                    color: visual.color,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: visual.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: unread
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!showTypeLabel) ...[
                              const SizedBox(width: AppSizes.spacingS),
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
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: visual.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: visual.color.withValues(alpha: 0.25)),
      ),
      child: Icon(visual.icon, color: visual.color, size: 26),
    );
  }
}
