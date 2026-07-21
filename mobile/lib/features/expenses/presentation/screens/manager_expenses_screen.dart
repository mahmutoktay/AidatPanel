import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/list_cache_refresh.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/app_confirm_actions.dart';
import '../../../../shared/widgets/building_selector_provider.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/premium_filter_button.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/premium_filter_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../../dashboard/presentation/utils/dashboard_filter_scope_routing.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_provider.dart';
import '../utils/expense_labels.dart';
import '../widgets/expense_list_item_card.dart';

class ManagerExpensesScreen extends ConsumerStatefulWidget {
  const ManagerExpensesScreen({
    super.key,
    this.initialScope = const DashboardFilterScope.all(),
  });

  final DashboardFilterScope initialScope;

  @override
  ConsumerState<ManagerExpensesScreen> createState() =>
      _ManagerExpensesScreenState();
}

class _ManagerExpensesScreenState extends ConsumerState<ManagerExpensesScreen> {
  final ScrollController _scrollController = ScrollController();
  late DashboardFilterScope _filterScope;
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    _filterScope = widget.initialScope;
    attachPaginationScroll(
      _scrollController,
      () => ref.read(expensesNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(expensesNotifierProvider).canLoadMore,
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

  /// Giderler yalnızca tek bina ile çalışır; Tümü/Site → somut binaya düşürülür.
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
    await ref
        .read(expensesNotifierProvider.notifier)
        .load(id, month: _month, year: _year);
  }

  void _onScopeChanged(DashboardFilterScope scope) {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    final normalized = _normalizeToBuildingScope(scope, buildings);
    setState(() => _filterScope = normalized);
    unawaited(_loadCurrentBuilding());
  }

  Future<void> _openForm({ExpenseEntity? expense}) async {
    final id = _filterScope.buildingId;
    if (id == null) return;
    final ok = await context.push<bool>(
      '/manager-dashboard/expenses/form?buildingId=${Uri.encodeComponent(id)}',
      extra: expense,
    );
    if (ok == true && mounted) {
      unawaited(invalidateExpensesRelatedCaches(ref));
      unawaited(_loadCurrentBuilding());
    }
  }

  Future<void> _confirmDelete(ExpenseEntity expense) async {
    final t = context.t.features.expenses;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteTitle),
        content: Text(t.deleteConfirm),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          SizedBox(
            width: double.maxFinite,
            child: AppConfirmActions(
              cancelLabel: context.t.common.cancel,
              confirmLabel: t.deleteAction,
              onCancel: () => Navigator.pop(ctx, false),
              onConfirm: () => Navigator.pop(ctx, true),
              dangerConfirm: true,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref
        .read(expensesNotifierProvider.notifier)
        .delete(expense.id);
    if (!mounted) return;
    if (ok) {
      unawaited(invalidateExpensesRelatedCaches(ref));
      ref
          .read(toastProvider.notifier)
          .show(t.deleteSuccess, type: ToastType.success);
    }
  }

  List<int> get _yearOptions =>
      List.generate(6, (i) => DateTime.now().year - i);

  bool get _hasNonDefaultPeriod {
    final now = DateTime.now();
    return _month != now.month || _year != now.year;
  }

  Future<void> _openFilterSheet() async {
    var draftMonth = _month;
    var draftYear = _year;
    final common = context.t.common;

    await PremiumFilterSheet.show(
      context: context,
      title: common.filter,
      applyLabel: common.apply,
      fieldBuilder: (ctx, setSheetState) => [
        PremiumFilterFieldConfig(
          label: common.year,
          value: '$draftYear',
          hint: common.year,
          icon: Icons.date_range_outlined,
          onTap: () async {
            final picked = await showPremiumSingleSelectPicker<int>(
              context: ctx,
              title: common.year,
              selected: draftYear,
              options: [
                for (final y in _yearOptions)
                  PremiumFilterPickerOption(
                    value: y,
                    label: '$y',
                    icon: Icons.calendar_today_outlined,
                  ),
              ],
            );
            if (picked == null) return;
            setSheetState(() => draftYear = picked);
          },
        ),
        PremiumFilterFieldConfig(
          label: common.month,
          value: localizedMonthName(ctx, draftMonth),
          hint: common.month,
          icon: Icons.calendar_month_outlined,
          onTap: () async {
            final picked = await showPremiumSingleSelectPicker<int>(
              context: ctx,
              title: common.month,
              selected: draftMonth,
              options: [
                for (var m = 1; m <= 12; m++)
                  PremiumFilterPickerOption(
                    value: m,
                    label: localizedMonthName(ctx, m),
                    icon: Icons.event_outlined,
                  ),
              ],
            );
            if (picked == null) return;
            setSheetState(() => draftMonth = picked);
          },
        ),
      ],
      onApply: () {
        setState(() {
          _month = draftMonth;
          _year = draftYear;
        });
        unawaited(_loadCurrentBuilding());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final state = ref.watch(expensesNotifierProvider);
    final t = context.t.features.expenses;
    final buildingId = _filterScope.buildingId;
    final canOperate = buildingId != null && buildingId.isNotEmpty;

    return DashboardSecondaryScaffold(
      title: t.title,
      showNotificationAction: true,
      floatingActionButton: !canOperate
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: Text(t.createTitle),
            ),
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
                    hasActiveFilters: _hasNonDefaultPeriod,
                    onPressed: canOperate ? _openFilterSheet : null,
                  ),
                  if (state.summary != null && canOperate) ...[
                    const SizedBox(height: AppSizes.spacingM),
                    _SummaryCard(summary: state.summary!),
                  ],
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
                      subtitle: t.emptySubtitle,
                    ),
                  ],
                )
              : _buildList(context, state),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, ExpensesState state) {
    final t = context.t.features.expenses;

    if (state.isLoading && state.expenses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.error != null && state.expenses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
          Center(
            child: Padding(
              padding: AppSizes.screenBodyScrollPadding,
              child: Column(
                children: [
                  Text(state.error!, textAlign: TextAlign.center),
                  const SizedBox(height: AppSizes.spacingM),
                  FilledButton(
                    onPressed: () => unawaited(_loadCurrentBuilding()),
                    child: Text(context.t.common.tryAgain),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (state.expenses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: t.emptyTitle,
            subtitle: t.emptySubtitle,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSizes.screenBodyScrollPadding,
      itemCount: state.expenses.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= state.expenses.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final e = state.expenses[i];
        return Padding(
          padding: DashboardScreenStyle.listItemPadding,
          child: ExpenseListItemCard(
            expense: e,
            onEdit: () => _openForm(expense: e),
            onDelete: () => _confirmDelete(e),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ExpenseSummaryEntity summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.expenses;
    return DashboardSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${t.total}: ${AppCurrencyFormat.formatWithCode(summary.totalAmount, summary.currency)}',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (summary.byCategory.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingS),
            Wrap(
              spacing: AppSizes.spacingS,
              runSpacing: AppSizes.spacingXS,
              children: summary.byCategory.map((c) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    borderRadius: BorderRadius.circular(
                      DashboardScreenStyle.pillRadius,
                    ),
                  ),
                  child: Text(
                    '${c.category.label(context)}: ${c.amount.toStringAsFixed(0)} ₺ (${c.count})',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
