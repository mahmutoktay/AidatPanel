import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dekont_model.dart';

abstract class DekontRemoteDataSource {
  Future<PaymentCollectionModel> getPaymentCollection();

  Future<DekontModel> uploadDekont({
    required String filePath,
    String? dueId,
  });

  Future<DekontModel> getDekont(String id);

  Future<List<DekontModel>> getMyDekonts({String? status});

  Future<List<DekontModel>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
  });

  Future<DekontModel> reviewDekont({
    required String id,
    required String decision,
    String? note,
    String? dueId,
  });

  Future<List<int>> getDekontFileBytes(String id, {bool download = false});
}

class DekontRemoteDataSourceImpl implements DekontRemoteDataSource {
  final DioClient _dioClient;

  DekontRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  Map<String, dynamic>? _query({
    String? status,
    String? apartmentId,
  }) {
    final q = <String, dynamic>{};
    if (status != null && status.isNotEmpty) q['status'] = status;
    if (apartmentId != null && apartmentId.isNotEmpty) {
      q['apartmentId'] = apartmentId;
    }
    return q.isEmpty ? null : q;
  }

  @override
  Future<PaymentCollectionModel> getPaymentCollection() async {
    final response = await _dioClient.get(ApiConstants.myPaymentCollection);
    final data = response.data['data'] as Map<String, dynamic>;
    return PaymentCollectionModel.fromJson(data);
  }

  @override
  Future<DekontModel> uploadDekont({
    required String filePath,
    String? dueId,
  }) async {
    final segments = filePath.replaceAll('\\', '/').split('/');
    final fileName = segments.isNotEmpty ? segments.last : 'dekont.pdf';
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      if (dueId != null) 'dueId': dueId,
    });
    final response = await _dioClient.post(
      ApiConstants.dekontUpload,
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return DekontModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<DekontModel> getDekont(String id) async {
    final response = await _dioClient.get(ApiConstants.dekont(id));
    return DekontModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<DekontModel>> getMyDekonts({String? status}) async {
    final response = await _dioClient.get(
      ApiConstants.myDekonts,
      queryParameters: _query(status: status),
    );
    return DekontModel.parseList(response.data['data']);
  }

  @override
  Future<List<DekontModel>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.buildingDekonts(buildingId),
      queryParameters: _query(status: status, apartmentId: apartmentId),
    );
    return DekontModel.parseList(response.data['data']);
  }

  @override
  Future<DekontModel> reviewDekont({
    required String id,
    required String decision,
    String? note,
    String? dueId,
  }) async {
    final body = <String, dynamic>{'decision': decision};
    if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();
    if (dueId != null && dueId.isNotEmpty) body['dueId'] = dueId;

    final response = await _dioClient.patch(
      ApiConstants.dekontReview(id),
      data: body,
    );
    return DekontModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<int>> getDekontFileBytes(String id, {bool download = false}) async {
    final response = await _dioClient.get<List<int>>(
      ApiConstants.dekontFile(id),
      queryParameters: download ? {'download': '1'} : null,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }
}
