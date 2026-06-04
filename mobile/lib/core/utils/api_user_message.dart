import '../../l10n/strings.g.dart';
import '../network/api_exception.dart';

/// API hata bağlamı — dekont modülünde öncelikli eşleştirme.
enum ApiMessageContext {
  general,
  dekont,
}

String _lower(String value) => value.trim().toLowerCase();

String _norm(String value) => _lower(value)
    .replaceAll('ı', 'i')
    .replaceAll('ğ', 'g')
    .replaceAll('ü', 'u')
    .replaceAll('ş', 's')
    .replaceAll('ö', 'o')
    .replaceAll('ç', 'c');

bool _has(String raw, String needle) {
  final l = _lower(raw);
  return l.contains(needle) || _norm(raw).contains(_norm(needle));
}

/// Backend `message` + HTTP kodunu hedef kitleye uygun metne çevirir.
String mapApiUserMessage(
  ApiException error, {
  ApiMessageContext context = ApiMessageContext.general,
}) {
  final t = LocaleSettings.instance.currentTranslations;
  final c = t.common;
  final api = c.api;
  final raw = error.message;
  final msg = _norm(raw);
  final code = error.statusCode;

  if (context == ApiMessageContext.dekont) {
    final dekontMsg = _mapDekont(t, raw, msg, code, error);
    if (dekontMsg != null) return dekontMsg;
  }

  if (_isTechnicalLeak(msg) || _isRouteLeak(msg)) {
    return api.serviceUnavailable;
  }

  final domain = _mapProfile(c, api, raw, msg, code) ??
      _mapAuth(api, raw, msg, code) ??
      _mapBuilding(c, api, raw, msg, code) ??
      _mapApartment(c, api, raw, msg, code) ??
      _mapTicket(api, t, raw, msg, code) ??
      _mapExpense(api, raw, msg, code) ??
      _mapNotification(api, raw, msg, code) ??
      _mapDues(api, raw, msg, code) ??
      _mapDekont(t, raw, msg, code, error);

  if (domain != null) return domain;

  if (error is NetworkException ||
      _has(raw, 'ağ bağlantısı') ||
      msg.contains('network') ||
      msg.contains('timeout') ||
      msg.contains('connection')) {
    return api.networkError;
  }

  if (error is UnauthorizedException ||
      code == 401 ||
      _has(raw, 'geçersiz token') ||
      _has(raw, 'token süresi') ||
      _has(raw, 'yetkisiz')) {
    return _has(raw, 'email') ||
            _has(raw, 'şifre') ||
            _has(raw, 'telefon') ||
            _has(raw, 'password')
        ? api.invalidCredentials
        : api.unauthorized;
  }

  if (code == 403 || _has(raw, 'yetkiniz yok') || _has(raw, 'yetki')) {
    return api.forbidden;
  }

  if (error is NotFoundException || code == 404) {
    return api.notFound;
  }

  if (error is ValidationException ||
      (code == 400 && (_has(raw, 'validasyon') || _has(raw, 'geçersiz')))) {
    return api.validationError;
  }

  if (code == 429 ||
      _has(raw, 'çok fazla istek') ||
      msg.contains('rate limit')) {
    return api.rateLimit;
  }

  if (error is ServerException ||
      code == 500 ||
      code == 502 ||
      code == 503 ||
      _has(raw, 'sunucu hatası') ||
      _has(raw, 'bir hata oluştu')) {
    return api.serverError;
  }

  if (code == 409 && _has(raw, 'zaten mevcut')) {
    return api.recordConflict;
  }

  return api.genericError;
}

String? _mapAuth(dynamic api, String raw, String msg, int? code) {
  if (_has(raw, 'email/telefon') ||
      (_has(raw, 'şifre hatalı') && !_has(raw, 'mevcut şifre')) ||
      _has(raw, 'invalid credentials')) {
    return api.invalidCredentials as String;
  }
  if (_has(raw, 'email adresi zaten') || _has(raw, 'email already')) {
    return api.duplicateEmail as String;
  }
  if (_has(raw, 'telefon numarası zaten') || _has(raw, 'phone already')) {
    return api.duplicatePhone as String;
  }
  if (_has(raw, 'geçersiz davet kodu')) {
    return api.invalidInviteCode as String;
  }
  if (_has(raw, 'davet kodu zaten kullanılmış')) {
    return api.inviteCodeUsed as String;
  }
  if (_has(raw, 'davet kodunun süresi')) {
    return api.inviteCodeExpired as String;
  }
  if (_has(raw, 'sıfırlama kodu') ||
      _has(raw, 'invalid or expired token') ||
      _has(raw, 'reset token')) {
    return api.resetTokenInvalid as String;
  }
  return null;
}

String? _mapProfile(dynamic c, dynamic api, String raw, String msg, int? code) {
  if (_has(raw, 'mevcut şifre hatalı') ||
      _has(raw, 'current password')) {
    return c.changePasswordWrongCurrent as String;
  }
  if (code == 409 &&
      (_has(raw, 'bina kayıtları') ||
          _has(raw, 'binaları silin') ||
          _has(raw, 'devredin'))) {
    return c.deleteAccountFailedManager as String;
  }
  if (_has(raw, 'telefon numarası zaten kullanılıyor')) {
    return api.duplicatePhone as String;
  }
  return null;
}

String? _mapBuilding(dynamic c, dynamic api, String raw, String msg, int? code) {
  if (_has(raw, 'geçersiz tr iban') || _has(raw, 'geçersiz iban')) {
    return api.invalidIban as String;
  }
  if (_has(raw, 'bina bulunamadı')) {
    return api.buildingAccessDenied as String;
  }
  if (msg.contains('foreign') ||
      msg.contains('p2003') ||
      (msg.contains('still') &&
          (msg.contains('apartment') || msg.contains('resident'))) ||
      (msg.contains('daire') && msg.contains('aidat')) ||
      (msg.contains('sakin') && msg.contains('aidat'))) {
    return c.buildingDeleteFailedFK as String;
  }
  return null;
}

String? _mapApartment(dynamic c, dynamic api, String raw, String msg, int? code) {
  if (_has(raw, 'kayıtlı sakin yok') || _has(raw, 'no resident')) {
    return api.apartmentNoResident as String;
  }
  if (_has(raw, 'forbidden') ||
      _has(raw, 'not the manager') ||
      (_has(raw, 'yetk') && _has(raw, 'daire'))) {
    return c.residentRemoveForbidden as String;
  }
  if (_has(raw, 'daire bulunamadı') &&
      (_has(raw, 'sakin') || _has(raw, 'çıkarma'))) {
    return c.residentRemoveNotFound as String;
  }
  if (msg.contains('foreign') ||
      msg.contains('p2003') ||
      (msg.contains('resident') && msg.contains('due')) ||
      (msg.contains('sakin') && msg.contains('aidat'))) {
    return c.apartmentDeleteFailedFK as String;
  }
  if (_has(raw, 'daire bulunamadı')) {
    return api.notFound as String;
  }
  return null;
}

String? _mapTicket(
  dynamic api,
  Translations t,
  String raw,
  String msg,
  int? code,
) {
  if (_has(raw, 'kapalı') && _has(raw, 'not eklenemez')) {
    return api.ticketClosedNote as String;
  }
  if (_has(raw, 'kapatılmış') && _has(raw, 'durumu değiştirilemez')) {
    return api.ticketClosedStatus as String;
  }
  if (_has(raw, 'geçersiz durum geçişi')) {
    return api.ticketInvalidStatus as String;
  }
  if (_has(raw, 'talep bulunamadı')) {
    return api.notFound as String;
  }
  return null;
}

String? _mapExpense(dynamic api, String raw, String msg, int? code) {
  if (_has(raw, 'gider kaydı bulunamadı')) {
    return api.expenseNotFound as String;
  }
  if (_has(raw, 'ay 1-12')) {
    return api.validationError as String;
  }
  return null;
}

String? _mapNotification(dynamic api, String raw, String msg, int? code) {
  if (_has(raw, 'bildirim bulunamadı')) {
    return api.notificationNotFound as String;
  }
  if (_has(raw, 'geçersiz') && _has(raw, 'cursor')) {
    return api.invalidCursor as String;
  }
  return null;
}

String? _mapDues(dynamic api, String raw, String msg, int? code) {
  if (_has(raw, 'aidat kaydı bulunamadı')) {
    return api.dueNotFound as String;
  }
  return null;
}

String? _mapDekont(
  Translations t,
  String raw,
  String msg,
  int? code,
  ApiException error,
) {
  final d = t.features.dekont;
  final api = t.common.api;

  if (code == 409 ||
      _has(raw, 'daha önce yüklenmiş') ||
      _has(raw, 'zaten yüklenmiş')) {
    return d.errorUploadDuplicate;
  }

  if (code == 429 ||
      _has(raw, 'çok fazla yükleme') ||
      (_has(raw, 'çok fazla') && _has(raw, 'istek'))) {
    return d.errorUploadRateLimit;
  }

  if (_has(raw, 'dosya boyutu') ||
      _has(raw, 'limiti aşıldı') ||
      (_has(raw, 'en fazla') && _has(raw, 'mb')) ||
      code == 413) {
    return d.fileTooLarge;
  }

  if (_has(raw, 'desteklenmeyen dosya')) {
    return d.invalidExtension;
  }

  if (_has(raw, 'dosya boş')) {
    return d.fileEmpty;
  }

  if (_has(raw, 'dosya içeriği') || _has(raw, 'türle uyuşmuyor')) {
    return api.fileContentMismatch;
  }

  if (_has(raw, 'geçersiz pdf')) {
    return api.invalidPdf;
  }

  if (_has(raw, 'dosya gereklidir') || _has(raw, 'dosya okunamadı')) {
    return d.errorUploadFileRequired;
  }

  if (_has(raw, 'yanıtı işlenemedi') ||
      _has(raw, 'yanıtı eksik') ||
      _has(raw, 'sunucu yanıtı okunamadı')) {
    return d.errorUploadServer;
  }

  if (_has(raw, 'dekont yüklenemedi') ||
      (_has(raw, 'yüklenemedi') && _has(raw, 'tekrar deneyin'))) {
    return d.errorUploadServer;
  }

  if (_has(raw, 'kaydedilemedi') ||
      (_has(raw, 'yüklenemedi') && _has(raw, 'dekont')) ||
      (_has(raw, 'sunucuya') && _has(raw, 'kaydedilemedi'))) {
    return d.errorUploadServer;
  }

  if (_has(raw, 'ödeme zaten işlenmiş')) {
    return d.errorReviewPaymentDone;
  }

  if (_has(raw, 'reddedilmiş dekont')) {
    return d.errorReviewRejected;
  }

  if (_has(raw, 'dueid') || _has(raw, 'onay için')) {
    return d.errorReviewNeedDue;
  }

  if (_has(raw, 'reddedilemez') ||
      _has(raw, 'onaylanamaz') ||
      msg.contains('pipeline')) {
    return d.errorReviewStatus;
  }

  if (_has(raw, 'dosyası bulunamadı') ||
      _has(raw, 'henüz hazırlanıyor') ||
      _has(raw, 'henüz hazirlaniyor')) {
    return d.errorFileDownload;
  }

  if (_has(raw, 'dekont bulunamadı')) {
    return api.dekontNotFound;
  }

  if (_has(raw, 'yeniden yükleyin') ||
      (_has(raw, 'kaydedilememiş') && _has(raw, 'dekont'))) {
    return d.errorUploadServer;
  }

  if (_has(raw, 'daire ataması gerekli') ||
      _has(raw, 'daire kaydınız bulunmuyor')) {
    return api.noApartmentForPayment;
  }

  if (code == 503) {
    return d.errorFileDownload;
  }

  if (code == 502 ||
      (code != null && code >= 500 && _has(raw, 'dekont yüklenemedi'))) {
    return d.errorUploadServer;
  }

  if (code == 404 &&
      (_has(raw, 'dosya') ||
          _has(raw, 'dekont') ||
          _has(raw, 'bulunamadı'))) {
    return d.errorFileDownload;
  }

  if (error is NetworkException) {
    return api.networkError;
  }

  return null;
}

bool _isTechnicalLeak(String msg) {
  return msg.contains('exception') ||
      msg.contains('stack') ||
      msg.contains('socket') ||
      msg.contains('dio') ||
      msg.contains('type ') ||
      msg.startsWith('failed host lookup') ||
      msg.contains('prisma');
}

bool _isRouteLeak(String msg) {
  return (msg.contains('route') &&
          (msg.contains('not found') || msg.contains('bulunamad'))) ||
      msg.contains('route bulunamad');
}

bool isDekontDuplicateError(ApiException e) {
  return e.statusCode == 409 ||
      _has(e.message, 'daha önce yüklenmiş') ||
      _has(e.message, 'zaten yüklenmiş');
}

