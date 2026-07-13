import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import 'welcome_illustrations.dart';

class WelcomeOnboardingPage extends StatelessWidget {
  const WelcomeOnboardingPage({
    super.key,
    required this.kind,
    required this.title,
    required this.description,
    required this.semanticsLabel,
  });

  final WelcomeIllustrationKind kind;
  final String title;
  final String description;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: WelcomeIllustration(kind: kind),
            ),
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.spacingM),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
