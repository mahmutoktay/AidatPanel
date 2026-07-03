import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/month_labels.dart';
<<<<<<< HEAD
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/premium_filter_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/sites_store.dart';
=======
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/toast_overlay.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
import '../../domain/entities/site_expense_entity.dart';
import '../providers/site_expenses_provider.dart';
import '../widgets/site_expense_list_item_card.dart';

class SiteExpensesScreen extends ConsumerStatefulWidget {
<<<<<<< HEAD
  const SiteExpensesScreen({super.key, required this.siteId});

  final String siteId;

=======
  final String siteId;

  const SiteExpensesScreen({super.key, required this.siteId});

>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  @override
  ConsumerState<SiteExpensesScreen> createState() => _SiteExpensesScreenState();
}

class _SiteExpensesScreenState extends ConsumerState<SiteExpensesScreen> {
<<<<<<< HEAD
=======
  final _scrollController = ScrollController();
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
<<<<<<< HEAD
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

=======
    attachPaginationScroll(
      _scrollController,
      () => ref.read(siteExpensesNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(siteExpensesNotifierProvider).canLoadMore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  void _load() {
    ref.read(siteExpensesNotifierProvider.notifier).load(
          widget.siteId,
          month: _month,
          year: _year,
        );
  }

  Future<void> _openForm({SiteExpenseEntity? expense}) async {
    final ok = await context.push<bool>(
      '/manager-dashboard/sites/${widget.siteId}/expenses/form',
      extra: expense,
    );
    if (ok == true && mounted) _load();
  }

  Future<void> _confirmDelete(SiteExpenseEntity expense) async {
<<<<<<< HEAD
    final t = context.t.features.expenses;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteTitle),
        content: Text(t.deleteConfirm),
=======
    final t = context.t.features.sites;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteExpenseTitle),
        content: Text(t.deleteExpenseConfirm),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
<<<<<<< HEAD
            child: Text(t.deleteAction),
=======
            child: Text(context.t.common.delete),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref
        .read(siteExpensesNotifierProvider.notifier)
<<<<<<< HEAD
        .delete(expense.id);
    if (!mounted) return;
    if (ok) {
      ref.read(toastProvider.notifier).show(
            t.deleteSuccess,
=======
        .delete(widget.siteId, expense.id);
    if (!mounted) return;
    if (ok) {
      ref.read(toastProvider.notifier).show(
            t.deleteExpenseSuccess,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
            type: ToastType.success,
          );
    }
  }

<<<<<<< HEAD
  Future<void> _pickPeriod() async {
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
        _load();
      },
    );
  }

  List<int> get _yearOptions =>
      List.generate(6, (i) => DateTime.now().year - i);

  @override
  Widget build(BuildContext context) {
    final siteAsync = ref.watch(siteDetailProvider(widget.siteId));
    final state = ref.watch(siteExpensesNotifierProvider);
    final t = context.t.features.sites;
    final expensesT = context.t.features.expenses;

    return DashboardSecondaryScaffold(
      title: siteAsync.value?.name == null
          ? t.siteExpensesTitle
          : '${siteAsync.value!.name} · ${t.siteExpensesTitle}',
      actions: [
        IconButton(
          onPressed: _pickPeriod,
          icon: const Icon(Icons.tune_rounded),
          tooltip: context.t.common.filter,
        ),
        IconButton(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          tooltip: t.addSiteExpense,
        ),
      ],
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _load(),
        child: state.isLoading && state.expenses.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.error != null && state.expenses.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: AppSizes.screenBodyScrollPadding,
                        child: Text(
                          userFacingError(state.error!),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : state.expenses.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyStateWidget(
                            icon: Icons.receipt_long_outlined,
                            title: t.siteExpensesEmpty,
                            subtitle: expensesT.emptySubtitle,
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: AppSizes.screenBodyScrollPadding,
                        itemCount: state.expenses.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final summary = state.summary;
                            if (summary == null) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.spacingM,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppSizes.spacingM,
                                ),
                                decoration: DashboardScreenStyle.whiteCard(),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expensesT.total,
                                            style: AppTypography.caption
                                                .copyWith(
                                              color: AppColors.mutedText,
                                            ),
                                          ),
                                          Text(
                                            '${summary.totalAmount.toStringAsFixed(2)} ₺',
                                            style: AppTypography.h4.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      t.apartmentCountLabel.replaceAll(
                                        '{count}',
                                        '${summary.apartmentCount}',
                                      ),
                                      style: AppTypography.body2.copyWith(
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final expense = state.expenses[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSizes.spacingS,
                            ),
                            child: SiteExpenseListItemCard(
                              expense: expense,
                              onEdit: () => _openForm(expense: expense),
                              onDelete: () => _confirmDelete(expense),
                            ),
                          );
                        },
                      ),
=======
  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final state = ref.watch(siteExpensesNotifierProvider);

    return DashboardSecondaryScaffold(
      title: t.siteExpensesTitle,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppSizes.screenBodyScrollPadding.copyWith(bottom: 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${localizedMonthName(context, _month)} $_year',
                    style: AppTypography.h4.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (state.summary != null)
                  Text(
                    t.totalExpenses.replaceAll(
                      '{amount}',
                      '${state.summary!.totalAmount.toStringAsFixed(0)} ₺',
                    ),
                    style: AppTypography.body2.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Expanded(
            child: state.isLoading && state.expenses.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.expenses.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.receipt_long_outlined,
                        title: t.noExpenses,
                        subtitle: t.noExpensesHint,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _load(),
                        color: AppColors.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: AppSizes.screenBodyScrollPadding.copyWith(
                            top: 0,
                          ),
                          itemCount: state.expenses.length +
                              (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.expenses.length) {
                              return const Padding(
                                padding: EdgeInsets.all(AppSizes.spacingM),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final expense = state.expenses[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.spacingS,
                              ),
                              child: SiteExpenseListItemCard(
                                expense: expense,
                                onEdit: () => _openForm(expense: expense),
                                onDelete: () => _confirmDelete(expense),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      ),
    );
  }
}
