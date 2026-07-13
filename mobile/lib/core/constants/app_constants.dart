class AppConstants {
  // App info
  static const String appName = 'AidatPanel';
  static const String devAppName = 'AidatPanel (DEV)';
  static String appVersion =
      '0.1.5'; // Runtime'da package_info_plus'tan güncellenecek

  // Storage keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String userKey = 'user';
  static const String languageKey = 'language';
  static const String themeKey = 'theme_preference';
  static const String fcmTokenKey = 'fcm_token';
  static const String sessionIdKey = 'session_id';

  /// Yönetici kayıtlı IBAN şablonları (backend yalnızca binalardan türetir; yetim setler cihazda).
  static const String localCollectionPresetsKey = 'local_collection_presets_v1';

  /// userId → fotoğraf referansı (çıkışta silinmez; backend yokken yerel).
  static const String profilePhotosKey = 'profile_photos_v1';

  /// Rol başına son giriş bilgisi (çıkışta silinmez).
  static const String loginHintsKey = 'login_hints_v1';

  /// İlk kurulum welcome / tanıtım tamamlandı (çıkışta silinmez).
  static const String onboardingCompletedKey = 'onboarding_completed';

  /// Kullanıcı başına tek seferlik bildirim izni açıklama diyaloğu.
  static String notificationPermissionPromptKey(String userId) =>
      'notification_permission_prompt_seen_$userId';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Dekont / makbuz multipart — ana API timeout'undan ayrı (FAZ 5).
  static const Duration uploadTimeout = Duration(minutes: 3);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Invite code
  static const int inviteCodeExpiryDays = 7;

  // Pagination
  static const int pageSize = 20;

  // Default language
  static const String defaultLanguage = 'tr';
}
