import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/strings.g.dart';
import 'dashboard_notification_button.dart';

/// Dashboard üst başlığı — rol başlığı + hoş geldiniz + dairesel bildirim.
class DashboardPageHeader extends StatelessWidget {
  final String title;
  final String userName;
  final bool showWelcome;

  const DashboardPageHeader({
    super.key,
    required this.title,
    required this.userName,
    this.showWelcome = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.common;

    return Row(
      crossAxisAlignment: showWelcome ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  height: 1.1,
                ),
              ),
              if (showWelcome) ...[
                const SizedBox(height: AppSizes.spacingXS),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${t.welcome}, ',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                      TextSpan(
                        text: userName,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        const DashboardNotificationButton(),
      ],
    );
  }
}
