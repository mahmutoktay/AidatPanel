import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/dekont_provider.dart';
import '../widgets/dekont_list_card.dart';

class MyDekontsScreen extends ConsumerStatefulWidget {
  const MyDekontsScreen({super.key});

  @override
  ConsumerState<MyDekontsScreen> createState() => _MyDekontsScreenState();
}

class _MyDekontsScreenState extends ConsumerState<MyDekontsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _filterKey;

  @override
  void initState() {
    super.initState();
    attachPaginationScroll(_scrollController, () {
      ref.read(myDekontsNotifierProvider.notifier).loadMore();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await ref
        .read(myDekontsNotifierProvider.notifier)
        .load(filterKey: _filterKey, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myDekontsNotifierProvider);
    final t = context.t.features.dekont;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(t.myDekontsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: t.makePaymentTitle,
            onPressed: () => context.push('/payment'),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingS,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: t.filterAll,
                  selected: _filterKey == null,
                  onTap: () {
                    setState(() => _filterKey = null);
                    _load();
                  },
                ),
                _FilterChip(
                  label: t.filterPending,
                  selected: _filterKey == 'pending',
                  onTap: () {
                    setState(() => _filterKey = 'pending');
                    _load();
                  },
                ),
                _FilterChip(
                  label: t.filterApproved,
                  selected: _filterKey == 'approved',
                  onTap: () {
                    setState(() => _filterKey = 'approved');
                    _load();
                  },
                ),
                _FilterChip(
                  label: t.filterRejected,
                  selected: _filterKey == 'rejected',
                  onTap: () {
                    setState(() => _filterKey = 'rejected');
                    _load();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: AppSizes.screenBodyScrollPadding,
                          child: Text(
                            userFacingError(state.error!),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : state.dekonts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        EmptyStateWidget(
                          icon: Icons.receipt_long_outlined,
                          title: t.emptyTitle,
                          subtitle: t.emptySubtitleResident,
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: AppSizes.screenBodyScrollPadding,
                      itemCount:
                          state.dekonts.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= state.dekonts.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.spacingM,
                            ),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final d = state.dekonts[i];
                        return DekontListCard(
                          dekont: d,
                          onTap: () => context.push('/dekonts/${d.id}'),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.spacingS),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: AppTypography.body2.copyWith(
          color: selected ? Colors.white : AppColors.textPrimary,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        showCheckmark: selected,
      ),
    );
  }
}
