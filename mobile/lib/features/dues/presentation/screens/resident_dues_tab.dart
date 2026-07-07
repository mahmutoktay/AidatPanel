import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_section_label.dart';
import '../../../dashboard/domain/resident_home_activity_item.dart';
import '../../../dashboard/presentation/widgets/resident_home/resident_home_activity_row.dart';
import '../../../dekont/presentation/providers/dekont_provider.dart';
import '../../domain/entities/due_entity.dart';
import '../../domain/resident_dues_list.dart';
import '../providers/dues_provider.dart';
import '../providers/resident_due_transactions_provider.dart';
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
  bool _loadMoreInFlight = false;
  int _selectedSegment = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDataLoaded());
    attachPaginationScroll(
      _scrollController,
      _onScrollNearEnd,
      canLoad: () {
        if (_loadMoreInFlight) return false;
        return ref.read(duesNotifierProvider).canLoadMore;
      },
    );
  }

  Future<void> _ensureDataLoaded() async {
    if (!mounted) return;
    final duesState = ref.read(duesNotifierProvider);
    if (duesState.dues.isEmpty && !duesState.isLoading) {
      await ref.read(duesNotifierProvider.notifier).loadMyDues();
    }
    final dekontsState = ref.read(myDekontsNotifierProvider);
    if (dekontsState.dekonts.isEmpty && !dekontsState.isLoading) {
      await ref.read(myDekontsNotifierProvider.notifier).load(refresh: true);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(duesNotifierProvider.notifier).loadMyDues(),
      ref.read(myDekontsNotifierProvider.notifier).load(refresh: true),
    ]);
  }

  void _onScrollNearEnd() {
    if (_loadMoreInFlight || _selectedSegment != 1) return;
    final duesState = ref.read(duesNotifierProvider);
    if (!duesState.canLoadMore) return;
    _loadMoreInFlight = true;
    ref
        .read(duesNotifierProvider.notifier)
        .loadMoreMyDues()
        .whenComplete(() => _loadMoreInFlight = false);
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
    final transactionsState = ref.watch(residentDueTransactionsProvider);
    final split = splitResidentDuesForDisplay(duesState.dues);
    final displayDues =
        _selectedSegment == 0 ? split.current : split.past;
    final transactionsT = context.t.features.dues.transactions;

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSizes.screenBodyScrollPadding.copyWith(
            top: 0,
            bottom: AppSizes.spacingXL,
          ),
          children: [
            DashboardSectionLabel(
              label: context.t.common.duesStatus,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSizes.spacingS),
            DuesSegmentToggle(
              segments: [
                context.t.common.dues,
                context.t.common.duesHistory,
              ],
              selectedIndex: _selectedSegment,
              onChanged: (index) => setState(() => _selectedSegment = index),
            ),
            if (_selectedSegment == 0) ...[
              const SizedBox(height: AppSizes.spacingM),
              Text(
                context.t.common.currentPeriodDue,
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingM),
            ..._buildDueSection(context, displayDues, duesState),
            const SizedBox(height: AppSizes.spacingL),
            DashboardSectionLabel(
              label: transactionsT.residentTitle,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSizes.spacingS),
            ..._buildTransactionsSection(context, transactionsState),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDueSection(
    BuildContext context,
    List<DueEntity> dues,
    DuesState duesState,
  ) {
    if (duesState.isLoading && dues.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.spacingXL),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (dues.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingL),
          child: Center(
            child: Text(
              context.t.common.residentNoDuesYet,
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ];
    }

    final items = <Widget>[
      for (final due in dues)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
          child: ResidentDueListCard(due: due),
        ),
    ];

    if (duesState.isLoadingMore && _selectedSegment == 1) {
      items.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
        child: Center(child: CircularProgressIndicator()),
      ));
    }

    return items;
  }

  List<Widget> _buildTransactionsSection(
    BuildContext context,
    ResidentDueTransactionsViewState state,
  ) {
    final t = context.t.features.dues.transactions;

    if (state.isLoading && state.transactions.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.spacingL),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state.transactions.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.residentEmptyTitle,
                textAlign: TextAlign.center,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXS),
              Text(
                t.residentEmptySubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    final duesById = duesByIdMap(ref.read(duesNotifierProvider).dues);

    return [
      for (final transaction in state.transactions)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
          child: ResidentHomeActivityRow(
            item: ResidentHomeActivityItem.transaction(transaction),
            duesById: duesById,
            onTap: transaction.dekontId != null
                ? () => context.push('/dekonts/${transaction.dekontId}')
                : null,
          ),
        ),
    ];
  }
}
