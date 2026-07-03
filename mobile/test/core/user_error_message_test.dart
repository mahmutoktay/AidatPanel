import 'package:aidatpanel/core/network/api_exception.dart';
import 'package:aidatpanel/core/utils/api_user_message.dart';
import 'package:aidatpanel/core/utils/user_error_message.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  group('userFacingError', () {
    test('bilinmeyen hata için i18n genericError döner', () {
      expect(
        userFacingError(Exception('SocketException: Connection refused')),
        'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
      );
    });

    test('kayıtsız e-posta girişi dekont hatasına dönüşmez', () {
      expect(
        userFacingError(
          NotFoundException(
            message: 'Bu e-posta adresiyle kayıtlı hesap bulunamadı.',
          ),
        ),
        'Bu e-posta adresiyle kayıtlı hesap bulunamadı. Bilgilerinizi kontrol edin veya kayıt olun.',
      );
    });

    test('kayıtlı e-posta kayıt denemesi anlaşılır metin', () {
      expect(
        userFacingError(
          ApiException(
            message: 'Bu e-posta adresi zaten kullanılıyor.',
            statusCode: 409,
          ),
        ),
        'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.',
      );
    });

    test('409 dekont duplicate için anlaşılır metin', () {
      expect(
        userFacingError(
          ApiException(
            message: 'Bu dekont dosyası daha önce yüklenmiş.',
            statusCode: 409,
          ),
          context: ApiMessageContext.dekont,
        ),
        'Bu dekontu daha önce yüklemişsiniz. Dekontlarım bölümünden kontrol edebilirsiniz.',
      );
    });

    test('mevcut şifre hatalı', () {
      expect(
        userFacingError(
          ApiException(message: 'Mevcut şifre hatalı.', statusCode: 400),
        ),
        'Mevcut şifre hatalı.',
      );
    });

    test('zaten kullanıcı metni olan String aynen döner', () {
      expect(
        userFacingError('Ağ bağlantısı hatası'),
        'Ağ bağlantısı hatası',
      );
    });
  });

  group('wrapAsyncStateError', () {
    test('ApiException mesajı eşlenir', () {
      final original = ApiException(
        message: 'Email/telefon veya şifre hatalı.',
        statusCode: 401,
      );
      final wrapped = wrapAsyncStateError(original);
      expect(wrapped, isA<ApiException>());
      expect(
        (wrapped as ApiException).message,
        'E-posta, telefon veya şifre hatalı. Bilgilerinizi kontrol edip tekrar deneyin.',
      );
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

