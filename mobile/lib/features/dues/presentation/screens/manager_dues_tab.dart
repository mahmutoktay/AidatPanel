import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../../dashboard/presentation/providers/dashboard_filter_scope_provider.dart';
import '../../../dashboard/presentation/utils/manager_dashboard_mapper.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/premium_filter_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../domain/entities/due_entity.dart';
import '../providers/dues_provider.dart';
import '../utils/dues_ui_helpers.dart';
import '../utils/due_collect_payment_flow.dart';
import '../widgets/due_detail_sheet.dart';
import '../widgets/dues_list_item_slidable.dart';
import '../widgets/dues_stat_cards_row.dart';

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

    final rawDues = duesState.dues;
    final dues = List<DueEntity>.from(rawDues)..sort((a, b) {
      if (a.year != b.year) {
        return b.year.compareTo(a.year);
      }
      if (a.month != b.month) {
        return b.month.compareTo(a.month);
      }
      
      final regExp = RegExp(r'^(\d+)(.*)$');
      final matchA = regExp.firstMatch(a.apartmentNumber.trim());
      final matchB = regExp.firstMatch(b.apartmentNumber.trim());

      if (matchA != null && matchB != null) {
        final numA = int.tryParse(matchA.group(1)!) ?? 0;
        final numB = int.tryParse(matchB.group(1)!) ?? 0;
        if (numA != numB) {
          return numA.compareTo(numB);
        }
        final restA = matchA.group(2) ?? '';
        final restB = matchB.group(2) ?? '';
        return restA.compareTo(restB);
      }
      return a.apartmentNumber.compareTo(b.apartmentNumber);
    });

    final isLoading = duesState.isLoading;
    final scopedBuildingIds = _scopedBuildingIds(filterScope, buildings);
    final statsSource = _statusFilter == null ? dues : _statsDues;
    final totalUnits = _resolveTotalUnits(
      filterScope,
      buildings,
      statsSource,
    );
    final currencySymbol = _currencySymbol();

    return RefreshIndicator(
      onRefresh: _reloadDues,
      color: AppColors.primary,
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
                    includeAllOption: true,
                    onScopeChanged: (scope) => ref
                        .read(dashboardFilterScopeProvider.notifier)
                        .update(scope),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _PeriodFilterChip(
                      label: _periodFilterLabel(context),
                      hasActiveFilters: _hasActivePeriodFilters,
                      enabled: !isLoading,
                      onTap: () => _openFilterSheet(context, dues, isLoading),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                ],
                if (statsSource.isNotEmpty || scopedBuildingIds.isNotEmpty)
                  DuesStatCardsRow(
                    paidCount: statsSource
                        .where((d) => d.status == DueStatus.paid)
                        .length,
                    pendingCount: statsSource
                        .where((d) => d.status == DueStatus.pending)
                        .length,
                    overdueCount: statsSource
                        .where((d) => d.status == DueStatus.overdue)
                        .length,
                    totalUnits: totalUnits,
                    selectedStatus: _statusFilter,
                    onStatusTap: _toggleStatusFilter,
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
          style: AppTypography.h3.copyWith(
            color: AppColors.inkDark,
            fontWeight: FontWeight.w800,
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

  void _toggleStatusFilter(DueStatus status) {
    setState(() {
      _statusFilter = _statusFilter == status ? null : status;
    });
    _reloadDues();
  }

  String _periodFilterLabel(BuildContext context) {
    final common = context.t.common;
    final monthPart = _monthFilter == null
        ? common.allMonths
        : monthName(context, _monthFilter!);
    final yearPart =
        _yearFilter == null ? common.allYears : '${_yearFilter!}';
    if (_monthFilter != null && _yearFilter != null) {
      return '$monthPart $yearPart';
    }
    if (_monthFilter != null) return monthPart;
    if (_yearFilter != null) return yearPart;
    return common.filter;
  }

  bool get _hasActivePeriodFilters {
    final now = DateTime.now();
    return _monthFilter == null ||
        _yearFilter == null ||
        _monthFilter != now.month ||
        _yearFilter != now.year;
  }

  List<int> _yearOptions(List<DueEntity> dues) {
    final currentYear = DateTime.now().year;
    final yearSet = <int>{
      for (var i = 0; i < 5; i++) currentYear - i,
      ...dues.map((d) => d.year),
    };
    return yearSet.toList()..sort((a, b) => b.compareTo(a));
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    List<DueEntity> dues,
    bool isLoading,
  ) async {
    if (isLoading) return;
    var draftMonth = _monthFilter;
    var draftYear = _yearFilter;
    final common = context.t.common;
    final years = _yearOptions(dues);

    await PremiumFilterSheet.show(
      context: context,
      title: common.filter,
      applyLabel: common.apply,
      fieldBuilder: (ctx, setSheetState) {
        final monthAllToken = Object();
        final yearAllToken = Object();
        return [
          PremiumFilterFieldConfig(
            label: common.month,
            value: draftMonth == null
                ? common.allMonths
                : monthName(ctx, draftMonth!),
            hint: common.allMonths,
            icon: Icons.calendar_month_outlined,
            onTap: () async {
              final picked = await showPremiumSingleSelectPicker<Object?>(
                context: ctx,
                title: common.month,
                selected: draftMonth ?? monthAllToken,
                options: [
                  PremiumFilterPickerOption(
                    value: monthAllToken,
                    label: common.allMonths,
                    icon: Icons.calendar_view_month_outlined,
                  ),
                  for (var m = 1; m <= 12; m++)
                    PremiumFilterPickerOption(
                      value: m,
                      label: monthName(ctx, m),
                      icon: Icons.event_outlined,
                    ),
                ],
              );
              if (picked == null) return;
              setSheetState(() {
                draftMonth = identical(picked, monthAllToken) ? null : picked as int;
              });
            },
          ),
          PremiumFilterFieldConfig(
            label: common.year,
            value: draftYear == null ? common.allYears : '$draftYear',
            hint: common.allYears,
            icon: Icons.date_range_outlined,
            onTap: () async {
              final picked = await showPremiumSingleSelectPicker<Object?>(
                context: ctx,
                title: common.year,
                selected: draftYear ?? yearAllToken,
                options: [
                  PremiumFilterPickerOption(
                    value: yearAllToken,
                    label: common.allYears,
                    icon: Icons.date_range_outlined,
                  ),
                  for (final y in years)
                    PremiumFilterPickerOption(
                      value: y,
                      label: '$y',
                      icon: Icons.calendar_today_outlined,
                    ),
                ],
              );
              if (picked == null) return;
              setSheetState(() {
                draftYear = identical(picked, yearAllToken) ? null : picked as int;
              });
            },
          ),
        ];
      },
      onApply: () {
        setState(() {
          _monthFilter = draftMonth;
          _yearFilter = draftYear;
        });
        _reloadDues();
      },
    );
  }

  int _resolveTotalUnits(
    DashboardFilterScope scope,
    List<BuildingEntity> buildings,
    List<DueEntity> statsSource,
  ) {
    return math.max(statsSource.length, 1);
  }

  void _tryInitialize(List<BuildingEntity> buildings) {
    if (_initialized || buildings.isEmpty) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scope = ref.read(dashboardFilterScopeProvider);
      if (_scopedBuildingIds(scope, buildings).isEmpty) {
        ref.read(dashboardFilterScopeProvider.notifier).update(
              DashboardFilterScope.building(buildings.first.id),
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
          merged.addAll(result.items);
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingL),
        child: Text(
          context.t.common.noDuesYet,
          style: AppTypography.body1.copyWith(color: AppColors.mutedText),
        ),
      ),
    );
  }

  String _currencySymbol() {
    return '₺';
  }
}

class _PeriodFilterChip extends StatelessWidget {
  const _PeriodFilterChip({
    required this.label,
    required this.hasActiveFilters,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool hasActiveFilters;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              color: hasActiveFilters
                  ? AppColors.inkDark.withValues(alpha: 0.08)
                  : AppColors.dashboardBackground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: hasActiveFilters
                    ? AppColors.inkDark.withValues(alpha: 0.2)
                    : AppColors.lineLight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: enabled ? AppColors.inkDark : AppColors.mutedText,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.body2.copyWith(
                    color: enabled ? AppColors.inkDark : AppColors.mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: enabled ? AppColors.mutedText : AppColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
