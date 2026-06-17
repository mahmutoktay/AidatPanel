import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../expenses/presentation/widgets/expense_list_item_card.dart';
import '../../domain/resident_dues_list.dart';
import '../providers/dues_provider.dart';
import '../widgets/dues_action_card.dart';
import '../widgets/dues_segment_toggle.dart';
import '../widgets/resident_due_list_card.dart';

class ResidentDuesTab extends ConsumerStatefulWidget {
  const ResidentDuesTab({super.key});

  @override
  ConsumerState<ResidentDuesTab> createState() => _ResidentDuesTabState();
}

class _ResidentDuesTabState extends ConsumerState<ResidentDuesTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _requestedExpenses = false;
  bool _loadMoreInFlight = false;
  int _selectedSegment = 0; // 0: Aidatlar, 1: Giderler

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDuesLoaded());
    attachPaginationScroll(
      _scrollController,
      _onScrollNearEnd,
      canLoad: () {
        if (_loadMoreInFlight) return false;
        if (_selectedSegment == 0) {
          return ref.read(duesNotifierProvider).canLoadMore;
        }
        return ref.read(expensesNotifierProvider).canLoadMore;
      },
    );
  }

  void _ensureDuesLoaded() {
    if (!mounted) return;
    final duesState = ref.read(duesNotifierProvider);
    if (duesState.dues.isEmpty && !duesState.isLoading) {
      ref.read(duesNotifierProvider.notifier).loadMyDues();
    }
  }

  void _onScrollNearEnd() {
    if (_loadMoreInFlight) return;

    if (_selectedSegment == 0) {
      final duesState = ref.read(duesNotifierProvider);
      if (!duesState.canLoadMore) return;
      _loadMoreInFlight = true;
      ref
          .read(duesNotifierProvider.notifier)
          .loadMoreMyDues()
          .whenComplete(() => _loadMoreInFlight = false);
      return;
    }

    final expensesState = ref.read(expensesNotifierProvider);
    if (!expensesState.canLoadMore) return;
    _loadMoreInFlight = true;
    ref
        .read(expensesNotifierProvider.notifier)
        .loadMore()
        .whenComplete(() => _loadMoreInFlight = false);
  }

  void _onSegmentChanged(int index) {
    if (_selectedSegment == index) return;
    setState(() => _selectedSegment = index);
    if (index == 1 && !_requestedExpenses) {
      _requestedExpenses = true;
      ref.read(expensesNotifierProvider.notifier).loadMyExpenses();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final duesState = ref.watch(duesNotifierProvider);
    final expensesState = ref.watch(expensesNotifierProvider);
    final contentItems = _buildContentItems(
      context,
      duesState,
      expensesState,
    );

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppSizes.screenBodyScrollPadding.copyWith(
              top: 0,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildActionCards(context),
                const SizedBox(height: AppSizes.spacingS),
                DuesSegmentToggle(
                    segments: [
                      context.t.common.dues,
                      context.t.features.expenses.title,
                    ],
                    selectedIndex: _selectedSegment,
                    onChanged: _onSegmentChanged,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_selectedSegment == 0) {
                    await ref
                        .read(duesNotifierProvider.notifier)
                        .loadMyDues();
                  } else {
                    await ref
                        .read(expensesNotifierProvider.notifier)
                        .loadMyExpenses();
                  }
                },
                color: AppColors.primary,
                child: contentItems.isEmpty
                    ? ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: AppSizes.screenBodyScrollPadding.copyWith(
                          top: 0,
                        ),
                        children: [
                          _buildContentState(
                            context,
                            duesState,
                            expensesState,
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: AppSizes.screenBodyScrollPadding.copyWith(
                          top: 0,
                          bottom: AppSizes.spacingXL,
                        ),
                        itemCount: contentItems.length,
                        itemBuilder: (context, index) =>
                            contentItems[index],
                      ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildContentState(
    BuildContext context,
    DuesState duesState,
    ExpensesState expensesState,
  ) {
    if (_selectedSegment == 0) {
      if (duesState.isLoading) {
        return const Padding(
          padding: EdgeInsets.only(top: AppSizes.spacingXL),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: AppSizes.spacingXL),
        child: Center(
          child: Text(
            context.t.common.noDuesYet,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (expensesState.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSizes.spacingXL),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (expensesState.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSizes.spacingXL),
        child: Center(
          child: Column(
            children: [
              Text(
                expensesState.error!,
                style: AppTypography.body1.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingM),
              FilledButton(
                onPressed: () {
                  _requestedExpenses = false;
                  ref
                      .read(expensesNotifierProvider.notifier)
                      .loadMyExpenses();
                },
                child: Text(context.t.common.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spacingXL),
      child: Center(
        child: Text(
          context.t.features.expenses.emptyTitle,
          style: AppTypography.body1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentItems(
    BuildContext context,
    DuesState duesState,
    ExpensesState expensesState,
  ) {
    if (_selectedSegment == 0) {
      if (duesState.isLoading || duesState.dues.isEmpty) {
        return const [];
      }

      final split = splitResidentDuesForDisplay(duesState.dues);
      final items = <Widget>[];

      if (split.current.isNotEmpty) {
        items.add(_sectionTitle(context.t.common.currentPeriodDue));
        items.add(const SizedBox(height: AppSizes.spacingS));
        for (final due in split.current) {
          items.add(ResidentDueListCard(due: due));
        }
      }

      if (split.past.isNotEmpty) {
        if (split.current.isNotEmpty) {
          items.add(const SizedBox(height: AppSizes.spacingL));
        }
        items.add(_sectionTitle(context.t.common.myPastDues));
        items.add(const SizedBox(height: AppSizes.spacingS));
        for (final due in split.past) {
          items.add(ResidentDueListCard(due: due));
        }
      }

      if (duesState.isLoadingMore) {
        items.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
          child: Center(child: CircularProgressIndicator()),
        ));
      }

      return items;
    }

    if (expensesState.isLoading ||
        expensesState.expenses.isEmpty ||
        expensesState.error != null) {
      return const [];
    }

    final items = <Widget>[
      for (final expense in expensesState.expenses)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
          child: ExpenseListItemCard(expense: expense),
        ),
    ];

    if (expensesState.isLoadingMore) {
      items.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
        child: Center(child: CircularProgressIndicator()),
      ));
    }

    return items;
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.h4.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    final dekontT = context.t.features.dekont;

    return Row(
      children: [
        Expanded(
          child: DuesActionCard(
            icon: Icons.credit_card_outlined,
            label: dekontT.makePaymentTitle,
            iconBg: AppColors.fill,
            iconColor: AppColors.textPrimary,
            onTap: () => context.push('/resident-dashboard/payment'),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: DuesActionCard(
            icon: Icons.receipt_long_outlined,
            label: dekontT.viewDekonts,
            iconBg: AppColors.fill,
            iconColor: AppColors.textPrimary,
            onTap: () => context.push('/resident-dashboard/dekonts'),
          ),
        ),
      ],
    );
  }
}
