import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/auth_screen_shell.dart';

/// Onboarding alt aksiyonları — geçiş animasyonunun dışında sabit kalır.
class OnboardingStepActions extends StatelessWidget {
  const OnboardingStepActions({
    super.key,
    this.primaryLabel,
    this.onPrimary,
    this.onBack,
    this.backLabel,
    this.primaryEnabled = true,
    this.isLoading = false,
    this.primaryTrailing,
    this.includeTopSpacing = true,
  });

  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onBack;
  final String? backLabel;
  final bool primaryEnabled;
  final bool isLoading;
  final Widget? primaryTrailing;
  final bool includeTopSpacing;

  bool get _hasActions => primaryLabel != null || onBack != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasActions) return const SizedBox.shrink();

    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (primaryLabel != null)
          AuthScreenShell.primaryBottomBar(
            onPressed: primaryEnabled && !isLoading ? onPrimary : null,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(primaryLabel!),
                      if (primaryTrailing != null) ...[
                        const SizedBox(width: AppSizes.spacingS),
                        primaryTrailing!,
                      ],
                    ],
                  ),
          ),
        if (onBack != null) ...[
          if (primaryLabel != null) const SizedBox(height: AppSizes.spacingS),
          SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: OutlinedButton(
              onPressed: isLoading ? null : onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
              ),
              child: Text(
                backLabel ??
                    MaterialLocalizations.of(context).backButtonTooltip,
                style:
                    AppTypography.body1.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );

    if (!includeTopSpacing) return actions;

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spacingM),
      child: actions,
    );
  }
}
