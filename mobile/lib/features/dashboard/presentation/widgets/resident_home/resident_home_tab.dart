import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/notifications/notification_toast.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/widgets/dashboard/dashboard_empty_card.dart';
import '../../../../../shared/widgets/dashboard/dashboard_quick_action_tile.dart';
import '../../../../../shared/widgets/dashboard/dashboard_stat_tile.dart';
import '../../../../dues/domain/entities/due_entity.dart';
import '../../../../dues/presentation/providers/dues_provider.dart';
import '../../../../tickets/domain/entities/ticket_entity.dart';
import '../../../../tickets/presentation/providers/tickets_provider.dart';
import 'resident_featured_due_card.dart';

class ResidentHomeTab extends ConsumerWidget {
  final VoidCallback onGoToDuesTab;
  final VoidCallback onGoToIssuesTab;

  const ResidentHomeTab({
    super.key,
    required this.onGoToDuesTab,
    required this.onGoToIssuesTab,
  });

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(duesNotifierProvider.notifier).loadMyDues(),
      ref.read(ticketsNotifierProvider.notifier).loadMyTickets(),
      pollAndShowNotificationToasts(ref),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dues = ref.watch(duesNotifierProvider.select((state) => state.dues));
    final tickets = ref.watch(ticketsNotifierProvider).tickets;

    final pendingCount = dues
        .where((d) => d.status == DueStatus.pending)
        .length;
    final overdueCount = dues
        .where((d) => d.status == DueStatus.overdue)
        .length;
    final paidCount = dues.where((d) => d.status == DueStatus.paid).length;
    final openTicketCount = tickets
        .where(
          (t) =>
              t.status == TicketStatus.open ||
              t.status == TicketStatus.inProgress,
        )
        .length;

    final featuredDue = pickFeaturedDue(dues);
    final t = context.t.common;

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
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
              DashboardStatRow(
                tiles: [
                  DashboardStatTile(
                    icon: Icons.schedule_rounded,
                    iconBg: AppColors.warningBg,
                    iconColor: AppColors.chartOrange,
                    value: '$pendingCount',
                    rollingValue: pendingCount,
                    label: t.pendingStatus,
                    valueColor: AppColors.chartOrange,
                  ),
                  DashboardStatTile(
                    icon: Icons.warning_amber_rounded,
                    iconBg: AppColors.errorBg,
                    iconColor: AppColors.chartRed,
                    value: '$overdueCount',
                    rollingValue: overdueCount,
                    rollingDelay: const Duration(milliseconds: 70),
                    label: t.overdueStatus,
                    valueColor: AppColors.chartRed,
                  ),
                  DashboardStatTile(
                    icon: Icons.check_rounded,
                    iconBg: AppColors.successBg,
                    iconColor: AppColors.chartGreen,
                    value: '$paidCount',
                    rollingValue: paidCount,
                    rollingDelay: const Duration(milliseconds: 140),
                    label: t.paidStatus,
                    valueColor: AppColors.chartGreen,
                  ),
                ],
              ),
              if (featuredDue != null) ...[
                const SizedBox(height: AppSizes.spacingM),
                ResidentFeaturedDueCard(
                  due: featuredDue,
                  overdueCount: overdueCount,
                  onPay: () => context.push('/resident-dashboard/payment'),
                ),
              ],
              const SizedBox(height: AppSizes.spacingM),
              DashboardQuickActionsRow(
                title: t.quickActions,
                actions: [
                  DashboardQuickActionTile(
                    icon: Icons.payment_outlined,
                    label: t.makePayment,
                    count: pendingCount + overdueCount,
                    iconBg: AppColors.infoBg,
                    iconColor: AppColors.chartBlue,
                    onTap: () => context.push('/resident-dashboard/payment'),
                  ),
                  DashboardQuickActionTile(
                    icon: Icons.receipt_outlined,
                    label: t.bills,
                    count: dues.length,
                    iconBg: AppColors.warningBg,
                    iconColor: AppColors.chartOrange,
                    onTap: onGoToDuesTab,
                  ),
                  DashboardQuickActionTile(
                    icon: Icons.support_agent_outlined,
                    label: t.support,
                    count: openTicketCount,
                    iconBg: AppColors.infoBg,
                    iconColor: AppColors.chartBlue,
                    onTap: onGoToIssuesTab,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                t.recentTransactions,
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              DashboardEmptyCard(
                icon: Icons.receipt_long_outlined,
                title: t.recentTransactions,
                subtitle: t.comingSoon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
