import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../theme/dashboard_screen_style.dart';
import '../animated_rolling_value.dart';

/// Özet istatistik kartı — pastel ikon kutusu + büyük rakam + gri etiket.
class DashboardStatTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color? valueColor;
  final num? rollingValue;
  final String rollingPrefix;
  final String rollingSuffix;
  final Duration rollingDelay;
  final String Function(num value)? rollingFormatter;

  const DashboardStatTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueColor,
    this.rollingValue,
    this.rollingPrefix = '',
    this.rollingSuffix = '',
    this.rollingDelay = Duration.zero,
    this.rollingFormatter,
  });
  @override
  Widget build(BuildContext context) {
    final valueStyle = AppTypography.h3.copyWith(
      color: valueColor ?? AppColors.textPrimary,
      fontWeight: FontWeight.w800,
      fontSize: 17,
      height: 1.1,
    );

    Widget valueWidget;
    if (rollingValue != null) {
      valueWidget = AnimatedRollingValue(
        target: rollingValue!,
        prefix: rollingPrefix,
        suffix: rollingSuffix,
        delay: rollingDelay,
        formatter: rollingFormatter,
        style: valueStyle,
      );
    } else {
      valueWidget = Text(
        value,
        style: valueStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      decoration: DashboardScreenStyle.statCard(),
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardScreenStyle.statTilePadding,
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: DashboardScreenStyle.iconBoxSize,
            height: DashboardScreenStyle.iconBoxSize,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius:
                  BorderRadius.circular(DashboardScreenStyle.iconBoxRadius),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                valueWidget,
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Yatay özet kart satırı — eşit genişlikte [DashboardStatTile] listesi.
class DashboardStatRow extends StatelessWidget {
  final List<DashboardStatTile> tiles;

  const DashboardStatRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSizes.spacingS),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }
}
