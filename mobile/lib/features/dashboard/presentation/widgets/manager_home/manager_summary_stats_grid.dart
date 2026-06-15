import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/widgets/dashboard/dashboard_stat_tile.dart';
import '../../../domain/entities/manager_dashboard_entities.dart';

/// 3×2 özet istatistik grid'i.
class ManagerSummaryStatsGrid extends StatelessWidget {
  final ManagerDashboardSummaryStats stats;

  const ManagerSummaryStatsGrid({super.key, required this.stats});

  static const _stagger = Duration(milliseconds: 70);

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final currency =
        stats.expenseCurrency == 'TRY' ? '₺' : stats.expenseCurrency;
    final expenseFormatter = NumberFormat.compactCurrency(
      locale: 'tr_TR',
      symbol: currency,
      decimalDigits: 0,
    );
    final expenseText = expenseFormatter.format(stats.monthTotalExpense);

    final items = [
      DashboardStatTile(
        icon: Icons.apartment_outlined,
        iconBg: AppColors.infoBg,
        iconColor: AppColors.chartBlue,
        value: '${stats.totalApartments}',
        rollingValue: stats.totalApartments,
        rollingDelay: _stagger * 0,
        label: context.t.common.totalApartments,
      ),
      DashboardStatTile(
        icon: Icons.trending_up,
        iconBg: AppColors.successBg,
        iconColor: AppColors.chartGreen,
        value: '%${stats.collectionRatePercent.round()}',
        rollingValue: stats.collectionRatePercent.round(),
        rollingPrefix: '%',
        rollingDelay: _stagger * 1,
        label: t.collectionRate,
        valueColor: AppColors.chartGreen,
      ),
      DashboardStatTile(
        icon: Icons.warning_amber_rounded,
        iconBg: AppColors.errorBg,
        iconColor: AppColors.chartRed,
        value: '${stats.overduePaymentCount}',
        rollingValue: stats.overduePaymentCount,
        rollingDelay: _stagger * 2,
        label: t.overduePayments,
        valueColor: AppColors.chartRed,
      ),
      DashboardStatTile(
        icon: Icons.build_circle_outlined,
        iconBg: AppColors.warningBg,
        iconColor: AppColors.chartOrange,
        value: '${stats.openTicketCount}',
        rollingValue: stats.openTicketCount,
        rollingDelay: _stagger * 3,
        label: t.openTicketRequests,
        valueColor: AppColors.chartOrange,
      ),
      DashboardStatTile(
        icon: Icons.receipt_long_outlined,
        iconBg: AppColors.warningBg,
        iconColor: AppColors.chartOrange,
        value: expenseText,
        rollingValue: stats.monthTotalExpense,
        rollingDelay: _stagger * 4,
        rollingFormatter: (n) => expenseFormatter.format(n),
        label: t.monthTotalExpense,
      ),
      DashboardStatTile(
        icon: Icons.rate_review_outlined,
        iconBg: AppColors.infoBg,
        iconColor: AppColors.chartBlue,
        value: '${stats.pendingDekontCount}',
        rollingValue: stats.pendingDekontCount,
        rollingDelay: _stagger * 5,
        label: t.pendingDekonts,
      ),
    ];

    return Column(
      children: [
        DashboardStatRow(tiles: items.sublist(0, 3)),
        const SizedBox(height: AppSizes.spacingS),
        DashboardStatRow(tiles: items.sublist(3, 6)),
      ],
    );
  }
}
