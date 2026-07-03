<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

=======
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
<<<<<<< HEAD
import '../../../buildings/presentation/widgets/buildings_expandable_fab.dart';
import '../../data/sites_store.dart';
import '../../domain/entities/site_entity.dart';
import 'site_list_card.dart';

class ManagerSitesTab extends ConsumerStatefulWidget {
  const ManagerSitesTab({super.key});

  @override
  ConsumerState<ManagerSitesTab> createState() => _ManagerSitesTabState();
}

class _ManagerSitesTabState extends ConsumerState<ManagerSitesTab> {
  bool _fabExpanded = false;
  final _fabKey = GlobalKey<BuildingsExpandableFabState>();

  static const _fabBottomPadding = 96.0;

  void _closeFab() {
    _fabKey.currentState?.close();
    if (_fabExpanded) setState(() => _fabExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(sitesStoreProvider);

    return sitesAsync.when(
      data: (sites) => _buildContent(context, sites: sites),
      loading: () {
        final cached = sitesAsync.value;
        if (cached != null && cached.isNotEmpty) {
          return _buildContent(context, sites: cached, isRefreshing: true);
        }
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, _) => Center(
        child: Padding(
          padding: AppSizes.screenBodyScrollPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.t.common.loadFailed,
                style: AppTypography.h4,
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                userFacingError(err),
                textAlign: TextAlign.center,
                style: AppTypography.body2.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: AppSizes.spacingM),
              ElevatedButton(
                onPressed: () =>
                    ref.read(sitesStoreProvider.notifier).loadSites(),
                child: Text(context.t.common.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<SiteEntity> sites,
    bool isRefreshing = false,
  }) {
    final t = context.t.features.sites;

    return Stack(
      children: [
        BuildingsExpandableFabOverlay(
          visible: _fabExpanded,
          onClose: _closeFab,
        ),
        RefreshIndicator(
          onRefresh: () =>
              ref.read(sitesStoreProvider.notifier).loadSites(),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: AppSizes.screenBodyScrollPadding.copyWith(
                  bottom: _fabBottomPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      t.mySites,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.inkDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    if (isRefreshing) ...[
                      const SizedBox(height: AppSizes.spacingS),
                      const LinearProgressIndicator(minHeight: 2),
                    ],
                    const SizedBox(height: AppSizes.spacingM),
                    if (sites.isEmpty)
                      Text(
                        t.emptySites,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.mutedText,
                        ),
                      )
                    else
                      ...sites.map(
                        (site) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.spacingS,
                          ),
                          child: SiteListCard(site: site),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: AppSizes.spacingM,
          bottom: AppSizes.spacingM,
          child: BuildingsExpandableFab(
            key: _fabKey,
            onNewSite: () => context.push('/manager-dashboard/add-site'),
            onNewBuilding: () {},
            showBuildingAction: false,
            onExpandedChanged: (expanded) {
              if (_fabExpanded != expanded) {
                setState(() => _fabExpanded = expanded);
              }
            },
          ),
        ),
      ],
    );
  }
=======
import '../../data/sites_store.dart';
import 'delete_site_dialog.dart';
import 'edit_site_bottom_sheet.dart';
import 'site_list_card.dart';

class ManagerSitesTab extends ConsumerWidget {
  const ManagerSitesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsync = ref.watch(sitesStoreProvider);
    final sites = sitesAsync.value ?? const [];
    final t = context.t.features.sites;
    final isRefreshing = sitesAsync.isLoading && sites.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () => ref.read(sitesStoreProvider.notifier).loadSites(),
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: AppSizes.screenBodyScrollPadding.copyWith(
              top: AppSizes.spacingS,
              bottom: 0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  t.mySites,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.inkDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                if (isRefreshing) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: AppColors.lineLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.statusBlue,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.spacingM),
              ]),
            ),
          ),
          if (sitesAsync.isLoading && sites.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (sitesAsync.hasError && sites.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: AppSizes.screenBodyScrollPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.t.common.loadFailed,
                        style: AppTypography.h4,
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      Text(
                        userFacingError(sitesAsync.error!),
                        textAlign: TextAlign.center,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                      FilledButton(
                        onPressed: () =>
                            ref.read(sitesStoreProvider.notifier).loadSites(),
                        child: Text(context.t.common.tryAgain),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (sites.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  t.emptySites,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: AppSizes.screenBodyScrollPadding.copyWith(top: 0),
              sliver: SliverList.builder(
                itemCount: sites.length,
                itemBuilder: (context, index) {
                  final site = sites[index];
                  return SiteListCard(
                    site: site,
                    onTap: () => context.push(
                      '/manager-dashboard/sites/${site.id}',
                    ),
                    onEdit: () => EditSiteBottomSheet.show(
                      context,
                      site: site,
                    ),
                    onDelete: () => unawaited(
                      DeleteSiteDialog.show(context, site: site),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
}
