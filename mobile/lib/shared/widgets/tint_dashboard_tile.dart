import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// Dashboard özet ve hızlı işlem kutuları — yönetici / sakin ana sayfa ortak stili.
class TintDashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tint;
  final String value;
  final VoidCallback? onTap;

  const TintDashboardTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              color: tint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tint.withValues(alpha: 0.22)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: tint, size: 16),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [tint.withValues(alpha: 0.14), tint.withValues(alpha: 0.06)],
      ),
      borderRadius: radius,
      border: Border.all(color: tint.withValues(alpha: 0.22)),
    );

    if (onTap == null) {
      return Container(decoration: decoration, child: content);
    }

    return Container(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: tint.withValues(alpha: 0.12),
          highlightColor: tint.withValues(alpha: 0.06),
          child: content,
        ),
      ),
    );
  }
}
