import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/notification_icon_button.dart';
import '../../../buildings/data/buildings_store.dart';
import '../providers/dekont_provider.dart';
import '../utils/dekont_labels.dart';
import '../widgets/dekont_list_card.dart';

class ManagerDekontsScreen extends ConsumerStatefulWidget {
  const ManagerDekontsScreen({super.key});

  @override
  ConsumerState<ManagerDekontsScreen> createState() =>
      _ManagerDekontsScreenState();
}

class _ManagerDekontsScreenState extends ConsumerState<ManagerDekontsScreen> {
  String? _buildingId;
  String? _filterKey;

  Future<void> _load() async {
    final id = _buildingId;
    if (id == null) return;
    await ref.read(managerDekontsNotifierProvider.notifier).loadBuilding(
          id,
          status: dekontStatusFilterApi(_filterKey),
        );
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

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(t.managerTitle),
        centerTitle: true,
        actions: const [NotificationIconButton()],
      ),
      body: Column(
        children: [
          if (buildings.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: AppSelectField<String>(
                label: context.t.common.buildingName,
                value: _buildingId,
                options: [
                  for (final b in buildings)
                    AppSelectOption(value: b.id, label: b.name),
                ],
                onChanged: (id) {
                  if (id == null) return;
                  setState(() => _buildingId = id);
                  _load();
                },
              ),
            ),
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
                  : state.isLoading
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
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    EmptyStateWidget(
                                      icon: Icons.receipt_long_outlined,
                                      title: t.emptyTitle,
                                      subtitle: t.emptySubtitleManager,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  padding: AppSizes.screenBodyScrollPadding,
                                  itemCount: state.dekonts.length,
                                  itemBuilder: (_, i) {
                                    final d = state.dekonts[i];
                                    final apt = d.apartment != null
                                        ? '${t.apartment}: ${d.apartment!.number}'
                                        : null;
                                    final uploader = d.uploadedBy != null
                                        ? '${t.uploadedBy}: ${d.uploadedBy!.name}'
                                        : null;
                                    return DekontListCard(
                                      dekont: d,
                                      apartmentLabel: apt,
                                      uploaderLabel: uploader,
                                      onTap: () =>
                                          context.push('/dekonts/${d.id}'),
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
      ),
    );
  }
}
