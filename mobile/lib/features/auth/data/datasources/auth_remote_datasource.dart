import '../../../../core/device/device_info_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/token_refresh_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/join_request.dart';
import '../models/join_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> checkIdentifier({
    required String identifier,
    required String purpose,
  });
  Future<RegisterResponse> register(RegisterRequest request);
  Future<JoinResponse> join(JoinRequest request);
  Future<TokenRefreshResult> refreshToken(String refreshToken);

  /// Sunucuya `POST /auth/logout` (Bearer) atar.
  /// Backend oturum kaydını değiştirmez; mobil `SecureStorage.clearAuth()` ile çıkar.
  Future<void> logout();

  /// Paralel 401'lerin `logout-all-devices` sırasında oturumu düşürmesini engeller.
  void beginSessionMutation();
  void endSessionMutation();

  /// `POST /auth/logout-all-devices` — diğer cihazların refresh oturumunu düşürür,
  /// bu cihaza yeni access + refresh token döner.
  Future<TokenRefreshResult> logoutAllDevices();

  /// Tur 5 / §10/6 — `POST /auth/forgot-password` body `{ email }`.
  /// Backend her zaman 200 döner (enumeration leak yok); kod sadece kayıtlı
  /// e-postalara Resend ile gönderilir.
  Future<void> forgotPassword({required String email});

  /// `POST /auth/reset-password` body `{ token, password }`.
  /// Token 6 karakter alfabesi `23456789ABCDEFGHJKLMNPQRSTUVWXYZ` (sunucu
  /// trim + büyük harfe çevirir). Geçersiz/expired token → 400.
  Future<void> resetPassword({
    required String token,
    required String password,
  });

  Future<void> sendOtp({
    String? phone,
    String? email,
    required String purpose,
    Map<String, dynamic>? payload,
  });

  Future<LoginResponse> verifyOtp({
    String? phone,
    String? email,
    required String code,
    required String purpose,
    Map<String, dynamic>? payload,
    String? name,
    String? password,
    String? inviteCode,
  });

  Future<String> validateInviteCode(String inviteCode);

  Future<bool> verifyResidentJoinOtp({
    required String phone,
    required String code,
    required String inviteCode,
  });

  Future<LoginResponse> completeResidentJoin({
    required String phone,
    required String name,
    required String inviteCode,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  void beginSessionMutation() => _dioClient.beginSessionMutation();

  @override
  void endSessionMutation() => _dioClient.endSessionMutation();

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data['data']);
  }

  @override
  Future<void> checkIdentifier({
    required String identifier,
    required String purpose,
  }) async {
    await _dioClient.post(
      ApiConstants.checkIdentifier,
      data: {
        'identifier': identifier,
        'purpose': purpose,
      },
    );
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
  Future<TokenRefreshResult> refreshToken(String refreshToken) async {
    final device = await DeviceInfoService.currentDeviceMeta();
    final response = await _dioClient.post(
      ApiConstants.refresh,
      data: {
        'refreshToken': refreshToken,
        ...device.toJson(),
      },
    );
    final raw = response.data;
    final Map<String, dynamic> payload = raw is Map && raw['data'] != null
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return TokenRefreshResult(
      accessToken: payload['accessToken'] as String,
      refreshToken: payload['refreshToken'] as String?,
    );
  }

  @override
  Future<void> logout() async {
    await _dioClient.post(ApiConstants.logout);
  }

  @override
  Future<TokenRefreshResult> logoutAllDevices() async {
    final response = await _dioClient.post(ApiConstants.logoutAllDevices);
    final raw = response.data;
    final Map<String, dynamic> payload = raw is Map && raw['data'] != null
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return TokenRefreshResult(
      accessToken: payload['accessToken'] as String,
      refreshToken: payload['refreshToken'] as String?,
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dioClient.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _dioClient.post(
      ApiConstants.resetPassword,
      data: {'token': token, 'password': password},
    );
  }

  @override
  Future<void> sendOtp({
    String? phone,
    String? email,
    required String purpose,
    Map<String, dynamic>? payload,
  }) async {
    await _dioClient.post(
      ApiConstants.otpSend,
      data: {
        'phone': ?phone,
        'email': ?email,
        'purpose': purpose,
        'payload': ?payload,
      },
    );
  }

  @override
  Future<LoginResponse> verifyOtp({
    String? phone,
    String? email,
    required String code,
    required String purpose,
    Map<String, dynamic>? payload,
    String? name,
    String? password,
    String? inviteCode,
  }) async {
    final device = await DeviceInfoService.currentDeviceMeta();
    final response = await _dioClient.post(
      ApiConstants.otpVerify,
      data: {
        'phone': ?phone,
        'email': ?email,
        'code': code,
        'purpose': purpose,
        'payload': ?payload,
        'name': ?name,
        'password': ?password,
        'inviteCode': ?inviteCode,
        ...device.toJson(),
      },
    );
    return LoginResponse.fromJson(response.data['data']);
  }

  @override
  Future<String> validateInviteCode(String inviteCode) async {
    final response = await _dioClient.post(
      ApiConstants.inviteValidate,
      data: {'inviteCode': inviteCode},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return data['label'] as String? ?? '';
  }

  @override
  Future<bool> verifyResidentJoinOtp({
    required String phone,
    required String code,
    required String inviteCode,
  }) async {
    final device = await DeviceInfoService.currentDeviceMeta();
    final response = await _dioClient.post(
      ApiConstants.otpVerify,
      data: {
        'phone': phone,
        'code': code,
        'purpose': 'resident_join',
        'inviteCode': inviteCode,
        ...device.toJson(),
      },
    );
    final data = response.data['data'] as Map<String, dynamic>?;
    return data?['requireName'] == true;
  }

  @override
  Future<LoginResponse> completeResidentJoin({
    required String phone,
    required String name,
    required String inviteCode,
  }) async {
    final device = await DeviceInfoService.currentDeviceMeta();
    final response = await _dioClient.post(
      ApiConstants.otpCompleteResidentJoin,
      data: {
        'phone': phone,
        'name': name,
        'inviteCode': inviteCode,
        ...device.toJson(),
      },
    );
    return LoginResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
