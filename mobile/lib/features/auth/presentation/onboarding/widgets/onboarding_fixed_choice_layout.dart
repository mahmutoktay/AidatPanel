import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Rol / deneyim seçim adımları — kartlar sabit bölgede, alt aksiyonlar ekranda.
class OnboardingFixedChoiceLayout extends StatelessWidget {
  const OnboardingFixedChoiceLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.choices,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final Widget choices;
  final bool centerTitle;

  static const _choicesTopGap = AppSizes.spacingXL;

  @override
  Widget build(BuildContext context) {
    final textAlign = centerTitle ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: AppTypography.h2,
                  textAlign: textAlign,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    subtitle!,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: textAlign,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: _choicesTopGap),
        choices,
        const Spacer(),
      ],
    );
  }
}
