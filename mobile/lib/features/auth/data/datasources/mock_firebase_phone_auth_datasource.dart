import '../../../../core/network/api_exception.dart';
import 'firebase_phone_auth_datasource.dart';

/// Dev preview — gerçek Firebase SMS çağrısı yok.
class MockFirebasePhoneAuthDataSource implements FirebasePhoneAuthDataSource {
  bool _started = false;

  @override
  bool get hasActiveSession => _started;

  @override
  bool get hasAutoVerifiedToken => false;

  @override
  void clearSession() {
    _started = false;
  }

  @override
  Future<void> startPhoneVerification(
    String phone10, {
    bool isResend = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (phone10.length != 10) {
      throw ApiException(message: 'firebase_phone_invalid');
    }
    _started = true;
  }

  @override
  Future<String> confirmSmsCode(String smsCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!_started) {
      throw ApiException(message: 'firebase_phone_session_expired');
    }
    if (smsCode.trim().length != 6) {
      throw ApiException(message: 'firebase_phone_code_invalid');
    }
    _started = false;
    return 'dev-mock-firebase-id-token';
  }

  @override
  Future<void> resendPhoneVerification(String phone10) async {
    await startPhoneVerification(phone10, isResend: true);
  }
}
