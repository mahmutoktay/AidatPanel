import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../../shared/widgets/dashboard/dashboard_quick_action_tile.dart';

/// Hızlı işlemler — 4'lü yatay buton satırı (başlıksız).
class ManagerQuickActionsSection extends StatelessWidget {
  final int openTicketCount;
  final int monthExpenseCount;
  final int monthAnnouncementCount;
  final int pendingDuesActionCount;
  final VoidCallback onTickets;
  final VoidCallback onExpenses;
  final VoidCallback onAnnouncement;
  final VoidCallback onDuesStatus;

  const ManagerQuickActionsSection({
    super.key,
    required this.openTicketCount,
    required this.monthExpenseCount,
    required this.monthAnnouncementCount,
    required this.pendingDuesActionCount,
    required this.onTickets,
    required this.onExpenses,
    required this.onAnnouncement,
    required this.onDuesStatus,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final faz2 = t.features.faz2;

    final actions = [
      DashboardQuickActionTile(
        icon: Icons.account_balance_wallet_outlined,
        label: t.features.dashboard.duesStatusAction,
        count: pendingDuesActionCount,
        iconBg: AppColors.infoBg,
        iconColor: AppColors.chartBlue,
        onTap: onDuesStatus,
      ),
      DashboardQuickActionTile(
        icon: Icons.assignment_outlined,
        label: faz2.tickets,
        count: openTicketCount,
        iconBg: AppColors.infoBg,
        iconColor: AppColors.chartBlue,
        onTap: onTickets,
      ),
      DashboardQuickActionTile(
        icon: Icons.receipt_long_outlined,
        label: faz2.expenses,
        count: monthExpenseCount,
        iconBg: AppColors.warningBg,
        iconColor: AppColors.chartOrange,
        onTap: onExpenses,
      ),
      DashboardQuickActionTile(
        icon: Icons.campaign_outlined,
        label: faz2.announcement,
        count: monthAnnouncementCount,
        iconBg: AppColors.successBg,
        iconColor: AppColors.chartGreen,
        onTap: onAnnouncement,
      ),
    ];

    return SizedBox(
      height: DashboardScreenStyle.quickActionRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSizes.spacingS),
            Expanded(child: actions[i]),
          ],
        ],
      ),
    );
  }
}
