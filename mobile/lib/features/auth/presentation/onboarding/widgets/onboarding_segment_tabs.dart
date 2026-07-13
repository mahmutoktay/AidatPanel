import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Adım 2 — Telefon / E-posta sekmeleri (referans pill toggle).
class OnboardingSegmentTabs extends StatelessWidget {
  const OnboardingSegmentTabs({
    super.key,
    required this.isSecondSelected,
    required this.firstLabel,
    required this.secondLabel,
    required this.onFirstTap,
    required this.onSecondTap,
    this.enabled = true,
  });

  /// false → birinci sekme (telefon), true → ikinci sekme (e-posta).
  final bool isSecondSelected;
  final String firstLabel;
  final String secondLabel;
  final VoidCallback onFirstTap;
  final VoidCallback onSecondTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: firstLabel,
              selected: !isSecondSelected,
              onTap: enabled ? onFirstTap : null,
            ),
          ),
          Expanded(
            child: _Tab(
              label: secondLabel,
              selected: isSecondSelected,
              onTap: enabled ? onSecondTap : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.action : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.buttonRadius - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius - 2),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.buttonHeightSmall),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.onAction : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
