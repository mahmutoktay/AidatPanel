import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import 'show_app_date_picker.dart';

/// Tarih seçimi — [AppSelectField] ile aynı kutu stili, hibrit takvim diyaloğu.
///
/// Projede tarih seçimi için yalnızca bu widget veya [pickDate] kullanılmalıdır.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  static String formatDayMonthYear(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  /// Herhangi bir ekrandan hibrit takvim diyaloğunu açar.
  static Future<DateTime?> pickDate(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final now = DateTime.now();
    return showAppDatePicker(
      context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(now.year + 2, now.month, now.day),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final picked = await pickDate(
      context,
      initialDate: value,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final canTap = enabled;
    final display = formatDayMonthYear(value);

    return Semantics(
      button: canTap,
      label: label,
      value: display,
      enabled: canTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? () => _openPicker(context) : null,
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
                  color: enabled
                      ? AppColors.textSecondary
                      : AppColors.textDisabled,
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
