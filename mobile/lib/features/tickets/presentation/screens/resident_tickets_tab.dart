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
import '../widgets/ticket_list_card.dart';

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
    attachPaginationScroll(_scrollController, () {
      ref.read(ticketsNotifierProvider.notifier).loadMore();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(ticketsNotifierProvider);
    final t = context.t.features.tickets;

    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(ticketsNotifierProvider.notifier).loadMyTickets();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        backgroundColor: AppColors.info,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          t.newTicket,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(ticketsNotifierProvider.notifier).loadMyTickets(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: AppSizes.screenBodyScrollPadding.copyWith(
                bottom: AppSizes.spacingXL + 72,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.myTickets,
                            style: AppTypography.h3.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingM),
                        ],
                      );
                    }

                    final adjustedIndex = index - 1;

                    if (ticketsState.isLoading &&
                        ticketsState.tickets.isEmpty) {
                      if (adjustedIndex == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(top: AppSizes.spacingXL),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return null;
                    }

                    if (ticketsState.tickets.isEmpty) {
                      if (adjustedIndex == 0) {
                        return EmptyStateWidget(
                          icon: Icons.support_agent_outlined,
                          title: t.emptyTitle,
                          subtitle: t.emptySubtitle,
                        );
                      }
                      return null;
                    }

                    if (adjustedIndex < ticketsState.tickets.length) {
                      final ticket = ticketsState.tickets[adjustedIndex];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSizes.spacingM,
                        ),
                        child: TicketListCard(
                          ticket: ticket,
                          showSubtitleMeta: false,
                          descriptionMaxLines: 1,
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

                    if (adjustedIndex == ticketsState.tickets.length &&
                        ticketsState.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSizes.spacingM,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return null;
                  },
                  childCount:
                      1 +
                      (ticketsState.isLoading && ticketsState.tickets.isEmpty
                          ? 1
                          : ticketsState.tickets.isEmpty
                          ? 1
                          : ticketsState.tickets.length +
                                (ticketsState.isLoadingMore ? 1 : 0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await context.push<bool>('/tickets/create');
    if (created == true && mounted) {
      await ref.read(ticketsNotifierProvider.notifier).loadMyTickets();
    }
  }
}
