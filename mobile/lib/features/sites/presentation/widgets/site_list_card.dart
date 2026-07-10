import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/site_entity.dart';

/// Site kartı — minimal: ikon, ad, adres ve gecikmiş daire rozeti.
class SiteListCard extends StatelessWidget {
  final SiteEntity site;
  final VoidCallback? onTap;

  const SiteListCard({
    super.key,
    required this.site,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DashboardScreenStyle.listItemPadding,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
          child: Ink(
            decoration: DashboardScreenStyle.whiteCard(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lineLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.location_city_rounded,
                    color: AppColors.inkDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site.name,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.inkDark,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (site.displayAddress.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          site.displayAddress,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (site.overdueCount > 0) ...[
                  const SizedBox(width: 8),
                  _OverdueBadge(count: site.overdueCount),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: AppColors.statusRed,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AppTypography.caption.copyWith(
              color: AppColors.statusRed,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
