import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../buildings/presentation/models/building_list_item_model.dart';
import '../../../buildings/presentation/utils/building_collection_status.dart';
import '../../../buildings/presentation/widgets/building_list_card.dart';
import '../../../buildings/presentation/widgets/building_sort_bottom_sheet.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../domain/entities/manager_dashboard_entities.dart';
import '../../presentation/utils/manager_dashboard_mapper.dart';
import 'manager_home/manager_dues_summary_card.dart';

class ManagerBuildingsTab extends ConsumerStatefulWidget {
  final AsyncValue<List<BuildingEntity>> buildingsAsync;

  const ManagerBuildingsTab({
    super.key,
    required this.buildingsAsync,
  });

  @override
  ConsumerState<ManagerBuildingsTab> createState() =>
      _ManagerBuildingsTabState();
}

class _ManagerBuildingsTabState extends ConsumerState<ManagerBuildingsTab> {
  BuildingListSort _sort = BuildingListSort.byOverdue;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = widget.buildingsAsync;
    final allDuesAsync = ref.watch(allBuildingsDuesProvider);
    final allDues = allDuesAsync.value ?? const <String, List<DueEntity>>{};

    return buildingsAsync.when(
      data: (buildings) => _buildScrollContent(
        context,
        buildings: buildings,
        allDues: allDues,
        isRefreshing: allDuesAsync.isLoading,
      ),
      loading: () {
        final cached = buildingsAsync.value;
        if (cached != null && cached.isNotEmpty) {
          return _buildScrollContent(
            context,
            buildings: cached,
            allDues: allDues,
            isRefreshing: true,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, _) => _BuildingsErrorView(
        message: userFacingError(err),
        onRetry: _onRetryBuildings,
      ),
    );
  }

  List<BuildingEntity> _standaloneBuildings(List<BuildingEntity> buildings) {
    return buildings
        .where((building) => building.siteId == null)
        .toList(growable: false);
  }

  List<BuildingEntity> _filterBySearch(
    List<BuildingEntity> buildings,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return buildings;

    return buildings.where((building) {
      final haystack =
          '${building.name} ${building.displayAddress}'.toLowerCase();
      return haystack.contains(normalized);
    }).toList(growable: false);
  }

  ManagerDuesAmountSummary _portfolioSummary(
    Map<String, List<DueEntity>> allDues,
  ) {
    final allDuesList =
        allDues.values.expand((list) => list).toList(growable: false);
    final now = DateTime.now();
    final currentMonthDues = ManagerDashboardMapper.filterDuesForMonth(
      allDuesList,
      month: now.month,
      year: now.year,
    );
    return ManagerDashboardMapper.duesAmountSummary(currentMonthDues);
  }

  Widget _buildScrollContent(
    BuildContext context, {
    required List<BuildingEntity> buildings,
    required Map<String, List<DueEntity>> allDues,
    required bool isRefreshing,
  }) {
    final standaloneBuildings = _standaloneBuildings(buildings);
    final visibleBuildings = _filterBySearch(standaloneBuildings, _searchQuery);
    final items = visibleBuildings
        .map(
          (building) => BuildingListItemModel.fromEntity(
            building: building,
            allDues: allDues,
          ),
        )
        .toList(growable: false);
    final sortedItems = sortBuildingListItems(items, _sort);
    final portfolioSummary = _portfolioSummary(allDues);
    final allBuildings = ref.watch(buildingsStoreProvider).value ?? const [];
    final currency =
        allBuildings.isNotEmpty ? allBuildings.first.currency : 'TRY';
    final hasSearch = _searchQuery.trim().isNotEmpty;

    return RefreshIndicator(
      onRefresh: _onRefresh,
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
                  hint: context.t.features.dashboard.searchBuildings,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: AppSizes.spacingL),
                _buildListHeader(context),
                if (isRefreshing && standaloneBuildings.isNotEmpty) ...[
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
          if (standaloneBuildings.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  context.t.common.myBuildings,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            )
          else if (sortedItems.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  hasSearch
                      ? context.t.common.noResults
                      : context.t.common.myBuildings,
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
                itemCount: sortedItems.length,
                itemBuilder: (context, index) {
                  final item = sortedItems[index];
                  final building = visibleBuildings.firstWhere(
                    (b) => b.id == item.id,
                  );
                  return BuildingListCard(
                    item: item,
                    onTap: () => _onBuildingTapped(building),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.t.common.myBuildings,
            style: AppTypography.h3.copyWith(
              color: AppColors.inkDark,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ),
        BuildingSortChip(
          sort: _sort,
          onTap: _onSortChipTapped,
        ),
      ],
    );
  }

  Future<void> _onSortChipTapped() async {
    final selected = await BuildingSortBottomSheet.show(
      context,
      current: _sort,
    );
    if (!mounted || selected == null || selected == _sort) return;
    setState(() => _sort = selected);
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(standaloneBuildingsStoreProvider.notifier).loadBuildings(),
      ref.refresh(allBuildingsDuesProvider.future),
    ]);
  }

  void _onRetryBuildings() {
    ref.read(standaloneBuildingsStoreProvider.notifier).loadBuildings();
  }

  void _onBuildingTapped(BuildingEntity building) {
    context.push('/manager-dashboard/buildings/${building.id}');
  }
}

class _BuildingsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BuildingsErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSizes.screenBodyScrollPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.statusRed, size: 32),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              context.t.common.loadFailed,
              style: AppTypography.h4.copyWith(color: AppColors.inkDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              message,
              style: AppTypography.body2.copyWith(color: AppColors.mutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingM),
            SizedBox(
              height: AppSizes.buttonHeightSecondary,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(context.t.common.tryAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
