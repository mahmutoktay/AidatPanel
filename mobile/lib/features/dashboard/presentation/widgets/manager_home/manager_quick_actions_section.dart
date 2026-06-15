import 'package:flutter/material.dart';



import '../../../../../core/theme/app_colors.dart';

import '../../../../../l10n/strings.g.dart';

import '../../../../../shared/widgets/dashboard/dashboard_quick_action_tile.dart';



/// Hızlı işlemler — 4 kartlı grid (mockup stili).

class ManagerQuickActionsSection extends StatelessWidget {

  final int openTicketCount;

  final int monthExpenseCount;

  final int monthAnnouncementCount;

  final int pendingDekontCount;

  final VoidCallback onTickets;

  final VoidCallback onExpenses;

  final VoidCallback onAnnouncement;

  final VoidCallback onDekonts;



  const ManagerQuickActionsSection({

    super.key,

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

    final t = context.t;

    final faz2 = t.features.faz2;

    return DashboardQuickActionsRow(

      title: t.common.quickActions,

      actions: [

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

        DashboardQuickActionTile(

          icon: Icons.rate_review_outlined,

          label: t.common.dekontShort,

          count: pendingDekontCount,

          iconBg: AppColors.infoBg,

          iconColor: AppColors.chartBlue,

          onTap: onDekonts,

        ),

      ],

    );

  }

}


