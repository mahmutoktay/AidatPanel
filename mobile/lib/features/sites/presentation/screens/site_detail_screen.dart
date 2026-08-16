import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/action_chevron.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../dashboard/presentation/utils/manager_overdue_remind_helper.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dashboard/domain/entities/manager_dashboard_entities.dart';
import '../../../dashboard/presentation/widgets/manager_home/manager_dues_summary_card.dart';
import '../../data/sites_store.dart';
import '../../domain/entities/site_entity.dart';
import '../widgets/delete_site_dialog.dart';
import '../widgets/edit_site_bottom_sheet.dart';
import '../widgets/site_detail_bottom_toolbar.dart';

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
      bottomNavigationBar: detailAsync.maybeWhen(
        data: (detail) => SiteDetailBottomToolbar(
          onDelete: () async {
            final deleted = await DeleteSiteDialog.show(
              context,
              site: detail.site,
            );
            if (deleted == true && context.mounted) {
              context.go('/manager-dashboard');
            }
          },
          onEdit: () async {
            await EditSiteBottomSheet.show(context, site: detail.site);
            if (!context.mounted) return;
            ref.invalidate(siteDetailProvider(siteId));
          },
          onExpenses: () async {
            await context.push(
              '/manager-dashboard/sites/$siteId/expenses',
            );
            if (!context.mounted) return;
            ref.invalidate(siteDetailProvider(siteId));
          },
          onReport: () => _showReportSheet(context, siteId, detail.site.name),
        ),
        orElse: () => null,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(userFacingError(e))),
        data: (detail) {
          final allDues = ref.watch(allBuildingsDuesProvider).value ?? const {};
          final now = DateTime.now();
          final remindDueIdsByBuilding = groupOverdueDueIdsByBuilding(
            allDues,
            buildingIds: detail.buildings.map((b) => b.id).toSet(),
            month: now.month,
            year: now.year,
          );

          return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(siteDetailProvider(siteId));
            await ref.read(siteDetailProvider(siteId).future);
          },
          color: AppColors.brand,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSizes.screenBodyScrollPadding.copyWith(
              bottom: AppSizes.spacingXL,
            ),
            children: [
              _SiteIdentityCard(site: detail.site),
              const SizedBox(height: AppSizes.spacingM),
              if (detail.aggregation.collectedAmount > 0 ||
                  detail.aggregation.expectedAmount > 0)
                ManagerDuesSummaryCard(
                  summary: ManagerDuesAmountSummary(
                    collectedAmount: detail.aggregation.collectedAmount,
                    expectedAmount: detail.aggregation.expectedAmount,
                    overdueCount: detail.site.overdueCount,
                  ),
                  currency: detail.aggregation.currency,
                  remindDueIdsByBuilding: remindDueIdsByBuilding.isEmpty
                      ? null
                      : remindDueIdsByBuilding,
                ),
              if (detail.aggregation.collectedAmount > 0 ||
                  detail.aggregation.expectedAmount > 0)
                const SizedBox(height: AppSizes.spacingL)
              else
                const SizedBox(height: AppSizes.spacingM),
              _BlocksSectionHeader(
                siteId: siteId,
                buildingCount: detail.buildings.length,
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
        );
        },
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
        boxShadow: const [],
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
                  style: AppTypography.sectionTitle.copyWith(
                    color: AppColors.inkDark,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (site.displayAddress.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlocksSectionHeader extends StatelessWidget {
  const _BlocksSectionHeader({
    required this.siteId,
    required this.buildingCount,
  });

  final String siteId;
  final int buildingCount;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          t.blocksTitle,
          style: AppTypography.sectionTitle.copyWith(
            color: AppColors.inkDark,
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$buildingCount ${t.blockCount}',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: t.addBlock,
          onPressed: () => context.push(
            '/manager-dashboard/sites/$siteId/add-building',
          ),
          icon: const Icon(Icons.add_rounded),
          color: AppColors.brand,
          style: IconButton.styleFrom(
            minimumSize: const Size(40, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    color: AppColors.brand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.view_module_outlined,
                    color: AppColors.brand,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
