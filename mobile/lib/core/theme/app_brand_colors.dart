import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Logo ile uyumlu marka renkleri (`assets/brand/app_logo.png`).
abstract final class AppBrandColors {
  /// Logo turuncusu — "Aidat" vurgusu.
  static const Color aidatOrange = Color(0xFFFF6600);

  /// Logo laciverti — "Panel" vurgusu (açık zemin).
  static const Color panelNavy = Color(0xFF00235B);

  /// Koyu zeminde okunabilir açık mavi ton (lacivert ailesi).
  static const Color panelNavyOnDark = Color(0xFF6BA3E0);

  static Color panelColor(BuildContext context) {
    return AppColors.isDark ? panelNavyOnDark : panelNavy;
  }
}
