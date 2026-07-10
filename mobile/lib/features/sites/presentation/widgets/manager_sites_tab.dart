import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
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
                MinimalSearchField(
                  hint: t.searchSites,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: AppSizes.spacingL),
                Text(
                  t.mySites,
                  style: AppTypography.sectionTitle.copyWith(
                    color: AppColors.inkDark,
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
              child: EmptyStateWidget(
                icon: Icons.location_city_outlined,
                title: t.emptySites,
              ),
            )
          else if (visibleSites.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                icon: Icons.search_off_outlined,
                title: hasSearch ? context.t.common.noResults : t.emptySites,
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
}
