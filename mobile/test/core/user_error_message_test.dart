import 'package:aidatpanel/core/network/api_exception.dart';
import 'package:aidatpanel/core/utils/user_error_message.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  group('userFacingError', () {
    test('ApiException mesajını olduğu gibi döner', () {
      expect(
        userFacingError(ApiException(message: 'E-posta hatalı')),
        'E-posta hatalı',
      );
    });

    test('bilinmeyen hata için i18n unexpectedError döner', () {
      expect(
        userFacingError(Exception('SocketException: Connection refused')),
        'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
      );
    });
  });

  group('wrapAsyncStateError', () {
    test('ApiException aynen korunur', () {
      final original = ApiException(message: 'Sunucu hatası', statusCode: 500);
      expect(identical(wrapAsyncStateError(original), original), isTrue);
    });

    test('diğer hatalar ApiException olarak sarılır', () {
      final wrapped = wrapAsyncStateError(StateError('bad state'));
      expect(wrapped, isA<ApiException>());
      expect(
        (wrapped as ApiException).message,
        'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
      );
    });
  });
}
