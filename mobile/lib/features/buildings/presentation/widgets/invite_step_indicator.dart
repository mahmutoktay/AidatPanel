import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';

/// Davet kodu akışı için 3 adımlı görsel adım göstergesi.
class InviteStepIndicator extends StatelessWidget {
  final int currentStep;
  final bool includeSiteStep;

  const InviteStepIndicator({
    super.key,
    required this.currentStep,
    this.includeSiteStep = false,
  });

  @override
  Widget build(BuildContext context) {
    final steps = <(String, IconData)>[
      if (includeSiteStep) (context.t.common.stepSite, Icons.domain_rounded),
      (context.t.common.stepBuilding, Icons.apartment_rounded),
      (context.t.common.stepApartment, Icons.door_front_door_outlined),
      (context.t.common.stepCode, Icons.qr_code_2_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.dashboardScreenPaddingHorizontal,
        AppSizes.spacingM,
        AppSizes.dashboardScreenPaddingHorizontal,
        AppSizes.spacingS,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingM,
        ),
        decoration: DashboardScreenStyle.whiteCard(),
        child: Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final lineActive = currentStep >= (i ~/ 2) + 1;
              return Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 18),
                  color: lineActive
                      ? AppColors.primary
                      : AppColors.borderColor.withValues(alpha: 0.35),
                ),
              );
            }
            final stepIndex = i ~/ 2;
            final active = currentStep >= stepIndex;
            final completed = currentStep > stepIndex;
            final (label, icon) = steps[stepIndex];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active
                          ? AppColors.primary
                          : AppColors.borderColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    completed ? Icons.check_rounded : icon,
                    size: 18,
                    color: active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: active ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
