import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../domain/entities/due_entity.dart';
import '../../domain/resident_dues_list.dart';
import '../providers/dues_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/utils/expense_labels.dart';

class ResidentDuesTab extends ConsumerStatefulWidget {
  const ResidentDuesTab({super.key});

  @override
  ConsumerState<ResidentDuesTab> createState() => _ResidentDuesTabState();
}

class _ResidentDuesTabState extends ConsumerState<ResidentDuesTab> {
  final ScrollController _scrollController = ScrollController();
  bool _requestedDues = false;
  bool _requestedExpenses = false;
  int _selectedSegment = 0; // 0: Aidatlar, 1: Giderler

  @override
  void initState() {
    super.initState();
    attachPaginationScroll(_scrollController, () {
      if (_selectedSegment == 0) {
        ref.read(duesNotifierProvider.notifier).loadMoreMyDues();
      } else {
        ref.read(expensesNotifierProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duesState = ref.watch(duesNotifierProvider);
    final expensesState = ref.watch(expensesNotifierProvider);
    final highlightDueId = ref.watch(residentDueHighlightIdProvider);

    if (!_requestedDues) {
      _requestedDues = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(duesNotifierProvider.notifier).loadMyDues();
      });
    }

    if (_selectedSegment == 1 && !_requestedExpenses) {
      _requestedExpenses = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(expensesNotifierProvider.notifier).loadMyExpenses();
      });
    }

    final items = _buildBodyItems(
      context,
      duesState,
      expensesState,
      highlightDueId,
    );

    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedSegment == 0) {
          await ref.read(duesNotifierProvider.notifier).loadMyDues();
        } else {
          await ref.read(expensesNotifierProvider.notifier).loadMyExpenses();
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSizes.screenBodyScrollPadding,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is _LoadingItem) {
            return const Padding(
              padding: EdgeInsets.only(top: AppSizes.spacingXL),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (item is _EmptyStateItem) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSizes.spacingXL),
              child: Center(
                child: Text(
                  item.isDue
                      ? context.t.common.noDuesYet
                      : context.t.features.expenses.emptyTitle,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }
          if (item is _ErrorStateItem) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSizes.spacingXL),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      item.message,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _requestedExpenses = false;
                        });
                      },
                      child: Text(context.t.common.tryAgain),
                    ),
                  ],
                ),
              ),
            );
          }
          if (item is _ActionButtonsItem) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildActionButtons(context),
            );
          }
          if (item is _SegmentedControlItem) {
            return _SegmentedControl(
              selectedIndex: _selectedSegment,
              onChanged: (val) {
                setState(() {
                  _selectedSegment = val;
                });
              },
            );
          }
          if (item is _SectionHeaderItem) {
            return Text(
              item.title,
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            );
          }
          if (item is _DueCardItem) {
            return _buildDueCard(
              context,
              item.due,
              highlighted: item.highlighted,
            );
          }
          if (item is _ExpenseCardItem) {
            return _buildExpenseCard(context, item.expense);
          }
          if (item is _SpacingItem) {
            return SizedBox(height: item.height);
          }
          if (item is _LoadingMoreItem) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<_ResidentDuesRowItem> _buildBodyItems(
    BuildContext context,
    DuesState duesState,
    ExpensesState expensesState,
    String? highlightDueId,
  ) {
    final items = <_ResidentDuesRowItem>[
      const _ActionButtonsItem(),
      const _SegmentedControlItem(),
      const _SpacingItem(AppSizes.spacingM),
    ];

    if (_selectedSegment == 0) {
      if (duesState.isLoading) {
        items.add(const _LoadingItem());
        return items;
      }

      if (duesState.dues.isEmpty) {
        items.add(const _EmptyStateItem(isDue: true));
        return items;
      }

      final split = splitResidentDuesForDisplay(duesState.dues);
      if (split.current.isNotEmpty) {
        items.add(_SectionHeaderItem(context.t.common.currentPeriodDue));
        items.add(const _SpacingItem(AppSizes.spacingM));
        for (final due in split.current) {
          items.add(
            _DueCardItem(
              due,
              highlighted: highlightDueId == null || highlightDueId == due.id,
            ),
          );
        }
      }

      if (split.past.isNotEmpty) {
        if (split.current.isNotEmpty) {
          items.add(const _SpacingItem(AppSizes.spacingL));
        }
        items.add(_SectionHeaderItem(context.t.common.myPastDues));
        items.add(const _SpacingItem(AppSizes.spacingM));
        for (final due in split.past) {
          items.add(_DueCardItem(due, highlighted: highlightDueId == due.id));
        }
      }
      if (duesState.isLoadingMore) {
        items.add(const _LoadingMoreItem());
      }
    } else {
      if (expensesState.isLoading) {
        items.add(const _LoadingItem());
        return items;
      }

      if (expensesState.error != null && expensesState.expenses.isEmpty) {
        items.add(_ErrorStateItem(message: expensesState.error!));
        return items;
      }

      if (expensesState.expenses.isEmpty) {
        items.add(const _EmptyStateItem(isDue: false));
        return items;
      }

      for (final expense in expensesState.expenses) {
        items.add(_ExpenseCardItem(expense));
      }
      if (expensesState.isLoadingMore) {
        items.add(const _LoadingMoreItem());
      }
    }

    return items;
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final t = context.t.features.dekont;
    return [
      Row(
        children: [
          Expanded(
            child: Material(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => context.push('/resident-dashboard/payment'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.payment_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.makePaymentTitle,
                        style: AppTypography.button.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Material(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => context.push('/resident-dashboard/dekonts'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.myDekontsTitle,
                        style: AppTypography.button.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSizes.spacingL),
    ];
  }

  Widget _buildDueCard(
    BuildContext context,
    DueEntity due, {
    required bool highlighted,
  }) {
    final statusVisual = _statusVisual(context, due.status);
    final periodLabel =
        '${_monthName(context, due.month)} ${due.year} • ${context.t.common.apartmentLabel} ${due.apartmentNumber}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  periodLabel,
                  style: (highlighted ? AppTypography.h3 : AppTypography.h4)
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusVisual.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusVisual.label,
                  style: AppTypography.caption.copyWith(
                    color: statusVisual.fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            '₺${due.amount.toStringAsFixed(2)}',
            style: (highlighted ? AppTypography.h3 : AppTypography.bodyLarge)
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, ExpenseEntity expense) {
    final date =
        '${expense.date.day}.${expense.date.month}.${expense.date.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/expenses/${expense.id}', extra: expense),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXS),
                    Text(
                      '${expense.category.label(context)} · $date',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (expense.note != null && expense.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.spacingXS),
                        child: Text(
                          expense.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Text(
                '${expense.amount?.toStringAsFixed(2) ?? "0.00"} ₺',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(BuildContext context, int month) {
    final t = context.t.common;
    switch (month) {
      case 1:
        return t.monthJanuary;
      case 2:
        return t.monthFebruary;
      case 3:
        return t.monthMarch;
      case 4:
        return t.monthApril;
      case 5:
        return t.monthMay;
      case 6:
        return t.monthJune;
      case 7:
        return t.monthJuly;
      case 8:
        return t.monthAugust;
      case 9:
        return t.monthSeptember;
      case 10:
        return t.monthOctober;
      case 11:
        return t.monthNovember;
      case 12:
        return t.monthDecember;
      default:
        return '$month';
    }
  }

  _StatusVisual _statusVisual(BuildContext context, DueStatus status) {
    switch (status) {
      case DueStatus.paid:
        return _StatusVisual(
          label: context.t.common.paidStatus,
          fg: AppColors.success,
          bg: AppColors.successBg,
        );
      case DueStatus.overdue:
        return _StatusVisual(
          label: context.t.common.overdueStatus,
          fg: AppColors.error,
          bg: AppColors.errorBg,
        );
      case DueStatus.waived:
        return _StatusVisual(
          label: context.t.common.waivedStatus,
          fg: AppColors.textSecondary,
          bg: AppColors.fill,
        );
      case DueStatus.pending:
        return _StatusVisual(
          label: context.t.common.pendingStatus,
          fg: AppColors.warning,
          bg: AppColors.warningBg,
        );
    }
  }
}

class _StatusVisual {
  final String label;
  final Color fg;
  final Color bg;

  const _StatusVisual({
    required this.label,
    required this.fg,
    required this.bg,
  });
}

class _SegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentItem(
              label: context.t.common.dues,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _SegmentItem(
              label: context.t.features.expenses.title,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

sealed class _ResidentDuesRowItem {
  const _ResidentDuesRowItem();
}

class _LoadingItem extends _ResidentDuesRowItem {
  const _LoadingItem();
}

class _EmptyStateItem extends _ResidentDuesRowItem {
  final bool isDue;
  const _EmptyStateItem({required this.isDue});
}

class _ErrorStateItem extends _ResidentDuesRowItem {
  final String message;
  const _ErrorStateItem({required this.message});
}

class _ActionButtonsItem extends _ResidentDuesRowItem {
  const _ActionButtonsItem();
}

class _SegmentedControlItem extends _ResidentDuesRowItem {
  const _SegmentedControlItem();
}

class _SectionHeaderItem extends _ResidentDuesRowItem {
  final String title;
  const _SectionHeaderItem(this.title);
}

class _DueCardItem extends _ResidentDuesRowItem {
  final DueEntity due;
  final bool highlighted;
  const _DueCardItem(this.due, {required this.highlighted});
}

class _ExpenseCardItem extends _ResidentDuesRowItem {
  final ExpenseEntity expense;
  const _ExpenseCardItem(this.expense);
}

class _SpacingItem extends _ResidentDuesRowItem {
  final double height;
  const _SpacingItem(this.height);
}

class _LoadingMoreItem extends _ResidentDuesRowItem {
  const _LoadingMoreItem();
}
