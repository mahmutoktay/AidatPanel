import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

/// Profil/ayarlar ekranı layout + tipografi (renkler AppColors üzerinden).
abstract final class ProfileSettingsUi {
  static Color get background => AppColors.background;
  static Color get ink => AppColors.ink;
  static Color get muted => AppColors.muted;
  static Color get line => AppColors.line;
  static Border get cardBorder => AppColors.cardBorder;
  static BorderSide get cardBorderSide => AppColors.cardBorderSide;
  static Color get fill => AppColors.fill;
  static const Color danger = AppColors.error;

  static const double avatarSize = 88;
  static const double avatarSizeLarge = 96;
  static const double iconSize = 24;
  static const double rowIconBox = 40;
  static const double buttonHeight = AppSizes.buttonHeightSecondary;
  static const double rowHeight = 58;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 999;

  static const double fieldRadius = 14;
  static Color get fieldFill => AppColors.fill;
  static const double fieldFocusBorderWidth = 1.5;
  static const double fieldIconSize = 22;
  static const double fieldDisabledOpacity = 0.5;
  static const double primaryButtonRadius = 16;

  static const EdgeInsets screenHorizontalPadding =
      AppSizes.screenBodyScrollPadding;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: AppSizes.screenPadding,
    vertical: 18,
  );

  static TextStyle get title => AppTypography.h3.copyWith(
        color: ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get name => AppTypography.h2.copyWith(
        color: ink,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get handle => AppTypography.body1.copyWith(
        color: muted,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get rowTitle => AppTypography.body1.copyWith(
        color: ink,
        fontSize: 17,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get rowTrailing => AppTypography.caption.copyWith(
        color: muted,
        fontSize: 15,
      );

  static TextStyle get fieldLabel => AppTypography.caption.copyWith(
        color: muted,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get fieldValue => AppTypography.body1.copyWith(
        color: ink,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get fieldPlaceholder => fieldValue.copyWith(
        color: AppColors.mutedText,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get fieldLabelUppercase => sectionLabel.copyWith(
        fontSize: 11,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get buttonLabel => AppTypography.button.copyWith(
        color: AppColors.actionButtonForeground,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get sectionLabel => AppTypography.label.copyWith(
        color: muted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      );

  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
        backgroundColor: AppColors.actionButton,
        foregroundColor: AppColors.actionButtonForeground,
        elevation: 0,
        shadowColor: Colors.transparent,
        side: BorderSide.none,
        minimumSize: const Size(double.infinity, buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(primaryButtonRadius),
        ),
        textStyle: buttonLabel,
      );

  static ButtonStyle get dangerOutlinedButton => OutlinedButton.styleFrom(
        foregroundColor: danger,
        side: const BorderSide(color: danger, width: 1),
        minimumSize: const Size(double.infinity, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: rowTitle.copyWith(
          color: danger,
          fontWeight: FontWeight.w700,
        ),
      );
}
