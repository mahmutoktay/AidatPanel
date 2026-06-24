import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> getProfile();

  Future<UserEntity> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? currentPassword,
  });

  Future<UserEntity> updateLanguage(String languageCode);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount();

  Future<UserEntity> uploadProfilePicture(String filePath);

  Future<UserEntity> deleteProfilePicture();
}
