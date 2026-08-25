import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// OTP ve davet kodu hücreleri — ortak dikdörtgen çerçeve + gölge (açık/koyu).
abstract final class CodeInputCellStyle {
  static const double radius = 8;
  static const double height = 60;
  static const double idleBorderWidth = 1.75;
  static const double focusedBorderWidth = 2.25;

  static Color get _idleBorder => AppColors.isDark
      ? AppColors.ink.withValues(alpha: 0.42)
      : AppColors.ink.withValues(alpha: 0.28);

  static Color get _idleShadow => AppColors.isDark
      ? Colors.black.withValues(alpha: 0.55)
      : AppColors.ink.withValues(alpha: 0.16);

  static Color get _focusedShadow => AppColors.isDark
      ? AppColors.brand.withValues(alpha: 0.4)
      : AppColors.brand.withValues(alpha: 0.22);

  static BoxDecoration decoration({required bool focused}) {
    return BoxDecoration(
      color: AppColors.isDark ? AppColors.fill : AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: focused ? AppColors.brand : _idleBorder,
        width: focused ? focusedBorderWidth : idleBorderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: focused ? _focusedShadow : _idleShadow,
          blurRadius: focused ? 10 : 7,
          offset: const Offset(0, 3),
          spreadRadius: focused ? 0.5 : 0,
        ),
      ],
    );
  }
}
