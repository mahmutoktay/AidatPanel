import 'package:aidatpanel/core/network/token_refresh_service.dart';
import 'package:aidatpanel/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}
class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('TokenRefreshService single-flight refresh', () {
    late TokenRefreshService service;
    late MockDio mockDio;
    late MockSecureStorage mockStorage;

    setUp(() {
      mockDio = MockDio();
      mockStorage = MockSecureStorage();
      service = TokenRefreshService(
        refreshDio: mockDio,
        secureStorage: mockStorage,
      );
    });

    test('concurrent refresh calls return same result without multiple POSTs', () async {
      when(() => mockStorage.getRefreshToken()).thenAnswer((_) async => 'valid_refresh');

      var callCount = 0;
      when(() => mockDio.post<Map<String, dynamic>>(any(that: predicate((s) => true)),
              data: any(named: 'data')))
          .thenAnswer((_) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return Response(
          requestOptions: RequestOptions(),
          data: {
            'data': {
              'accessToken': 'new_access',
              'refreshToken': 'new_refresh',
            },
          },
        );
      });

      when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveTokenExpiry(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveRefreshToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveSessionId(any())).thenAnswer((_) async {});

      final results = await Future.wait([
        service.refreshAndPersist(),
        service.refreshAndPersist(),
        service.refreshAndPersist(),
      ]);

      expect(callCount, 1, reason: 'Single-flight refresh: only 1 POST executes');
      expect(results.length, 3);
    });
  });
}