import 'package:aidatpanel/core/network/api_exception.dart';
import 'package:aidatpanel/core/utils/api_user_message.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  group('mapApiUserMessage', () {
    test('409 duplicate dekont', () {
      expect(
        mapApiUserMessage(
          ApiException(
            message: 'Bu dekont dosyası daha önce yüklenmiş.',
            statusCode: 409,
          ),
          context: ApiMessageContext.dekont,
        ),
        'Bu dekontu daha önce yüklemişsiniz. Dekontlarım bölümünden kontrol edebilirsiniz.',
      );
    });

    test('giriş bilgileri hatalı', () {
      expect(
        mapApiUserMessage(
          ApiException(
            message: 'Email/telefon veya şifre hatalı.',
            statusCode: 401,
          ),
        ),
        'E-posta, telefon veya şifre hatalı. Bilgilerinizi kontrol edip tekrar deneyin.',
      );
    });

    test('bina silme FK', () {
      expect(
        mapApiUserMessage(
          ApiException(message: 'Foreign key constraint failed', statusCode: 409),
        ),
        'Bu binayı silemezsiniz: hâlâ daire, sakin veya aidat kayıtları var. Önce daireleri/aidatları temizleyip tekrar deneyin.',
      );
    });

    test('kapalı talep notu', () {
      expect(
        mapApiUserMessage(
          ApiException(
            message: 'Kapalı veya sonuçlanmış talebe not eklenemez.',
            statusCode: 409,
          ),
        ),
        'Kapalı veya sonuçlanmış talebe not eklenemez.',
      );
    });

    test('production generic sunucu metni', () {
      expect(
        mapApiUserMessage(
          ApiException(message: 'Bir hata oluştu', statusCode: 500),
        ),
        'Sunucuya ulaşılamadı. Lütfen biraz sonra tekrar deneyin.',
      );
    });

    test('production dekont upload metni', () {
      expect(
        mapApiUserMessage(
          ApiException(
            message: 'Dekont yüklenemedi. Lütfen tekrar deneyin.',
            statusCode: 500,
          ),
          context: ApiMessageContext.dekont,
        ),
        'Dekont sunucuya kaydedilemedi. Lütfen biraz sonra tekrar deneyin.',
      );
    });

    test('teknik route metni gizlenir', () {
      expect(
        mapApiUserMessage(
          ApiException(
            message: 'Route bulunamadı: POST /api/v1/tickets',
            statusCode: 404,
          ),
        ),
        'İşlem şu an yapılamıyor. Lütfen biraz sonra tekrar deneyin.',
      );
    });

    test('OTP rate limit dekont metnine dönüşmez', () {
      expect(
        mapApiUserMessage(
          ApiException(
            message:
                'Bu işlem için saatlik limit aşıldı. Lütfen daha sonra tekrar deneyin.',
            statusCode: 429,
          ),
        ),
        'Çok fazla deneme yaptınız. Lütfen kısa süre bekleyip tekrar deneyin.',
      );
    });

    test('dekont yükleme rate limit', () {
      expect(
        mapApiUserMessage(
          ApiException(
            message: 'Dekont yükleme limitine ulaştınız. Lütfen bir saat sonra tekrar deneyin.',
            statusCode: 429,
          ),
        ),
        'Kısa sürede çok fazla dekont yüklediniz. Lütfen bir süre bekleyin.',
      );
    });
  });
}
