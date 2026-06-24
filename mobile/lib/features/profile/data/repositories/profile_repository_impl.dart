import '../../../../core/network/api_exception.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../datasources/profile_remote_datasource.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<UserEntity> getProfile() async {
    try {
      final data = await _remoteDataSource.getMe();
      return data.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Profil bilgileri alınamadı');
    }
  }

  @override
  Future<UserEntity> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? currentPassword,
  }) async {
    try {
      final data = await _remoteDataSource.updateMe(
        name: name,
        email: email,
        phone: phone,
        currentPassword: currentPassword,
      );
      return data.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Profil güncellenemedi');
    }
  }

  @override
  Future<UserEntity> updateLanguage(String languageCode) async {
    try {
      final data = await _remoteDataSource.updateLanguage(languageCode);
      return data.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Dil tercihi kaydedilemedi');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Şifre değiştirilemedi: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Hesap kapatılamadı: $e');
    }
  }

  @override
  Future<UserEntity> uploadProfilePicture(String filePath) async {
    try {
      final data = await _remoteDataSource.uploadProfilePicture(filePath);
      return data.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Profil fotoğrafı yüklenemedi');
    }
  }

  @override
  Future<UserEntity> deleteProfilePicture() async {
    try {
      final data = await _remoteDataSource.deleteProfilePicture();
      return data.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Profil fotoğrafı silinemedi');
    }
  }
}
