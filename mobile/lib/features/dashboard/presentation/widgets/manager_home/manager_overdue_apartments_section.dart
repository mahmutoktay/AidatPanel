import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/widgets/action_chevron.dart';
import '../../../domain/entities/manager_dashboard_entities.dart';
import 'manager_overdue_feed_row.dart';

/// Ödemesi geciken aidatlar — sakin Son Hareketler bölümü ile aynı düzen.
class ManagerOverdueApartmentsSection extends StatelessWidget {
  static const int previewLimit = 5;

  final List<ManagerOverdueApartmentItem> items;
  final void Function(ManagerOverdueApartmentItem item)? onRemind;
  final void Function(ManagerOverdueApartmentItem item)? onTap;
  final VoidCallback? onSeeAll;
  final String? remindingDueId;

  const ManagerOverdueApartmentsSection({
    super.key,
    required this.items,
    this.onRemind,
    this.onTap,
    this.onSeeAll,
    this.remindingDueId,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final common = context.t.common;
    final previewItems = items.take(previewLimit).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                t.overdueApartments,
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.chartBlue,
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      common.seeAll,
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const ActionChevron(size: 20),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        if (previewItems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            child: Text(
              t.noOverdueApartments,
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Column(
            children: [
              for (final item in previewItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                  child: ManagerOverdueFeedRow(
                    item: item,
                    onTap: onTap == null ? null : () => onTap!(item),
                    onRemind: onRemind,
                    isReminding: remindingDueId == item.dueId,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
