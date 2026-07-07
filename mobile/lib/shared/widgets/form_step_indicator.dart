import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../theme/dashboard_screen_style.dart';

class FormStepDescriptor {
  final String label;
  final IconData icon;

  const FormStepDescriptor({required this.label, required this.icon});
}

/// Çok adımlı form wizard'ları için yatay adım göstergesi.
class FormStepIndicator extends StatelessWidget {
  final List<FormStepDescriptor> steps;
  final int currentStep;

  const FormStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
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
          mainAxisSize: MainAxisSize.min,
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final lineActive = currentStep >= (i ~/ 2) + 1;
              return SizedBox(
                width: 20,
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
            final step = steps[stepIndex];
            return SizedBox(
              width: 72,
              child: Column(
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
                      completed ? Icons.check_rounded : step.icon,
                      size: 18,
                      color: active ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.label,
                    style: AppTypography.caption.copyWith(
                      color:
                          active ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
