import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_exception.dart';
import '../storage/secure_storage.dart';
import 'fcm_platform.dart';
import 'fcm_token_remote_datasource.dart';
import 'notification_payload.dart';
typedef FcmNavigationHandler = void Function(NotificationPayload payload);

/// FCM izin, token kaydı ve mesaj dinleyicileri.
class FcmService {
  final FirebaseMessaging _messaging;
  final FcmTokenRemoteDataSource _tokenDataSource;
  final SecureStorage _secureStorage;

  bool _listenersAttached = false;
  Future<void>? _syncInFlight;
  DateTime? _rateLimitedUntil;

  FcmService({
    required FirebaseMessaging messaging,
    required FcmTokenRemoteDataSource tokenDataSource,
    required SecureStorage secureStorage,
  })  : _messaging = messaging,
        _tokenDataSource = tokenDataSource,
        _secureStorage = secureStorage;

  Future<void> attachListeners({
    required FcmNavigationHandler onOpenFromNotification,
    void Function(RemoteMessage message)? onForegroundMessage,
  }) async {
    if (_listenersAttached) return;
    _listenersAttached = true;

    // iOS: Uygulama ön plandayken sistem bildirimini (banner/alert) bastırır.
    // Bildirim yalnızca uygulama içi overlay (toast) olarak gösterilecek.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      if (kDebugMode) {
        debugPrint(
          '[FCM foreground] ${message.notification?.title ?? message.data['title']}',
        );
      }
      // Ön planda sistem tepsisi bildirimi BASILMAZ.
      // Sadece uygulama içi overlay (toast) tetiklenir.
      onForegroundMessage?.call(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onForegroundMessage?.call(message);
      onOpenFromNotification(NotificationPayload.fromFcmData(message.data));
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      onForegroundMessage?.call(initial);
      onOpenFromNotification(NotificationPayload.fromFcmData(initial.data));
    }

    _messaging.onTokenRefresh.listen((token) async {
      if (kDebugMode) {
        debugPrint('[FCM] onTokenRefresh (${token.length} char)');
      }
      await _secureStorage.saveFcmToken(token);
      await _uploadIfPossible(token);
    });
  }

  /// Oturum açıkken token alır ve backend'e yükler.
  /// [forceUpload] → token değişmese bile PUT (giriş / cold start).
  Future<void> syncTokenToBackend({bool forceUpload = false}) async {
    if (_syncInFlight != null) {
      return _syncInFlight;
    }
    _syncInFlight = _syncTokenToBackendImpl(forceUpload: forceUpload);
    try {
      await _syncInFlight;
    } finally {
      _syncInFlight = null;
    }
  }

  Future<void> _syncTokenToBackendImpl({required bool forceUpload}) async {
    if (!isFcmSupported) {
      if (kDebugMode) {
        debugPrint(
          '[FCM] Bu platformda push desteklenmiyor ($defaultTargetPlatform). '
          'Android emülatör/cihaz veya iOS kullanın.',
        );
      }
      return;
    }

    String? token;
    try {
      token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        await Future<void>.delayed(const Duration(seconds: 1));
        token = await _messaging.getToken();
      }
    } catch (e, st) {
      if (kDebugMode) {
        final msg = e.toString();
        if (msg.contains('MISSING_INSTANCEID_SERVICE') ||
            msg.contains('Google Play services')) {
          debugPrint(
            '[FCM] Google Play Services yok. Android Studio → Device Manager → '
            '"Play Store" simgesi olan x86_64 emülatör seçin veya fiziksel cihaz kullanın.',
          );
        } else {
          debugPrint('[FCM] getToken hata: $e\n$st');
        }
      }
      return;
    }

    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[FCM] Token alınamadı. Android: Google Play içeren emülatör/cihaz; '
          'iOS: gerçek cihaz veya push-capable simülatör + GoogleService-Info.plist.',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[FCM] Cihaz token alındı (${token.length} karakter)');
    }

    final access = await _secureStorage.getToken();
    if (access == null || access.isEmpty) {
      if (kDebugMode) {
        debugPrint('[FCM] JWT yok — upload atlandı (önce giriş yapın).');
      }
      await _secureStorage.saveFcmToken(token);
      return;
    }

    final stored = await _secureStorage.getFcmToken();
    await _secureStorage.saveFcmToken(token);
    if (forceUpload || stored != token) {
      await _uploadIfPossible(token);
    }
  }

  Future<void> _uploadIfPossible(String token) async {
    final now = DateTime.now();
    if (_rateLimitedUntil != null && now.isBefore(_rateLimitedUntil!)) {
      if (kDebugMode) {
        debugPrint(
          '[FCM] PUT /me/fcm-token atlandı: rate limit aktif '
          '(${_rateLimitedUntil!.toIso8601String()})',
        );
      }
      return;
    }

    const maxAttempts = 4;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final access = await _secureStorage.getToken();
      if (access == null || access.isEmpty) {
        if (kDebugMode) {
          debugPrint('[FCM] Upload atlandı: access token yok.');
        }
        return;
      }

      try {
        await _tokenDataSource.uploadToken(token);
        if (kDebugMode) {
          debugPrint('[FCM] PUT /me/fcm-token başarılı.');
        }
        return;
      } on ApiException catch (e) {
        if (e.statusCode == 429) {
          _rateLimitedUntil = DateTime.now().add(const Duration(minutes: 15));
          if (kDebugMode) {
            debugPrint(
              '[FCM] 429 alındı, tekrar denemeler durduruldu. '
              'Yeni deneme: ${_rateLimitedUntil!.toIso8601String()}',
            );
          }
          return;
        }
        if (kDebugMode) {
          debugPrint(
            '[FCM] PUT /me/fcm-token başarısız (${e.statusCode}): ${e.message} '
            '(deneme $attempt/$maxAttempts)',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[FCM] PUT /me/fcm-token hata: $e (deneme $attempt/$maxAttempts)',
          );
        }
      }

      if (attempt < maxAttempts) {
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[FCM] Token sunucuya kaydedilemedi — push gelmez. '
        'Uygulamayı açık tutup tekrar giriş yapın; logda başarılı PUT bekleyin.',
      );
    }
  }
}
