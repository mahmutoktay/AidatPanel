import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/notification_entity.dart';
import '../utils/notification_labels.dart';
import '../utils/notification_style.dart';

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
    final dateStr = DateFormat('d MMM, HH:mm', locale).format(n.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
      child: Material(
        color: AppColors.surface,
        elevation: n.isRead ? 0 : 2,
        shadowColor: AppColors.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(
                color: n.isRead
                    ? AppColors.border
                    : visual.color.withValues(alpha: 0.45),
                width: n.isRead ? AppSizes.cardBorderWidth : 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!n.isRead)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.spacingS,
                        ),
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: visual.color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.spacingM),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: visual.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: visual.color.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              visual.icon,
                              color: visual.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: n.isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: visual.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: visual.color.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    n.type.label(context),
                                    style: AppTypography.caption.copyWith(
                                      color: visual.color,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSizes.spacingXS),
                                Text(
                                  n.body,
                                  style: AppTypography.body1.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSizes.spacingXS),
                                Text(
                                  dateStr,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingS),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
