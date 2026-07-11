import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/premium_filter_button.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/premium_filter_sheet.dart';
import '../providers/expenses_provider.dart';
import '../widgets/expense_list_item_card.dart';

/// Sakin — bina giderlerini salt okunur listeler (`GET /me/expenses`).
class ResidentExpensesScreen extends ConsumerStatefulWidget {
  const ResidentExpensesScreen({super.key});

  @override
  ConsumerState<ResidentExpensesScreen> createState() =>
      _ResidentExpensesScreenState();
}

class _ResidentExpensesScreenState extends ConsumerState<ResidentExpensesScreen> {
  final ScrollController _scrollController = ScrollController();
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    attachPaginationScroll(
      _scrollController,
      () => ref.read(expensesNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(expensesNotifierProvider).canLoadMore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_load());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() {
    return ref.read(expensesNotifierProvider.notifier).loadMyExpenses(
          month: _month,
          year: _year,
        );
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
        unawaited(_load());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesNotifierProvider);
    final t = context.t.features.expenses;

    return DashboardSecondaryScaffold(
      title: t.residentTitle,
      showNotificationAction: true,
      body: DashboardListScreenBody(
        header: PremiumFilterButton(
          hasActiveFilters: _hasNonDefaultPeriod,
          onPressed: _openFilterSheet,
        ),
        list: RefreshIndicator(
          onRefresh: _load,
          child: _buildList(context, state),
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
                    onPressed: () => unawaited(_load()),
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
            subtitle: t.residentEmptySubtitle,
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
          child: ExpenseListItemCard(expense: e),
        );
      },
    );
  }
}
