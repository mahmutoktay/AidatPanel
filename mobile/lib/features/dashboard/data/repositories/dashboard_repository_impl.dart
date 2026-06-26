import '../../../../../core/network/api_exception.dart';
import '../../domain/entities/manager_dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource _remote;

  DashboardRepositoryImpl({required DashboardDataSource remote})
      : _remote = remote;

  @override
  Future<ManagerDashboardSummaryStats> fetchBuildingSummary(
      String buildingId) async {
    try {
      final model = await _remote.fetchBuildingSummary(buildingId);
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
          message: 'Dashboard özeti alınırken bir hata oluştu');
    }
  }

  @override
  Future<ManagerDuesCollectionStats> fetchDuesCollectionStats(
      String buildingId) async {
    try {
      final model = await _remote.fetchBuildingSummary(buildingId);
      return model.toDuesCollectionStats();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
          message: 'Tahsilat özeti alınırken bir hata oluştu');
    }
  }

  @override
  Future<Map<String, ManagerDashboardSummaryStats>> fetchBatchSummary(
      List<String> buildingIds) async {
    try {
      final modelMap = await _remote.fetchBatchSummary(buildingIds);
      return modelMap.map((key, value) =>
          MapEntry(key, value.toEntity()));
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
          message: 'Dashboard özeti alınırken bir hata oluştu');
    }
  }
}
