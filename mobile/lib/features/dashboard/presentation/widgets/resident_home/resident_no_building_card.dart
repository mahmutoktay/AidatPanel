import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/theme/dashboard_screen_style.dart';

/// Sakin daire bağlantısı yokken ana sayfada gösterilen katılım kartı.
class ResidentNoBuildingCard extends StatelessWidget {
  const ResidentNoBuildingCard({
    super.key,
    required this.onJoinTap,
  });

  final VoidCallback onJoinTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
        boxShadow: DashboardScreenStyle.cardShadow,
      ),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.apartment_outlined,
              color: AppColors.chartBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            t.noBuildingTitle,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            t.noBuildingBody,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          SizedBox(
            height: AppSizes.buttonHeightPrimary,
            child: FilledButton.icon(
              onPressed: onJoinTap,
              icon: const Icon(Icons.qr_code_2_rounded),
              label: Text(t.joinBuildingCta),
              style: FilledButton.styleFrom(
                textStyle: AppTypography.button.copyWith(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
