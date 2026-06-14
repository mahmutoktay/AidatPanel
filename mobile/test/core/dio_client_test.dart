import 'package:aidatpanel/core/constants/api_constants.dart';
import 'package:aidatpanel/core/network/dio_client.dart';
import 'package:aidatpanel/core/storage/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioClient auth rules', () {
    test('public path token gerektirmez', () {
      final client = DioClient(secureStorage: _FakeSecureStorage());

      expect(client.isPublicPathForTest(ApiConstants.login), isTrue);
      expect(client.isPublicPathForTest(ApiConstants.refresh), isTrue);
      expect(client.isPublicPathForTest(ApiConstants.register), isTrue);
      expect(client.isPublicPathForTest(ApiConstants.buildings), isFalse);
    });

    test('session mutation sırasında refresh bloklanır', () {
      final client = DioClient(secureStorage: _FakeSecureStorage());

      expect(client.isRefreshBlockedForTest, isFalse);

      client.beginSessionMutation();
      expect(client.isRefreshBlockedForTest, isTrue);

      client.beginSessionMutation();
      expect(client.isRefreshBlockedForTest, isTrue);

      client.endSessionMutation();
      expect(client.isRefreshBlockedForTest, isTrue);

      client.endSessionMutation();
      expect(client.isRefreshBlockedForTest, isFalse);

      client.endSessionMutation();
      expect(client.isRefreshBlockedForTest, isFalse);
    });
  });
}

class _FakeSecureStorage extends SecureStorage {
  String? _token;
  String? _refreshToken;
  DateTime? _expiry;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
  }

  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {
    _expiry = expiry;
  }

  @override
  Future<bool> needsTokenRefresh() async {
    if (_expiry == null) return true;
    return DateTime.now().isAfter(_expiry!);
  }

  @override
  Future<void> clearAuth() async {
    _token = null;
    _refreshToken = null;
    _expiry = null;
  }
}
