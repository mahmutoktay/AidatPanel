import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/join_request.dart';
import '../models/join_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<RegisterResponse> register(RegisterRequest request);
  Future<JoinResponse> join(JoinRequest request);
  Future<String> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data['data']);
  }

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    return RegisterResponse.fromJson(response.data['data']);
  }

  @override
  Future<JoinResponse> join(JoinRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.join,
      data: request.toJson(),
    );
    return JoinResponse.fromJson(response.data['data']);
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      ApiConstants.refresh,
      data: {'refreshToken': refreshToken},
    );
    final raw = response.data;
    final Map<String, dynamic> payload = raw is Map && raw['data'] != null
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return payload['accessToken'] as String;
  }
}
