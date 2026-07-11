import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../utils/dekont_labels.dart';

/// Tek durum kartı — yalnızca ikon + kısa açıklama (başlık yok; rozet hero'da).
class DekontStatusBanner extends StatelessWidget {
  final DekontStatusVisual visual;

  const DekontStatusBanner({super.key, required this.visual});

  @override
  Widget build(BuildContext context) {
    final description = visual.description?.trim();
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: visual.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(visual.icon, color: visual.color, size: 22),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              description,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
