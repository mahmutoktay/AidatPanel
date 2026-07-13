import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/activity_history_range.dart';

class ActivityHistoryRangeBar extends StatelessWidget {
  const ActivityHistoryRangeBar({
    super.key,
    required this.selected,
    required this.labels,
    required this.onSelected,
  });

  final ActivityHistoryRange selected;
  final Map<ActivityHistoryRange, String> labels;
  final ValueChanged<ActivityHistoryRange> onSelected;

  static const _order = [
    ActivityHistoryRange.today,
    ActivityHistoryRange.thisWeek,
    ActivityHistoryRange.thisMonth,
    ActivityHistoryRange.threeMonths,
    ActivityHistoryRange.sixMonths,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingXS),
      child: Row(
        children: [
          for (var i = 0; i < _order.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSizes.spacingS),
            _RangeChip(
              label: labels[_order[i]] ?? '',
              selected: selected == _order[i],
              onTap: () => onSelected(_order[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.actionButton : AppColors.fill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? AppColors.actionButton
                  : AppColors.border.withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.body2.copyWith(
              color: selected
                  ? AppColors.actionButtonForeground
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
