import 'dart:async';

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
import '../../../buildings/presentation/models/building_list_item_model.dart';
import '../../../buildings/presentation/utils/building_collection_status.dart';
import '../../../buildings/presentation/widgets/building_list_card.dart';
import '../../../buildings/presentation/widgets/building_sort_bottom_sheet.dart';
import '../../../buildings/presentation/widgets/buildings_expandable_fab.dart';
import '../../../buildings/presentation/widgets/buildings_summary_strip.dart';
import '../../../buildings/presentation/widgets/delete_building_dialog.dart';
import '../../../buildings/presentation/widgets/edit_building_bottom_sheet.dart';
import '../../../buildings/presentation/widgets/edit_building_collection_bottom_sheet.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';

class ManagerBuildingsTab extends ConsumerStatefulWidget {
  const ManagerBuildingsTab({super.key});

  @override
  ConsumerState<ManagerBuildingsTab> createState() =>
      _ManagerBuildingsTabState();
}

class _ManagerBuildingsTabState extends ConsumerState<ManagerBuildingsTab> {
  BuildingListSort _sort = BuildingListSort.byOverdue;
  bool _fabExpanded = false;
  final _fabKey = GlobalKey<BuildingsExpandableFabState>();

  static const _fabBottomPadding = 96.0;

  void _closeFab() {
    _fabKey.currentState?.close();
    if (_fabExpanded) setState(() => _fabExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(standaloneBuildingsProvider);
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

  Widget _buildScrollContent(
    BuildContext context, {
    required List<BuildingEntity> buildings,
    required Map<String, List<DueEntity>> allDues,
    required bool isRefreshing,
  }) {
    final items = buildings
        .map(
          (building) => BuildingListItemModel.fromEntity(
            building: building,
            allDues: allDues,
          ),
        )
        .toList(growable: false);
    final sortedItems = sortBuildingListItems(items, _sort);
    final totals = BuildingsSummaryTotals.fromItems(items);

<<<<<<< HEAD
    return Stack(
      children: [
        BuildingsExpandableFabOverlay(
          visible: _fabExpanded,
          onClose: _closeFab,
        ),
        RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: AppSizes.screenBodyScrollPadding.copyWith(bottom: 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    BuildingsSummaryStrip(totals: totals),
=======
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: AppSizes.screenBodyScrollPadding.copyWith(top: AppSizes.spacingS, bottom: 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildActionButtons(context),
                const SizedBox(height: AppSizes.spacingM),
                BuildingsSummaryStrip(totals: totals),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
                const SizedBox(height: AppSizes.spacingL),
                _buildListHeader(context),
                if (isRefreshing && buildings.isNotEmpty) ...[
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
          if (sortedItems.isEmpty)
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
          else
            SliverPadding(
              padding: AppSizes.screenBodyScrollPadding.copyWith(
                top: 0,
                bottom: _fabBottomPadding,
              ),
              sliver: SliverList.builder(
                itemCount: sortedItems.length,
                itemBuilder: (context, index) {
                  final item = sortedItems[index];
                  final building = buildings.firstWhere(
                    (b) => b.id == item.id,
                  );
                  return BuildingListCard(
                    item: item,
                    onTap: () => _onBuildingTapped(building),
                    onEdit: () =>
                        EditBuildingBottomSheet.show(context, building: building),
                    onCollection: () => EditBuildingCollectionBottomSheet.show(
                      context,
                      building: building,
                    ),
                    onDelete: () =>
                        unawaited(DeleteBuildingDialog.show(context, building: building)),
                  );
                },
              ),
            ),
<<<<<<< HEAD
            ],
          ),
        ),
        Positioned(
          right: AppSizes.spacingM,
          bottom: AppSizes.spacingM,
          child: BuildingsExpandableFab(
            key: _fabKey,
            onNewSite: () => context.push('/manager-dashboard/add-site'),
            onNewBuilding: _onAddBuildingPressed,
            showSiteAction: false,
            onExpandedChanged: (expanded) {
              if (_fabExpanded != expanded) {
                setState(() => _fabExpanded = expanded);
              }
            },
=======
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSizes.buttonHeightPrimary,
            child: ElevatedButton.icon(
              onPressed: _onCreateInviteCodePressed,
              style: _actionButtonStyle(AppButtonStyles.elevatedAccent()),
              icon: const Icon(Icons.qr_code_2),
              label: Text(context.t.common.inviteCode),
            ),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
          ),
        ),
      ],
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
<<<<<<< HEAD
    ref.invalidate(standaloneBuildingsProvider);
    await ref.read(buildingsStoreProvider.notifier).loadBuildings();
    await ref.refresh(standaloneBuildingsProvider.future);
    await ref.refresh(allBuildingsDuesProvider.future);
  }

  void _onRetryBuildings() {
    ref.invalidate(standaloneBuildingsProvider);
    ref.refresh(standaloneBuildingsProvider);
=======
    await Future.wait([
      ref.read(standaloneBuildingsStoreProvider.notifier).loadBuildings(),
      ref.refresh(allBuildingsDuesProvider.future),
    ]);
  }

  void _onRetryBuildings() {
    ref.read(standaloneBuildingsStoreProvider.notifier).loadBuildings();
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
                style: AppButtonStyles.elevatedPrimary(),
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
