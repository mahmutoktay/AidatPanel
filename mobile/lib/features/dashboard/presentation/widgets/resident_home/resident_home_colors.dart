import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Sakin ana sayfa vurgu renkleri — logo marka token’larına bağlı.
abstract final class ResidentHomeColors {
  static Color get blue => AppColors.brand;
  static Color get blueDeep => AppColors.brandSoft;

  static Color get topOrange => AppColors.accent;
  static Color get topRed => AppColors.statusRed;
  static Color get topGreen => AppColors.statusGreen;

  static Color get secondaryOrangeBg =>
      AppColors.isDark ? AppColors.fill : AppColors.paymentCta;
  static Color get secondaryBlueBg =>
      AppColors.isDark ? AppColors.fill : AppColors.statusBlueBg;
}
