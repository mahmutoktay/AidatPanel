import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_intl_locale.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../dues/presentation/utils/dues_ui_helpers.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/notifications/notification_toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/presentation/widgets/due_detail_sheet.dart';
import '../../../notifications/presentation/widgets/announcement_form_sheet.dart';
import '../providers/dashboard_filter_scope_provider.dart';
import '../../domain/entities/dashboard_filter_scope.dart';
import '../../domain/entities/manager_dashboard_entities.dart';
import '../providers/manager_dashboard_snapshot_provider.dart';
import '../providers/manager_home_counts_provider.dart';
import '../utils/manager_dashboard_mapper.dart';
import '../utils/dashboard_filter_scope_routing.dart';
import '../utils/manager_overdue_remind_helper.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import 'manager_home/manager_dashboard_charts.dart';
import 'manager_home/manager_overdue_apartments_section.dart';
import 'manager_home/manager_dues_summary_card.dart';
import 'manager_home/manager_quick_actions_section.dart';

class ManagerHomeTab extends ConsumerStatefulWidget {
  final AsyncValue<List<BuildingEntity>> buildingsAsync;
  final VoidCallback onRetryBuildings;

  const ManagerHomeTab({
    super.key,
    required this.buildingsAsync,
    required this.onRetryBuildings,
  });

  @override
  ConsumerState<ManagerHomeTab> createState() => _ManagerHomeTabState();
}

class _ManagerHomeTabState extends ConsumerState<ManagerHomeTab> {
  DateTime? _lastTransientErrorHintAt;
  String? _lastTransientErrorMessage;
  String? _remindingDueId;

  /// Sağlanan async değerlerden hatası olanların sayısı.
  int _errorCount(List<AsyncValue<dynamic>> values) {
    return values.where((v) => v.hasError).length;
  }

  @override
  Widget build(BuildContext context) {
    final filterScope = ref.watch(dashboardFilterScopeProvider);
    final buildings = widget.buildingsAsync.value ?? const <BuildingEntity>[];
    final scopedBuildings = ManagerDashboardMapper.filterBuildingsByScope(
      buildings,
      siteId: filterScope.siteId,
      buildingId: filterScope.buildingId,
    );
    final scopedBuildingIds =
        scopedBuildings.map((building) => building.id).toSet();

    final allDuesAsync = ref.watch(allBuildingsDuesProvider);
    final allDues = allDuesAsync.value ?? const <String, List<DueEntity>>{};
    final filteredDues = ManagerDashboardMapper.filterDuesByScope(
      allDues,
      scopedBuildings,
    );

    final ticketStatsAsync =
        ref.watch(managerTicketStatusStatsForScopeProvider(filterScope));
    final monthExpenseTotalAsync =
        ref.watch(managerMonthExpenseTotalForScopeProvider(filterScope));
    final sixMonthExpensesAsync =
        ref.watch(managerSixMonthExpenseTotalsForScopeProvider(filterScope));
    final pendingDueActionsAsync = ref.watch(
      managerPendingDekontsForScopeProvider(filterScope),
    );

    final monthExpensesCountAsync =
        ref.watch(managerMonthExpensesCountForScopeProvider(filterScope));
    final monthAnnouncementsAsync =
        ref.watch(managerMonthAnnouncementsCountProvider);

    final allAsyncValues = [
      widget.buildingsAsync,
      allDuesAsync,
      ticketStatsAsync,
      monthExpenseTotalAsync,
      sixMonthExpensesAsync,
      pendingDueActionsAsync,
      monthExpensesCountAsync,
      monthAnnouncementsAsync,
    ];
    final totalErrorCount = _errorCount(allAsyncValues);

    _maybeShowTransientErrorHint(allAsyncValues);

    final languageCode = AppIntlLocale.fromContext(context);
    final now = DateTime.now();
    final currentMonthDues = ManagerDashboardMapper.filterDuesForMonth(
      filteredDues,
      month: now.month,
      year: now.year,
    );

    final duesAmountSummary =
        ManagerDashboardMapper.duesAmountSummary(currentMonthDues);
    final ticketStats = ticketStatsAsync.value ?? ManagerTicketStatusStats.empty;
    final pendingDueActionCount = pendingDueActionsAsync.value ?? 0;
    final expenseTotals = sixMonthExpensesAsync.value ?? const {};

    final monthlyFinance = ManagerDashboardMapper.monthlyFinancePoints(
      dues: filteredDues,
      expenseTotalsByMonth: expenseTotals,
      anchor: now,
      localeName: languageCode,
    );

    final buildingNames = {
      for (final building in buildings) building.id: building.name,
    };

    final overdueItems = ManagerDashboardMapper.overdueApartmentsFromMap(
      allDues,
      buildingNames,
      buildingId: filterScope.buildingId,
      buildingIds: filterScope.isAll ? null : scopedBuildingIds,
    );
    final remindDueIdsByBuilding = groupOverdueDueIdsByBuilding(
      allDues,
      buildingIds: filterScope.isAll ? null : scopedBuildingIds,
    );

    final expenseCurrency = scopedBuildings.isNotEmpty
        ? scopedBuildings.first.currency
        : 'TRY';

    final isRefreshing = widget.buildingsAsync.isLoading ||
        allDuesAsync.isLoading ||
        ticketStatsAsync.isLoading;

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: RefreshIndicator(
        onRefresh: _refreshHomeTab,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSizes.screenBodyScrollPadding.copyWith(
            top: 0,
            bottom: AppSizes.spacingXL,
          ),
          child: Column(
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
                const SizedBox(height: AppSizes.spacingS),
              ],
              if (isRefreshing)
                LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: AppColors.lineLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.statusBlue,
                  ),
                ),
              if (isRefreshing) const SizedBox(height: AppSizes.spacingS),
              if (totalErrorCount > 0)
                _DataWarningBanner(errorCount: totalErrorCount),
              if (totalErrorCount > 0) const SizedBox(height: AppSizes.spacingS),
              ManagerDuesSummaryCard(
                summary: duesAmountSummary,
                currency: expenseCurrency,
                remindDueIdsByBuilding: remindDueIdsByBuilding.isEmpty
                    ? null
                    : remindDueIdsByBuilding,
              ),
              const SizedBox(height: AppSizes.spacingM),
              ManagerQuickActionsSection(
                openTicketCount:
                    ticketStats.openCount + ticketStats.inProgressCount,
                monthExpenseCount: monthExpensesCountAsync.value ?? 0,
                monthAnnouncementCount: monthAnnouncementsAsync.value ?? 0,
                pendingDuesActionCount: pendingDueActionCount,
                onTickets: () => _openAndInvalidate(ticketsPath(filterScope)),
                onExpenses: () => _openAndInvalidate(expensesPath(filterScope)),
                onAnnouncement: () async {
                  final sent = await AnnouncementFormSheet.show(context);
                  if (!mounted) return;
                  if (sent == true) {
                    ref.invalidate(managerMonthAnnouncementsCountProvider);
                  }
                },
                onDuesStatus: () {
                  final scope = ref.read(dashboardFilterScopeProvider);
                  _openAndInvalidate(dueTransactionsPath(scope));
                },
              ),
              const SizedBox(height: AppSizes.spacingL),
              ManagerOverdueApartmentsSection(
                items: overdueItems,
                onRemind: _onRemindOverdue,
                onTap: (item) => _openOverdueDueDetail(item, allDues),
                remindingDueId: _remindingDueId,
                onSeeAll: () => _openOverdueDuesList(filterScope),
              ),
              const SizedBox(height: AppSizes.spacingL),
              ManagerFinanceBarChart(points: monthlyFinance),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRemindOverdue(ManagerOverdueApartmentItem item) {
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

  void _openOverdueDuesList(DashboardFilterScope scope) {
    context.push(overdueApartmentsPath(scope));
  }

  Future<void> _openOverdueDueDetail(
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

  Future<void> _openAndInvalidate(String route) async {
    await context.push(route);
    if (!mounted) return;
    final filterScope = ref.read(dashboardFilterScopeProvider);
    ref.invalidate(managerTicketStatusStatsForScopeProvider(filterScope));
    ref.invalidate(managerMonthExpensesCountForScopeProvider(filterScope));
    ref.invalidate(managerMonthExpenseTotalForScopeProvider(filterScope));
    ref.invalidate(managerSixMonthExpenseTotalsForScopeProvider(filterScope));
    ref.invalidate(managerPendingDekontsForScopeProvider(filterScope));
    ref.invalidate(managerMonthAnnouncementsCountProvider);
  }

  void _maybeShowTransientErrorHint(List<AsyncValue<dynamic>> values) {
    Object? firstError;
    for (final value in values) {
      if (value.hasError) {
        firstError = value.error;
        break;
      }
    }
    if (firstError == null || !mounted) return;

    var isRateLimited = false;
    if (firstError is ApiException && firstError.statusCode == 429) {
      isRateLimited = true;
    } else {
      final fallback = userFacingError(firstError).toLowerCase();
      isRateLimited =
          fallback.contains('çok fazla istek') ||
          fallback.contains('too many requests') ||
          fallback.contains('429');
    }
    if (!isRateLimited) return;
    final message = context.t.common.rateLimitHint;

    final now = DateTime.now();
    final shouldDebounce =
        _lastTransientErrorMessage == message &&
        _lastTransientErrorHintAt != null &&
        now.difference(_lastTransientErrorHintAt!) <
            const Duration(seconds: 20);
    if (shouldDebounce) return;

    _lastTransientErrorMessage = message;
    _lastTransientErrorHintAt = now;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            message,
            type: ToastType.info,
            duration: const Duration(seconds: 5),
          );
    });
  }

  Future<void> _refreshHomeTab() async {
    final filterScope = ref.read(dashboardFilterScopeProvider);
    ref.invalidate(allBuildingsDuesProvider);
    ref.invalidate(managerTicketStatusStatsForScopeProvider(filterScope));
    ref.invalidate(managerMonthExpenseTotalForScopeProvider(filterScope));
    ref.invalidate(managerSixMonthExpenseTotalsForScopeProvider(filterScope));
    ref.invalidate(managerPendingDekontsForScopeProvider(filterScope));
    ref.invalidate(managerMonthExpensesCountForScopeProvider(filterScope));
    ref.invalidate(managerMonthAnnouncementsCountProvider);
    await Future.wait([
      ref.read(buildingsStoreProvider.notifier).loadBuildings(),
      pollAndShowNotificationToasts(ref),
    ]);
  }
}

/// Dashboard verisi kısmen hatalıysa gösterilen uyarı banner'ı.
class _DataWarningBanner extends StatelessWidget {
  final int errorCount;
  const _DataWarningBanner({required this.errorCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.statusAmberBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.statusAmber),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 20, color: AppColors.statusAmber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.t.features.dashboard.dataWarningBanner
                  .replaceAll('{count}', '$errorCount'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.statusAmber,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
