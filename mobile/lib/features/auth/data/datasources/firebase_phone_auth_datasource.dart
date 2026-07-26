import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/security/recaptcha_enterprise_service.dart';
import '../../../../core/utils/phone_utils.dart';

void _phoneAuthLog(String message) {
  // Release + USB: flutter run / adb logcat'te görünsün.
  // ignore: avoid_print
  print('[FirebasePhone] $message');
  developer.log(message, name: 'FirebasePhone');
}

Future<void> _reportPhoneAuthFailure(
  String stage,
  Object error, {
  StackTrace? stack,
}) async {
  _phoneAuthLog('$stage: $error');
  try {
    if (error is FirebaseAuthException) {
      await FirebaseCrashlytics.instance.setCustomKey(
        'firebase_phone_code',
        error.code,
      );
      await FirebaseCrashlytics.instance.setCustomKey(
        'firebase_phone_message',
        (error.message ?? '').substring(
          0,
          (error.message?.length ?? 0).clamp(0, 200),
        ),
      );
    }
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack ?? StackTrace.current,
      reason: 'FirebasePhone:$stage',
      fatal: false,
    );
  } catch (_) {
    // Crashlytics yoksa (test) sessiz geç.
  }
}

/// Firebase Auth Phone — SMS gönderimi ve kod doğrulama sözleşmesi.
abstract class FirebasePhoneAuthDataSource {
  bool get hasActiveSession;
  bool get hasAutoVerifiedToken;
  void clearSession();
  Future<void> startPhoneVerification(String phone10, {bool isResend = false});
  Future<String> confirmSmsCode(String smsCode);
  Future<void> resendPhoneVerification(String phone10);
}

/// Üretim implementasyonu — başarılı doğrulama sonrası Firebase oturumu kapatılır.
class FirebasePhoneAuthDataSourceImpl implements FirebasePhoneAuthDataSource {
  FirebasePhoneAuthDataSourceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  String? _verificationId;
  int? _forceResendingToken;
  String? _autoIdToken;
  Completer<void>? _startCompleter;
  bool _testingSettingsApplied = false;

  @override
  bool get hasActiveSession =>
      (_verificationId != null && _verificationId!.isNotEmpty) ||
      (_autoIdToken != null && _autoIdToken!.isNotEmpty);

  @override
  bool get hasAutoVerifiedToken =>
      _autoIdToken != null && _autoIdToken!.isNotEmpty;

  @override
  void clearSession() {
    _verificationId = null;
    _forceResendingToken = null;
    _autoIdToken = null;
    _startCompleter = null;
  }

  /// Emülatör / debug: Play Integrity + reCAPTCHA atlanır.
  /// Yalnızca Firebase Console → Authentication → Phone → test numaraları ile çalışır.
  Future<void> _ensureTestingSettings() async {
    if (_testingSettingsApplied || !kDebugMode) return;
    try {
      await _auth.setSettings(appVerificationDisabledForTesting: true);
      _testingSettingsApplied = true;
      if (kDebugMode) {
        debugPrint(
          '[FirebasePhone] appVerificationDisabledForTesting=true '
          '(yalnızca Console test numaraları)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirebasePhone] setSettings başarısız: $e');
      }
    }
  }

  @override
  Future<void> startPhoneVerification(
    String phone10, {
    bool isResend = false,
  }) async {
    final e164 = PhoneUtils.toE164Tr(phone10);
    if (e164 == null) {
      throw ApiException(message: 'firebase_phone_invalid');
    }

    await _ensureTestingSettings();
    await RecaptchaEnterpriseService.warmUpForPhoneAuth();

    final resendToken = isResend ? _forceResendingToken : null;
    _verificationId = null;
    _autoIdToken = null;
    if (!isResend) {
      _forceResendingToken = null;
    }

    final completer = Completer<void>();
    _startCompleter = completer;

    _phoneAuthLog('verifyPhoneNumber start resend=$isResend');

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: e164,
        timeout: const Duration(seconds: 90),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCred = await _auth.signInWithCredential(credential);
            final token = await userCred.user?.getIdToken();
            if (token == null || token.isEmpty) {
              throw ApiException(message: 'firebase_phone_failed');
            }
            _autoIdToken = token;
            await _auth.signOut();
            _phoneAuthLog('auto-verify tamam, idToken alındı');
            if (!completer.isCompleted) completer.complete();
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(_mapError(e));
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          unawaited(
            _reportPhoneAuthFailure('verificationFailed', e),
          );
          if (!completer.isCompleted) {
            completer.completeError(_mapFirebaseAuthException(e));
          }
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          _verificationId = verificationId;
          _forceResendingToken = forceResendingToken;
          _phoneAuthLog('codeSent');
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          _phoneAuthLog('codeAutoRetrievalTimeout');
        },
      );
      await completer.future.timeout(
        const Duration(seconds: 100),
        onTimeout: () {
          unawaited(
            _reportPhoneAuthFailure(
              'timeout',
              ApiException(message: 'firebase_phone_timeout'),
            ),
          );
          throw ApiException(message: 'firebase_phone_timeout');
        },
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      unawaited(_reportPhoneAuthFailure('startCatch', e, stack: st));
      throw _mapError(e);
    } finally {
      if (identical(_startCompleter, completer)) {
        _startCompleter = null;
      }
    }
  }

  @override
  Future<String> confirmSmsCode(String smsCode) async {
    if (hasAutoVerifiedToken) {
      final token = _autoIdToken!;
      clearSession();
      return token;
    }

    final verificationId = _verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      throw ApiException(message: 'firebase_phone_session_expired');
    }

    final trimmed = smsCode.trim();
    if (trimmed.length != 6) {
      throw ApiException(message: 'firebase_phone_code_invalid');
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: trimmed,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final token = await userCred.user?.getIdToken();
      await _auth.signOut();
      clearSession();
      if (token == null || token.isEmpty) {
        throw ApiException(message: 'firebase_phone_failed');
      }
      return token;
    } on ApiException {
      rethrow;
    } on FirebaseAuthException catch (e, st) {
      unawaited(_reportPhoneAuthFailure('confirmSmsCode', e, stack: st));
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> resendPhoneVerification(String phone10) async {
    await startPhoneVerification(phone10, isResend: true);
  }

  ApiException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return ApiException(message: 'firebase_phone_invalid');
      case 'too-many-requests':
        return ApiException(message: 'firebase_phone_too_many');
      case 'session-expired':
      case 'code-expired':
        return ApiException(message: 'firebase_phone_session_expired');
      case 'invalid-verification-code':
      case 'invalid-verification-id':
        return ApiException(message: 'firebase_phone_code_invalid');
      case 'network-request-failed':
        return ApiException(message: 'network_error');
      case 'missing-client-identifier':
      case 'app-not-authorized':
      case 'captcha-check-failed':
      case 'web-context-cancelled':
      case 'invalid-app-credential':
      case 'missing-recaptcha-token':
        return ApiException(message: 'firebase_phone_app_verify');
      case 'operation-not-allowed':
        return ApiException(message: 'firebase_phone_not_enabled');
      default:
        return ApiException(message: 'firebase_phone_failed');
    }
  }

  Object _mapError(Object e) {
    if (e is ApiException) return e;
    if (e is FirebaseAuthException) {
      // PluginRegistrant'ta firebase_auth eksikse pigeon channel-error döner.
      if (e.code == 'channel-error') {
        return ApiException(message: 'firebase_phone_failed');
      }
      return _mapFirebaseAuthException(e);
    }
    final text = e.toString();
    if (text.contains('channel-error') || text.contains('verifyPhoneNumber')) {
      return ApiException(message: 'firebase_phone_failed');
    }
    return ApiException(message: 'firebase_phone_failed');
  }
}
