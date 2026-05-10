import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/due_model.dart';

abstract class DuesRemoteDataSource {
  Future<List<DueModel>> getBuildingDues(String buildingId);
  Future<List<DueModel>> getMyDues();
  Future<DueModel> updateDueStatus({
    required String buildingId,
    required String dueId,
    required String status,
  });
  Future<void> updateBuildingDueAmount({
    required String buildingId,
    required double dueAmount,
    int? dueDay,
    String? currency,
    bool affectCurrent = false,
  });
}

class DuesRemoteDataSourceImpl implements DuesRemoteDataSource {
  final DioClient _dioClient;

  DuesRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<DueModel>> getBuildingDues(String buildingId) async {
    final response = await _dioClient.get(ApiConstants.buildingDues(buildingId));
    final data = response.data['data'] as List;
    return data
        .map((json) => DueModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DueModel>> getMyDues() async {
    final response = await _dioClient.get(ApiConstants.myDues);
    final data = response.data['data'] as List;
    return data
        .map((json) => DueModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DueModel> updateDueStatus({
    required String buildingId,
    required String dueId,
    required String status,
  }) async {
    final response = await _dioClient.patch(
      ApiConstants.buildingDueStatus(buildingId, dueId),
      data: {'status': status},
    );
    return DueModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateBuildingDueAmount({
    required String buildingId,
    required double dueAmount,
    int? dueDay,
    String? currency,
    bool affectCurrent = false,
  }) async {
    await _dioClient.patch(
      ApiConstants.buildingDueAmount(buildingId),
      data: {
        'dueAmount': dueAmount,
        'dueDay': ?dueDay,
        if (currency != null && currency.isNotEmpty) 'currency': currency,
        'affectCurrent': affectCurrent,
      },
    );
  }
}
