import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/compact_number_format.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../domain/entities/manager_dashboard_entities.dart';
import 'manager_dashboard_card.dart';

/// Aidat tahsilat durumu donut grafiği.
class ManagerDuesCollectionChart extends StatelessWidget {
  final ManagerDuesCollectionStats stats;
  final String? periodLabel;

  const ManagerDuesCollectionChart({
    super.key,
    required this.stats,
    this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final hasData = stats.total > 0;

    return ManagerDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ManagerDashboardSectionHeader(
            title: t.duesCollectionStatus,
            trailing: periodLabel != null
                ? ManagerDashboardPill(label: periodLabel!)
                : null,
          ),
          const SizedBox(height: AppSizes.spacingM),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingL),
              child: Text(
                t.noChartData,
                textAlign: TextAlign.center,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 52,
                            startDegreeOffset: -90,
                            sections: [
                              _section(
                                stats.paidCount.toDouble(),
                                AppColors.chartGreen,
                              ),
                              _section(
                                stats.overdueCount.toDouble(),
                                AppColors.chartRed,
                              ),
                              _section(
                                stats.pendingCount.toDouble(),
                                AppColors.chartYellow,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '%${stats.collectionRatePercent.round()}',
                              style: AppTypography.h2.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              t.collectionRate,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendRow(
                          color: AppColors.chartGreen,
                          label: t.legendPaid,
                          count: stats.paidCount,
                        ),
                        const SizedBox(height: 10),
                        _LegendRow(
                          color: AppColors.chartRed,
                          label: t.legendOverdue,
                          count: stats.overdueCount,
                        ),
                        const SizedBox(height: 10),
                        _LegendRow(
                          color: AppColors.chartYellow,
                          label: t.legendPending,
                          count: stats.pendingCount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  PieChartSectionData _section(double value, Color color) {
    return PieChartSectionData(
      value: value <= 0 ? 0.001 : value,
      color: color,
      radius: 28,
      showTitle: false,
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final unit = context.t.features.dashboard.legendUnit
        .replaceAll('{count}', '$count');

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label  $unit',
            style: AppTypography.body2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Son 6 ay gelir/gider karşılaştırma bar grafiği.
class ManagerFinanceBarChart extends StatelessWidget {
  final List<ManagerMonthlyFinancePoint> points;

  const ManagerFinanceBarChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final hasData = points.any(
      (p) => p.collectedDues > 0 || p.totalExpenses > 0,
    );
    final maxY = _maxValue(points);

    return ManagerDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ManagerDashboardSectionHeader(
            title: t.incomeExpenseComparison,
            trailing: ManagerDashboardPill(label: t.last6Months),
          ),
          const SizedBox(height: AppSizes.spacingM),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingL),
              child: Text(
                t.noChartData,
                textAlign: TextAlign.center,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.fill,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            CompactNumberFormat.number(value),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              points[index].monthLabel,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(points.length, (index) {
                    final point = points[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: point.collectedDues,
                          color: AppColors.chartBlue,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          toY: point.totalExpenses,
                          color: AppColors.chartOrange,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }),
                ),
              ),
            ),
          if (hasData) ...[
            const SizedBox(height: AppSizes.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BarLegend(color: AppColors.chartBlue, label: t.collectedDues),
                const SizedBox(width: AppSizes.spacingM),
                _BarLegend(color: AppColors.chartOrange, label: t.totalExpense),
              ],
            ),
          ],
        ],
      ),
    );
  }

  double _maxValue(List<ManagerMonthlyFinancePoint> points) {
    var max = 0.0;
    for (final p in points) {
      if (p.collectedDues > max) max = p.collectedDues;
      if (p.totalExpenses > max) max = p.totalExpenses;
    }
    if (max <= 0) return 100;
    return max * 1.2;
  }
}

class _BarLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _BarLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Arıza talepleri durum yatay progress bar'ları.
class ManagerTicketStatusBars extends StatelessWidget {
  final ManagerTicketStatusStats stats;

  const ManagerTicketStatusBars({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;
    final maxCount = [
      stats.openCount,
      stats.inProgressCount,
      stats.resolvedCount,
    ].fold<int>(0, (a, b) => a > b ? a : b);

    return ManagerDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ManagerDashboardSectionHeader(title: t.ticketStatusTitle),
          const SizedBox(height: AppSizes.spacingM),
          Container(
            padding: const EdgeInsets.all(AppSizes.spacingS),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _StatusBarRow(
                  label: t.ticketOpen,
                  count: stats.openCount,
                  color: AppColors.chartOrange,
                  maxCount: maxCount,
                ),
                const SizedBox(height: 12),
                _StatusBarRow(
                  label: t.ticketInProgress,
                  count: stats.inProgressCount,
                  color: AppColors.chartBlue,
                  maxCount: maxCount,
                ),
                const SizedBox(height: 12),
                _StatusBarRow(
                  label: t.ticketResolved,
                  count: stats.resolvedCount,
                  color: AppColors.chartGreen,
                  maxCount: maxCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBarRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final int maxCount;

  const _StatusBarRow({
    required this.label,
    required this.count,
    required this.color,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount == 0 ? 0.0 : count / maxCount;

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTypography.body2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: fraction,
              backgroundColor: AppColors.background,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: AppTypography.body2.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
