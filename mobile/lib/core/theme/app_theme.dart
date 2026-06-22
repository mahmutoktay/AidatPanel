import 'package:flutter/material.dart';

import 'app_button_styles.dart';
import 'app_color_palette.dart';
import 'app_colors.dart';
import 'app_date_picker_theme.dart';
import 'app_sizes.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData lightTheme() => _buildTheme(AppColorPalette.light);

  static ThemeData darkTheme() => _buildTheme(AppColorPalette.dark);

  static ThemeData _buildTheme(AppColorPalette palette) {
    final isDark = identical(palette, AppColorPalette.dark);
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: palette.primary,
      scaffoldBackgroundColor: palette.dashboardBackground,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: palette.primary,
              onPrimary: palette.datePickerSelectedDayForeground,
              secondary: palette.textSecondary,
              error: AppColors.error,
              surface: palette.surface,
              onSurface: palette.textPrimary,
            )
          : ColorScheme.light(
              primary: palette.primary,
              onPrimary: Colors.white,
              secondary: palette.textSecondary,
              error: AppColors.error,
              surface: palette.surface,
              onSurface: palette.textPrimary,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle:
            AppTypography.h3.copyWith(color: palette.textPrimary),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.elevatedPrimary(
          fullWidth: true,
          palette: palette,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.actionButton,
          foregroundColor: palette.actionButtonForeground,
          minimumSize: const Size(
            double.infinity,
            AppSizes.buttonHeightSecondary,
          ),
          shape: AppButtonStyles.shape,
          textStyle: AppTypography.button.copyWith(
            color: palette.actionButtonForeground,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlinedPrimary(
          fullWidth: true,
          palette: palette,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(AppButtonStyles.shape),
          visualDensity: VisualDensity.standard,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.fill,
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
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle:
            AppTypography.body1.copyWith(color: palette.textDisabled),
        labelStyle: AppTypography.label.copyWith(
          color: palette.textSecondary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge:
            AppTypography.h1.copyWith(color: palette.textPrimary),
        displayMedium:
            AppTypography.h2.copyWith(color: palette.textPrimary),
        displaySmall:
            AppTypography.h3.copyWith(color: palette.textPrimary),
        bodyLarge:
            AppTypography.body1.copyWith(color: palette.textPrimary),
        bodyMedium:
            AppTypography.body2.copyWith(color: palette.textPrimary),
        bodySmall: AppTypography.caption.copyWith(
          color: palette.textSecondary,
        ),
        labelLarge:
            AppTypography.label.copyWith(color: palette.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.navSelected,
        unselectedItemColor: palette.textDisabled,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.fill,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: palette.navSelected,
              size: AppSizes.iconSize,
            );
          }
          return IconThemeData(
            color: palette.textDisabled,
            size: AppSizes.iconSize,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(
              color: palette.navSelected,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTypography.caption.copyWith(
            color: palette.textDisabled,
          );
        }),
      ),
      datePickerTheme: AppDatePickerTheme.dataFor(palette),
      dialogTheme: AppDatePickerTheme.dialogTheme(
        DialogThemeData(backgroundColor: palette.surface),
        palette,
      ),
    );
  }
}
