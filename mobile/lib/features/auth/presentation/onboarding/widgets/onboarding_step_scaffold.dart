import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Onboarding form adımı — başlık + gövde (kaydırma üst scaffold’da).
class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
  });

  final String title;
  final String? subtitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTypography.h2),
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.spacingS),
          Text(
            subtitle!,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.spacingL),
        body,
      ],
    );
  }
}
