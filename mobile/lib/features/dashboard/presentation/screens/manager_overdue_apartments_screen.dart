import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../../dashboard/presentation/providers/dashboard_filter_scope_provider.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../domain/entities/manager_dashboard_entities.dart';
import '../utils/manager_dashboard_mapper.dart';
import '../utils/manager_overdue_remind_helper.dart';
import '../widgets/manager_home/manager_dashboard_card.dart';
import '../widgets/manager_home/manager_overdue_apartment_row.dart';

class ManagerOverdueApartmentsScreen extends ConsumerStatefulWidget {
  final String? initialBuildingId;

  const ManagerOverdueApartmentsScreen({
    super.key,
    this.initialBuildingId,
  });

  @override
  ConsumerState<ManagerOverdueApartmentsScreen> createState() =>
      _ManagerOverdueApartmentsScreenState();
}

class _ManagerOverdueApartmentsScreenState
    extends ConsumerState<ManagerOverdueApartmentsScreen> {
  String? _remindingDueId;
  bool _isRemindingAll = false;

  @override
  void initState() {
    super.initState();
    final initialBuildingId = widget.initialBuildingId;
    if (initialBuildingId == null || initialBuildingId.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(dashboardFilterScopeProvider.notifier).update(
            DashboardFilterScope.building(initialBuildingId),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final allDuesAsync = ref.watch(allBuildingsDuesProvider);
    final buildings = ref.watch(buildingsStoreProvider).value ?? const [];
    final filterScope = ref.watch(dashboardFilterScopeProvider);
    final scopedBuildingIds = filterScope.isAll
        ? null
        : ManagerDashboardMapper.filterBuildingsByScope(
            buildings,
            siteId: filterScope.siteId,
            buildingId: filterScope.buildingId,
          ).map((building) => building.id).toSet();

    final buildingNames = {
      for (final building in buildings) building.id: building.name,
    };

    return DashboardSecondaryScaffold(
      title: t.overdueApartments,
      showNotificationAction: true,
      body: allDuesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: AppSizes.screenBodyScrollPadding,
            child: Text(
              context.t.common.api.genericError,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (allDues) {
          final items = ManagerDashboardMapper.overdueApartmentsFromMap(
            allDues,
            buildingNames,
            buildingId: filterScope.buildingId,
            buildingIds: scopedBuildingIds,
          );

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(allBuildingsDuesProvider);
              await ref.read(allBuildingsDuesProvider.future);
            },
            child: DashboardListScreenBody(
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (buildings.isNotEmpty) ...[
                    DashboardBuildingSelector(
                      buildings: buildings,
                      scope: filterScope,
                      includeAllOption: true,
                      onScopeChanged: (scope) => ref
                          .read(dashboardFilterScopeProvider.notifier)
                          .update(scope),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                  ],
                  ManagerDashboardSectionHeader(
                    title: t.overdueApartments,
                    trailing: ManagerDashboardPill(
                      label: t.apartmentCountBadge
                          .replaceAll('{count}', '${items.length}'),
                    ),
                  ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spacingM),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _isRemindingAll || _remindingDueId != null
                            ? null
                            : () => _onRemindAll(items),
                        icon: _isRemindingAll
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.notifications_active_outlined),
                        label: Text(t.remindAll),
                      ),
                    ),
                  ],
                ],
              ),
              list: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.dashboardScreenPaddingHorizontal,
                  AppSizes.spacingM,
                  AppSizes.dashboardScreenPaddingHorizontal,
                  AppSizes.spacingXL,
                ),
                children: items.isEmpty
                    ? [
                        ManagerDashboardCard(
                          child: Text(
                            t.noOverdueApartments,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ]
                    : [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSizes.spacingM),
                          ManagerOverdueApartmentRow(
                            item: items[i],
                            onRemind: _onRemind,
                            isReminding: _remindingDueId == items[i].dueId,
                          ),
                        ],
                      ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onRemind(ManagerOverdueApartmentItem item) {
    return remindOverdueApartment(
      context: context,
      ref: ref,
      item: item,
      onLoadingChanged: (dueId) {
        if (!mounted) return;
        setState(() => _remindingDueId = dueId);
      },
    );
  }

  Future<void> _onRemindAll(List<ManagerOverdueApartmentItem> items) {
    return remindAllOverdueApartments(
      context: context,
      ref: ref,
      items: items,
      onLoadingChanged: (isLoading) {
        if (!mounted) return;
        setState(() => _isRemindingAll = isLoading);
      },
    );
  }
}
