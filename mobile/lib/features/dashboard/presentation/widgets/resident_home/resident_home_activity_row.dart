import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/resident_home_activity_item.dart';
import '../../../../dues/domain/entities/due_entity.dart';
import '../../utils/resident_home_activity_labels.dart';

class ResidentHomeActivityRow extends StatelessWidget {
  const ResidentHomeActivityRow({
    super.key,
    required this.item,
    required this.duesById,
    this.onTap,
  });

  final ResidentHomeActivityItem item;
  final Map<String, DueEntity> duesById;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final transaction = item.transaction;
    final announcement = item.announcement;

    final String title;
    final String subtitle;
    final String? trailing;

    if (transaction != null) {
      title = residentTransactionPeriodTitle(context, transaction, duesById);
      subtitle = residentTransactionSubtitle(context, transaction);
      trailing = residentTransactionTrailing(context, transaction);
    } else if (announcement != null) {
      title = residentAnnouncementTitle(context, announcement);
      subtitle = residentAnnouncementSubtitle(announcement);
      trailing = null;
    } else {
      return const SizedBox.shrink();
    }

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSizes.spacingS),
                  Text(
                    trailing,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
