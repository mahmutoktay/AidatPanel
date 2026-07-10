import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_confirm_actions.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../providers/site_expenses_provider.dart';
import '../widgets/site_expense_list_item_card.dart';

class SiteExpensesScreen extends ConsumerStatefulWidget {
  final String siteId;

  const SiteExpensesScreen({super.key, required this.siteId});

  @override
  ConsumerState<SiteExpensesScreen> createState() => _SiteExpensesScreenState();
}

class _SiteExpensesScreenState extends ConsumerState<SiteExpensesScreen> {
  final _scrollController = ScrollController();
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
    final t = context.t.features.sites;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteExpenseTitle),
        content: Text(t.deleteExpenseConfirm),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          SizedBox(
            width: double.maxFinite,
            child: AppConfirmActions(
              cancelLabel: context.t.common.cancel,
              confirmLabel: context.t.common.delete,
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
        .read(siteExpensesNotifierProvider.notifier)
        .delete(widget.siteId, expense.id);
    if (!mounted) return;
    if (ok) {
      ref.read(toastProvider.notifier).show(
            t.deleteExpenseSuccess,
            type: ToastType.success,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.sites;
    final state = ref.watch(siteExpensesNotifierProvider);

    return DashboardSecondaryScaffold(
      title: t.siteExpensesTitle,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(t.addExpense),
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
      ),
    );
  }
}
