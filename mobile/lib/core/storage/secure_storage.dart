import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/feature_tour/domain/feature_tour_models.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> saveUser(String user) async {
    await _storage.write(key: AppConstants.userKey, value: user);
  }

  Future<String?> getUser() async {
    return await _storage.read(key: AppConstants.userKey);
  }

  Future<void> saveLanguage(String language) async {
    await _storage.write(key: AppConstants.languageKey, value: language);
  }

  Future<String?> getLanguage() async {
    return await _storage.read(key: AppConstants.languageKey);
  }

  Future<void> saveTheme(String theme) async {
    await _storage.write(key: AppConstants.themeKey, value: theme);
  }

  Future<String?> getTheme() async {
    return await _storage.read(key: AppConstants.themeKey);
  }

  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: AppConstants.fcmTokenKey, value: token);
  }

  Future<String?> getFcmToken() async {
    return await _storage.read(key: AppConstants.fcmTokenKey);
  }

  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: AppConstants.sessionIdKey, value: sessionId);
  }

  Future<String?> getSessionId() async {
    return await _storage.read(key: AppConstants.sessionIdKey);
  }

  Future<void> clearSessionId() async {
    await _storage.delete(key: AppConstants.sessionIdKey);
  }

  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _storage.write(
      key: AppConstants.tokenExpiryKey,
      value: expiry.millisecondsSinceEpoch.toString(),
    );
  }

  Future<DateTime?> getTokenExpiry() async {
    final value = await _storage.read(key: AppConstants.tokenExpiryKey);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
  }

  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Süresi dolmuş veya [AppConstants.tokenRefreshThreshold] içinde dolacaksa true.
  Future<bool> needsTokenRefresh() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    final refreshAt = expiry.subtract(AppConstants.tokenRefreshThreshold);
    return !DateTime.now().isBefore(refreshAt);
  }

  Future<void> clearAuth() async {
    final language = await getLanguage();
    final theme = await getTheme();
    final profilePhotos = await getProfilePhotosMap();
    final localPresets = await readRaw(AppConstants.localCollectionPresetsKey);
    final loginHints = await readRaw(AppConstants.loginHintsKey);
    final onboardingCompleted = await isOnboardingCompleted();
    final managerTourDone =
        await isFeatureTourCompleted(FeatureTourId.managerHome);
    final residentTourDone =
        await isFeatureTourCompleted(FeatureTourId.residentHome);
    await _storage.deleteAll();
    if (language != null) await saveLanguage(language);
    if (theme != null) await saveTheme(theme);
    if (profilePhotos.isNotEmpty) {
      await saveProfilePhotosMap(profilePhotos);
    }
    if (localPresets != null && localPresets.isNotEmpty) {
      await writeRaw(AppConstants.localCollectionPresetsKey, localPresets);
    }
    if (loginHints != null && loginHints.isNotEmpty) {
      await writeRaw(AppConstants.loginHintsKey, loginHints);
    }
    if (onboardingCompleted) {
      await markOnboardingCompleted();
    }
    if (managerTourDone) {
      await markFeatureTourCompleted(FeatureTourId.managerHome);
    }
    if (residentTourDone) {
      await markFeatureTourCompleted(FeatureTourId.residentHome);
    }
  }

  Future<bool> isOnboardingCompleted() async {
    final raw = await _storage.read(key: AppConstants.onboardingCompletedKey);
    return raw == '1' || raw == 'true';
  }

  Future<void> markOnboardingCompleted() async {
    await _storage.write(
      key: AppConstants.onboardingCompletedKey,
      value: '1',
    );
  }

  String _featureTourStorageKey(FeatureTourId tourId) {
    return switch (tourId) {
      FeatureTourId.managerHome => AppConstants.featureTourManagerHomeV1Key,
      FeatureTourId.residentHome => AppConstants.featureTourResidentHomeV1Key,
    };
  }

  Future<bool> isFeatureTourCompleted(FeatureTourId tourId) async {
    final raw = await _storage.read(key: _featureTourStorageKey(tourId));
    return raw == '1' || raw == 'true';
  }

  Future<void> markFeatureTourCompleted(FeatureTourId tourId) async {
    await _storage.write(key: _featureTourStorageKey(tourId), value: '1');
  }

  Future<void> clearFeatureTourCompleted(FeatureTourId tourId) async {
    await _storage.delete(key: _featureTourStorageKey(tourId));
  }

  Future<String?> readRaw(String key) => _storage.read(key: key);

  Future<void> writeRaw(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<Map<String, String>> getProfilePhotosMap() async {
    final raw = await _storage.read(key: AppConstants.profilePhotosKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveProfilePhotosMap(Map<String, String> map) async {
    await _storage.write(
      key: AppConstants.profilePhotosKey,
      value: jsonEncode(map),
    );
  }

  Future<String?> getProfilePhotoRef(String userId) async {
    if (userId.isEmpty) return null;
    final map = await getProfilePhotosMap();
    return map[userId];
  }

  Future<void> setProfilePhotoRef(String userId, String photoRef) async {
    if (userId.isEmpty) return;
    final map = await getProfilePhotosMap();
    map[userId] = photoRef;
    await saveProfilePhotosMap(map);
  }

  Future<bool> hasSeenNotificationPermissionPrompt(String userId) async {
    if (userId.isEmpty) return true;
    final raw = await _storage.read(
      key: AppConstants.notificationPermissionPromptKey(userId),
    );
    return raw == '1';
  }

  Future<void> markNotificationPermissionPromptSeen(String userId) async {
    if (userId.isEmpty) return;
    await _storage.write(
      key: AppConstants.notificationPermissionPromptKey(userId),
      value: '1',
    );
  }

  Future<void> removeProfilePhotoRef(String userId) async {
    if (userId.isEmpty) return;
    final map = await getProfilePhotosMap();
    map.remove(userId);
    await saveProfilePhotosMap(map);
  }

  Future<String?> getLoginHintsRaw() => readRaw(AppConstants.loginHintsKey);

  Future<void> saveLoginHintsRaw(String value) =>
      writeRaw(AppConstants.loginHintsKey, value);
}
