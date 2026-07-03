import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/action_chevron.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/strings.g.dart';
import '../theme/dashboard_screen_style.dart';

/// Liste ekranları için kompakt filtre tetikleyicisi — bina seçici kartıyla uyumlu.
class PremiumFilterButton extends StatelessWidget {
  const PremiumFilterButton({
    super.key,
    required this.onPressed,
    this.hasActiveFilters = false,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final bool hasActiveFilters;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final label = context.t.common.filter;

    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(DashboardScreenStyle.cardRadius),
              boxShadow: DashboardScreenStyle.cardShadow,
              border: hasActiveFilters
                  ? Border.all(
                      color: AppColors.inkDark.withValues(alpha: 0.14),
                    )
                  : null,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: hasActiveFilters
                            ? AppColors.inkDark.withValues(alpha: 0.08)
                            : AppColors.dashboardBackground,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: enabled
                            ? (hasActiveFilters
                                ? AppColors.inkDark
                                : AppColors.mutedText)
                            : AppColors.mutedText.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.body2.copyWith(
                          color: enabled
                              ? AppColors.inkDark
                              : AppColors.mutedText,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppColors.inkDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    const ActionChevron(
                      direction: ChevronDirection.down,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
