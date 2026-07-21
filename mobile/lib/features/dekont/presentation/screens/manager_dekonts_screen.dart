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
import '../../../dashboard/presentation/utils/dashboard_filter_scope_routing.dart';
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

  @override
  void initState() {
    super.initState();
    _filterScope = widget.initialScope;
    attachPaginationScroll(
      _scrollController,
      () => ref.read(managerDekontsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(managerDekontsNotifierProvider).canLoadMore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_bootstrap());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Dekontlar yalnızca tek bina ile çalışır; Tümü/Site → somut binaya düşürülür.
  DashboardFilterScope _normalizeToBuildingScope(
    DashboardFilterScope scope,
    List<BuildingEntity> buildings,
  ) {
    return normalizeToBuildingScope(scope, buildings);
  }

  Future<void> _bootstrap() async {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    if (buildings.isEmpty) return;
    final normalized = _normalizeToBuildingScope(_filterScope, buildings);
    if (normalized != _filterScope) {
      setState(() => _filterScope = normalized);
    }
    await _loadCurrentBuilding();
  }

  Future<void> _loadCurrentBuilding() async {
    final id = _filterScope.buildingId;
    if (id == null || id.isEmpty) return;
    await ref.read(managerDekontsNotifierProvider.notifier).loadBuilding(
          id,
          filterKey: ref.read(managerDekontFilterProvider),
        );
  }

  void _onScopeChanged(DashboardFilterScope scope) {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    final normalized = _normalizeToBuildingScope(scope, buildings);
    setState(() => _filterScope = normalized);
    unawaited(_loadCurrentBuilding());
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
        unawaited(_loadCurrentBuilding());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final state = ref.watch(managerDekontsNotifierProvider);
    final t = context.t.features.dekont;
    final buildingId = _filterScope.buildingId;
    final canFilter = buildingId != null && buildingId.isNotEmpty;

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
                    scope: _filterScope.isBuilding
                        ? _filterScope
                        : _normalizeToBuildingScope(_filterScope, buildings),
                    includeAllOption: false,
                    onScopeChanged: _onScopeChanged,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  PremiumFilterButton(
                    hasActiveFilters:
                        ref.watch(managerDekontFilterProvider) != null,
                    onPressed: canFilter ? _openFilterSheet : null,
                  ),
                ],
              ),
        list: RefreshIndicator(
          onRefresh: _loadCurrentBuilding,
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
            onTap: () async {
              await context.push('/dekonts/${d.id}');
              if (!mounted) return;
              await _loadCurrentBuilding();
            },
          ),
        );
      },
    );
  }
}
