import 'dart:convert';

import '../../../../core/device/device_info_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/token_refresh_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/jwt_utils.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/saved_login_hint.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/join_request.dart';
import '../models/user_data.dart';

abstract class AuthRepository {
  /// `identifier` email **veya** telefon olabilir (Belge §3).
  Future<UserEntity> login(String identifier, String password);
  Future<void> checkIdentifier({
    required String identifier,
    required String purpose,
  });
  Future<void> register(
    String? email,
    String password,
    String name,
    String? phone,
  );
  Future<UserEntity> join(
    String inviteCode,
    String email,
    String password,
    String name,
    String? phone,
  );
  Future<void> logout();

  /// Diğer cihazlardan çıkış; bu cihazda yeni token ile oturum sürer.
  Future<void> logoutAllDevices();

  /// Tur 5 / §10/6 — Şifremi unuttum akışı.
  /// Backend her zaman 200 döner; UI kullanıcıya "kod gönderildi" mesajı
  /// gösterip reset ekranına geçirir (enumeration leak korumalı).
  Future<void> forgotPassword(String email);

  /// 6 karakter token + yeni şifre. Geçersiz/expired token → ApiException.
  Future<void> resetPassword(String token, String password);

  Future<UserEntity?> getStoredUser();

  /// Uygulama açılışında çağrılır. SecureStorage'daki kullanıcıyı geri yükler.
  /// - Token geçerliyse direkt user döner.
  /// - Token süresi dolmuşsa refresh dener; başarılıysa user döner.
  /// - Refresh 401/403 alırsa storage temizlenir, null döner.
  /// - Ağ hatasında stale token'la user döndürür (interceptor sonra yeniler).
  Future<UserEntity?> restoreSession();

  /// Profil güncellemesi sonrası SecureStorage kullanıcı önbelleğini yazar.
  Future<void> persistUser(UserEntity user);

  Future<void> sendOtp({
    String? phone,
    String? email,
    required String purpose,
    Map<String, dynamic>? payload,
  });

  Future<UserEntity> verifyOtp({
    String? phone,
    String? email,
    required String code,
    required String purpose,
    Map<String, dynamic>? payload,
    String? name,
    String? password,
    String? inviteCode,
  });

  Future<String> validateInvite(String inviteCode);

  Future<bool> verifyResidentJoinOtp({
    required String phone,
    required String code,
    required String inviteCode,
  });

  Future<UserEntity> completeResidentJoin({
    required String phone,
    required String name,
    required String inviteCode,
  });

  Future<SavedLoginHint?> getSavedLoginHint(UserRole role);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorage secureStorage,
  }) : _remoteDataSource = remoteDataSource,
       _secureStorage = secureStorage;

  Future<void> _persistTokens(String accessToken, String refreshToken) async {
    await _secureStorage.saveToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
    await _secureStorage.saveTokenExpiry(JwtUtils.parseExpiry(accessToken));
    final sid =
        JwtUtils.parseSessionId(refreshToken) ??
        JwtUtils.parseSessionId(accessToken);
    if (sid != null) {
      await _secureStorage.saveSessionId(sid);
    }
  }

  String _roleStorageKey(UserRole role) =>
      role == UserRole.manager ? 'MANAGER' : 'RESIDENT';

  Future<void> _saveLoginHintForUser(UserEntity user) async {
    final hint = SavedLoginHint(
      role: user.role,
      name: user.name,
      phone: user.phone,
      email: user.email,
    );
    final raw = await _secureStorage.getLoginHintsRaw();
    final map = <String, dynamic>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          map.addAll(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }
    map[_roleStorageKey(user.role)] = hint.toJson();
    await _secureStorage.saveLoginHintsRaw(jsonEncode(map));
  }

  @override
  Future<SavedLoginHint?> getSavedLoginHint(UserRole role) async {
    final raw = await _secureStorage.getLoginHintsRaw();
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final entry = decoded[_roleStorageKey(role)];
      if (entry is! Map) return null;
      return SavedLoginHint.fromJson(Map<String, dynamic>.from(entry));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserEntity> login(String identifier, String password) async {
    try {
      final device = await DeviceInfoService.currentDeviceMeta();
      final request = LoginRequest(
        identifier: identifier,
        password: password,
        deviceLabel: device.deviceLabel,
        platform: device.platform,
      );
      final response = await _remoteDataSource.login(request);

      await _persistTokens(response.accessToken, response.refreshToken);
      await _secureStorage.saveUser(jsonEncode(response.user.toJson()));
      final user = response.user.toEntity();
      await _saveLoginHintForUser(user);

      return user;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'auth_login_failed');
    }
  }

  @override
  Future<void> checkIdentifier({
    required String identifier,
    required String purpose,
  }) async {
    try {
      await _remoteDataSource.checkIdentifier(
        identifier: PhoneUtils.normalizeLoginIdentifier(identifier),
        purpose: purpose,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'identifier_check_failed');
    }
  }

  @override
  Future<void> register(
    String? email,
    String password,
    String name,
    String? phone,
  ) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      await _remoteDataSource.register(request);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'auth_register_failed');
    }
  }

  @override
  Future<UserEntity> join(
    String inviteCode,
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    try {
      final device = await DeviceInfoService.currentDeviceMeta();
      final request = JoinRequest(
        inviteCode: inviteCode,
        email: email,
        password: password,
        name: name,
        phone: phone,
        deviceLabel: device.deviceLabel,
        platform: device.platform,
      );
      final response = await _remoteDataSource.join(request);

      await _persistTokens(response.accessToken, response.refreshToken);
      await _secureStorage.saveUser(jsonEncode(response.user.toJson()));
      final user = response.user.toEntity();
      await _saveLoginHintForUser(user);

      return user;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'auth_join_failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {}
    final user = await getStoredUser();
    if (user != null) {
      await _saveLoginHintForUser(user);
    }
    await _secureStorage.clearAuth();
  }

  @override
  Future<void> logoutAllDevices() async {
    _remoteDataSource.beginSessionMutation();
    try {
      final tokens = await _remoteDataSource.logoutAllDevices();
      await _persistTokenPair(tokens);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'auth_logout_all_devices_failed');
    } finally {
      _remoteDataSource.endSessionMutation();
    }
  }

  Future<void> _persistTokenPair(TokenRefreshResult tokens) async {
    final refresh = tokens.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      throw ApiException(message: 'auth_logout_all_devices_failed');
    }
    await _persistTokens(tokens.accessToken, refresh);
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email: email);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'auth_forgot_password_request_failed');
    }
  }

  @override
  Future<void> resetPassword(String token, String password) async {
    try {
      await _remoteDataSource.resetPassword(token: token, password: password);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'auth_reset_password_failed');
    }
  }

  @override
  Future<void> persistUser(UserEntity user) async {
    final data = UserData(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role == UserRole.manager ? 'MANAGER' : 'RESIDENT',
      language: user.language,
      apartmentId: user.apartmentId,
    );
    await _secureStorage.saveUser(jsonEncode(data.toJson()));
  }

  @override
  Future<UserEntity?> getStoredUser() async {
    final userJson = await _secureStorage.getUser();
    if (userJson == null) return null;

    try {
      final userData = UserData.fromJson(jsonDecode(userJson));
      return userData.toEntity();
    } catch (_) {
      await _secureStorage.clearAll();
      return null;
    }
  }

  @override
  Future<UserEntity?> restoreSession() async {
    final user = await getStoredUser();
    if (user == null) return null;

    final accessToken = await _secureStorage.getToken();
    if (accessToken == null) {
      await _secureStorage.clearAuth();
      return null;
    }

    final isExpired = await _secureStorage.isTokenExpired();
    if (!isExpired) return user;

    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) {
      await _secureStorage.clearAuth();
      return null;
    }

    try {
      final result = await _remoteDataSource.refreshToken(refreshToken);
      await _secureStorage.saveToken(result.accessToken);
      await _secureStorage.saveTokenExpiry(
        JwtUtils.parseExpiry(result.accessToken),
      );
      if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
        await _secureStorage.saveRefreshToken(result.refreshToken!);
      }
      final sid =
          JwtUtils.parseSessionId(result.refreshToken ?? refreshToken) ??
          JwtUtils.parseSessionId(result.accessToken);
      if (sid != null) {
        await _secureStorage.saveSessionId(sid);
      }
      return user;
    } on ApiException catch (e) {
      // Refresh token gerçekten geçersiz olduğunda oturumu kapat.
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _secureStorage.clearAuth();
        return null;
      }
      // Ağ/timeout/sunucu hatası: kullanıcıyı oturumda tut, ilk istek
      // sırasında interceptor tekrar refresh deneyecek.
      return user;
    } catch (_) {
      return user;
    }
  }

  @override
  Future<void> sendOtp({
    String? phone,
    String? email,
    required String purpose,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _remoteDataSource.sendOtp(
        phone: phone,
        email: email,
        purpose: purpose,
        payload: payload,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'otp_send_failed');
    }
  }

  @override
  Future<UserEntity> verifyOtp({
    String? phone,
    String? email,
    required String code,
    required String purpose,
    Map<String, dynamic>? payload,
    String? name,
    String? password,
    String? inviteCode,
  }) async {
    try {
      final response = await _remoteDataSource.verifyOtp(
        phone: phone,
        email: email,
        code: code,
        purpose: purpose,
        payload: payload,
        name: name,
        password: password,
        inviteCode: inviteCode,
      );
      await _persistTokens(response.accessToken, response.refreshToken);
      await _secureStorage.saveUser(jsonEncode(response.user.toJson()));
      final user = response.user.toEntity();
      await _saveLoginHintForUser(user);
      return user;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'otp_verify_failed');
    }
  }

  @override
  Future<String> validateInvite(String inviteCode) async {
    try {
      return await _remoteDataSource.validateInviteCode(inviteCode);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'invite_invalid');
    }
  }

  @override
  Future<bool> verifyResidentJoinOtp({
    required String phone,
    required String code,
    required String inviteCode,
  }) async {
    try {
      return await _remoteDataSource.verifyResidentJoinOtp(
        phone: phone,
        code: code,
        inviteCode: inviteCode,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'otp_verify_failed');
    }
  }

  @override
  Future<UserEntity> completeResidentJoin({
    required String phone,
    required String name,
    required String inviteCode,
  }) async {
    try {
      final response = await _remoteDataSource.completeResidentJoin(
        phone: phone,
        name: name,
        inviteCode: inviteCode,
      );
      await _persistTokens(response.accessToken, response.refreshToken);
      await _secureStorage.saveUser(jsonEncode(response.user.toJson()));
      final user = response.user.toEntity();
      await _saveLoginHintForUser(user);
      return user;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'otp_verify_failed');
    }
  }
}
