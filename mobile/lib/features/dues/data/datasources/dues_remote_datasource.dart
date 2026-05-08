import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/due_model.dart';

abstract class DuesRemoteDataSource {
  Future<List<DueModel>> getBuildingDues(String buildingId);
  Future<List<DueModel>> getApartmentDues(String apartmentId);
  Future<List<DueModel>> getMyDues();
  Future<DueModel> updateDueStatus({
    required String dueId,
    required String status,
  });
  Future<List<DueModel>> createBulkDues({
    required String buildingId,
    required double amount,
    required int month,
    required int year,
    String currency,
    String? note,
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
  Future<List<DueModel>> getApartmentDues(String apartmentId) async {
    final response = await _dioClient.get(ApiConstants.apartmentDues(apartmentId));
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
    required String dueId,
    required String status,
  }) async {
    final response = await _dioClient.patch(
      ApiConstants.dueStatus(dueId),
      data: {'status': status},
    );
    return DueModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<DueModel>> createBulkDues({
    required String buildingId,
    required double amount,
    required int month,
    required int year,
    String currency = 'TRY',
    String? note,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.bulkDues(buildingId),
      data: {
        'amount': amount,
        'month': month,
        'year': year,
        'currency': currency,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    final data = response.data['data'] as List;
    return data
        .map((json) => DueModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
