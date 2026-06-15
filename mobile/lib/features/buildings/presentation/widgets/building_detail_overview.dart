import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../models/building_list_item_model.dart';
import '../utils/building_collection_status.dart';
import 'building_summary_card.dart';

/// Bina detay ekranı — kimlik ve metrikler ayrı bloklarda.
class BuildingDetailOverview extends StatelessWidget {
  final BuildingListItemModel item;

  const BuildingDetailOverview({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = BuildingCollectionStatus.fromRate(item.collectionRate);
    final chip = resolveBuildingStatusChip(
      context,
      overdueCount: item.overdueCount,
      pendingCount: item.pendingCount,
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthlyText = NumberFormat.compactCurrency(
      locale: locale,
      symbol: '₺',
      decimalDigits: 0,
    ).format(item.monthlyDues);
    final perUnitText = item.perUnitDues != null
        ? NumberFormat.currency(
            locale: locale,
            symbol: '₺',
            decimalDigits: 0,
          ).format(item.perUnitDues)
        : '—';
    final listT = context.t.features.buildings.list;
    final progress = (item.collectionRate / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BuildingIdentityCard(item: item),
        const SizedBox(height: AppSizes.spacingM),
        _BuildingStatsGrid(
          unitCount: item.unitCount,
          collectionRate: item.collectionRate.round(),
          monthlyText: monthlyText,
        ),
        const SizedBox(height: AppSizes.spacingM),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(BuildingSummaryCard.cardRadius),
            boxShadow: BuildingSummaryCard.cardShadow,
          ),
          padding: const EdgeInsets.all(AppSizes.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.lineLight,
                  valueColor: AlwaysStoppedAnimation<Color>(status.color),
                ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      listT.paidUnitsProgress
                          .replaceAll('{paid}', '${item.paidUnitCount}')
                          .replaceAll('{total}', '${item.unitCount}'),
                      style: AppTypography.label.copyWith(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    listT.perUnitDues.replaceAll('{amount}', perUnitText),
                    style: AppTypography.label.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingM),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: chip.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${chip.emoji} ${chip.label}',
                    style: AppTypography.label.copyWith(
                      color: chip.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            child: const Icon(
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
                  style: AppTypography.h3.copyWith(
                    color: AppColors.inkDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.statusRed.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingStatsGrid extends StatelessWidget {
  final int unitCount;
  final int collectionRate;
  final String monthlyText;

  const _BuildingStatsGrid({
    required this.unitCount,
    required this.collectionRate,
    required this.monthlyText,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final listT = context.t.features.buildings.list;

    final tiles = [
      _StatTileData(
        icon: Icons.door_front_door_outlined,
        iconBg: AppColors.infoBg,
        iconColor: AppColors.chartBlue,
        value: '$unitCount',
        label: t.common.apartmentsBadge,
      ),
      _StatTileData(
        icon: Icons.trending_up,
        iconBg: AppColors.successBg,
        iconColor: AppColors.statusGreen,
        value: '%$collectionRate',
        label: t.common.collection,
        valueColor: AppColors.statusGreen,
      ),
      _StatTileData(
        icon: Icons.payments_outlined,
        iconBg: AppColors.warningBg,
        iconColor: AppColors.chartOrange,
        value: monthlyText,
        label: listT.monthlyDuesShort,
      ),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSizes.spacingS),
            Expanded(child: _DetailStatTile(data: tiles[i])),
          ],
        ],
      ),
    );
  }
}

class _StatTileData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatTileData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueColor,
  });
}

class _DetailStatTile extends StatelessWidget {
  final _StatTileData data;

  const _DetailStatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: BuildingSummaryCard.cardShadow,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, color: data.iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: AppTypography.h3.copyWith(
              color: data.valueColor ?? AppColors.inkDark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: AppTypography.label.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
