import 'package:flutter/material.dart';
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
              _SiteInfoCard(site: detail.site, aggregation: detail.aggregation),
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

class _SiteInfoCard extends StatelessWidget {
  final SiteEntity site;
  final SiteAggregationEntity aggregation;

  const _SiteInfoCard({
    required this.site,
    required this.aggregation,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final rate = aggregation.collectionRate.round();

    return DashboardSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  color: AppColors.primary,
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
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      site.displayAddress,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
          const SizedBox(height: AppSizes.spacingL),
          PremiumInfoCard(
            children: [
              PremiumInfoRow(
                icon: Icons.apartment_outlined,
                label: t.blockCount,
                value: '${site.buildingCount}',
              ),
              PremiumInfoRow(
                icon: Icons.door_front_door_outlined,
                label: t.apartmentCount,
                value: '${site.totalApartments}',
              ),
              PremiumInfoRow(
                icon: Icons.payments_outlined,
                label: t.collectedAmount,
                value: AppCurrencyFormat.format(aggregation.collectedAmount),
              ),
              PremiumInfoRow(
                icon: Icons.trending_up_outlined,
                label: t.expectedAmount,
                value: AppCurrencyFormat.format(aggregation.expectedAmount),
              ),
              PremiumInfoRow(
                icon: Icons.percent_outlined,
                label: t.collectionRate,
                value: '%$rate',
              ),
            ],
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
                Icon(Icons.chevron_right, color: AppColors.mutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
