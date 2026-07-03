import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/ticket_entity.dart';
import '../providers/tickets_provider.dart';
import '../widgets/resident_application_card.dart';
import '../widgets/ticket_filter_tabs.dart';

enum _ApplicationFilter { all, faults, requests }

class ResidentTicketsTab extends ConsumerStatefulWidget {
  const ResidentTicketsTab({super.key});

  @override
  ConsumerState<ResidentTicketsTab> createState() => _ResidentTicketsTabState();
}

class _ResidentTicketsTabState extends ConsumerState<ResidentTicketsTab> {
  final ScrollController _scrollController = ScrollController();
  bool _requested = false;
  _ApplicationFilter _filter = _ApplicationFilter.all;

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

  List<TicketEntity> _filtered(List<TicketEntity> tickets) {
    switch (_filter) {
      case _ApplicationFilter.faults:
        return tickets
            .where(
              (t) =>
                  t.category == TicketCategory.malfunction ||
                  t.category == TicketCategory.complaint,
            )
            .toList();
      case _ApplicationFilter.requests:
        return tickets
            .where((t) => t.category == TicketCategory.request)
            .toList();
      case _ApplicationFilter.all:
        return tickets;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsNotifierProvider);
    final t = context.t;
    final ticketsT = t.features.tickets;
    final common = t.common;

    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(ticketsNotifierProvider.notifier).loadMyTickets();
      });
    }

    final filtered = _filtered(ticketsState.tickets);
    final listItemCount = _listItemCount(ticketsState, filtered);

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppSizes.screenBodyScrollPadding.copyWith(
              top: 0,
              bottom: AppSizes.spacingM,
            ),
            child: TicketFilterTabs(
              labels: [common.tabAll, common.tabFaults, common.tabRequests],
              selectedIndex: _filter.index,
              onChanged: (index) => setState(
                () => _filter = _ApplicationFilter.values[index],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () =>
                      ref.read(ticketsNotifierProvider.notifier).loadMyTickets(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSizes.screenBodyScrollPadding.copyWith(
                      top: 0,
                      bottom: AppSizes.spacingXL + 80,
                    ),
                    itemCount: listItemCount,
                    itemBuilder: (context, index) {
                      if (ticketsState.isLoading &&
                          ticketsState.tickets.isEmpty) {
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(top: AppSizes.spacingXL),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      if (filtered.isEmpty) {
                        if (index == 0) {
                          return EmptyStateWidget(
                            icon: Icons.assignment_outlined,
                            title: ticketsT.myApplicationsTitle,
                            subtitle: ticketsT.emptySubtitle,
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      if (index < filtered.length) {
                        final ticket = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.spacingM,
                          ),
                          child: ResidentApplicationCard(
                            ticket: ticket,
                            onTap: () async {
                              await context.push('/tickets/${ticket.id}');
                              if (mounted) {
                                await ref
                                    .read(ticketsNotifierProvider.notifier)
                                    .loadMyTickets();
                              }
                            },
                          ),
                        );
                      }

                      if (index == filtered.length &&
                          ticketsState.isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSizes.spacingM,
                          ),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                Positioned(
                  right: AppSizes.dashboardScreenPaddingHorizontal,
                  bottom: AppSizes.spacingM,
                  child: SafeArea(
                    child: FloatingActionButton.extended(
                      onPressed: () => _openCreate(context),
                      backgroundColor: AppColors.primary,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        common.addRequest,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _listItemCount(TicketsState ticketsState, List<TicketEntity> filtered) {
    if (ticketsState.isLoading && ticketsState.tickets.isEmpty) return 1;
    if (filtered.isEmpty) return 1;
    return filtered.length + (ticketsState.isLoadingMore ? 1 : 0);
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await context.push<bool>('/tickets/create');
    if (created == true && mounted) {
      await ref.read(ticketsNotifierProvider.notifier).loadMyTickets();
    }
  }
}
