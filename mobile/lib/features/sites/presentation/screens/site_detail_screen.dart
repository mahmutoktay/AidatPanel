import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../buildings/presentation/widgets/building_summary_card.dart';
import '../../data/sites_store.dart';
import '../../domain/entities/site_entity.dart';

class SiteDetailScreen extends ConsumerWidget {
  const SiteDetailScreen({super.key, required this.siteId});

  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siteAsync = ref.watch(siteDetailProvider(siteId));
    final t = context.t.features.sites;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          siteAsync.value?.name ?? t.siteDetail,
          style: AppTypography.h3.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/manager-dashboard/sites/$siteId/add-building',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business_outlined),
        label: Text(t.addBlock),
      ),
      body: siteAsync.when(
        data: (site) => _SiteDetailBody(site: site),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: AppSizes.screenBodyScrollPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(userFacingError(err), textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.spacingM),
                ElevatedButton(
                  onPressed: () => ref.invalidate(siteDetailProvider(siteId)),
                  style: AppButtonStyles.elevatedPrimary(),
                  child: Text(context.t.common.tryAgain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SiteDetailBody extends ConsumerWidget {
  const _SiteDetailBody({required this.site});

  final SiteEntity site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.features.sites;
    final buildingsAsync = ref.watch(siteBuildingsProvider(site.id));
    final buildings = buildingsAsync.value ?? const <BuildingEntity>[];

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(siteDetailProvider(site.id));
        ref.invalidate(siteBuildingsProvider(site.id));
        await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
      },
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSizes.screenBodyScrollPadding.copyWith(bottom: 96),
        children: [
          _SummaryCard(site: site),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            t.blocksTitle,
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.inkDark,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          if (buildingsAsync.isLoading && buildings.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (buildings.isEmpty)
            Text(
              t.noBlocksYet,
              style: AppTypography.body1.copyWith(color: AppColors.mutedText),
            )
          else
            ...buildings.map(
              (building) => _BlockTile(
                building: building,
                onTap: () => context.push(
                  '/manager-dashboard/buildings/${building.id}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.site});

  final SiteEntity site;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BuildingSummaryCard.cardRadius),
        side: BorderSide(color: AppColors.lineLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              site.displayAddress,
              style: AppTypography.body2.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Row(
              children: [
                _Metric(
                  label: t.blockCount,
                  value: '${site.buildingCount}',
                ),
                const SizedBox(width: AppSizes.spacingL),
                _Metric(
                  label: context.t.common.duesCollection,
                  value: '%${site.collectionRate.toStringAsFixed(0)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.mutedText)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({required this.building, required this.onTap});

  final BuildingEntity building;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (building.blockLabel != null && building.blockLabel!.isNotEmpty)
        building.blockLabel,
      '${building.occupiedApartments}/${building.totalApartments} ${context.t.common.apartments}',
    ].whereType<String>().join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BuildingSummaryCard.cardRadius),
        side: BorderSide(color: AppColors.lineLight),
      ),
      child: ListTile(
        minTileHeight: AppSizes.minTouchTarget,
        title: Text(
          building.name,
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
