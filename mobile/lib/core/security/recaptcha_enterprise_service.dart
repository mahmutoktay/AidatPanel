import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_enterprise_flutter.dart';

/// Firebase Phone Auth / Identity Platform SMS defense için reCAPTCHA Enterprise.
///
/// Site key'ler Firebase Console → Authentication → Settings → reCAPTCHA
/// (Identity Platform `recaptchaConfig`) ile eşleşir. İstemci anahtarlarıdır;
/// `--dart-define` ile override edilebilir.
abstract final class RecaptchaEnterpriseService {
  static const String androidSiteKey = String.fromEnvironment(
    'RECAPTCHA_ANDROID_SITE_KEY',
    defaultValue: '6LdibmQtAAAAAPO48UmXpNizoLNVNRAj6bI3i2WA',
  );

  static const String iosSiteKey = String.fromEnvironment(
    'RECAPTCHA_IOS_SITE_KEY',
    defaultValue: '6LdyN2YtAAAAAPqaPnB5xT_DeNLRXCZ_-fm7egVC',
  );

  static RecaptchaClient? _client;
  static bool _initialized = false;

  static bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool get isReady => _client != null;

  static String get _siteKey {
    if (Platform.isAndroid) return androidSiteKey;
    if (Platform.isIOS) return iosSiteKey;
    return '';
  }

  /// Uygulama açılışında erken çağrılır — native SDK link + Firebase Auth config.
  static Future<void> initialize() async {
    if (_initialized || !isSupportedPlatform) return;
    _initialized = true;

    final siteKey = _siteKey.trim();
    if (siteKey.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[reCAPTCHA] Site key yok — Phone Auth SDK link eksik kalabilir.',
        );
      }
      return;
    }

    try {
      _client = await Recaptcha.fetchClient(siteKey);
      if (kDebugMode) {
        debugPrint(
          '[reCAPTCHA] fetchClient OK (${Platform.operatingSystem})',
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[reCAPTCHA] fetchClient başarısız: $e\n$st');
      }
    }

    try {
      await FirebaseAuth.instance.initializeRecaptchaConfig();
      if (kDebugMode) {
        debugPrint('[reCAPTCHA] FirebaseAuth.initializeRecaptchaConfig OK');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[reCAPTCHA] initializeRecaptchaConfig başarısız: $e\n$st',
        );
      }
    }
  }

  /// Sakin telefon doğrulaması öncesi sinyal toplama (login action).
  /// Başarısızlık Phone Auth'u engellemez — Firebase SDK kendi akışını sürdürür.
  static Future<void> warmUpForPhoneAuth() async {
    if (!isSupportedPlatform) return;

    if (_client == null && !_initialized) {
      await initialize();
    }

    final client = _client;
    if (client == null) return;

    try {
      await client.execute(RecaptchaAction.LOGIN(), timeout: 10);
      if (kDebugMode) {
        debugPrint('[reCAPTCHA] execute(LOGIN) OK');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[reCAPTCHA] execute(LOGIN) atlandı: $e');
      }
    }
  }
}
