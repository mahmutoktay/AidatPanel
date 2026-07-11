import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Onboarding form adımı — başlık + gövde; birincil CTA üst scaffold’daki
/// [FormStepActions] ile formun hemen altında gösterilir.
class AuthStepScaffold extends StatelessWidget {
  const AuthStepScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryEnabled = true,
    this.isLoading = false,
    this.footer,
    this.secondary,
    this.centerBody = false,
    this.primaryTrailing,
    @Deprecated('CTA form altında FormStepActions ile verilir')
    this.showPrimaryBar = false,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryEnabled;
  final bool isLoading;
  final Widget? footer;
  final Widget? secondary;
  final bool centerBody;
  final Widget? primaryTrailing;
  final bool showPrimaryBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centerBody
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (centerBody)
          Text(title, style: AppTypography.h2, textAlign: TextAlign.center)
        else
          Text(title, style: AppTypography.h2),
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.spacingS),
          Text(
            subtitle!,
            textAlign: centerBody ? TextAlign.center : TextAlign.start,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.spacingL),
        body,
        if (footer != null) ...[
          const SizedBox(height: AppSizes.spacingM),
          footer!,
        ],
        if (secondary != null) ...[
          const SizedBox(height: AppSizes.spacingM),
          secondary!,
        ],
      ],
    );
  }
}
