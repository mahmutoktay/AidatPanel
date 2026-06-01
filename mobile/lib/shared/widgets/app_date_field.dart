import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// Tarih seçimi — [AppSelectField] ile aynı kutu stili.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final DateTime value;
  final VoidCallback? onTap;
  final bool enabled;

  static String formatDayMonthYear(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && onTap != null;
    final display = formatDayMonthYear(value);

    return Semantics(
      button: canTap,
      label: label,
      value: display,
      enabled: canTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? onTap : null,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTargetComfort,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingS,
            ),
            decoration: BoxDecoration(
              color: enabled ? AppColors.surface : AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              border: AppColors.cardBorder,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          color: enabled
                              ? AppColors.textSecondary
                              : AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        display,
                        style: AppTypography.body1.copyWith(
                          color: enabled
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color:
                      enabled ? AppColors.textSecondary : AppColors.textDisabled,
                  size: AppSizes.iconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
