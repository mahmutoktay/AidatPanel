import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Numaralı daireler + bağlantı çizgisi — referans 6 adımlı progress bar.
class AuthProgressIndicator extends StatelessWidget {
  const AuthProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
  });

  final int currentIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    if (totalSteps <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            final stepBefore = i ~/ 2;
            final lineActive = stepBefore < currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: lineActive ? AppColors.action : AppColors.border,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final active = stepIndex <= currentIndex;
          final isCurrent = stepIndex == currentIndex;
          return _StepDot(
            number: stepIndex + 1,
            active: active,
            isCurrent: isCurrent,
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.active,
    required this.isCurrent,
  });

  final int number;
  final bool active;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final fill = active ? AppColors.action : AppColors.surface;
    final border = isCurrent || active ? AppColors.action : AppColors.border;
    final textColor = active ? AppColors.onAction : AppColors.textSecondary;

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: border, width: isCurrent ? 2 : 1),
      ),
      child: Text(
        '$number',
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
