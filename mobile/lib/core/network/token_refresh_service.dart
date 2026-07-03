import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../device/device_info_service.dart';
import '../storage/secure_storage.dart';
import '../utils/jwt_utils.dart';

class TokenRefreshResult {
  final String accessToken;
  final String? refreshToken;

  const TokenRefreshResult({required this.accessToken, this.refreshToken});
}

/// Oturum sonlandığında çağrılacak callback türü.
typedef SessionExpiredCallback = void Function();

/// Tek uçuş (single-flight) refresh — eşzamanlı 401'lerde tek POST /auth/refresh.
class TokenRefreshService {
  final Dio _refreshDio;
  final SecureStorage _secureStorage;

  /// Callback değil, callback döndüren bir getter.
  /// Bu sayede DioClient oluşturulduktan sonra callback tanımlansa bile
  /// çağrı anında güncel değer alınır.
  final SessionExpiredCallback? Function()? _onSessionExpiredGetter;

  Future<TokenRefreshResult?>? _inFlight;

  TokenRefreshService({
    required Dio refreshDio,
    required SecureStorage secureStorage,
    SessionExpiredCallback? Function()? onSessionExpiredGetter,
  }) : _refreshDio = refreshDio,
       _secureStorage = secureStorage,
       _onSessionExpiredGetter = onSessionExpiredGetter;

  /// Başarılı refresh sonrası token'ları kaydeder ve sonucu döner.
  /// Refresh token yoksa veya sunucu reddederse `null`.
  Future<TokenRefreshResult?> refreshAndPersist() async {
    if (_inFlight != null) {
      try {
        return await _inFlight;
      } catch (_) {
        return null;
      }
    }

    _inFlight = _performRefresh();
    try {
      return await _inFlight;
    } finally {
      _inFlight = null;
    }
  }

  Future<TokenRefreshResult?> _performRefresh() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final device = await DeviceInfoService.currentDeviceMeta();
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: {
          'refreshToken': refreshToken,
          ...device.toJson(),
        },
      );

      final raw = response.data;
      if (raw == null) return null;

      final Map<String, dynamic> payload = raw['data'] is Map
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : Map<String, dynamic>.from(raw);

      final accessToken = payload['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) return null;

      final rotatedRefresh = payload['refreshToken'] as String?;

      await _secureStorage.saveToken(accessToken);
      await _secureStorage.saveTokenExpiry(JwtUtils.parseExpiry(accessToken));
      if (rotatedRefresh != null && rotatedRefresh.isNotEmpty) {
        await _secureStorage.saveRefreshToken(rotatedRefresh);
      }
      final sid = JwtUtils.parseSessionId(rotatedRefresh ?? refreshToken) ??
          JwtUtils.parseSessionId(accessToken);
      if (sid != null) {
        await _secureStorage.saveSessionId(sid);
      }

      return TokenRefreshResult(
        accessToken: accessToken,
        refreshToken: rotatedRefresh,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        rethrow;
      }
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        await _secureStorage.clearAuth();
        _onSessionExpiredGetter?.call()?.call();
      }
      return null;
    }
  }
}
