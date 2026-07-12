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
import '../../../dashboard/presentation/utils/dashboard_filter_scope_routing.dart';
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

  /// Talepler yalnızca tek bina ile çalışır; Tümü/Site → somut binaya düşürülür.
  DashboardFilterScope _normalizeToBuildingScope(
    DashboardFilterScope scope,
    List<BuildingEntity> buildings,
  ) {
    return normalizeToBuildingScope(scope, buildings);
  }

  Future<void> _bootstrap() async {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    if (buildings.isEmpty) return;
    final normalized = _normalizeToBuildingScope(_filterScope, buildings);
    if (normalized != _filterScope) {
      setState(() => _filterScope = normalized);
    }
    await _loadCurrentBuilding();
  }

  Future<void> _loadCurrentBuilding() async {
    final id = _filterScope.buildingId;
    if (id == null || id.isEmpty) return;
    await ref.read(ticketsNotifierProvider.notifier).loadBuildingTickets(id);
  }

  void _onScopeChanged(DashboardFilterScope scope) {
    final buildings = ref.read(buildingsStoreProvider).value ?? [];
    final normalized = _normalizeToBuildingScope(scope, buildings);
    setState(() => _filterScope = normalized);
    unawaited(_loadCurrentBuilding());
  }

  Future<void> _openTicket(String ticketId) async {
    await context.push('/tickets/$ticketId');
    if (mounted) {
      await _loadCurrentBuilding();
      ref.invalidate(managerOpenTicketsCountProvider);
    }
  }

  List<TicketEntity> _filteredTickets(List<TicketEntity> tickets) {
    final filterStatus = ref.watch(managerTicketFilterProvider);
    if (filterStatus == null || filterStatus == TicketStatus.open) {
      return tickets;
    }
    return tickets.where((t) => t.status == filterStatus).toList();
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
    final buildingId = _filterScope.buildingId;
    final canFilter = buildingId != null && buildingId.isNotEmpty;

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
                    scope: _filterScope.isBuilding
                        ? _filterScope
                        : _normalizeToBuildingScope(_filterScope, buildings),
                    includeAllOption: false,
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
          onRefresh: _loadCurrentBuilding,
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
              : _buildList(context, state, filtered),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    TicketsState state,
    List<TicketEntity> tickets,
  ) {
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
                    onPressed: _loadCurrentBuilding,
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
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
          child: TicketListCard(
            ticket: ticket,
            onTap: () => _openTicket(ticket.id),
          ),
        );
      },
    );
  }
}
