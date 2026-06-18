import 'package:flutter/material.dart';



import 'app_colors.dart';

import 'app_sizes.dart';

import 'app_typography.dart';



/// Monokrom + anlamlı renkli CTA stilleri.

abstract final class AppButtonStyles {

  static final RoundedRectangleBorder shape = RoundedRectangleBorder(

    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),

  );



  static final RoundedRectangleBorder sheetTop = RoundedRectangleBorder(

    borderRadius: BorderRadius.vertical(

      top: Radius.circular(AppSizes.buttonRadius),

    ),

  );



  static ButtonStyle _filled({

    required Color background,

    required Color foreground,

    bool fullWidth = false,

  }) {

    return ElevatedButton.styleFrom(

      backgroundColor: background,

      foregroundColor: foreground,

      elevation: 0,

      shadowColor: Colors.transparent,

      side: BorderSide.none,

      minimumSize: fullWidth

          ? const Size(double.infinity, AppSizes.buttonHeightSecondary)

          : const Size(0, AppSizes.minTouchTarget),

      shape: shape,

      textStyle: AppTypography.button.copyWith(color: foreground),

    );

  }



  /// Güçlü CTA: premium lacivert dolgu + beyaz metin.

  static ButtonStyle elevatedPrimary({bool fullWidth = false}) =>

      _filled(

        background: AppColors.actionButton,

        foreground: Colors.white,

        fullWidth: fullWidth,

      );



  static ButtonStyle elevatedAccent({bool fullWidth = false}) =>

      _filled(

        background: AppColors.accent,

        foreground: Colors.white,

        fullWidth: fullWidth,

      );



  static ButtonStyle elevatedSuccess({bool fullWidth = false}) =>

      _filled(

        background: AppColors.success,

        foreground: Colors.white,

        fullWidth: fullWidth,

      );



  /// Ödeme Yap — hafif sarımsı turuncu.

  static ButtonStyle elevatedPayment({bool fullWidth = false}) =>

      _filled(

        background: AppColors.paymentCta,

        foreground: AppColors.paymentCtaForeground,

        fullWidth: fullWidth,

      );



  static ButtonStyle elevatedInfo({bool fullWidth = false}) =>

      _filled(

        background: AppColors.info,

        foreground: Colors.white,

        fullWidth: fullWidth,

      );



  static ButtonStyle outlinedNeutral({bool fullWidth = false}) {

    return OutlinedButton.styleFrom(

      foregroundColor: AppColors.textPrimary,

      backgroundColor: AppColors.surface,

      side: AppColors.cardBorderSide,

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

      backgroundColor: AppColors.surface,

      side: const BorderSide(
        color: AppColors.primary,
        width: AppSizes.cardBorderWidth,
      ),

      minimumSize: fullWidth

          ? const Size(double.infinity, AppSizes.buttonHeightSecondary)

          : const Size(0, AppSizes.minTouchTarget),

      shape: shape,

      textStyle: AppTypography.button,

    );

  }



  static ButtonStyle outlinedDanger({bool fullWidth = false}) {

    return OutlinedButton.styleFrom(

      foregroundColor: AppColors.error,

      backgroundColor: AppColors.surface,

      side: const BorderSide(
        color: AppColors.error,
        width: AppSizes.cardBorderWidth,
      ),

      minimumSize: fullWidth

          ? const Size(double.infinity, AppSizes.buttonHeightSecondary)

          : const Size(0, AppSizes.minTouchTarget),

      shape: shape,

      textStyle: AppTypography.button,

    );

  }



  static ButtonStyle filledDanger({bool fullWidth = false}) =>

      _filled(

        background: AppColors.error,

        foreground: Colors.white,

        fullWidth: fullWidth,

      );

}

