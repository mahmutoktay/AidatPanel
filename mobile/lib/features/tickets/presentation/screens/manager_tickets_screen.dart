import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/building_selector_provider.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/sliding_segmented_control.dart';
import '../../../dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../../dashboard/presentation/providers/dashboard_filter_scope_provider.dart';
import '../../../dashboard/presentation/utils/dashboard_filter_scope_routing.dart';
import '../../../dashboard/presentation/utils/manager_dashboard_mapper.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/manager_open_tickets_count_provider.dart';
import '../providers/tickets_provider.dart';
import '../providers/manager_ticket_filter_provider.dart';
import '../utils/ticket_labels.dart';
import '../widgets/ticket_list_card.dart';

class ManagerTicketsScreen extends ConsumerStatefulWidget {
  const ManagerTicketsScreen({
    super.key,
    this.initialScope = const DashboardFilterScope.all(),
  });

  final DashboardFilterScope initialScope;

  @override
  ConsumerState<ManagerTicketsScreen> createState() =>
      _ManagerTicketsScreenState();
}

class _ManagerTicketsScreenState extends ConsumerState<ManagerTicketsScreen> {
  final ScrollController _scrollController = ScrollController();
  late DashboardFilterScope _filterScope;

  /// Segment sırası: Tümü | Onaylandı | Yapıldı | Reddedildi (Açık yok).
  static const _statusFilterOptions = <TicketStatus?>[
    null,
    TicketStatus.inProgress,
    TicketStatus.resolved,
    TicketStatus.closed,
  ];

  @override
  void initState() {
    super.initState();
    _filterScope = widget.initialScope;
    attachPaginationScroll(
      _scrollController,
      () => ref.read(ticketsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(ticketsNotifierProvider).canLoadMore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_bootstrap());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Varsayılan açılış: anasayfada hatırlanan bina (Tümü/Site → somut bina).
  DashboardFilterScope _defaultOpeningScope(
    DashboardFilterScope scope,
    List<BuildingEntity> buildings,
  ) {
    if (scope.isBuilding &&
        scope.buildingId != null &&
        buildings.any((b) => b.id == scope.buildingId)) {
      return scope;
    }

    final remembered = ref.read(dashboardFilterScopeProvider);
    if (remembered.isBuilding &&
        remembered.buildingId != null &&
        buildings.any((b) => b.id == remembered.buildingId)) {
      return remembered;
    }

    return normalizeToBuildingScope(
      remembered.isAll ? scope : remembered,
      buildings,
    );
  }

  List<String> _scopedBuildingIds(List<BuildingEntity> buildings) {
    return ManagerDashboardMapper.filterBuildingsByScope(
      buildings,
      siteId: _filterScope.siteId,
      buildingId: _filterScope.buildingId,
    ).map((b) => b.id).toList(growable: false);
  }

  Future<void> _bootstrap() async {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    if (buildings.isEmpty) return;
    final resolved = _defaultOpeningScope(_filterScope, buildings);
    if (resolved != _filterScope) {
      setState(() => _filterScope = resolved);
    }
    await _loadCurrentScope();
  }

  Future<void> _loadCurrentScope() async {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    final ids = _scopedBuildingIds(buildings);
    if (ids.isEmpty) return;
    await ref
        .read(ticketsNotifierProvider.notifier)
        .loadScopedBuildingTickets(ids);
  }

  void _onScopeChanged(DashboardFilterScope scope) {
    setState(() => _filterScope = scope);
    unawaited(_loadCurrentScope());
  }

  Future<void> _openTicket(String ticketId) async {
    await context.push('/tickets/$ticketId');
    if (mounted) {
      await _loadCurrentScope();
      ref.invalidate(managerOpenTicketsCountProvider);
    }
  }

  List<TicketEntity> _filteredTickets(List<TicketEntity> tickets) {
    final filterStatus = ref.watch(managerTicketFilterProvider);

    Iterable<TicketEntity> result = tickets;
    if (filterStatus != null && filterStatus != TicketStatus.open) {
      result = result.where((t) => t.status == filterStatus);
    }
    return result.toList(growable: false);
  }

  int get _filterIndex {
    final status = ref.watch(managerTicketFilterProvider);
    final index = _statusFilterOptions.indexOf(status);
    return index < 0 ? 0 : index;
  }

  void _onFilterIndexChanged(int index) {
    if (index < 0 || index >= _statusFilterOptions.length) return;
    final next = _statusFilterOptions[index];
    if (next == ref.read(managerTicketFilterProvider)) return;
    ref.read(managerTicketFilterProvider.notifier).select(next);
  }

  List<String> _filterLabels(BuildContext context) {
    return [
      context.t.common.all,
      for (final status in _statusFilterOptions.skip(1))
        status!.label(context),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final state = ref.watch(ticketsNotifierProvider);
    final t = context.t.features.tickets;
    final filtered = _filteredTickets(state.tickets);
    final canFilter = buildings.isNotEmpty;
    final showBuildingName = !_filterScope.isBuilding;
    final buildingNames = {
      for (final b in buildings) b.id: b.name,
    };

    return DashboardSecondaryScaffold(
      title: t.managerTitle,
      showNotificationAction: true,
      body: DashboardListScreenBody(
        header: buildings.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DashboardBuildingSelector(
                    buildings: buildings,
                    scope: _filterScope,
                    includeAllOption: true,
                    onScopeChanged: _onScopeChanged,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  SlidingSegmentedControl(
                    segments: _filterLabels(context),
                    selectedIndex: _filterIndex,
                    onChanged: _onFilterIndexChanged,
                    enabled: canFilter,
                    fontSize: 14,
                  ),
                ],
              ),
        list: RefreshIndicator(
          onRefresh: _loadCurrentScope,
          child: buildings.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    EmptyStateWidget(
                      icon: Icons.apartment_outlined,
                      title: t.managerNoBuildingsTitle,
                      subtitle: t.managerNoBuildingsSubtitle,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingL,
                        ),
                        child: SizedBox(
                          height: AppSizes.buttonHeightSecondary,
                          child: FilledButton(
                            onPressed: () => context.push(
                              '/manager-dashboard/add-building',
                            ),
                            child: Text(context.t.common.addBuilding),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildList(
                  context,
                  state,
                  filtered,
                  showBuildingName: showBuildingName,
                  buildingNames: buildingNames,
                ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    TicketsState state,
    List<TicketEntity> tickets, {
    required bool showBuildingName,
    required Map<String, String> buildingNames,
  }) {
    final t = context.t.features.tickets;
    if (state.isLoading && state.tickets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.error != null && state.tickets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          Center(
            child: Padding(
              padding: AppSizes.screenBodyScrollPadding,
              child: Column(
                children: [
                  Text(state.error ?? t.loadError, textAlign: TextAlign.center),
                  const SizedBox(height: AppSizes.spacingM),
                  FilledButton(
                    onPressed: _loadCurrentScope,
                    child: Text(context.t.common.tryAgain),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (tickets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyStateWidget(
            icon: Icons.support_agent_outlined,
            title: t.managerNoMatchingTicketsTitle,
            subtitle: t.managerNoMatchingTicketsSubtitle,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSizes.screenBodyScrollPadding,
      itemCount: tickets.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= tickets.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final ticket = tickets[i];
        final buildingName = showBuildingName && ticket.buildingId != null
            ? buildingNames[ticket.buildingId]
            : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
          child: TicketListCard(
            ticket: ticket,
            subtitlePrefix: buildingName,
            onTap: () => _openTicket(ticket.id),
          ),
        );
      },
    );
  }
}
