import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Alt sabit Geri butonu — onboarding adımlarında üst ok yerine kullanılır.
class OnboardingBackButton extends StatelessWidget {
  const OnboardingBackButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeightSecondary,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
