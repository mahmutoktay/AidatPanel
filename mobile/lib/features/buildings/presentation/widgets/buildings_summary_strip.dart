import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../models/building_list_item_model.dart';

/// Tüm binaların toplamını gösteren 4 sütunlu özet şerit.
class BuildingsSummaryStrip extends StatelessWidget {
  final BuildingsSummaryTotals totals;

  const BuildingsSummaryStrip({super.key, required this.totals});

  static const _cardRadius = 20.0;
  static const _valueHeight = 28.0;
  static const _labelHeight = 18.0;
  static const _valueLabelGap = 6.0;

  static List<BoxShadow> get _cardShadow => [];

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings.list;

    final columns = [
      _SummaryColumn(
        value: '${totals.buildingCount}',
        label: t.buildingCount,
      ),
      _SummaryColumn(
        value: '${totals.unitCount}',
        label: t.unitCount,
      ),
      _SummaryColumn(
        value: '${totals.overdueCount}',
        label: t.overdueShort,
        valueColor: totals.overdueCount > 0
            ? AppColors.statusRed
            : AppColors.inkDark,
      ),
      _SummaryColumn(
        value: '%${totals.collectionRate.round()}',
        label: t.collectionShort,
        valueColor: totals.collectionRate > 0
            ? AppColors.statusGreen
            : AppColors.inkDark,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spacingM,
        horizontal: AppSizes.spacingXS,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              if (i > 0)
                Center(
                  child: Container(
                    width: 1,
                    height: _valueHeight + _valueLabelGap + _labelHeight,
                    color: AppColors.lineLight,
                  ),
                ),
              Expanded(child: columns[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _SummaryColumn({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: BuildingsSummaryStrip._valueHeight,
            width: double.infinity,
            child: Center(
              child: Text(
                value,
                style: AppTypography.h3.copyWith(
                  color: valueColor ?? AppColors.inkDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: BuildingsSummaryStrip._valueLabelGap),
          SizedBox(
            height: BuildingsSummaryStrip._labelHeight,
            width: double.infinity,
            child: Center(
              child: Text(
                label,
                style: AppTypography.label.copyWith(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
