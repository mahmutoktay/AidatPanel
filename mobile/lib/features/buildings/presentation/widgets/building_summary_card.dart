import 'package:flutter/material.dart';

import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/compact_number_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../models/building_list_item_model.dart';
import '../utils/building_collection_status.dart';

/// Bina özet kartı — liste ve detay ekranlarında ortak görsel dil.
class BuildingSummaryCard extends StatelessWidget {
  final BuildingListItemModel item;
  final Widget? trailing;

  const BuildingSummaryCard({
    super.key,
    required this.item,
    this.trailing,
  });

  static const cardRadius = 20.0;
  static const statusStripWidth = 6.0;
  static const metricGap = 26.0;
  static const metricCol1Width = 58.0;
  static const metricCol2Width = 76.0;
  static const metricCol3Width = 98.0;

  static double get metricsBlockWidth =>
      metricCol1Width + metricCol2Width + metricCol3Width + (2 * metricGap);

  static List<BoxShadow> get cardShadow => [];

  @override
  Widget build(BuildContext context) {
    final status = BuildingCollectionStatus.fromRate(item.collectionRate);
    final chip = resolveBuildingStatusChip(
      context,
      overdueCount: item.overdueCount,
      pendingCount: item.pendingCount,
    );
    final locale = LocaleSettings.currentLocale.languageCode;
    final monthlyText = CompactNumberFormat.currency(
      item.monthlyDues,
      languageCode: locale,
    );
    final perUnitText = item.perUnitDues != null
        ? AppCurrencyFormat.format(item.perUnitDues!, decimalDigits: 0)
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: statusStripWidth,
                color: AppColors.primary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.spacingM,
                    AppSizes.spacingM,
                    AppSizes.spacingS,
                    AppSizes.spacingM,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: AppSizes.spacingM),
                      _buildMetricsBlock(
                        context,
                        status,
                        monthlyText,
                        perUnitText,
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                      _buildStatusChip(chip),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            Icons.apartment_rounded,
            color: AppColors.inkDark,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTypography.body1.copyWith(
                  color: AppColors.inkDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.statusRed.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.address,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildMetricsBlock(
    BuildContext context,
    BuildingCollectionStatus status,
    String monthlyText,
    String perUnitText,
  ) {
    final t = context.t;
    final listT = context.t.features.buildings.list;
    final progress = (item.collectionRate / 100).clamp(0.0, 1.0);

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: metricsBlockWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricCell(
                  width: metricCol1Width,
                  label: t.common.apartment.toUpperCase(),
                  value: '${item.unitCount}',
                ),
                const SizedBox(width: metricGap),
                _MetricCell(
                  width: metricCol2Width,
                  label: t.common.collection.toUpperCase(),
                  value: '%${item.collectionRate.round()}',
                  valueColor: AppColors.statusGreen,
                ),
                const SizedBox(width: metricGap),
                _MetricCell(
                  width: metricCol3Width,
                  label: listT.monthlyDuesShort.toUpperCase(),
                  value: monthlyText,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.lineLight,
                valueColor: AlwaysStoppedAnimation<Color>(status.color),
              ),
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildingStatusChip chip) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}

class _MetricCell extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricCell({
    required this.width,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: valueColor ?? AppColors.inkDark,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
