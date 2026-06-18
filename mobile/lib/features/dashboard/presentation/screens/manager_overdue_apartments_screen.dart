import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../buildings/data/buildings_store.dart';
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
  String? _selectedBuildingId;
  String? _remindingDueId;
  bool _isRemindingAll = false;

  @override
  void initState() {
    super.initState();
    _selectedBuildingId = widget.initialBuildingId;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final allDuesAsync = ref.watch(allBuildingsDuesProvider);
    final buildings = ref.watch(buildingsStoreProvider).value ?? const [];

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
            buildingId: _selectedBuildingId,
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
                      selectedBuildingId: _selectedBuildingId,
                      includeAllOption: true,
                      onSelected: (id) =>
                          setState(() => _selectedBuildingId = id),
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
                    const SizedBox(height: AppSizes.spacingS),
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.minTouchTarget,
                      child: OutlinedButton(
                        onPressed: _isRemindingAll || _remindingDueId != null
                            ? null
                            : () => _onRemindAll(items),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.chartBlue,
                          side: const BorderSide(color: AppColors.chartBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isRemindingAll
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                t.remindAll,
                                style: AppTypography.body1.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
              list: items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSizes.screenBodyScrollPadding,
                      children: [
                        ManagerDashboardCard(
                          child: Text(
                            t.noOverdueApartments,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.dashboardScreenPaddingHorizontal,
                        AppSizes.spacingS,
                        AppSizes.dashboardScreenPaddingHorizontal,
                        AppSizes.spacingXL,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSizes.spacingM),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ManagerOverdueApartmentRow(
                          item: item,
                          isReminding: _remindingDueId == item.dueId,
                          onRemind: _isRemindingAll ? null : _onRemind,
                        );
                      },
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
