import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/building_picker_sheet.dart';
import '../../../../shared/widgets/premium_filter_button.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/premium_filter_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../domain/entities/due_entity.dart';
import '../providers/dues_provider.dart';
import '../utils/dues_ui_helpers.dart';
import '../widgets/due_status_sheet.dart';
import '../widgets/dues_building_selector_card.dart';
import '../widgets/dues_list_item_card.dart';
import '../widgets/dues_quick_amount_card.dart';
import '../widgets/dues_stat_cards_row.dart';

class ManagerDuesTab extends ConsumerStatefulWidget {
  const ManagerDuesTab({super.key});

  @override
  ConsumerState<ManagerDuesTab> createState() => _ManagerDuesTabState();
}

class _ManagerDuesTabState extends ConsumerState<ManagerDuesTab> {
  final TextEditingController _amountController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? _selectedDueDay;
  DueStatus? _statusFilter;
  int? _monthFilter = DateTime.now().month;
  int? _yearFilter = DateTime.now().year;
  bool _affectCurrent = false;
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
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final duesState = ref.watch(duesNotifierProvider);
    final highlightDueId = ref.watch(managerDueHighlightIdProvider);

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
            ref.read(selectedBuildingIdProvider.notifier).select(buildingId);
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
    final selectedBuildingId = ref.watch(selectedBuildingIdProvider);
    final selectedBuilding = selectedBuildingId != null
        ? _buildingFor(selectedBuildingId, buildings)
        : null;
    final statsSource =
        _statusFilter == null ? dues : _statsDues;
    final totalUnits = _resolveTotalUnits(selectedBuilding, statsSource);
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
                if (selectedBuilding != null) ...[
                  DuesBuildingSelectorCard(
                    building: selectedBuilding,
                    currencySymbol: currencySymbol,
                    onTap: () => _showBuildingPicker(context, buildings),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                ],
                PremiumFilterButton(
                  enabled: !isLoading,
                  hasActiveFilters: _hasActiveFilters,
                  onPressed: () => _openFilterSheet(context, dues, isLoading),
                ),
                const SizedBox(height: AppSizes.spacingM),
                if (statsSource.isNotEmpty || selectedBuilding != null)
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
                  ),
                const SizedBox(height: AppSizes.spacingM),
                if (selectedBuilding != null)
                  DuesQuickAmountCard(
                    amountText: selectedBuilding.dueAmount != null
                        ? '$currencySymbol${selectedBuilding.dueAmount!.toStringAsFixed(0)}'
                        : '—',
                    currencySymbol: currencySymbol,
                    onTap: () => _openAmountUpdateSheet(
                      context,
                      selectedBuilding,
                      isLoading,
                    ),
                  ),
                const SizedBox(height: AppSizes.spacingL),
                if (selectedBuilding != null) _buildDueListHeader(dues.length),
                const SizedBox(height: AppSizes.spacingM),
                if (isLoading && dues.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(minHeight: 3),
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
                    child: DuesListItemCard(
                      due: dues[index],
                      currencySymbol: currencySymbol,
                      highlighted: highlightDueId == dues[index].id,
                      onMenuTap: () => _openDueStatusSheet(context, dues[index]),
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

  Future<void> _showBuildingPicker(
    BuildContext context,
    List<BuildingEntity> buildings,
  ) async {
    final result = await BuildingPickerSheet.show(
      context,
      buildings: buildings,
      selectedBuildingId: ref.watch(selectedBuildingIdProvider),
    );
    if (result.cancelled || result.buildingId == null) return;
    if (result.buildingId == ref.read(selectedBuildingIdProvider)) return;
    ref.read(selectedBuildingIdProvider.notifier).select(result.buildingId);
    setState(() {
      _selectedDueDay = null;
    });
    _reloadDues();
  }

  Future<void> _openAmountUpdateSheet(
    BuildContext context,
    BuildingEntity building,
    bool isLoading,
  ) async {
    _amountController.clear();
    setState(() {
      _selectedDueDay = null;
      _affectCurrent = false;
    });
    await DuesAmountUpdateSheet.show(
      context,
      amountController: _amountController,
      selectedDueDay: _selectedDueDay,
      affectCurrent: _affectCurrent,
      isLoading: isLoading,
      hintAmount: building.dueAmount?.toStringAsFixed(0),
      currencySymbol: _currencySymbol(),
      onDueDayChanged: (value) => setState(() => _selectedDueDay = value),
      onAffectCurrentChanged: (value) =>
          setState(() => _affectCurrent = value),
      onSubmit: () => _updateDueAmount([building]),
    );
  }

  List<int> _yearOptions(List<DueEntity> dues) {
    final currentYear = DateTime.now().year;
    final yearSet = <int>{
      for (var i = 0; i < 5; i++) currentYear - i,
      ...dues.map((d) => d.year),
    };
    return yearSet.toList()..sort((a, b) => b.compareTo(a));
  }

  bool get _hasActiveFilters {
    final now = DateTime.now();
    return _statusFilter != null ||
        _monthFilter == null ||
        _yearFilter == null ||
        _monthFilter != now.month ||
        _yearFilter != now.year;
  }

  String _dueStatusLabel(BuildContext context, DueStatus? status) {
    final common = context.t.common;
    if (status == null) return common.all;
    switch (status) {
      case DueStatus.paid:
        return common.paidStatus;
      case DueStatus.pending:
        return common.pendingStatus;
      case DueStatus.overdue:
        return common.overdueStatus;
      case DueStatus.waived:
        return common.all;
    }
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    List<DueEntity> dues,
    bool isLoading,
  ) async {
    if (isLoading) return;
    var draftStatus = _statusFilter;
    var draftMonth = _monthFilter;
    var draftYear = _yearFilter;
    final common = context.t.common;
    final years = _yearOptions(dues);

    await PremiumFilterSheet.show(
      context: context,
      title: common.filter,
      applyLabel: common.apply,
      fieldBuilder: (ctx, setSheetState) {
        final statusAllToken = Object();
        final monthAllToken = Object();
        final yearAllToken = Object();
        return [
          PremiumFilterFieldConfig(
            label: common.status,
            value: _dueStatusLabel(ctx, draftStatus),
            hint: common.all,
            icon: Icons.flag_outlined,
            onTap: () async {
              final picked = await showPremiumSingleSelectPicker<Object?>(
                context: ctx,
                title: common.status,
                selected: draftStatus ?? statusAllToken,
                options: [
                  PremiumFilterPickerOption(
                    value: statusAllToken,
                    label: common.all,
                    icon: Icons.layers_outlined,
                  ),
                  PremiumFilterPickerOption(
                    value: DueStatus.paid,
                    label: common.paidStatus,
                    icon: Icons.check_circle_outline,
                  ),
                  PremiumFilterPickerOption(
                    value: DueStatus.pending,
                    label: common.pendingStatus,
                    icon: Icons.schedule_outlined,
                  ),
                  PremiumFilterPickerOption(
                    value: DueStatus.overdue,
                    label: common.overdueStatus,
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              );
              if (picked == null) return;
              setSheetState(() {
                draftStatus = identical(picked, statusAllToken)
                    ? null
                    : picked as DueStatus;
              });
            },
          ),
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
          _statusFilter = draftStatus;
          _monthFilter = draftMonth;
          _yearFilter = draftYear;
        });
        _reloadDues();
      },
    );
  }

  int _resolveTotalUnits(
    BuildingEntity? building,
    List<DueEntity> statsSource,
  ) {
    final fromBuilding = building?.totalApartments ?? 0;
    final fromDues = statsSource.length;
    return math.max(math.max(fromBuilding, fromDues), 1);
  }

  void _tryInitialize(List<BuildingEntity> buildings) {
    if (_initialized || buildings.isEmpty) return;
    _initialized = true;
    final firstId = buildings.first.id;
    ref.read(selectedBuildingIdProvider.notifier).select(firstId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reloadDues();
    });
  }

  Future<void> _reloadDues() async {
    final buildingId = ref.read(selectedBuildingIdProvider);
    if (buildingId == null) return;

    await ref.read(duesNotifierProvider.notifier).loadBuildingDues(
          buildingId,
          month: _monthFilter,
          year: _yearFilter,
          status: _statusFilter,
          paginated: false,
        );

    if (!mounted) return;

    if (_statusFilter != null) {
      try {
        final result = await ref.read(duesRepositoryProvider).getBuildingDues(
              buildingId,
              month: _monthFilter,
              year: _yearFilter,
              paginated: false,
            );
        setState(() => _statsDues = result.items);
      } catch (_) {
        setState(() => _statsDues = ref.read(duesNotifierProvider).dues);
      }
    } else {
      setState(() => _statsDues = const []);
    }
  }

  void _invalidateDashboardDuesHero() {
    ref.invalidate(allBuildingsDuesProvider);
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

  Future<void> _openDueStatusSheet(BuildContext context, DueEntity due) async {
    final monthLabel = '${monthName(context, due.month)} ${due.year}';
    final status = await DueStatusSheet.show(
      context,
      due: due,
      monthLabel: monthLabel,
    );
    if (!mounted || status == null || status == due.status) return;
    await _updateStatus(due.id, status);
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

  Future<void> _updateDueAmount(List<BuildingEntity> buildings) async {
    final buildingId = ref.read(selectedBuildingIdProvider);
    if (buildingId == null) return;

    final toast = ref.read(toastProvider.notifier);
    void validationToast(String msg) {
      toast.show(msg, type: ToastType.info);
    }

    final amountText = _amountController.text
        .trim()
        .replaceAll(',', '.')
        .replaceAll(' ', '');
    final dueDay = _selectedDueDay;

    double? parsedAmount;
    if (amountText.isNotEmpty) {
      parsedAmount = double.tryParse(amountText);
      if (parsedAmount == null || parsedAmount <= 0) {
        validationToast(context.t.common.dueAmountInvalidPositive);
        return;
      }
    }

    final hasAmount = parsedAmount != null && parsedAmount > 0;
    final hasDueDay = dueDay != null;
    if (!hasAmount && !hasDueDay) {
      validationToast(context.t.common.dueUpdateNeedAmountOrDay);
      return;
    }

    final building = _buildingFor(buildingId, buildings);
    late final double resolvedAmount;
    if (hasAmount) {
      resolvedAmount = parsedAmount;
    } else {
      final stored = building?.dueAmount;
      if (stored == null || stored <= 0) {
        validationToast(context.t.common.dueUpdateNeedStoredAmount);
        return;
      }
      resolvedAmount = stored;
    }

    final ok = await ref
        .read(duesNotifierProvider.notifier)
        .updateBuildingDueAmount(
          buildingId: buildingId,
          dueAmount: resolvedAmount,
          dueDay: dueDay,
          currency: _currencyCode(),
          affectCurrent: _affectCurrent,
        );

    if (!mounted) return;
    toast.show(
      ok
          ? context.t.common.dueAmountUpdated
          : context.t.common.dueAmountUpdateFailed,
      type: ok ? ToastType.success : ToastType.error,
    );
    if (ok) {
      _amountController.clear();
      setState(() {
        _selectedDueDay = null;
        _affectCurrent = false;
      });
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
      await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
      if (!mounted) return;
      _invalidateDashboardDuesHero();
      if (!mounted) return;
      await _reloadDues();
    }
  }

  BuildingEntity? _buildingFor(String buildingId, List<BuildingEntity> list) {
    for (final b in list) {
      if (b.id == buildingId) return b;
    }
    return null;
  }

  Future<void> _updateStatus(String dueId, DueStatus status) async {
    final buildingId = ref.read(selectedBuildingIdProvider);
    if (buildingId == null) return;
    await ref.read(duesNotifierProvider.notifier).updateStatus(
          buildingId: buildingId,
          dueId: dueId,
          status: status,
        );
    if (!mounted) return;
    await _reloadDues();
    if (!mounted) return;
    _invalidateDashboardDuesHero();
    ref
        .read(toastProvider.notifier)
        .show(context.t.common.duesUpdated, type: ToastType.success);
  }

  String _currencyCode() {
    return LocaleSettings.currentLocale == AppLocale.tr ? 'TRY' : 'USD';
  }

  String _currencySymbol() {
    return LocaleSettings.currentLocale == AppLocale.tr ? '₺' : r'$';
  }
}
