import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// Form / wizard aksiyonları — Geri (sol) | Birincil (sağ), form öğelerinin hemen altında.
class FormStepActions extends StatelessWidget {
  const FormStepActions({
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

    final primaryChild = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.onAction,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (primaryLabel != null) Text(primaryLabel!),
              if (primaryTrailing != null) ...[
                const SizedBox(width: AppSizes.spacingS),
                primaryTrailing!,
              ],
            ],
          );

    final Widget actions;
    if (primaryLabel != null && onBack != null) {
      actions = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
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
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: SizedBox(
              height: AppSizes.buttonHeightSecondary,
              child: FilledButton(
                onPressed: primaryEnabled && !isLoading ? onPrimary : null,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                ),
                child: primaryChild,
              ),
            ),
          ),
        ],
      );
    } else if (primaryLabel != null) {
      actions = SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeightSecondary,
        child: FilledButton(
          onPressed: primaryEnabled && !isLoading ? onPrimary : null,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
            ),
          ),
          child: primaryChild,
        ),
      );
    } else {
      actions = SizedBox(
        width: double.infinity,
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
            backLabel ?? MaterialLocalizations.of(context).backButtonTooltip,
            style: AppTypography.body1.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    if (!includeTopSpacing) return actions;

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spacingL),
      child: actions,
    );
  }
}
