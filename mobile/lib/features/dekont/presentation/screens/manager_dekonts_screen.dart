import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/building_selector_provider.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/premium_filter_button.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/premium_filter_sheet.dart';
import '../../../dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../../dashboard/presentation/utils/manager_dashboard_mapper.dart';
import '../providers/dekont_provider.dart';
import '../providers/manager_dekont_filter_provider.dart';
import '../widgets/dekont_list_card.dart';

class ManagerDekontsScreen extends ConsumerStatefulWidget {
  const ManagerDekontsScreen({
    super.key,
    this.initialScope = const DashboardFilterScope.all(),
  });

  final DashboardFilterScope initialScope;

  @override
  ConsumerState<ManagerDekontsScreen> createState() =>
      _ManagerDekontsScreenState();
}

class _ManagerDekontsScreenState extends ConsumerState<ManagerDekontsScreen> {
  final ScrollController _scrollController = ScrollController();
  late DashboardFilterScope _filterScope;
  String? _localBuildingId;

  @override
  void initState() {
    super.initState();
    _filterScope = widget.initialScope;
    if (widget.initialScope.isBuilding) {
      _localBuildingId = widget.initialScope.buildingId;
    }
    attachPaginationScroll(
      _scrollController,
      () => ref.read(managerDekontsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(managerDekontsNotifierProvider).canLoadMore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadForCurrentScope());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<BuildingEntity> _scopedBuildings(List<BuildingEntity> buildings) {
    return ManagerDashboardMapper.filterBuildingsByScope(
      buildings,
      siteId: _filterScope.siteId,
      buildingId: _filterScope.buildingId,
    );
  }

  String? _resolveLocalBuildingId(List<BuildingEntity> buildings) {
    if (_filterScope.isBuilding) return _filterScope.buildingId;
    final scoped = _scopedBuildings(buildings);
    if (_localBuildingId != null &&
        scoped.any((b) => b.id == _localBuildingId)) {
      return _localBuildingId;
    }
    return null;
  }

  Future<void> _loadForCurrentScope() async {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    if (buildings.isEmpty) return;
    final buildingId = _resolveLocalBuildingId(buildings);
    if (buildingId == null) {
      return;
    }
    await _loadBuilding(buildingId);
  }

  Future<void> _loadBuilding(String buildingId) {
    _localBuildingId = buildingId;
    return ref.read(managerDekontsNotifierProvider.notifier).loadBuilding(
          buildingId,
          filterKey: ref.read(managerDekontFilterProvider),
        );
  }

  Future<void> _load() async {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    final id = _resolveLocalBuildingId(buildings);
    if (id == null) return;
    await _loadBuilding(id);
  }

  void _onScopeChanged(DashboardFilterScope scope) {
    setState(() {
      _filterScope = scope;
      if (scope.isBuilding) {
        _localBuildingId = scope.buildingId;
      } else {
        _localBuildingId = null;
      }
    });
    unawaited(_loadForCurrentScope());
  }

  String _dekontFilterLabel(BuildContext context, String? key) {
    final t = context.t.features.dekont;
    switch (key) {
      case 'pending':
        return t.filterPending;
      case 'approved':
        return t.filterApproved;
      case 'rejected':
        return t.filterRejected;
      default:
        return t.filterAll;
    }
  }

  Future<void> _openFilterSheet() async {
    final currentKey = ref.read(managerDekontFilterProvider);
    var draftKey = currentKey;
    final common = context.t.common;
    final t = context.t.features.dekont;
    final allToken = Object();

    await PremiumFilterSheet.show(
      context: context,
      title: common.filter,
      applyLabel: common.apply,
      fieldBuilder: (ctx, setSheetState) => [
        PremiumFilterFieldConfig(
          label: common.status,
          value: _dekontFilterLabel(ctx, draftKey),
          hint: t.filterAll,
          icon: Icons.receipt_long_outlined,
          onTap: () async {
            final picked = await showPremiumSingleSelectPicker<Object?>(
              context: ctx,
              title: common.status,
              selected: draftKey ?? allToken,
              options: [
                PremiumFilterPickerOption(
                  value: allToken,
                  label: t.filterAll,
                  icon: Icons.layers_outlined,
                ),
                PremiumFilterPickerOption(
                  value: 'pending',
                  label: t.filterPending,
                  icon: Icons.hourglass_top_outlined,
                ),
                PremiumFilterPickerOption(
                  value: 'approved',
                  label: t.filterApproved,
                  icon: Icons.check_circle_outline,
                ),
                PremiumFilterPickerOption(
                  value: 'rejected',
                  label: t.filterRejected,
                  icon: Icons.cancel_outlined,
                ),
              ],
            );
            if (picked == null) return;
            setSheetState(() {
              draftKey = identical(picked, allToken) ? null : picked as String?;
            });
          },
        ),
      ],
      onApply: () {
        ref.read(managerDekontFilterProvider.notifier).select(draftKey);
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final state = ref.watch(managerDekontsNotifierProvider);
    final t = context.t.features.dekont;
    final buildingId = _resolveLocalBuildingId(buildings);
    final needsBuildingPick =
        buildings.isNotEmpty && buildingId == null && !_filterScope.isBuilding;

    return DashboardSecondaryScaffold(
      title: t.managerTitle,
      showNotificationAction: true,
      body: DashboardListScreenBody(
        header: buildings.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DashboardBuildingSelector(
                    buildings: buildings,
                    scope: _filterScope,
                    includeAllOption: true,
                    onScopeChanged: _onScopeChanged,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  PremiumFilterButton(
                    hasActiveFilters:
                        ref.watch(managerDekontFilterProvider) != null,
                    onPressed: buildingId == null ? null : _openFilterSheet,
                  ),
                ],
              ),
        list: RefreshIndicator(
          onRefresh: _load,
          child: buildings.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    EmptyStateWidget(
                      icon: Icons.apartment_outlined,
                      title: context.t.features.notifications.noBuilding,
                    ),
                  ],
                )
              : needsBuildingPick
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        EmptyStateWidget(
                          icon: Icons.apartment_outlined,
                          title: context.t.features.notifications.noBuilding,
                          subtitle: t.emptySubtitleManager,
                        ),
                      ],
                    )
                  : _buildList(context, state),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, ManagerDekontsState state) {
    final t = context.t.features.dekont;
    if (state.isLoading && state.dekonts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.error != null && state.dekonts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          Center(
            child: Padding(
              padding: AppSizes.screenBodyScrollPadding,
              child: Text(
                userFacingError(state.error!),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (state.dekonts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: t.emptyTitle,
            subtitle: t.emptySubtitleManager,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSizes.screenBodyScrollPadding,
      itemCount: state.dekonts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= state.dekonts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final d = state.dekonts[i];
        final apt = d.apartment != null
            ? '${t.apartment}: ${d.apartment!.number}'
            : null;
        final uploader = d.uploadedBy != null
            ? '${t.uploadedBy}: ${d.uploadedBy!.name}'
            : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
          child: DekontListCard(
            dekont: d,
            apartmentLabel: apt,
            uploaderLabel: uploader,
            onTap: () => context.push('/dekonts/${d.id}'),
          ),
        );
      },
    );
  }
}
