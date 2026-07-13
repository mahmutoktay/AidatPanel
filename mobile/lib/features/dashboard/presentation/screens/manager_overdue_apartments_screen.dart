import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../dues/presentation/utils/dues_ui_helpers.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../dashboard/domain/entities/dashboard_filter_scope.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/presentation/widgets/due_detail_sheet.dart';
import '../../domain/entities/manager_dashboard_entities.dart';
import '../utils/manager_dashboard_mapper.dart';
import '../utils/manager_overdue_remind_helper.dart';
import '../widgets/manager_home/manager_dashboard_card.dart';
import '../widgets/manager_home/manager_overdue_apartment_row.dart';

class ManagerOverdueApartmentsScreen extends ConsumerStatefulWidget {
  final DashboardFilterScope initialScope;

  const ManagerOverdueApartmentsScreen({
    super.key,
    this.initialScope = const DashboardFilterScope.all(),
  });

  @override
  ConsumerState<ManagerOverdueApartmentsScreen> createState() =>
      _ManagerOverdueApartmentsScreenState();
}

class _ManagerOverdueApartmentsScreenState
    extends ConsumerState<ManagerOverdueApartmentsScreen> {
  late DashboardFilterScope _filterScope;
  String? _remindingDueId;
  bool _isRemindingAll = false;

  @override
  void initState() {
    super.initState();
    _filterScope = widget.initialScope;
  }

  void _onScopeChanged(DashboardFilterScope scope) {
    setState(() => _filterScope = scope);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final allDuesAsync = ref.watch(allBuildingsDuesProvider);
    final buildings = ref.watch(buildingsStoreProvider).value ?? const [];
    final scopedBuildingIds = _filterScope.isAll
        ? null
        : ManagerDashboardMapper.filterBuildingsByScope(
            buildings,
            siteId: _filterScope.siteId,
            buildingId: _filterScope.buildingId,
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
            buildingId: _filterScope.buildingId,
            buildingIds: scopedBuildingIds,
          );

          return RefreshIndicator(
            color: AppColors.brand,
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
                      scope: _filterScope,
                      includeAllOption: true,
                      onScopeChanged: _onScopeChanged,
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
                            onTap: () => _openDueDetail(items[i], allDues),
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

  Future<void> _openDueDetail(
    ManagerOverdueApartmentItem item,
    Map<String, List<DueEntity>> allDues,
  ) async {
    final due = findDueById(allDues, item.dueId, item.buildingId);
    if (due == null || !mounted) return;

    final monthLabel = '${monthName(context, due.month)} ${due.year}';
    final currencySymbol =
        item.currency == 'TRY' ? AppCurrencyFormat.symbol : item.currency;

    await DueDetailSheet.show(
      context,
      due: due,
      buildingId: item.buildingId,
      monthLabel: monthLabel,
      currencySymbol: currencySymbol,
      onCollectPayment: null,
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
