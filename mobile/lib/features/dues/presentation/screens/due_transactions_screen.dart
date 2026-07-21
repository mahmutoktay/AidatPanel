import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/building_selector_provider.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../../dashboard/presentation/utils/manager_dashboard_mapper.dart';
import '../../domain/entities/due_transaction_entity.dart';
import '../providers/due_transactions_provider.dart';
import '../widgets/due_transaction_tile.dart';

class DueTransactionsScreen extends ConsumerStatefulWidget {
  const DueTransactionsScreen({
    super.key,
    this.initialScope = const DashboardFilterScope.all(),
  });

  final DashboardFilterScope initialScope;

  @override
  ConsumerState<DueTransactionsScreen> createState() =>
      _DueTransactionsScreenState();
}

class _DueTransactionsScreenState extends ConsumerState<DueTransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  late DashboardFilterScope _filterScope;
  String? _lastLoadedScopeKey;

  @override
  void initState() {
    super.initState();
    _filterScope = widget.initialScope;
    attachPaginationScroll(
      _scrollController,
      () => ref.read(dueTransactionsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(dueTransactionsNotifierProvider).canLoadMore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadForCurrentScope());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _scopeKey(DashboardFilterScope scope) {
    if (scope.isBuilding) return 'b:${scope.buildingId}';
    if (scope.isSite) return 's:${scope.siteId}';
    return 'all';
  }

  List<BuildingEntity> _scopedBuildings(List<BuildingEntity> buildings) {
    return ManagerDashboardMapper.filterBuildingsByScope(
      buildings,
      siteId: _filterScope.siteId,
      buildingId: _filterScope.buildingId,
    );
  }

  Future<void> _loadForCurrentScope() async {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    if (buildings.isEmpty) return;

    // "Tüm Binalar" bu ekranda yok; all → alfabetik ilk bina (site korunur).
    if (_filterScope.isAll) {
      final sorted = [...buildings]..sort((a, b) => a.name.compareTo(b.name));
      _filterScope = DashboardFilterScope.building(sorted.first.id);
      if (mounted) setState(() {});
    }

    final scopeKey = _scopeKey(_filterScope);
    if (_lastLoadedScopeKey == scopeKey) return;
    _lastLoadedScopeKey = scopeKey;

    final scopedBuildings = _scopedBuildings(buildings);
    final buildingIds =
        scopedBuildings.map((building) => building.id).toList(growable: false);

    await ref
        .read(dueTransactionsNotifierProvider.notifier)
        .loadBuildings(buildingIds);
  }

  void _onScopeChanged(DashboardFilterScope scope) {
    setState(() {
      _filterScope = scope;
      _lastLoadedScopeKey = null;
    });
    unawaited(_loadForCurrentScope());
  }

  Future<void> _openTransaction(DueTransactionEntity transaction) async {
    if (transaction.dekontId == null) return;
    await context.push('/dekonts/${transaction.dekontId}');
    if (!mounted) return;
    await _loadForCurrentScope();
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final state = ref.watch(dueTransactionsNotifierProvider);
    final t = context.t.features.dues.transactions;

    return DashboardSecondaryScaffold(
      title: t.title,
      showNotificationAction: true,
      fallbackRoute: '/manager-dashboard',
      body: DashboardListScreenBody(
        header: buildings.isEmpty
            ? null
            : DashboardBuildingSelector(
                buildings: buildings,
                scope: _filterScope,
                includeAllOption: false,
                onScopeChanged: _onScopeChanged,
              ),
        list: RefreshIndicator(
          onRefresh: _loadForCurrentScope,
          child: buildings.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    EmptyStateWidget(
                      icon: Icons.apartment_outlined,
                      title: context.t.features.notifications.noBuilding,
                    ),
                  ],
                )
              : _buildList(context, state),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, DueTransactionsState state) {
    final t = context.t.features.dues.transactions;

    if (state.isLoading && state.transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.error != null && state.transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          Center(
            child: Padding(
              padding: AppSizes.screenBodyScrollPadding,
              child: Text(
                userFacingError(state.error!),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (state.transactions.isEmpty) {
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
      itemCount: state.transactions.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (_, index) {
        if (index >= state.transactions.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final item = state.transactions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
          child: DueTransactionTile(
            transaction: item,
            onTap: item.dekontId != null ? () => _openTransaction(item) : null,
          ),
        );
      },
    );
  }
}
