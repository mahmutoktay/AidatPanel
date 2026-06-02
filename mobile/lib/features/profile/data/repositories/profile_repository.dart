import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> getProfile();

  Future<UserEntity> updateProfile({
    required String name,
    String? phone,
  });

  Future<UserEntity> updateLanguage(String languageCode);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount();
}
