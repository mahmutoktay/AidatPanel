import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/strings.g.dart';
import '../../../features/profile/presentation/theme/profile_settings_ui.dart';
import 'dashboard_notification_button.dart';
import '../profile_avatar.dart';

/// Dashboard üst şerit — profil (sol), rol başlığı (orta), bildirim (sağ).
class DashboardAppBar extends StatelessWidget {
  final String roleTitle;
  final String userName;
  final bool showWelcome;
  final VoidCallback onProfileTap;

  const DashboardAppBar({
    super.key,
    required this.roleTitle,
    required this.userName,
    required this.onProfileTap,
    this.showWelcome = false,
  });

  @override
  Widget build(BuildContext context) {
    final welcomePrefix = context.t.common.welcome;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ProfileAvatar(
              size: AppSizes.minTouchTarget,
              userName: userName,
              onTap: onProfileTap,
            ),
            Expanded(
              child: Text(
                roleTitle,
                textAlign: TextAlign.center,
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const DashboardNotificationButton(),
          ],
        ),
        if (showWelcome) ...[
          const SizedBox(height: AppSizes.spacingS),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$welcomePrefix, ',
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
    );
  }
}

/// Menü sekmesi bölüm başlığı.
class MenuSectionTitle extends StatelessWidget {
  final String title;

  const MenuSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.spacingXS,
        bottom: AppSizes.spacingS,
      ),
      child: Text(
        title,
        style: ProfileSettingsUi.handle.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
