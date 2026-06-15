import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import 'dues_screen_style.dart';

class DuesPeriodChips extends StatelessWidget {
  final int? selectedMonth;
  final int? selectedYear;
  final List<int> years;
  final bool enabled;
  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<int?> onYearChanged;
  final String Function(int month) monthLabel;

  const DuesPeriodChips({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.years,
    required this.enabled,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final monthText = selectedMonth == null
        ? context.t.common.allMonths
        : monthLabel(selectedMonth!);
    final yearText =
        selectedYear == null ? context.t.common.allYears : '$selectedYear';

    return Row(
      children: [
        Expanded(
          child: _PeriodChip(
            topLabel: context.t.common.monthChipLabel,
            value: monthText,
            enabled: enabled,
            onTap: () => _showMonthPicker(context),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: _PeriodChip(
            topLabel: context.t.common.yearChipLabel,
            value: yearText,
            enabled: enabled,
            onTap: () => _showYearPicker(context),
          ),
        ),
      ],
    );
  }

  void _showMonthPicker(BuildContext context) {
    if (!enabled) return;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                child: Text(
                  context.t.common.month,
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkDark,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 13,
                  itemBuilder: (_, i) {
                    final month = i == 0 ? null : i;
                    final label = month == null
                        ? context.t.common.allMonths
                        : monthLabel(month);
                    final selected = selectedMonth == month;
                    return ListTile(
                      minTileHeight: AppSizes.minTouchTarget,
                      title: Text(
                        label,
                        style: AppTypography.body1.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.inkDark,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.inkDark,
                            )
                          : null,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onMonthChanged(month);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showYearPicker(BuildContext context) {
    if (!enabled) return;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                child: Text(
                  context.t.common.year,
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkDark,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: years.length + 1,
                  itemBuilder: (_, i) {
                    final year = i == 0 ? null : years[i - 1];
                    final label =
                        year == null ? context.t.common.allYears : '$year';
                    final selected = selectedYear == year;
                    return ListTile(
                      minTileHeight: AppSizes.minTouchTarget,
                      title: Text(
                        label,
                        style: AppTypography.body1.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.inkDark,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.inkDark,
                            )
                          : null,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onYearChanged(year);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String topLabel;
  final String value;
  final bool enabled;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.topLabel,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(DuesScreenStyle.chipRadius),
        child: Ink(
          decoration: DuesScreenStyle.whiteCard(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topLabel,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.inkDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.mutedText.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
