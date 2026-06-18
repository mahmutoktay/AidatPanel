import 'package:flutter/material.dart';
import 'app_button_styles.dart';
import 'app_colors.dart';
import 'app_date_picker_theme.dart';
import 'app_sizes.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.dashboardBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.textSecondary,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.elevatedPrimary(fullWidth: true),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.actionButton,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            AppSizes.buttonHeightSecondary,
          ),
          shape: AppButtonStyles.shape,
          textStyle: AppTypography.button.copyWith(color: Colors.white),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlinedPrimary(fullWidth: true),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(AppButtonStyles.shape),
          visualDensity: VisualDensity.standard,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTypography.body1.copyWith(color: AppColors.textDisabled),
        labelStyle: AppTypography.label.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.h1.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTypography.body1.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTypography.body2.copyWith(color: AppColors.textPrimary),
        bodySmall: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
        labelLarge: AppTypography.label.copyWith(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisabled,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.fill,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: AppSizes.iconSize,
            );
          }
          return const IconThemeData(
            color: AppColors.textDisabled,
            size: AppSizes.iconSize,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTypography.caption.copyWith(color: AppColors.textDisabled);
        }),
      ),
      datePickerTheme: AppDatePickerTheme.data,
      dialogTheme: AppDatePickerTheme.dialogTheme(const DialogThemeData()),
    );
  }
}
