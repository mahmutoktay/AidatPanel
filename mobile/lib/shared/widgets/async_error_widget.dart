import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/strings.g.dart';

class AsyncErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? title;
  final IconData icon;

  const AsyncErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.title,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSizes.screenBodyScrollPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, color: AppColors.error, size: 44),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              title ?? context.t.common.loadFailed,
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              message,
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingL),
            SizedBox(
              height: AppSizes.buttonHeightSecondary,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(context.t.features.buildings.tekrarDene),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionButton,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
