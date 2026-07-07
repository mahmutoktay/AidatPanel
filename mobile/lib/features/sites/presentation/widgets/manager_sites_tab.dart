import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../dashboard/domain/entities/manager_dashboard_entities.dart';
import '../../../dashboard/presentation/widgets/manager_home/manager_dues_summary_card.dart';
import '../../data/sites_store.dart';
import '../../domain/entities/site_entity.dart';
import 'site_list_card.dart';

class ManagerSitesTab extends ConsumerStatefulWidget {
  const ManagerSitesTab({super.key});

  @override
  ConsumerState<ManagerSitesTab> createState() => _ManagerSitesTabState();
}

class _ManagerSitesTabState extends ConsumerState<ManagerSitesTab> {
  String _searchQuery = '';

  List<SiteEntity> _filterBySearch(List<SiteEntity> sites, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return sites;

    return sites.where((site) {
      final haystack = '${site.name} ${site.displayAddress}'.toLowerCase();
      return haystack.contains(normalized);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(sitesStoreProvider);
    final sites = sitesAsync.value ?? const [];
    final visibleSites = _filterBySearch(sites, _searchQuery);
    final t = context.t.features.sites;
    final isRefreshing = sitesAsync.isLoading && sites.isNotEmpty;
    final portfolioSummary = _portfolioSummaryFromSites(sites);
    final currency = sites.isNotEmpty ? sites.first.currency : 'TRY';
    final hasSearch = _searchQuery.trim().isNotEmpty;

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
                ManagerDuesSummaryCard(
                  summary: portfolioSummary,
                  currency: currency,
                ),
                const SizedBox(height: AppSizes.spacingM),
                MinimalSearchField(
                  hint: t.searchSites,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: AppSizes.spacingL),
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
          else if (visibleSites.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  hasSearch
                      ? context.t.common.noResults
                      : t.emptySites,
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
                itemCount: visibleSites.length,
                itemBuilder: (context, index) {
                  final site = visibleSites[index];
                  return SiteListCard(
                    site: site,
                    onTap: () => context.push(
                      '/manager-dashboard/sites/${site.id}',
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  static ManagerDuesAmountSummary _portfolioSummaryFromSites(
    List<SiteEntity> sites,
  ) {
    if (sites.isEmpty) return ManagerDuesAmountSummary.empty;

    var collected = 0.0;
    var expected = 0.0;
    var overdue = 0;

    for (final site in sites) {
      collected += site.collectedAmount;
      expected += site.expectedAmount;
      overdue += site.overdueCount;
    }

    return ManagerDuesAmountSummary(
      collectedAmount: collected,
      expectedAmount: expected,
      overdueCount: overdue,
    );
  }
}
