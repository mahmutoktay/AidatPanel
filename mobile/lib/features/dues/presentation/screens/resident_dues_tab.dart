import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_section_label.dart';
import '../../domain/entities/due_entity.dart';
import '../../domain/resident_dues_list.dart';
import '../providers/dues_provider.dart';
import '../widgets/resident_due_ledger_row.dart';
import '../widgets/resident_dues_status_banner.dart';

class ResidentDuesTab extends ConsumerStatefulWidget {
  const ResidentDuesTab({super.key});

  @override
  ConsumerState<ResidentDuesTab> createState() => _ResidentDuesTabState();
}

class _ResidentDuesTabState extends ConsumerState<ResidentDuesTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _loadMoreInFlight = false;

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
  }

  Future<void> _refresh() async {
    await ref.read(duesNotifierProvider.notifier).loadMyDues();
  }

  void _onScrollNearEnd() {
    if (_loadMoreInFlight) return;
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
    final displayDues = prepareResidentDuesList(duesState.dues);
    final r = context.t.features.dues.resident;

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.brand,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSizes.screenBodyScrollPadding.copyWith(
            top: 0,
            bottom: AppSizes.spacingXL,
          ),
          children: [
            if (!duesState.isLoading || duesState.dues.isNotEmpty) ...[
              ResidentDuesStatusBanner(dues: displayDues),
              const SizedBox(height: AppSizes.spacingM),
            ],
            DashboardSectionLabel(
              label: r.paymentRecordsLabel,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSizes.spacingXS),
            ..._buildDueSection(context, displayDues, duesState),
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
      for (var i = 0; i < dues.length; i++)
        ResidentDueLedgerRow(
          due: dues[i],
          showDivider: i < dues.length - 1 || duesState.isLoadingMore,
        ),
    ];

    if (duesState.isLoadingMore) {
      items.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
        child: Center(child: CircularProgressIndicator()),
      ));
    }

    return items;
  }
}
