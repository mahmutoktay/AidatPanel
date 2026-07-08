import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/compact_number_format.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../domain/entities/manager_dashboard_entities.dart';
import 'manager_dashboard_card.dart';

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
            title: t.financeTrendTitle,
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

/// (Talep durumu özet kartı, Faz 2 `ManagerTicketsScreen` içinde gösterilir.)
