import 'package:flutter/material.dart';



import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_sizes.dart';

import '../../../../core/theme/app_typography.dart';



/// Profil/ayarlar ekranı layout + tipografi (renkler AppColors üzerinden).

abstract final class ProfileSettingsUi {

  static const Color background = AppColors.background;

  static const Color ink = AppColors.ink;

  static const Color muted = AppColors.muted;

  static const Color line = AppColors.line;

  /// Kart / satır çerçevesi — [AppColors.cardBorder] ile aynı.
  static const Border cardBorder = AppColors.cardBorder;

  static const BorderSide cardBorderSide = AppColors.cardBorderSide;

  static const Color fill = AppColors.fill;

  static const Color danger = AppColors.error;



  static const double avatarSize = 88;

  static const double avatarSizeLarge = 96;

  static const double iconSize = 24;

  static const double rowIconBox = 40;

  static const double buttonHeight = 52;

  static const double rowHeight = 58;

  static const double radiusMd = 12;

  static const double radiusLg = 16;

  static const double radiusPill = 999;



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



  static TextStyle get buttonLabel => AppTypography.button.copyWith(

        color: Colors.white,

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

        backgroundColor: ink,

        foregroundColor: Colors.white,

        elevation: 0,

        shadowColor: Colors.transparent,

        side: BorderSide.none,

        minimumSize: const Size(double.infinity, buttonHeight),

        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),

        shape: RoundedRectangleBorder(

          borderRadius: BorderRadius.circular(radiusMd),

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

