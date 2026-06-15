import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

/// Yönetici / sakin dashboard ortak görsel sabitleri.
abstract final class DashboardScreenStyle {
  static const double cardRadius = 18;
  static const double chipRadius = 22;
  static const double pillRadius = 14;
  static const double iconBoxSize = 32;
  static const double iconBoxRadius = 8;
  static const double quickActionRowHeight = 112;
  static const double quickActionIconSize = 44;
  static const double statTilePadding = 10;
  static const double navActivePillRadius = 20;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.inkDark.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static BoxDecoration whiteCard({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: cardShadow,
      );

  static BoxDecoration statCard({Color? color}) => BoxDecoration(
        color: color ?? AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: subtleShadow,
      );

  static BoxDecoration sectionCard({Color? color}) => whiteCard(color: color);

  static EdgeInsets get listItemPadding =>
      const EdgeInsets.only(bottom: AppSizes.spacingM);
}
