import 'package:flutter/material.dart';
import '../../../../shared/widgets/action_chevron.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../buildings/presentation/utils/building_collection_status.dart';
import '../../data/sites_store.dart';
import '../../domain/entities/site_entity.dart';

class SiteDetailScreen extends ConsumerWidget {
  final String siteId;

  const SiteDetailScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.features.sites;
    final detailAsync = ref.watch(siteDetailProvider(siteId));

    return DashboardSecondaryScaffold(
      title: t.siteDetailTitle,
      fallbackRoute: '/manager-dashboard',
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(userFacingError(e))),
        data: (detail) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(siteDetailProvider(siteId));
            await ref.read(siteDetailProvider(siteId).future);
          },
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSizes.screenBodyScrollPadding,
            children: [
              _SiteIdentityCard(site: detail.site),
              const SizedBox(height: AppSizes.spacingM),
              _SiteStatsGrid(site: detail.site, aggregation: detail.aggregation),
              const SizedBox(height: AppSizes.spacingM),
              _SiteProgressCard(site: detail.site, aggregation: detail.aggregation),
              const SizedBox(height: AppSizes.spacingM),
              _ActionRow(
                onExpenses: () => context.push(
                  '/manager-dashboard/sites/$siteId/expenses',
                ),
                onReport: () => _showReportSheet(context, siteId, detail.site.name),
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                t.blocksTitle,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.inkDark,
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              if (detail.buildings.isEmpty)
                Text(
                  t.noBlocks,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.mutedText,
                  ),
                )
              else
                ...detail.buildings.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                    child: _BlockTile(building: b),
                  ),
                ),
              const SizedBox(height: AppSizes.spacingL),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/manager-dashboard/sites/$siteId/add-building',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(t.addBlock),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportSheet(BuildContext context, String siteId, String siteName) {
    final t = context.t.features.sites;
    PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (ctx) => PremiumBottomSheetScaffold(
        title: t.reportSheetTitle,
        scrollable: false,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PremiumActionSheetTile(
              icon: Icons.calendar_month_outlined,
              label: t.monthlyReport,
              onTap: () {
                Navigator.pop(ctx);
                context.push(
                  '/manager-dashboard/sites/$siteId/report?type=monthly&name=${Uri.encodeComponent(siteName)}',
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXS),
            PremiumActionSheetTile(
              icon: Icons.date_range_outlined,
              label: t.annualReport,
              onTap: () {
                Navigator.pop(ctx);
                context.push(
                  '/manager-dashboard/sites/$siteId/report?type=annual&name=${Uri.encodeComponent(siteName)}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SiteIdentityCard extends StatelessWidget {
  final SiteEntity site;

  const _SiteIdentityCard({required this.site});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkDark.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
              Icons.location_city_rounded,
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
                  site.name,
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
                        site.displayAddress,
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

class _ActionRow extends StatelessWidget {
  final VoidCallback onExpenses;
  final VoidCallback onReport;

  const _ActionRow({
    required this.onExpenses,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: OutlinedButton.icon(
              onPressed: onExpenses,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.receipt_long_outlined, size: 20),
              label: Text(t.commonExpenses),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingM),
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightSecondary,
            child: OutlinedButton.icon(
              onPressed: onReport,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
              label: Text(t.report),
            ),
          ),
        ),
      ],
    );
  }
}

class _BlockTile extends StatelessWidget {
  final BuildingEntity building;

  const _BlockTile({required this.building});

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          '/manager-dashboard/buildings/${building.id}',
        ),
        borderRadius: BorderRadius.circular(DashboardScreenStyle.cardRadius),
        child: Ink(
          decoration: DashboardScreenStyle.whiteCard(),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingM),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.view_module_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.displayName,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.blockApartments.replaceAll(
                          '{count}',
                          '${building.totalApartments}',
                        ),
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const ActionChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SiteStatsGrid extends StatelessWidget {
  final SiteEntity site;
  final SiteAggregationEntity aggregation;

  const _SiteStatsGrid({
    required this.site,
    required this.aggregation,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final rate = aggregation.collectionRate.round();

    return Column(
      children: [
        // Üst sıra: blok, daire, tahsilat % — 3 kart yan yana
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SiteDetailStatTile(
                  data: _SiteStatTileData(
                    icon: Icons.view_module_outlined,
                    iconBg: AppColors.infoBg,
                    iconColor: AppColors.chartBlue,
                    value: '${site.buildingCount}',
                    label: t.blockCount,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: _SiteDetailStatTile(
                  data: _SiteStatTileData(
                    icon: Icons.door_front_door_outlined,
                    iconBg: AppColors.infoBg,
                    iconColor: AppColors.chartBlue,
                    value: '${site.totalApartments}',
                    label: t.apartmentCount,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: _SiteDetailStatTile(
                  data: _SiteStatTileData(
                    icon: Icons.trending_up_outlined,
                    iconBg: AppColors.successBg,
                    iconColor: AppColors.statusGreen,
                    value: '%$rate',
                    label: t.collectionRate,
                    valueColor: AppColors.statusGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        // Alt sıra: toplanan tutar — full genişlik, büyük font
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.inkDark.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.payments_outlined,
                  color: AppColors.chartOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.collectedAmount,
                      style: AppTypography.label.copyWith(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppCurrencyFormat.format(aggregation.collectedAmount),
                      style: AppTypography.h2.copyWith(
                        color: AppColors.inkDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SiteStatTileData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color? valueColor;

  const _SiteStatTileData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueColor,
  });
}

class _SiteDetailStatTile extends StatelessWidget {
  final _SiteStatTileData data;

  const _SiteDetailStatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkDark.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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

class _SiteProgressCard extends StatelessWidget {
  final SiteEntity site;
  final SiteAggregationEntity aggregation;

  const _SiteProgressCard({
    required this.site,
    required this.aggregation,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final status = BuildingCollectionStatus.fromRate(aggregation.collectionRate);
    final chip = resolveBuildingStatusChip(
      context,
      overdueCount: site.overdueCount,
      pendingCount: site.pendingCount,
    );
    final progress = (aggregation.collectionRate / 100).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkDark.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
          Text(
            t.collectedExpected
                .replaceAll('{collected}', AppCurrencyFormat.format(aggregation.collectedAmount))
                .replaceAll('{expected}', AppCurrencyFormat.format(aggregation.expectedAmount)),
            style: AppTypography.label.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    );
  }
}
