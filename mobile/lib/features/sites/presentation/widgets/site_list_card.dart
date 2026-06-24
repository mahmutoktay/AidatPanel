import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/compact_number_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/site_entity.dart';

class SiteListCard extends StatelessWidget {
  final SiteEntity site;
  final VoidCallback? onTap;

  const SiteListCard({
    super.key,
    required this.site,
    this.onTap,
  });

  static const cardRadius = 20.0;
  static const statusStripWidth = 6.0;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final locale = LocaleSettings.currentLocale.languageCode;
    final collectedText = CompactNumberFormat.currency(
      site.collectedAmount,
      languageCode: locale,
    );
    final expectedText = AppCurrencyFormat.format(site.expectedAmount);
    final rate = site.collectionRate.round().clamp(0, 100);
    final progress = (rate / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ??
              () => context.push('/manager-dashboard/sites/${site.id}'),
          borderRadius: BorderRadius.circular(cardRadius),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(cardRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.inkDark.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
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
                          AppSizes.spacingM,
                          AppSizes.spacingM,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            color: AppColors.statusRed
                                                .withValues(alpha: 0.85),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              site.displayAddress,
                                              style:
                                                  AppTypography.body2.copyWith(
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
                              ],
                            ),
                            const SizedBox(height: AppSizes.spacingM),
                            Row(
                              children: [
                                _MetricCell(
                                  label: t.blockCount.toUpperCase(),
                                  value: '${site.buildingCount}',
                                ),
                                const SizedBox(width: 24),
                                _MetricCell(
                                  label: t.apartmentCount.toUpperCase(),
                                  value: '${site.totalApartments}',
                                ),
                                const SizedBox(width: 24),
                                _MetricCell(
                                  label: t.collectionRate.toUpperCase(),
                                  value: '%$rate',
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
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.statusGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.collectedExpected
                                      .replaceAll('{collected}', collectedText)
                                      .replaceAll('{expected}', expectedText),
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.mutedText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
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
}

class _MetricCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        ),
      ],
    );
  }
}
