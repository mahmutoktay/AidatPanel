import 'package:aidatpanel/core/constants/app_constants.dart';
import 'package:aidatpanel/core/utils/jwt_utils.dart';
import 'package:flutter_test/flutter_test.dart';

/// [SecureStorage.needsTokenRefresh] ile aynı mantık — saf fonksiyon testi.
bool needsTokenRefreshAt(DateTime? expiry, DateTime now) {
  if (expiry == null) return true;
  final refreshAt = expiry.subtract(AppConstants.tokenRefreshThreshold);
  return !now.isBefore(refreshAt);
}

void main() {
  group('needsTokenRefreshAt', () {
    final now = DateTime(2026, 5, 31, 12);

    test('expiry geçmişse true', () {
      expect(
        needsTokenRefreshAt(now.subtract(const Duration(minutes: 1)), now),
        isTrue,
      );
    });

    test('threshold içindeyse true', () {
      expect(
        needsTokenRefreshAt(now.add(const Duration(minutes: 2)), now),
        isTrue,
      );
    });

    test('threshold dışındaysa false', () {
      expect(
        needsTokenRefreshAt(
          now.add(AppConstants.tokenRefreshThreshold + const Duration(minutes: 1)),
          now,
        ),
        isFalse,
      );
    });
  });

  group('JwtUtils.parseExpiry', () {
    test('exp claim okunur', () {
      const header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
      const payload = 'eyJleHAiOjE4OTM0NTYwMDB9';
      final token = '$header.$payload.x';
      final dt = JwtUtils.parseExpiry(token);
      expect(
        dt,
        DateTime.fromMillisecondsSinceEpoch(1893456000 * 1000),
      );
    });

    test('geçersiz token fallback döner', () {
      final fb = DateTime.utc(2028, 6, 1);
      final dt = JwtUtils.parseExpiry('not-a-jwt', fallback: fb);
      expect(dt, fb);
    });
  });
}
