import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CountBadge extends StatelessWidget {
  final int count;
  final bool emphasized;
  final Color color;
  final bool compact;

  const CountBadge({
    super.key,
    required this.count,
    required this.emphasized,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = count.toString();
    if (emphasized) {
      final minSide = compact ? 20.0 : 28.0;
      return Container(
        constraints: BoxConstraints(minWidth: minSide, minHeight: minSide),
        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(compact ? 10 : 14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: compact ? 11 : 14,
          ),
        ),
      );
    }
    return Text(
      text,
      style: AppTypography.caption.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}
