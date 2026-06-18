import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/utils/app_intl_locale.dart';
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
import '../../../notifications/presentation/widgets/announcement_form_sheet.dart';
import '../../domain/entities/manager_dashboard_entities.dart';
import '../providers/manager_dashboard_snapshot_provider.dart';
import '../providers/manager_home_counts_provider.dart';
import '../utils/manager_dashboard_mapper.dart';
import '../utils/manager_overdue_remind_helper.dart';
import '../../../../shared/widgets/dashboard_building_selector.dart';
import 'manager_home/manager_dashboard_charts.dart';
import 'manager_home/manager_overdue_apartments_section.dart';
import 'manager_home/manager_quick_actions_section.dart';
import 'manager_home/manager_summary_stats_grid.dart';

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
  String? _selectedBuildingId;
  String? _remindingDueId;

  @override
  Widget build(BuildContext context) {
    final buildings = widget.buildingsAsync.value ?? const <BuildingEntity>[];
    final selectedBuildingId = _selectedBuildingId;
    final filteredBuildings = ManagerDashboardMapper.filterBuildings(
      buildings,
      selectedBuildingId,
    );

    final allDuesAsync = ref.watch(allBuildingsDuesProvider);
    final allDues = allDuesAsync.value ?? const <String, List<DueEntity>>{};
    final filteredDues = ManagerDashboardMapper.filterDues(
      allDues,
      selectedBuildingId,
    );

    final ticketStatsAsync =
        ref.watch(managerTicketStatusStatsProvider(selectedBuildingId));
    final monthExpenseTotalAsync =
        ref.watch(managerMonthExpenseTotalProvider(selectedBuildingId));
    final sixMonthExpensesAsync =
        ref.watch(managerSixMonthExpenseTotalsProvider(selectedBuildingId));
    final pendingDekontsAsync =
        ref.watch(managerPendingDekontsForBuildingProvider(selectedBuildingId));

    final monthExpensesCountAsync = ref.watch(managerMonthExpensesCountProvider);
    final monthAnnouncementsAsync =
        ref.watch(managerMonthAnnouncementsCountProvider);

    _maybeShowTransientErrorHint([
      widget.buildingsAsync,
      allDuesAsync,
      ticketStatsAsync,
      monthExpenseTotalAsync,
      sixMonthExpensesAsync,
      pendingDekontsAsync,
      monthExpensesCountAsync,
      monthAnnouncementsAsync,
    ]);

    final languageCode = AppIntlLocale.fromContext(context);
    final now = DateTime.now();
    final currentMonthDues = ManagerDashboardMapper.filterDuesForMonth(
      filteredDues,
      month: now.month,
      year: now.year,
    );

    final duesStats =
        ManagerDashboardMapper.duesCollectionStats(currentMonthDues);
    final ticketStats = ticketStatsAsync.value ?? ManagerTicketStatusStats.empty;
    final monthExpenseTotal = monthExpenseTotalAsync.value ?? 0;
    final pendingDekontCount = pendingDekontsAsync.value ?? 0;
    final expenseTotals = sixMonthExpensesAsync.value ?? const {};

    final monthlyFinance = ManagerDashboardMapper.monthlyFinancePoints(
      dues: filteredDues,
      expenseTotalsByMonth: expenseTotals,
      anchor: DateTime.now(),
      localeName: languageCode,
    );

    final buildingNames = {
      for (final building in buildings) building.id: building.name,
    };

    final overdueItems = ManagerDashboardMapper.overdueApartmentsFromMap(
      allDues,
      buildingNames,
      buildingId: selectedBuildingId,
    );

    final expenseCurrency = filteredBuildings.isNotEmpty
        ? filteredBuildings.first.currency
        : 'TRY';

    final summaryStats = ManagerDashboardMapper.summaryStats(
      buildings: filteredBuildings,
      dues: currentMonthDues,
      openTicketCount: ticketStats.openCount,
      monthTotalExpense: monthExpenseTotal,
      expenseCurrency: expenseCurrency,
      pendingDekontCount: pendingDekontCount,
    );

    final periodLabel = AppDateFormat.monthYear(DateTime.now())
        .replaceRange(
          0,
          1,
          AppDateFormat.monthYear(DateTime.now()).substring(0, 1).toUpperCase(),
        );

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
                  selectedBuildingId: selectedBuildingId,
                  includeAllOption: true,
                  onSelected: (id) => setState(() => _selectedBuildingId = id),
                ),
                const SizedBox(height: AppSizes.spacingS),
              ],
              if (isRefreshing)
                const LinearProgressIndicator(minHeight: 2),
              if (isRefreshing) const SizedBox(height: AppSizes.spacingS),
              ManagerSummaryStatsGrid(stats: summaryStats),
              const SizedBox(height: AppSizes.spacingM),
              ManagerQuickActionsSection(
                openTicketCount:
                    ticketStats.openCount + ticketStats.inProgressCount,
                monthExpenseCount: monthExpensesCountAsync.value ?? 0,
                monthAnnouncementCount: monthAnnouncementsAsync.value ?? 0,
                pendingDekontCount: pendingDekontCount,
                onTickets: () => _openAndInvalidate('/manager-dashboard/tickets'),
                onExpenses: () => _openAndInvalidate('/manager-dashboard/expenses'),
                onAnnouncement: () async {
                  final sent = await AnnouncementFormSheet.show(context);
                  if (!mounted) return;
                  if (sent == true) {
                    ref.invalidate(managerMonthAnnouncementsCountProvider);
                  }
                },
                onDekonts: () => _openAndInvalidate('/manager-dashboard/dekonts'),
              ),
              const SizedBox(height: AppSizes.spacingL),
              ManagerDuesCollectionChart(
                stats: duesStats,
                periodLabel: periodLabel,
              ),
              const SizedBox(height: AppSizes.spacingM),
              ManagerFinanceBarChart(points: monthlyFinance),
              const SizedBox(height: AppSizes.spacingM),
              ManagerTicketStatusBars(stats: ticketStats),
              const SizedBox(height: AppSizes.spacingL),
              ManagerOverdueApartmentsSection(
                items: overdueItems,
                onRemind: _onRemindOverdue,
                remindingDueId: _remindingDueId,
                onSeeAll: overdueItems.isNotEmpty
                    ? () => _openOverdueDuesList(selectedBuildingId)
                    : null,
              ),
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

  void _openOverdueDuesList(String? buildingId) {
    final query = buildingId != null ? '?buildingId=$buildingId' : '';
    context.push('/manager-dashboard/overdue-apartments$query');
  }

  Future<void> _openAndInvalidate(String route) async {
    await context.push(route);
    if (!mounted) return;
    ref.invalidate(managerTicketStatusStatsProvider(_selectedBuildingId));
    ref.invalidate(managerMonthExpensesCountProvider);
    ref.invalidate(managerMonthExpenseTotalProvider(_selectedBuildingId));
    ref.invalidate(managerSixMonthExpenseTotalsProvider(_selectedBuildingId));
    ref.invalidate(managerPendingDekontsForBuildingProvider(_selectedBuildingId));
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
    ref.invalidate(allBuildingsDuesProvider);
    ref.invalidate(managerTicketStatusStatsProvider(_selectedBuildingId));
    ref.invalidate(managerMonthExpenseTotalProvider(_selectedBuildingId));
    ref.invalidate(managerSixMonthExpenseTotalsProvider(_selectedBuildingId));
    ref.invalidate(managerPendingDekontsForBuildingProvider(_selectedBuildingId));
    ref.invalidate(managerMonthExpensesCountProvider);
    ref.invalidate(managerMonthAnnouncementsCountProvider);
    await Future.wait([
      ref.read(buildingsStoreProvider.notifier).loadBuildings(),
      pollAndShowNotificationToasts(ref),
    ]);
  }
}
