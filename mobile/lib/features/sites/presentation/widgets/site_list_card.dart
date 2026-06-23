import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../buildings/presentation/widgets/building_summary_card.dart';
import '../../domain/entities/site_entity.dart';

class SiteListCard extends StatelessWidget {
  const SiteListCard({super.key, required this.site});

  final SiteEntity site;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    return Material(
      color: AppColors.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(BuildingSummaryCard.cardRadius),
      child: InkWell(
        onTap: () => context.push('/manager-dashboard/sites/${site.id}'),
        borderRadius: BorderRadius.circular(BuildingSummaryCard.cardRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          padding: const EdgeInsets.all(AppSizes.spacingM),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(BuildingSummaryCard.cardRadius),
            border: Border.all(color: AppColors.lineLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.domain, color: AppColors.primary),
                  const SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: Text(
                      site.name,
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.mutedText),
                ],
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                site.displayAddress,
                style: AppTypography.body2.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                '${site.buildingCount} ${t.blockCount} · %${site.collectionRate.toStringAsFixed(0)} ${context.t.common.duesCollection}',
                style: AppTypography.body2.copyWith(
                  color: AppColors.inkDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
