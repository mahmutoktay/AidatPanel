import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../dashboard/domain/entities/manager_dashboard_entities.dart';
import '../../../dashboard/presentation/widgets/manager_home/manager_dues_summary_card.dart';
import '../models/building_list_item_model.dart';
import 'building_summary_card.dart';

/// Bina detay ekranı — kimlik kartı + bankacılık tarzı aidat özeti.
class BuildingDetailOverview extends StatelessWidget {
  final BuildingListItemModel item;
  final ManagerDuesAmountSummary summary;
  final String currency;
  final Map<String, List<String>>? remindDueIdsByBuilding;

  const BuildingDetailOverview({
    super.key,
    required this.item,
    required this.summary,
    this.currency = 'TRY',
    this.remindDueIdsByBuilding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BuildingIdentityCard(item: item),
        const SizedBox(height: AppSizes.spacingM),
        ManagerDuesSummaryCard(
          summary: summary,
          currency: currency,
          remindDueIdsByBuilding: remindDueIdsByBuilding,
        ),
      ],
    );
  }
}

class _BuildingIdentityCard extends StatelessWidget {
  final BuildingListItemModel item;

  const _BuildingIdentityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(BuildingSummaryCard.cardRadius),
        boxShadow: BuildingSummaryCard.cardShadow,
      ),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.lineLight,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.apartment_rounded,
              color: AppColors.inkDark,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.sectionTitle.copyWith(
                    color: AppColors.inkDark,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.address.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.address,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
