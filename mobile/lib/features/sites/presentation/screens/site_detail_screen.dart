import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
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

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(t.siteDetailTitle, style: AppTypography.h3),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/manager-dashboard/sites/$siteId/add-building',
        ),
        icon: const Icon(Icons.add),
        label: Text(t.addBlock),
      ),
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
            padding: AppSizes.screenBodyScrollPadding.copyWith(
              bottom: AppSizes.spacingXXL,
            ),
            children: [
              _SiteInfoCard(site: detail.site, aggregation: detail.aggregation),
              const SizedBox(height: AppSizes.spacingL),
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
            ],
          ),
        ),
      ),
    );
  }

  void _showReportSheet(BuildContext context, String siteId, String siteName) {
    final t = context.t.features.sites;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.reportSheetTitle, style: AppTypography.h4),
              const SizedBox(height: AppSizes.spacingM),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text(t.monthlyReport),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(
                    '/manager-dashboard/sites/$siteId/report?type=monthly&name=${Uri.encodeComponent(siteName)}',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range_outlined),
                title: Text(t.annualReport),
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

    return Container(
      decoration: DashboardScreenStyle.whiteCard(),
      padding: const EdgeInsets.all(AppSizes.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lineLight,
                  borderRadius: BorderRadius.circular(14),
                ),
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
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      site.displayAddress,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              style: AppButtonStyles.outlinedPrimary(),
              icon: const Icon(Icons.receipt_long_outlined),
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
              style: AppButtonStyles.outlinedPrimary(),
              icon: const Icon(Icons.picture_as_pdf_outlined),
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
                Icon(Icons.view_module_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.displayName,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        t.blockApartments.replaceAll(
                          '{count}',
                          '${building.totalApartments}',
                        ),
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mutedText,
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
