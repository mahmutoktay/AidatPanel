import 'package:flutter/material.dart';

import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/compact_number_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../buildings/presentation/utils/building_collection_status.dart';
import '../../domain/entities/site_entity.dart';

/// Site kartı — BuildingSummaryCard ile görsel uyumlu.
/// Dinamik durum çubuğu, metrikler, progress bar ve durum rozeti.
class SiteListCard extends StatelessWidget {
  final SiteEntity site;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SiteListCard({
    super.key,
    required this.site,
    this.onTap,
    this.onEdit,
    this.onDelete,
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
    final status = BuildingCollectionStatus.fromRate(site.collectionRate);
    final chip = resolveBuildingStatusChip(
      context,
      overdueCount: site.overdueCount,
      pendingCount: site.pendingCount,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardRadius),
          child: Container(
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
                      color: status.color,
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
                            _buildMetricsBlock(context, status),
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
            Icons.location_city_rounded,
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
                site.name,
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
                      site.displayAddress,
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
        _buildMenu(context),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    final hasActions = onEdit != null || onDelete != null;
    if (!hasActions) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      icon: Icon(
        Icons.more_vert,
        color: AppColors.mutedText,
        size: AppSizes.iconSize,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: AppSizes.minTouchTarget,
        minHeight: AppSizes.minTouchTarget,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
          case 'delete':
            onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Text(context.t.common.edit),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            context.t.common.delete,
            style: const TextStyle(color: AppColors.statusRed),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsBlock(
    BuildContext context,
    BuildingCollectionStatus status,
  ) {
    final t = context.t.features.sites;
    final progress = (site.collectionRate / 100).clamp(0.0, 1.0);
    final locale = LocaleSettings.currentLocale.languageCode;
    final collectedText = CompactNumberFormat.currency(
      site.collectedAmount,
      languageCode: locale,
    );
    final expectedText = AppCurrencyFormat.format(site.expectedAmount);

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
                  label: t.blockCount.toUpperCase(),
                  value: '${site.buildingCount}',
                ),
                const SizedBox(width: metricGap),
                _MetricCell(
                  width: metricCol2Width,
                  label: t.apartmentCount.toUpperCase(),
                  value: '${site.totalApartments}',
                ),
                const SizedBox(width: metricGap),
                _MetricCell(
                  width: metricCol3Width,
                  label: t.collectionRate.toUpperCase(),
                  value: '%${site.collectionRate.round()}',
                  valueColor: AppColors.statusGreen,
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
                    t.collectedExpected
                        .replaceAll('{collected}', collectedText)
                        .replaceAll('{expected}', expectedText),
                    style: AppTypography.label.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
