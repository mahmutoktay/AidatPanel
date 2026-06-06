import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../../shared/widgets/tint_dashboard_tile.dart';
import '../../../../core/notifications/notification_toast.dart';
import '../../../notifications/presentation/widgets/announcement_form_sheet.dart';
import '../providers/manager_home_counts_provider.dart';
import '../../../tickets/presentation/providers/manager_open_tickets_count_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import 'buildings_async_section.dart';

class ManagerHomeTab extends ConsumerStatefulWidget {
  final AsyncValue<List<BuildingEntity>> buildingsAsync;
  final VoidCallback onRetryBuildings;
  final List<Widget> Function(List<BuildingEntity>) buildBuildingCards;

  const ManagerHomeTab({
    super.key,
    required this.buildingsAsync,
    required this.onRetryBuildings,
    required this.buildBuildingCards,
  });

  @override
  ConsumerState<ManagerHomeTab> createState() => _ManagerHomeTabState();
}

class _ManagerHomeTabState extends ConsumerState<ManagerHomeTab> {
  DateTime? _lastTransientErrorHintAt;
  String? _lastTransientErrorMessage;

  @override
  Widget build(BuildContext context) {
    final openTicketsAsync = ref.watch(managerOpenTicketsCountProvider);
    final monthExpensesAsync = ref.watch(managerMonthExpensesCountProvider);
    final monthAnnouncementsAsync = ref.watch(
      managerMonthAnnouncementsCountProvider,
    );
    final pendingDekontsAsync = ref.watch(managerPendingDekontsCountProvider);
    _maybeShowTransientErrorHint([
      widget.buildingsAsync,
      openTicketsAsync,
      monthExpensesAsync,
      monthAnnouncementsAsync,
      pendingDekontsAsync,
    ]);
    final openTicketCount = openTicketsAsync.value ?? 0;
    final monthExpenseCount = monthExpensesAsync.value ?? 0;
    final monthAnnouncementCount = monthAnnouncementsAsync.value ?? 0;
    final pendingDekontCount = pendingDekontsAsync.value ?? 0;
    final authState = ref.watch(authStateProvider);
    final userName = authState.user?.name ?? context.t.common.user;
    final buildings = widget.buildingsAsync.value ?? const <BuildingEntity>[];
    
    final allDuesAsync = ref.watch(allBuildingsDuesProvider);
    final allDues = allDuesAsync.value ?? const <String, List<DueEntity>>{};

    int totalApartments = 0;
    for (final b in buildings) {
      totalApartments += b.totalApartments;
    }
    final collectionRate = globalCollectionRate(allDues);
    final overdueCount = globalOverdueCount(allDues);

    return RefreshIndicator(
      onRefresh: _refreshHomeTab,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSizes.screenBodyScrollPadding.copyWith(
          top: AppSizes.spacingS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16.0),
               child: Text(
                  '${context.t.common.welcome}, $userName!',
                  style: AppTypography.h3,
                ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            _HeroSummaryCard(
              totalApartments: totalApartments,
              collectionRate: collectionRate,
              overdueCount: overdueCount,
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              context.t.common.quickActions,
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            _ManagerQuickActionsRow(
              openTicketCount: openTicketCount,
              monthExpenseCount: monthExpenseCount,
              monthAnnouncementCount: monthAnnouncementCount,
              pendingDekontCount: pendingDekontCount,
              onTickets: () async {
                await context.push('/manager-dashboard/tickets');
                if (!mounted) return;
                ref.invalidate(managerOpenTicketsCountProvider);
              },
              onExpenses: () async {
                await context.push('/manager-dashboard/expenses');
                if (!mounted) return;
                ref.invalidate(managerMonthExpensesCountProvider);
              },
              onAnnouncement: () async {
                final sent = await AnnouncementFormSheet.show(context);
                if (!mounted) return;
                if (sent == true) {
                  ref.invalidate(managerMonthAnnouncementsCountProvider);
                }
              },
              onDekonts: () async {
                await context.push('/manager-dashboard/dekonts');
                if (!mounted) return;
                ref.invalidate(managerPendingDekontsCountProvider);
              },
            ),
            const SizedBox(height: AppSizes.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.t.common.managedBuildings,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingS,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: AppColors.cardBorder,
                  ),
                  child: Text(
                    buildings.length.toString(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            BuildingsAsyncSection(
              buildingsAsync: widget.buildingsAsync,
              onRetry: widget.onRetryBuildings,
              buildList: widget.buildBuildingCards,
            ),
          ],
        ),
      ),
    );
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
      ref
          .read(toastProvider.notifier)
          .show(
            message,
            type: ToastType.info,
            duration: const Duration(seconds: 5),
          );
    });
  }

  Future<void> _refreshHomeTab() async {
    ref.invalidate(allBuildingsDuesProvider);
    ref.invalidate(managerOpenTicketsCountProvider);
    ref.invalidate(managerMonthExpensesCountProvider);
    ref.invalidate(managerMonthAnnouncementsCountProvider);
    ref.invalidate(managerPendingDekontsCountProvider);
    await Future.wait([
      ref.read(buildingsStoreProvider.notifier).loadBuildings(),
      pollAndShowNotificationToasts(ref),
    ]);
  }
}

class _HeroSummaryCard extends StatelessWidget {
  final int totalApartments;
  final double collectionRate;
  final int overdueCount;

  const _HeroSummaryCard({
    required this.totalApartments,
    required this.collectionRate,
    required this.overdueCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DashboardMetricTile.kTileHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.apartment_outlined,
              animatedValue: totalApartments,
              label: context.t.common.totalApartments,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.trending_up,
              animatedValue: collectionRate.round(),
              valuePrefix: '%',
              label: context.t.common.collection,
              valueColor: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: DashboardMetricTile(
              icon: Icons.warning_amber_rounded,
              animatedValue: overdueCount,
              label: context.t.common.overdueStatus,
              valueColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerQuickActionsRow extends StatelessWidget {
  final int openTicketCount;
  final int monthExpenseCount;
  final int monthAnnouncementCount;
  final int pendingDekontCount;
  final VoidCallback onTickets;
  final VoidCallback onExpenses;
  final VoidCallback onAnnouncement;
  final VoidCallback onDekonts;

  const _ManagerQuickActionsRow({
    required this.openTicketCount,
    required this.monthExpenseCount,
    required this.monthAnnouncementCount,
    required this.pendingDekontCount,
    required this.onTickets,
    required this.onExpenses,
    required this.onAnnouncement,
    required this.onDekonts,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.faz2;
    final dekontT = context.t.features.dekont;
    return Column(
      children: [
        SizedBox(
          height: DashboardActionTile.compactRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: DashboardActionTile(
                  icon: Icons.support_agent_outlined,
                  value: openTicketCount.toString(),
                  label: t.tickets,
                  valueColor: AppColors.info,
                  compact: true,
                  onTap: onTickets,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: DashboardActionTile(
                  icon: Icons.receipt_long_outlined,
                  value: monthExpenseCount.toString(),
                  label: t.expenses,
                  valueColor: AppColors.accent,
                  compact: true,
                  onTap: onExpenses,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: DashboardActionTile(
                  icon: Icons.campaign_outlined,
                  value: monthAnnouncementCount.toString(),
                  label: t.announcement,
                  valueColor: AppColors.primaryLight,
                  compact: true,
                  onTap: onAnnouncement,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        SizedBox(
          width: double.infinity,
          height: AppSizes.minTouchTargetComfort,
          child: DashboardActionTile(
            icon: Icons.rate_review_outlined,
            value: pendingDekontCount.toString(),
            label: dekontT.reviewAction,
            iconColor: AppColors.textPrimary,
            valueColor: AppColors.textPrimary,
            compact: false,
            onTap: onDekonts,
          ),
        ),
      ],
    );
  }
}
