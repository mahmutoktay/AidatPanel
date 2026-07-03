import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../theme/dashboard_screen_style.dart';
import '../count_badge.dart';

/// Hızlı işlem kartı — pastel dairesel ikon + başlık + köşe rozeti.
class DashboardQuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const DashboardQuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: DashboardScreenStyle.quickActionIconSize,
                      height: DashboardScreenStyle.quickActionIconSize,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    if (count > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CountBadge(
                          count: count,
                          emphasized: true,
                          color: iconColor,
                          compact: true,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hızlı işlemler bölüm başlığı + kart satırı.
class DashboardQuickActionsRow extends StatelessWidget {
  final String title;
  final List<DashboardQuickActionTile> actions;

  const DashboardQuickActionsRow({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        SizedBox(
          height: DashboardScreenStyle.quickActionRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSizes.spacingS),
                Expanded(child: actions[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
