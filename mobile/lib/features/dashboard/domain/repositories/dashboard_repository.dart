import '../entities/manager_dashboard_entities.dart';

abstract class DashboardRepository {
  /// Tek bina dashboard özeti — backend [`/buildings/:id/dashboard-summary`](backend/src/controllers/dashboardController.js:18).
  Future<ManagerDashboardSummaryStats> fetchBuildingSummary(
      String buildingId);

  /// Tahsilat durumu donut grafiği için.
  Future<ManagerDuesCollectionStats> fetchDuesCollectionStats(
      String buildingId);

  /// Çoklu bina dashboard özeti — backend [`POST /buildings/dashboard-summary/batch`].
  /// Tüm binalar için tek API çağrısı yaparak N+1'i önler.
  Future<Map<String, ManagerDashboardSummaryStats>> fetchBatchSummary(
      List<String> buildingIds);
}
