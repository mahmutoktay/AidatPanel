import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_typography.dart';

/// Material takvim diyaloğu — AidatPanel marka stili.
abstract final class AppDatePickerTheme {
  static DatePickerThemeData get data => DatePickerThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
        ),
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: AppTypography.h3.copyWith(color: Colors.white),
        headerHelpStyle: AppTypography.caption.copyWith(
          color: Colors.white.withValues(alpha: 0.88),
          fontWeight: FontWeight.w600,
        ),
        weekdayStyle: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        dayStyle: AppTypography.body1.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        yearStyle: AppTypography.body1.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        todayForegroundColor: WidgetStatePropertyAll(AppColors.primary),
        todayBackgroundColor: WidgetStatePropertyAll(AppColors.fill),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) {
            return AppColors.textDisabled;
          }
          return AppColors.textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
          minimumSize: const Size(72, AppSizes.minTouchTarget),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
          minimumSize: const Size(72, AppSizes.minTouchTarget),
        ),
      );

  static DialogThemeData dialogTheme(DialogThemeData base) => base.copyWith(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
        ),
      );
}
