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
      primaryColor: palette.action,
      scaffoldBackgroundColor: palette.dashboardBackground,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: palette.action,
              onPrimary: palette.onAction,
              secondary: palette.accent,
              onSecondary: palette.onAction,
              tertiary: palette.brandSoft,
              error: AppColors.error,
              surface: palette.surface,
              onSurface: palette.ink,
            )
          : ColorScheme.light(
              primary: palette.action,
              onPrimary: palette.onAction,
              secondary: palette.accent,
              onSecondary: palette.onAction,
              tertiary: palette.brandSoft,
              error: AppColors.error,
              surface: palette.surface,
              onSurface: palette.ink,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle:
            AppTypography.h3.copyWith(color: palette.ink),
        iconTheme: IconThemeData(color: palette.ink),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.elevatedPrimary(
          fullWidth: true,
          palette: palette,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.action,
          foregroundColor: palette.onAction,
          minimumSize: const Size(
            double.infinity,
            AppSizes.buttonHeightSecondary,
          ),
          shape: AppButtonStyles.shape,
          textStyle: AppTypography.button.copyWith(
            color: palette.onAction,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.action,
        foregroundColor: palette.onAction,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
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
          foregroundColor: palette.brand,
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
          borderSide: BorderSide(color: palette.brand, width: 1.5),
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
            AppTypography.h1.copyWith(color: palette.ink),
        displayMedium:
            AppTypography.h2.copyWith(color: palette.ink),
        displaySmall:
            AppTypography.h3.copyWith(color: palette.ink),
        bodyLarge:
            AppTypography.body1.copyWith(color: palette.ink),
        bodyMedium:
            AppTypography.body2.copyWith(color: palette.ink),
        bodySmall: AppTypography.caption.copyWith(
          color: palette.textSecondary,
        ),
        labelLarge:
            AppTypography.label.copyWith(color: palette.ink),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.brand,
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
              color: palette.brand,
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
              color: palette.brand,
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
