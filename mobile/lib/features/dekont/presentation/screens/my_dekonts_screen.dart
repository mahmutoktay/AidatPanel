import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_filterable_list_screen.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/premium_filter_button.dart';
import '../../../../shared/widgets/premium_filter_picker.dart';
import '../../../../shared/widgets/premium_filter_sheet.dart';
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
    attachPaginationScroll(
      _scrollController,
      () => ref.read(myDekontsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(myDekontsNotifierProvider).canLoadMore,
    );
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

  String _dekontFilterLabel(BuildContext context, String? key) {
    final t = context.t.features.dekont.resident;
    switch (key) {
      case 'pending':
        return t.filterPending;
      case 'approved':
        return t.filterApproved;
      case 'rejected':
        return t.filterRejected;
      default:
        return t.filterAll;
    }
  }

  Future<void> _openFilterSheet() async {
    var draftKey = _filterKey;
    final common = context.t.common;
    final t = context.t.features.dekont.resident;
    final allToken = Object();

    await PremiumFilterSheet.show(
      context: context,
      title: common.filter,
      applyLabel: common.apply,
      fieldBuilder: (ctx, setSheetState) => [
        PremiumFilterFieldConfig(
          label: common.status,
          value: _dekontFilterLabel(ctx, draftKey),
          hint: t.filterAll,
          icon: Icons.receipt_long_outlined,
          onTap: () async {
            final picked = await showPremiumSingleSelectPicker<Object?>(
              context: ctx,
              title: common.status,
              selected: draftKey ?? allToken,
              options: [
                PremiumFilterPickerOption(
                  value: allToken,
                  label: t.filterAll,
                  icon: Icons.layers_outlined,
                ),
                PremiumFilterPickerOption(
                  value: 'pending',
                  label: t.filterPending,
                  icon: Icons.hourglass_top_outlined,
                ),
                PremiumFilterPickerOption(
                  value: 'approved',
                  label: t.filterApproved,
                  icon: Icons.check_circle_outline,
                ),
                PremiumFilterPickerOption(
                  value: 'rejected',
                  label: t.filterRejected,
                  icon: Icons.cancel_outlined,
                ),
              ],
            );
            if (picked == null) return;
            setSheetState(() {
              draftKey = identical(picked, allToken) ? null : picked as String?;
            });
          },
        ),
      ],
      onApply: () {
        setState(() => _filterKey = draftKey);
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myDekontsNotifierProvider);
    final t = context.t.features.dekont;

    return DashboardFilterableListScreen(
      title: t.myDekontsTitle,
      onRefresh: _load,
      actions: [
        IconButton(
          tooltip: t.makePaymentTitle,
          onPressed: () => context.push('/payment'),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
      header: PremiumFilterButton(
        hasActiveFilters: _filterKey != null,
        onPressed: _openFilterSheet,
      ),
      list: _buildList(context, state),
    );
  }

  Widget _buildList(BuildContext context, MyDekontsState state) {
    final t = context.t.features.dekont;

    if (state.isLoading && state.dekonts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.error != null && state.dekonts.isEmpty) {
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

    if (state.dekonts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: t.emptyTitle,
            subtitle: t.emptySubtitleResident,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSizes.screenBodyScrollPadding,
      itemCount: state.dekonts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= state.dekonts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final d = state.dekonts[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
          child: DekontListCard(
            dekont: d,
            forResident: true,
            onTap: () => context.push('/dekonts/${d.id}'),
          ),
        );
      },
    );
  }
}
