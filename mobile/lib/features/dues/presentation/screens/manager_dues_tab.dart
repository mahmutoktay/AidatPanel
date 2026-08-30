import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/natural_string_compare.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../../dashboard/presentation/providers/dashboard_filter_scope_provider.dart';
import '../../../dashboard/presentation/utils/manager_dashboard_mapper.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../domain/entities/due_entity.dart';
import '../providers/dues_provider.dart';
import '../utils/dues_ui_helpers.dart';
import '../utils/due_collect_payment_flow.dart';
import '../widgets/due_detail_sheet.dart';
import '../widgets/dues_list_item_slidable.dart';
import '../widgets/dues_period_filter_row.dart';
import '../widgets/dues_status_filter_bar.dart';

class ManagerDuesTab extends ConsumerStatefulWidget {
  const ManagerDuesTab({super.key});

  @override
  ConsumerState<ManagerDuesTab> createState() => _ManagerDuesTabState();
}

class _ManagerDuesTabState extends ConsumerState<ManagerDuesTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollectingPayment = false;

  DueStatus? _statusFilter;
  int? _monthFilter = DateTime.now().month;
  int? _yearFilter = DateTime.now().year;
  bool _initialized = false;
  List<DueEntity> _statsDues = const [];

  @override
  void initState() {
    super.initState();
    attachPaginationScroll(
      _scrollController,
      () => ref.read(duesNotifierProvider.notifier).loadMoreBuildingDues(),
      canLoad: () => ref.read(duesNotifierProvider).canLoadMore,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final duesState = ref.watch(duesNotifierProvider);
    final highlightDueId = ref.watch(managerDueHighlightIdProvider);
    final filterScope = ref.watch(dashboardFilterScopeProvider);

    ref.listen<DashboardFilterScope>(dashboardFilterScopeProvider, (
      previous,
      next,
    ) {
      if (previous == next || !_initialized) return;
      _reloadDues();
    });

    ref.listen<ManagerDueNavigationIntent?>(
      managerDueNavigationIntentProvider,
      (previous, next) {
        if (next == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final buildingId = next.buildingId;
          if (buildingId != null &&
              buildingId.isNotEmpty &&
              buildings.any((b) => b.id == buildingId)) {
            ref.read(dashboardFilterScopeProvider.notifier).update(
                  DashboardFilterScope.building(buildingId),
                );
          }
          final statusFilter = _statusFromIntent(next.statusFilter);
          if (statusFilter != null) {
            setState(() => _statusFilter = statusFilter);
          }
          if (buildingId != null || statusFilter != null) {
            await _reloadDues();
          }
          ref.read(managerDueNavigationIntentProvider.notifier).update(null);
        });
      },
    );

    _tryInitialize(buildings);

    final rawDues = duesState.dues
        .where((due) => due.resident != null)
        .toList(growable: false);
    final dues = List<DueEntity>.from(rawDues)..sort((a, b) {
      if (a.year != b.year) {
        return b.year.compareTo(a.year);
      }
      if (a.month != b.month) {
        return b.month.compareTo(a.month);
      }
      return compareNaturalStrings(a.apartmentNumber, b.apartmentNumber);
    });

    final isLoading = duesState.isLoading;
    final scopedBuildingIds = _scopedBuildingIds(filterScope, buildings);
    final statsSource = (_statusFilter == null ? dues : _statsDues)
        .where((due) => due.resident != null)
        .toList(growable: false);
    final currencySymbol = _currencySymbol();

    return RefreshIndicator(
      onRefresh: _reloadDues,
      color: AppColors.brand,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.dashboardScreenPaddingHorizontal,
              AppSizes.spacingM,
              AppSizes.dashboardScreenPaddingHorizontal,
              0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (buildings.isNotEmpty) ...[
                  DashboardBuildingSelector(
                    buildings: buildings,
                    scope: filterScope,
                    includeAllOption: false,
                    onScopeChanged: (scope) => ref
                        .read(dashboardFilterScopeProvider.notifier)
                        .update(scope),
                  ),
                  const SizedBox(height: AppSizes.spacingXS),
                  DuesPeriodFilterRow(
                    month: _monthFilter,
                    year: _yearFilter,
                    yearOptions: _yearOptions(dues),
                    enabled: !isLoading,
                    onMonthChanged: (month) {
                      if (month == _monthFilter) return;
                      setState(() => _monthFilter = month);
                      _reloadDues();
                    },
                    onYearChanged: (year) {
                      if (year == _yearFilter) return;
                      setState(() => _yearFilter = year);
                      _reloadDues();
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingXS),
                ],
                if (statsSource.isNotEmpty || scopedBuildingIds.isNotEmpty)
                  DuesStatusFilterBar(
                    paidCount: statsSource
                        .where((d) => d.status == DueStatus.paid)
                        .length,
                    pendingCount: statsSource
                        .where((d) => d.status == DueStatus.pending)
                        .length,
                    overdueCount: statsSource
                        .where((d) => d.status == DueStatus.overdue)
                        .length,
                    selectedStatus: _statusFilter,
                    enabled: !isLoading,
                    onChanged: _onStatusFilterChanged,
                  ),
                const SizedBox(height: AppSizes.spacingL),
                if (scopedBuildingIds.isNotEmpty)
                  _buildDueListHeader(dues.length),
                const SizedBox(height: AppSizes.spacingM),
                if (isLoading && dues.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: AppColors.lineLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.statusBlue,
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          if (isLoading && dues.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (dues.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.dashboardScreenPaddingHorizontal,
                0,
                AppSizes.dashboardScreenPaddingHorizontal,
                AppSizes.spacingL,
              ),
              sliver: SliverToBoxAdapter(child: _buildEmptyState(context)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.dashboardScreenPaddingHorizontal,
                0,
                AppSizes.dashboardScreenPaddingHorizontal,
                AppSizes.spacingL,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => KeyedSubtree(
                    key: ValueKey<String>(dues[index].id),
                    child: DuesListItemSlidable(
                      due: dues[index],
                      currencySymbol: currencySymbol,
                      highlighted: highlightDueId == dues[index].id,
                      onTap: () => _openDueDetailSheet(context, dues[index]),
                      onCollectPayment: _canCollectPayment(dues[index])
                          ? () => _handleCollectPayment(context, dues[index])
                          : null,
                    ),
                  ),
                  childCount: dues.length,
                ),
              ),
            ),
          if (duesState.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.spacingL),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDueListHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.t.common.buildingDues,
          style: AppTypography.sectionTitle.copyWith(
            color: AppColors.inkDark,
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.dashboardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lineLight),
          ),
          alignment: Alignment.center,
          child: Text(
            count.toString(),
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  List<String> _scopedBuildingIds(
    DashboardFilterScope scope,
    List<BuildingEntity> buildings,
  ) {
    return ManagerDashboardMapper.filterBuildingsByScope(
      buildings,
      siteId: scope.siteId,
      buildingId: scope.buildingId,
    ).map((building) => building.id).toList(growable: false);
  }

  void _onStatusFilterChanged(DueStatus? status) {
    if (status == _statusFilter) return;
    setState(() => _statusFilter = status);
    _reloadDues();
  }

  List<int> _yearOptions(List<DueEntity> dues) {
    final currentYear = DateTime.now().year;
    final yearSet = <int>{
      for (var i = 0; i < 5; i++) currentYear - i,
      ...dues.map((d) => d.year),
    };
    return yearSet.toList()..sort((a, b) => b.compareTo(a));
  }

  void _tryInitialize(List<BuildingEntity> buildings) {
    if (_initialized || buildings.isEmpty) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Aidat sekmesinde "Tüm Binalar" yok; anasayfadan gelen all → ilk bina.
      final scope = ref.read(dashboardFilterScopeProvider);
      if (scope.isAll) {
        final sorted = [...buildings]
          ..sort((a, b) => a.name.compareTo(b.name));
        ref.read(dashboardFilterScopeProvider.notifier).update(
              DashboardFilterScope.building(sorted.first.id),
            );
      }
      _reloadDues();
    });
  }

  Future<void> _reloadDues() async {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    final scope = ref.read(dashboardFilterScopeProvider);
    final buildingIds = _scopedBuildingIds(scope, buildings);
    if (buildingIds.isEmpty) return;

    await ref.read(duesNotifierProvider.notifier).loadScopedBuildingDues(
          buildingIds,
          month: _monthFilter,
          year: _yearFilter,
          status: _statusFilter,
          paginated: false,
        );

    if (!mounted) return;

    if (_statusFilter != null) {
      try {
        final merged = <DueEntity>[];
        final repo = ref.read(duesRepositoryProvider);
        for (final buildingId in buildingIds) {
          final result = await repo.getBuildingDues(
            buildingId,
            month: _monthFilter,
            year: _yearFilter,
            paginated: false,
          );
          merged.addAll(
            result.items.where((due) => due.resident != null),
          );
        }
        setState(() => _statsDues = merged);
      } catch (_) {
        setState(() => _statsDues = ref.read(duesNotifierProvider).dues);
      }
    } else {
      setState(() => _statsDues = const []);
    }
  }

  DueStatus? _statusFromIntent(String? value) {
    switch (value) {
      case 'pending':
        return DueStatus.pending;
      case 'paid':
        return DueStatus.paid;
      case 'overdue':
        return DueStatus.overdue;
      case 'waived':
        return DueStatus.waived;
      default:
        return null;
    }
  }

  bool _canCollectPayment(DueEntity due) =>
      due.status == DueStatus.pending || due.status == DueStatus.overdue;

  String? _dueBuildingId(DueEntity due) {
    return ref.read(duesNotifierProvider.notifier).dueBuildingIds[due.id] ??
        ref.read(dashboardFilterScopeProvider).buildingId;
  }

  Future<void> _handleCollectPayment(BuildContext context, DueEntity due) async {
    final buildingId = _dueBuildingId(due);
    if (buildingId == null || _isCollectingPayment) return;

    setState(() => _isCollectingPayment = true);
    final success = await collectDuePayment(
      context: context,
      ref: ref,
      due: due,
      buildingId: buildingId,
    );
    if (!mounted) return;
    setState(() => _isCollectingPayment = false);

    if (!success) return;
    if (_statusFilter != null) {
      await _reloadDues();
    }
    if (!mounted || !context.mounted) return;
    ref
        .read(toastProvider.notifier)
        .show(context.t.common.duesUpdated, type: ToastType.success);
  }

  Future<void> _openDueDetailSheet(BuildContext context, DueEntity due) async {
    // Boş daire aidatı detayda açılmaz (K4).
    if (due.resident == null) return;

    final monthLabel = '${monthName(context, due.month)} ${due.year}';
    final buildingId = _dueBuildingId(due);
    final canCollect = _canCollectPayment(due) && buildingId != null;

    await DueDetailSheet.show(
      context,
      due: due,
      buildingId: buildingId,
      monthLabel: monthLabel,
      currencySymbol: _currencySymbol(),
      isCollecting: _isCollectingPayment,
      onCollectPayment: canCollect
          ? () {
              Navigator.of(context).pop();
              _handleCollectPayment(context, due);
            }
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: context.t.common.noDuesYet,
    );
  }

  String _currencySymbol() {
    return '₺';
  }
}
