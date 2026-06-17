import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_filter_chips_row.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/manager_open_tickets_count_provider.dart';
import '../providers/tickets_provider.dart';
import '../utils/ticket_labels.dart';
import '../widgets/ticket_list_card.dart';

class ManagerTicketsScreen extends ConsumerStatefulWidget {
  const ManagerTicketsScreen({super.key});

  @override
  ConsumerState<ManagerTicketsScreen> createState() =>
      _ManagerTicketsScreenState();
}

class _ManagerTicketsScreenState extends ConsumerState<ManagerTicketsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _buildingId;
  TicketStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    attachPaginationScroll(
      _scrollController,
      () => ref.read(ticketsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(ticketsNotifierProvider).canLoadMore,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load(String buildingId) {
    return ref
        .read(ticketsNotifierProvider.notifier)
        .loadBuildingTickets(buildingId);
  }

  Future<void> _openTicket(String ticketId) async {
    await context.push('/tickets/$ticketId');
    final id = _buildingId;
    if (id != null && mounted) {
      await _load(id);
      ref.invalidate(managerOpenTicketsCountProvider);
    }
  }

  List<TicketEntity> _filteredTickets(List<TicketEntity> tickets) {
    if (_statusFilter == null) return tickets;
    return tickets.where((t) => t.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final state = ref.watch(ticketsNotifierProvider);
    final t = context.t.features.tickets;
    final filtered = _filteredTickets(state.tickets);

    if (_buildingId == null && buildings.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _buildingId = buildings.first.id);
        _load(buildings.first.id);
      });
    }

    return DashboardSecondaryScaffold(
      title: t.managerTitle,
      showNotificationAction: true,
      body: DashboardListScreenBody(
        header: buildings.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DashboardSingleBuildingSelector(
                    buildings: buildings,
                    selectedBuildingId: _buildingId,
                    onSelected: (id) {
                      setState(() => _buildingId = id);
                      _load(id);
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  DashboardFilterChipsRow(
                    chips: [
                      DashboardFilterChipItem(
                        label: context.t.common.all,
                        selected: _statusFilter == null,
                        onTap: () => setState(() => _statusFilter = null),
                      ),
                      DashboardFilterChipItem(
                        label: TicketStatus.open.label(context),
                        selected: _statusFilter == TicketStatus.open,
                        onTap: () =>
                            setState(() => _statusFilter = TicketStatus.open),
                      ),
                      DashboardFilterChipItem(
                        label: TicketStatus.inProgress.label(context),
                        selected: _statusFilter == TicketStatus.inProgress,
                        onTap: () => setState(
                          () => _statusFilter = TicketStatus.inProgress,
                        ),
                      ),
                      DashboardFilterChipItem(
                        label: TicketStatus.closed.label(context),
                        selected: _statusFilter == TicketStatus.closed,
                        onTap: () =>
                            setState(() => _statusFilter = TicketStatus.closed),
                      ),
                    ],
                  ),
                ],
              ),
        list: RefreshIndicator(
          onRefresh: () async {
            final id = _buildingId;
            if (id != null) await _load(id);
          },
          child: _buildList(context, state, filtered),
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
                    onPressed: () {
                      final id = _buildingId;
                      if (id != null) _load(id);
                    },
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
            title: context.t.features.tickets.emptyTitle,
            subtitle: context.t.features.tickets.emptySubtitle,
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
