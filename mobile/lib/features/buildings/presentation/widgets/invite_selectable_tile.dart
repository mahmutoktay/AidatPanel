import 'package:flutter/material.dart';
import '../../../../shared/widgets/action_chevron.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';

/// Davet kodu akışında bina/daire seçimi için kullanılan kart.
class InviteSelectableTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  /// Aktif kod kartlarında kalan süre (gün/saat) her zaman alt satırda.
  final String? subtitleLine2;
  final Widget? trailing;
  final VoidCallback onTap;

  const InviteSelectableTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.subtitleLine2,
    this.trailing,
  });

  static final TextStyle _subtitleStyle = AppTypography.body2.copyWith(
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    final tileRadius =
        BorderRadius.circular(DashboardScreenStyle.cardRadius);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard().copyWith(
        borderRadius: tileRadius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: tileRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: tileRadius,
          splashColor: AppColors.border.withValues(alpha: 0.4),
          highlightColor: AppColors.border.withValues(alpha: 0.25),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTargetComfort,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: _subtitleStyle,
                          maxLines: subtitleLine2 == null ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitleLine2 != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleLine2!,
                            style: _subtitleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSizes.spacingS),
                    trailing!,
                  ] else ...[
                    const SizedBox(width: 4),
                    const ActionChevron(
                      size: 22,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
