import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_typography.dart';

/// Bina oluştur / kayıtlı IBAN ile uyumlu köşeli buton şekilleri (oval/hap yok).
abstract final class AppButtonStyles {
  static final RoundedRectangleBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
  );

  static final RoundedRectangleBorder sheetTop = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppSizes.buttonRadius),
    ),
  );

  static ButtonStyle elevatedPrimary({bool fullWidth = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: fullWidth
          ? const Size(double.infinity, AppSizes.buttonHeightSecondary)
          : const Size(0, AppSizes.minTouchTarget),
      shape: shape,
      textStyle: AppTypography.button,
    );
  }

  static ButtonStyle outlinedNeutral({bool fullWidth = false}) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      side: const BorderSide(color: AppColors.borderColor, width: 1.5),
      minimumSize: fullWidth
          ? const Size(double.infinity, AppSizes.buttonHeightSecondary)
          : const Size(0, AppSizes.minTouchTarget),
      shape: shape,
      textStyle: AppTypography.button,
    );
  }

  static ButtonStyle outlinedPrimary({bool fullWidth = false}) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      minimumSize: fullWidth
          ? const Size(double.infinity, AppSizes.buttonHeightSecondary)
          : const Size(0, AppSizes.minTouchTarget),
      shape: shape,
      textStyle: AppTypography.button,
    );
  }

  static ButtonStyle filledDanger({bool fullWidth = false}) {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.error,
      foregroundColor: Colors.white,
      minimumSize: fullWidth
          ? const Size(double.infinity, AppSizes.minTouchTarget)
          : const Size(0, AppSizes.minTouchTarget),
      shape: shape,
      textStyle: AppTypography.button,
    );
  }
}
