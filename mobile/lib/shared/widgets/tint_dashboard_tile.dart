import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// Dashboard özet ve hızlı işlem kutuları — monokrom kart, renkli metin vurgusu.
class TintDashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const TintDashboardTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = valueColor ?? iconColor ?? AppColors.textPrimary;
    final iconTint = iconColor ?? accent;
    final valueTint = valueColor ?? accent;
    final radius = BorderRadius.circular(AppSizes.cardRadius);

    final content = Padding(
      padding: const EdgeInsets.all(AppSizes.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconTint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: iconTint.withValues(alpha: 0.22)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconTint, size: 16),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: valueTint,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    final decoration = BoxDecoration(
      color: AppColors.surface,
      borderRadius: radius,
      border: AppColors.cardBorder,
    );

    if (onTap == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: decoration,
        child: content,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.fill,
          highlightColor: AppColors.fill.withValues(alpha: 0.6),
          child: content,
        ),
      ),
    );
  }
}
