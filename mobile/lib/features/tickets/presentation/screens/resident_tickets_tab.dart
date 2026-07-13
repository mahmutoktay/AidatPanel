import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/tickets_provider.dart';
import '../widgets/resident_application_card.dart';

class ResidentTicketsTab extends ConsumerStatefulWidget {
  const ResidentTicketsTab({super.key});

  @override
  ConsumerState<ResidentTicketsTab> createState() => _ResidentTicketsTabState();
}

class _ResidentTicketsTabState extends ConsumerState<ResidentTicketsTab> {
  final ScrollController _scrollController = ScrollController();
  bool _requested = false;

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

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsNotifierProvider);
    final ticketsT = context.t.features.tickets;

    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(ticketsNotifierProvider.notifier).loadMyTickets();
      });
    }

    final tickets = ticketsState.tickets;
    final listItemCount = _listItemCount(ticketsState, tickets);

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () =>
                ref.read(ticketsNotifierProvider.notifier).loadMyTickets(),
            color: AppColors.brand,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSizes.screenBodyScrollPadding.copyWith(
                top: 0,
                bottom: AppSizes.spacingXL + 80,
              ),
              itemCount: listItemCount,
              itemBuilder: (context, index) {
                if (ticketsState.isLoading && tickets.isEmpty) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(top: AppSizes.spacingXL),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                }

                if (tickets.isEmpty) {
                  if (index == 0) {
                    return EmptyStateWidget(
                      icon: Icons.assignment_outlined,
                      title: ticketsT.residentEmptyTitle,
                      subtitle: ticketsT.residentEmptySubtitle,
                    );
                  }
                  return const SizedBox.shrink();
                }

                if (index < tickets.length) {
                  final ticket = tickets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
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

                if (index == tickets.length && ticketsState.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
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
                backgroundColor: AppColors.actionButton,
                foregroundColor: AppColors.actionButtonForeground,
                icon: const Icon(Icons.add),
                label: Text(
                  ticketsT.createTitle,
                  style: AppTypography.button.copyWith(
                    color: AppColors.actionButtonForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _listItemCount(TicketsState ticketsState, List tickets) {
    if (ticketsState.isLoading && tickets.isEmpty) return 1;
    if (tickets.isEmpty) return 1;
    return tickets.length + (ticketsState.isLoadingMore ? 1 : 0);
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await context.push<bool>('/tickets/create');
    if (created == true && mounted) {
      await ref.read(ticketsNotifierProvider.notifier).loadMyTickets();
    }
  }
}
