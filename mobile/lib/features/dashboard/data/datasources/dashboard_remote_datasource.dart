import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_summary_model.dart';

/// Dashboard özet verisi için remote data source.
/// Backend [`dashboardController.getDashboardSummary()`](backend/src/controllers/dashboardController.js:18) endpoint'ini kullanır.
abstract class DashboardDataSource {
  /// `GET /buildings/:id/dashboard-summary` — tek bina özeti.
  Future<DashboardSummaryModel> fetchBuildingSummary(String buildingId);

  /// `POST /buildings/dashboard-summary/batch` — çoklu bina özeti.
  /// Body: `{ buildingIds: [id1, id2, ...] }`
  /// Response: `{ data: { [buildingId]: summary, ... }, partial, warnings }`
  Future<Map<String, DashboardSummaryModel>> fetchBatchSummary(
      List<String> buildingIds);
}

class DashboardRemoteDataSourceImpl implements DashboardDataSource {
  final DioClient _dioClient;

  DashboardRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<DashboardSummaryModel> fetchBuildingSummary(String buildingId) async {
    final response = await _dioClient.get(
      ApiConstants.buildingDashboardSummary(buildingId),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return DashboardSummaryModel.fromJson(data);
  }

  @override
  Future<Map<String, DashboardSummaryModel>> fetchBatchSummary(
      List<String> buildingIds) async {
    final response = await _dioClient.post(
      ApiConstants.buildingDashboardSummaryBatch,
      data: {'buildingIds': buildingIds},
    );
    final dataMap = response.data['data'] as Map<String, dynamic>;
    return dataMap.map((key, value) => MapEntry(
          key,
          DashboardSummaryModel.fromJson(value as Map<String, dynamic>),
        ));
  }
}
