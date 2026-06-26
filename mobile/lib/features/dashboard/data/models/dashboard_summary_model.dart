import '../../domain/entities/manager_dashboard_entities.dart';

/// Backend [`dashboardController.getDashboardSummary()`](backend/src/controllers/dashboardController.js:103) yanıtındaki `data` alanı.
class DashboardSummaryModel {
  final Map<String, dynamic> apartments;
  final Map<String, dynamic> dues;
  final Map<String, dynamic> expenses;
  final int unreadNotifications;
  final int openTickets;
  final int pendingDekonts;
  final Map<String, dynamic> period;

  const DashboardSummaryModel({
    required this.apartments,
    required this.dues,
    required this.expenses,
    required this.unreadNotifications,
    required this.openTickets,
    required this.pendingDekonts,
    required this.period,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      apartments: json['apartments'] as Map<String, dynamic>? ?? {},
      dues: json['dues'] as Map<String, dynamic>? ?? {},
      expenses: json['expenses'] as Map<String, dynamic>? ?? {},
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
      openTickets: (json['openTickets'] as num?)?.toInt() ?? 0,
      pendingDekonts: (json['pendingDekonts'] as num?)?.toInt() ?? 0,
      period: json['period'] as Map<String, dynamic>? ?? {},
    );
  }

  ManagerDashboardSummaryStats toEntity() {
    final totalApartments = (apartments['total'] as num?)?.toInt() ?? 0;

    final paidCount = (dues['PAID']?['count'] as num?)?.toInt() ?? 0;
    final overdueCount = (dues['OVERDUE']?['count'] as num?)?.toInt() ?? 0;
    final pendingCount = (dues['PENDING']?['count'] as num?)?.toInt() ?? 0;
    final totalDueCount = paidCount + overdueCount + pendingCount;
    final collectionRate =
        totalDueCount == 0 ? 0.0 : (paidCount / totalDueCount) * 100;

    final monthTotalExpense =
        (expenses['total'] as num?)?.toDouble() ?? 0.0;

    return ManagerDashboardSummaryStats(
      totalApartments: totalApartments,
      collectionRatePercent: collectionRate,
      overduePaymentCount: overdueCount,
      openTicketCount: openTickets,
      monthTotalExpense: monthTotalExpense,
      pendingDekontCount: pendingDekonts,
    );
  }

  /// Aidat durum dağılımı (donut grafiği için).
  ManagerDuesCollectionStats toDuesCollectionStats() {
    final paidCount = (dues['PAID']?['count'] as num?)?.toInt() ?? 0;
    final overdueCount = (dues['OVERDUE']?['count'] as num?)?.toInt() ?? 0;
    final pendingCount = (dues['PENDING']?['count'] as num?)?.toInt() ?? 0;
    return ManagerDuesCollectionStats(
      paidCount: paidCount,
      overdueCount: overdueCount,
      pendingCount: pendingCount,
    );
  }
}
