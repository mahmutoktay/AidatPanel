import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';

/// Aidatlar sekmesi ortak görsel sabitleri (mockup paleti).
abstract final class DuesScreenStyle {
  static const double cardRadius = DashboardScreenStyle.cardRadius;
  static const double iconBoxRadius = 20.0;
  static const double chipRadius = DashboardScreenStyle.pillRadius;

  static List<BoxShadow> get cardShadow => DashboardScreenStyle.cardShadow;

  /// Kart yüzeyi — `AppColors.surface` ([DashboardScreenStyle.whiteCard]).
  static BoxDecoration whiteCard({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: cardShadow,
      );

  /// [whiteCard] ile aynı — semantik alias.
  static BoxDecoration surfaceCard({Color? color}) => whiteCard(color: color);

  /// Toplam daire sayısına göre durum oranı (0.0–1.0).
  static double statusProgressRatio(int count, int totalUnits) {
    if (totalUnits <= 0) return 0;
    return (count / totalUnits).clamp(0.0, 1.0);
  }
}
