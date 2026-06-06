import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';

class AuthTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AuthTextButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.body2.copyWith(
                  color: onTap == null ? AppColors.textDisabled : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
