import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../shared/theme/dashboard_screen_style.dart';

/// Dashboard bölümleri için ortak beyaz kart (mockup: radius 16 + hafif gölge).
class ManagerDashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ManagerDashboardCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: DashboardScreenStyle.whiteCard(color: AppColors.background),
      padding: padding ?? const EdgeInsets.all(AppSizes.spacingM),
      child: child,
    );
  }
}

/// Bölüm başlığı + opsiyonel sağ rozet.
class ManagerDashboardSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const ManagerDashboardSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSizes.spacingS),
          trailing!,
        ],
      ],
    );
  }
}

/// Küçük gri filtre/pill rozeti.
class ManagerDashboardPill extends StatelessWidget {
  final String label;

  const ManagerDashboardPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
      ),
    );
  }
}
