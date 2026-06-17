import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/utils/pagination_scroll.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../utils/dekont_filter_chips.dart';
import '../../../../shared/widgets/dashboard_filter_chips_row.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../buildings/data/buildings_store.dart';
import '../providers/dekont_provider.dart';
import '../widgets/dekont_list_card.dart';

class ManagerDekontsScreen extends ConsumerStatefulWidget {
  const ManagerDekontsScreen({super.key});

  @override
  ConsumerState<ManagerDekontsScreen> createState() =>
      _ManagerDekontsScreenState();
}

class _ManagerDekontsScreenState extends ConsumerState<ManagerDekontsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _buildingId;
  String? _filterKey;

  @override
  void initState() {
    super.initState();
    attachPaginationScroll(
      _scrollController,
      () => ref.read(managerDekontsNotifierProvider.notifier).loadMore(),
      canLoad: () => ref.read(managerDekontsNotifierProvider).canLoadMore,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = _buildingId;
    if (id == null) return;
    await ref
        .read(managerDekontsNotifierProvider.notifier)
        .loadBuilding(id, filterKey: _filterKey);
  }

  @override
  Widget build(BuildContext context) {
    final buildings = ref.watch(buildingsStoreProvider).value ?? [];
    final state = ref.watch(managerDekontsNotifierProvider);
    final t = context.t.features.dekont;

    if (_buildingId == null && buildings.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _buildingId = buildings.first.id);
        _load();
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
                      _load();
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  DashboardFilterChipsRow(
                    chips: dekontStatusFilterChips(
                      context,
                      selectedFilterKey: _filterKey,
                      onSelected: (key) {
                        setState(() => _filterKey = key);
                        _load();
                      },
                    ),
                  ),
                ],
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

  Widget _buildList(BuildContext context, ManagerDekontsState state) {
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
            subtitle: t.emptySubtitleManager,
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
        final apt = d.apartment != null
            ? '${t.apartment}: ${d.apartment!.number}'
            : null;
        final uploader = d.uploadedBy != null
            ? '${t.uploadedBy}: ${d.uploadedBy!.name}'
            : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
          child: DekontListCard(
            dekont: d,
            apartmentLabel: apt,
            uploaderLabel: uploader,
            onTap: () => context.push('/dekonts/${d.id}'),
          ),
        );
      },
    );
  }
}
