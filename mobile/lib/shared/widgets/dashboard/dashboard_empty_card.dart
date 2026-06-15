import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../theme/dashboard_screen_style.dart';

/// Boş durum — beyaz kart içinde ortalanmış ikon + metin (donut kart stili).
class DashboardEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconBg;
  final Color? iconColor;

  const DashboardEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconBg,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: DashboardScreenStyle.whiteCard(color: AppColors.background),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spacingXL,
        horizontal: AppSizes.spacingM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBg ?? AppColors.infoBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor ?? AppColors.chartBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            title,
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.spacingS),
            Text(
              subtitle!,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
