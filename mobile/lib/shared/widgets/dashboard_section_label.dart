import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// Küçük gri bölüm etiketi — bina seçici ve sakin feed ile aynı görsel dil.
class DashboardSectionLabel extends StatelessWidget {
  const DashboardSectionLabel({
    super.key,
    required this.label,
    this.padding,
  });

  final String label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.fromLTRB(
            AppSizes.spacingL,
            AppSizes.spacingS,
            AppSizes.spacingL,
            AppSizes.spacingXS,
          ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.mutedText,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
