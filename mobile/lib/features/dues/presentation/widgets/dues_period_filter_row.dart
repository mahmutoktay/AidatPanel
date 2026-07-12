import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../utils/dues_ui_helpers.dart';

/// Aidat sekmesi — Filtrele butonu yerine kompakt ay / yıl seçicileri.
class DuesPeriodFilterRow extends StatelessWidget {
  const DuesPeriodFilterRow({
    super.key,
    required this.month,
    required this.year,
    required this.yearOptions,
    required this.onMonthChanged,
    required this.onYearChanged,
    this.enabled = true,
  });

  final int? month;
  final int? year;
  final List<int> yearOptions;
  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<int?> onYearChanged;
  final bool enabled;

  static const double _height = AppSizes.minTouchTarget;

  @override
  Widget build(BuildContext context) {
    final common = context.t.common;
    return SizedBox(
      height: _height,
      child: Row(
        children: [
          Expanded(
            child: _PeriodChip(
              label: month == null ? common.allMonths : monthName(context, month!),
              enabled: enabled,
              onTap: () => _pickMonth(context),
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: _PeriodChip(
              label: year == null ? common.allYears : '$year',
              enabled: enabled,
              onTap: () => _pickYear(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    if (!enabled) return;
    final common = context.t.common;
    final allToken = Object();
    final picked = await showPremiumSingleSelectPicker<Object?>(
      context: context,
      title: common.month,
      selected: month ?? allToken,
      options: [
        PremiumFilterPickerOption(
          value: allToken,
          label: common.allMonths,
          icon: Icons.calendar_view_month_outlined,
        ),
        for (var m = 1; m <= 12; m++)
          PremiumFilterPickerOption(
            value: m,
            label: monthName(context, m),
            icon: Icons.event_outlined,
          ),
      ],
    );
    if (picked == null) return;
    onMonthChanged(identical(picked, allToken) ? null : picked as int);
  }

  Future<void> _pickYear(BuildContext context) async {
    if (!enabled) return;
    final common = context.t.common;
    final allToken = Object();
    final picked = await showPremiumSingleSelectPicker<Object?>(
      context: context,
      title: common.year,
      selected: year ?? allToken,
      options: [
        PremiumFilterPickerOption(
          value: allToken,
          label: common.allYears,
          icon: Icons.date_range_outlined,
        ),
        for (final y in yearOptions)
          PremiumFilterPickerOption(
            value: y,
            label: '$y',
            icon: Icons.calendar_today_outlined,
          ),
      ],
    );
    if (picked == null) return;
    onYearChanged(identical(picked, allToken) ? null : picked as int);
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body2.copyWith(
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.mutedText.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: enabled
                      ? AppColors.textSecondary
                      : AppColors.mutedText.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
