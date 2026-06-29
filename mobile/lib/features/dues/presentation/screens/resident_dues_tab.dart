import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../domain/entities/due_entity.dart';
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
  bool _loadMoreInFlight = false;
  int _selectedSegment = 0;

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
        return ref.read(duesNotifierProvider).canLoadMore;
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
    final split = splitResidentDuesForDisplay(duesState.dues);
    final displayDues =
        _selectedSegment == 0 ? split.current : split.past;
    final contentItems = _buildDueItems(context, displayDues, duesState);

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
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(duesNotifierProvider.notifier).loadMyDues(),
              color: AppColors.primary,
              child: contentItems.isEmpty
                  ? ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSizes.screenBodyScrollPadding.copyWith(
                        top: 0,
                      ),
                      children: [
                        _buildEmptyState(context, duesState),
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
                      itemBuilder: (context, index) => contentItems[index],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DuesState duesState) {
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

  List<Widget> _buildDueItems(
    BuildContext context,
    List<DueEntity> dues,
    DuesState duesState,
  ) {
    if (duesState.isLoading || dues.isEmpty) return const [];

    final items = <Widget>[
      for (final due in dues) ResidentDueListCard(due: due),
    ];

    if (duesState.isLoadingMore && _selectedSegment == 1) {
      items.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
        child: Center(child: CircularProgressIndicator()),
      ));
    }

    return items;
  }

  Widget _buildActionCards(BuildContext context) {
    final dekontT = context.t.features.dekont;

    return Row(
      children: [
        Expanded(
          child: DuesActionCard(
            icon: Icons.credit_card_outlined,
            label: context.t.common.makePayment,
            iconBg: AppColors.primary.withValues(alpha: 0.1),
            iconColor: AppColors.primary,
            onTap: () => context.push('/resident-dashboard/payment'),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: DuesActionCard(
            icon: Icons.receipt_long_outlined,
            label: dekontT.viewDekonts,
            iconBg: AppColors.primary.withValues(alpha: 0.1),
            iconColor: AppColors.primary,
            onTap: () => context.push('/resident-dashboard/dekonts'),
          ),
        ),
      ],
    );
  }
}
