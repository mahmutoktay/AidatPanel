import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_data.dart';

/// Tur 5 / §10/4-5 — Backend `meControllers` (commit 8cc2152) tarafından
/// açılan kullanıcı profil ve hesap kapama uçları.
abstract class ProfileRemoteDataSource {
  /// `GET /api/v1/me` — güncel profil bilgisi.
  Future<UserData> getMe();

  /// `PUT /api/v1/me` — ad / telefon güncelleme.
  Future<UserData> updateMe({
    required String name,
    String? phone,
  });

  /// `PUT /api/v1/me/language` — bildirim dili (tr | en).
  Future<UserData> updateLanguage(String languageCode);
  /// `PUT /api/v1/me/password` body `{ currentPassword, newPassword }`.
  /// Backend başarıdan sonra `refreshTokenVersion++` yapıyor → mevcut
  /// refresh token geçersizleşir, sonraki 401'de mobile otomatik logout.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// `DELETE /api/v1/me` — KVKK soft delete.
  /// Backend yanıtları:
  ///  - 200: hesap kapatıldı (PII maskelendi, refreshTokenVersion++)
  ///  - 409: yöneticide bina var → "Önce binaları silin/devredin"
  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient _dioClient;

  ProfileRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  UserData _parseUserPayload(dynamic data) {
    final map = data as Map<String, dynamic>;
    if (map['user'] is Map<String, dynamic>) {
      return UserData.fromJson(map['user'] as Map<String, dynamic>);
    }
    return UserData.fromJson(map);
  }

  @override
  Future<UserData> getMe() async {
    final response = await _dioClient.get(ApiConstants.profile);
    return _parseUserPayload(response.data['data']);
  }

  @override
  Future<UserData> updateMe({
    required String name,
    String? phone,
  }) async {
    final body = <String, dynamic>{'name': name.trim()};
    final trimmedPhone = phone?.trim();
    // Profil kaydında telefon her zaman gönderilir: dolu → güncelle,
    // boş/null → sunucuda sil (PUT /me body.phone: null).
    if (trimmedPhone != null && trimmedPhone.isNotEmpty) {
      body['phone'] = trimmedPhone;
    } else {
      body['phone'] = null;
    }
    final response = await _dioClient.put(
      ApiConstants.profile,
      data: body,
    );
    return _parseUserPayload(response.data['data']);
  }

  @override
  Future<UserData> updateLanguage(String languageCode) async {
    final response = await _dioClient.put(
      ApiConstants.changeLanguage,
      data: {'language': languageCode},
    );
    return _parseUserPayload(response.data['data']);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dioClient.put(
      ApiConstants.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<void> deleteAccount() async {
    await _dioClient.delete(ApiConstants.profile);
  }
}
