import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/building_selector_provider.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/due_transaction_entity.dart';
import '../providers/due_transactions_provider.dart';
import '../widgets/due_transaction_tile.dart';

class DueTransactionsScreen extends ConsumerStatefulWidget {
  const DueTransactionsScreen({super.key});

  @override
  ConsumerState<DueTransactionsScreen> createState() =>
      _DueTransactionsScreenState();
}

class _DueTransactionsScreenState extends ConsumerState<DueTransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _lastRequestedBuildingId;
  String? _pendingSyncBuildingId;

  @override
  void initState() {
    super.initState();
    attachPaginationScroll(
      _scrollController,
      () => ref.read(dueTransactionsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(dueTransactionsNotifierProvider).canLoadMore,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _syncSelectedBuildingAndLoad(
    List<BuildingEntity> buildings,
    String? selectedBuildingId,
  ) {
    if (buildings.isEmpty) return;

    final selectedExists =
        selectedBuildingId != null &&
        buildings.any((building) => building.id == selectedBuildingId);
    final effectiveId = selectedExists
        ? selectedBuildingId
        : buildings.first.id;

    if (_lastRequestedBuildingId == effectiveId && selectedExists) return;
    if (_pendingSyncBuildingId == effectiveId) return;

    _pendingSyncBuildingId = effectiveId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingSyncBuildingId = null;
      if (!mounted) return;

      final latestBuildings = ref.read(buildingsStoreProvider).value ?? [];
      if (latestBuildings.isEmpty) return;

      final latestSelectedId = ref.read(selectedBuildingIdProvider);
      final latestSelectedExists =
          latestSelectedId != null &&
          latestBuildings.any((building) => building.id == latestSelectedId);
      final id = latestSelectedExists
          ? latestSelectedId
          : latestBuildings.first.id;

      if (!latestSelectedExists) {
        ref.read(selectedBuildingIdProvider.notifier).select(id);
      }
      if (_lastRequestedBuildingId == id) return;

      _lastRequestedBuildingId = id;
      unawaited(_loadBuilding(id));
    });
  }

  Future<void> _loadBuilding(String buildingId) {
    return ref
        .read(dueTransactionsNotifierProvider.notifier)
        .loadBuilding(buildingId);
  }

  Future<void> _load() async {
    final id = ref.read(selectedBuildingIdProvider);
    if (id == null) return;
    _lastRequestedBuildingId = id;
    await _loadBuilding(id);
  }

  void _openTransaction(DueTransactionEntity transaction) {
    if (transaction.dekontId != null) {
      context.push('/dekonts/${transaction.dekontId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final state = ref.watch(dueTransactionsNotifierProvider);
    final t = context.t.features.dues.transactions;
    final buildingId = ref.watch(selectedBuildingIdProvider);

    _syncSelectedBuildingAndLoad(buildings, buildingId);

    return DashboardSecondaryScaffold(
      title: t.title,
      showNotificationAction: true,
      fallbackRoute: '/manager-dashboard',
      body: DashboardListScreenBody(
        header: buildings.isEmpty
            ? null
            : DashboardSingleBuildingSelector(
                buildings: buildings,
                selectedBuildingId: buildingId,
                onSelected: (id) {
                  ref.read(selectedBuildingIdProvider.notifier).select(id);
                  unawaited(_load());
                },
              ),
        list: RefreshIndicator(
          onRefresh: _load,
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
