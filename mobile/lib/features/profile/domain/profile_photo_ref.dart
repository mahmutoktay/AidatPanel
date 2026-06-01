import '../../../core/constants/app_assets.dart';

/// Yerel profil fotoğrafı referansı (backend yokken cihazda kullanıcıya özel).
abstract final class ProfilePhotoRef {
  static const String assetPrefix = 'asset:';
  static const String filePrefix = 'file:';

  static String bundledDefault() => '$assetPrefix${AppAssets.defaultProfileAvatar}';

  static bool isAsset(String ref) => ref.startsWith(assetPrefix);

  static bool isFile(String ref) => ref.startsWith(filePrefix);

  static String assetPath(String ref) => ref.substring(assetPrefix.length);

  static String filePath(String ref) => ref.substring(filePrefix.length);
}
