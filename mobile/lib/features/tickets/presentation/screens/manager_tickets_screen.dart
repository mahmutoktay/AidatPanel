import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/navigation_provider.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/premium_filter_button.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/premium_filter_sheet.dart';
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
    final id = ref.read(selectedBuildingIdProvider);
    if (id != null && mounted) {
      await _load(id);
      ref.invalidate(managerOpenTicketsCountProvider);
    }
  }

  List<TicketEntity> _filteredTickets(List<TicketEntity> tickets) {
    if (_statusFilter == null) return tickets;
    return tickets.where((t) => t.status == _statusFilter).toList();
  }

  String _statusFilterLabel(BuildContext context, TicketStatus? status) {
    if (status == null) return context.t.common.all;
    return status.label(context);
  }

  Future<void> _openFilterSheet() async {
    var draftStatus = _statusFilter;
    final common = context.t.common;

    await PremiumFilterSheet.show(
      context: context,
      title: common.filter,
      applyLabel: common.apply,
      fieldBuilder: (ctx, setSheetState) {
        final allToken = Object();
        return [
          PremiumFilterFieldConfig(
            label: common.status,
            value: _statusFilterLabel(ctx, draftStatus),
            hint: common.all,
            icon: Icons.flag_outlined,
            onTap: () async {
              final picked = await showPremiumSingleSelectPicker<Object?>(
                context: ctx,
                title: common.status,
                selected: draftStatus ?? allToken,
                options: [
                  PremiumFilterPickerOption(
                    value: allToken,
                    label: common.all,
                    icon: Icons.layers_outlined,
                  ),
                  PremiumFilterPickerOption(
                    value: TicketStatus.open,
                    label: TicketStatus.open.label(ctx),
                    icon: Icons.radio_button_unchecked,
                  ),
                  PremiumFilterPickerOption(
                    value: TicketStatus.inProgress,
                    label: TicketStatus.inProgress.label(ctx),
                    icon: Icons.autorenew_rounded,
                  ),
                  PremiumFilterPickerOption(
                    value: TicketStatus.closed,
                    label: TicketStatus.closed.label(ctx),
                    icon: Icons.check_circle_outline,
                  ),
                ],
              );
              if (picked == null) return;
              setSheetState(() {
                draftStatus = identical(picked, allToken)
                    ? null
                    : picked as TicketStatus;
              });
            },
          ),
        ];
      },
      onApply: () => setState(() => _statusFilter = draftStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final state = ref.watch(ticketsNotifierProvider);
    final t = context.t.features.tickets;
    final filtered = _filteredTickets(state.tickets);

    final buildingId = ref.watch(selectedBuildingIdProvider);
    if (buildingId == null && buildings.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(selectedBuildingIdProvider.notifier).select(buildings.first.id);
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
                    selectedBuildingId: buildingId,
                    onSelected: (id) {
                      ref.read(selectedBuildingIdProvider.notifier).select(id);
                      _load(id);
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  PremiumFilterButton(
                    hasActiveFilters: _statusFilter != null,
                    onPressed: _openFilterSheet,
                  ),
                ],
              ),
        list: RefreshIndicator(
          onRefresh: () async {
            final id = ref.read(selectedBuildingIdProvider);
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
                      final id = ref.read(selectedBuildingIdProvider);
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
