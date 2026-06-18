import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/session_model.dart';

abstract class SessionsRemoteDataSource {
  Future<List<SessionModel>> getSessions();

  Future<void> revokeSession(String sessionId);
}

class SessionsRemoteDataSourceImpl implements SessionsRemoteDataSource {
  final DioClient _dioClient;

  SessionsRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<SessionModel>> getSessions() async {
    final response = await _dioClient.get(ApiConstants.sessions);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => SessionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    await _dioClient.delete(ApiConstants.sessionDetail(sessionId));
  }
}
