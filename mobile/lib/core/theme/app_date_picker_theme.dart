import 'package:flutter/material.dart';

import 'app_color_palette.dart';
import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_typography.dart';

/// Material takvim diyaloğu — AidatPanel marka stili.
abstract final class AppDatePickerTheme {
  static DatePickerThemeData dataFor(AppColorPalette palette) =>
      DatePickerThemeData(
        backgroundColor: palette.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
        ),
        headerBackgroundColor: palette.brand,
        headerForegroundColor: palette.datePickerHeaderForeground,
        headerHeadlineStyle: AppTypography.h3.copyWith(
          color: palette.datePickerHeaderForeground,
        ),
        headerHelpStyle: AppTypography.caption.copyWith(
          color: palette.datePickerHeaderForeground.withValues(alpha: 0.88),
          fontWeight: FontWeight.w600,
        ),
        weekdayStyle: AppTypography.caption.copyWith(
          color: palette.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        dayStyle: AppTypography.body1.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        yearStyle: AppTypography.body1.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        todayForegroundColor: WidgetStatePropertyAll(palette.brand),
        todayBackgroundColor: WidgetStatePropertyAll(palette.fill),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.onAction;
          }
          if (states.contains(WidgetState.disabled)) {
            return palette.textDisabled;
          }
          return palette.textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.action;
          return Colors.transparent;
        }),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: palette.brand,
          textStyle: AppTypography.button,
          minimumSize: const Size(72, AppSizes.minTouchTarget),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: palette.brand,
          textStyle: AppTypography.button,
          minimumSize: const Size(72, AppSizes.minTouchTarget),
        ),
      );

  /// Aktif palet ile (widget katmanı).
  static DatePickerThemeData get data => dataFor(
        AppColors.isDark ? AppColorPalette.dark : AppColorPalette.light,
      );

  static DialogThemeData dialogTheme(
    DialogThemeData base,
    AppColorPalette palette,
  ) =>
      base.copyWith(
        backgroundColor: palette.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
        ),
      );
}
