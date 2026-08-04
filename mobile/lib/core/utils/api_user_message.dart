import '../../l10n/strings.g.dart';
import '../network/api_exception.dart';

/// API hata bağlamı — dekont modülünde öncelikli eşleştirme.
enum ApiMessageContext { general, dekont }

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

  final keyedMessage = _mapErrorKey(t, raw);
  if (keyedMessage != null) return keyedMessage;

  if (context == ApiMessageContext.dekont) {
    final dekontMsg = _mapDekont(t, raw, msg, code, error);
    if (dekontMsg != null) return dekontMsg;
  }

  if (_isTechnicalLeak(msg) || _isRouteLeak(msg)) {
    return api.serviceUnavailable;
  }

  final domain =
      _mapProfile(c, api, raw, msg, code) ??
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
    final errors = error.responseData?['errors'];
    if (errors is List && errors.isNotEmpty) {
      final messages = errors
          .map((e) => e['message']?.toString() ?? '')
          .where((m) => m.isNotEmpty)
          .join(', ');
      if (messages.isNotEmpty) return messages;
    }
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

String? _mapErrorKey(Translations t, String raw) {
  final c = t.common;
  final e = c.errorKeys;
  switch (raw) {
    case 'auth_login_failed':
      return e.authLoginFailed;
    case 'identifier_check_failed':
      return c.api.identifierCheckFailed;
    case 'auth_register_failed':
      return e.authRegisterFailed;
    case 'auth_join_failed':
      return e.authJoinFailed;
    case 'auth_logout_all_devices_failed':
      return e.authLogoutAllDevicesFailed;
    case 'auth_forgot_password_request_failed':
      return e.authForgotPasswordRequestFailed;
    case 'auth_reset_password_failed':
      return e.authResetPasswordFailed;
    case 'dashboard_summary_fetch_failed':
      return e.dashboardSummaryFetchFailed;
    case 'dashboard_collection_fetch_failed':
      return e.dashboardCollectionFetchFailed;
    case 'building_fetch_failed':
      return e.buildingFetchFailed;
    case 'collection_presets_fetch_failed':
      return e.collectionPresetsFetchFailed;
    case 'building_create_failed':
      return e.buildingCreateFailed;
    case 'building_update_failed':
      return e.buildingUpdateFailed;
    case 'building_collection_update_failed':
      return e.buildingCollectionUpdateFailed;
    case 'collection_preset_not_found':
      return e.collectionPresetNotFound;
    case 'invalid_iban':
      return c.api.invalidIban;
    case 'collection_iban_duplicate':
      return t.features.buildings.collection.ibanAlreadyExists;
    case 'collection_preset_save_failed':
      return e.collectionPresetSaveFailed;
    case 'collection_preset_delete_failed':
      return e.collectionPresetDeleteFailed;
    case 'building_delete_failed':
      return e.buildingDeleteFailed;
    case 'invite_code_create_failed':
      return e.inviteCodeCreateFailed;
    case 'apartments_fetch_failed':
      return e.apartmentsFetchFailed;
    case 'apartment_create_failed':
      return e.apartmentCreateFailed;
    case 'apartment_update_failed':
      return e.apartmentUpdateFailed;
    case 'apartment_delete_failed':
      return e.apartmentDeleteFailed;
    case 'resident_remove_failed':
      return e.residentRemoveFailed;
    case 'building_dues_fetch_failed':
      return e.buildingDuesFetchFailed;
    case 'my_dues_fetch_failed':
      return e.myDuesFetchFailed;
    case 'due_status_update_failed':
      return e.dueStatusUpdateFailed;
    case 'due_amount_update_failed':
      return e.dueAmountUpdateFailed;
    case 'due_reminder_failed':
      return e.dueReminderFailed;
    case 'my_tickets_fetch_failed':
      return e.myTicketsFetchFailed;
    case 'building_tickets_fetch_failed':
      return e.buildingTicketsFetchFailed;
    case 'ticket_detail_fetch_failed':
      return e.ticketDetailFetchFailed;
    case 'ticket_create_failed':
      return e.ticketCreateFailed;
    case 'ticket_note_add_failed':
      return e.ticketNoteAddFailed;
    case 'ticket_status_update_failed':
      return e.ticketStatusUpdateFailed;
    case 'expenses_fetch_failed':
      return e.expensesFetchFailed;
    case 'expense_summary_fetch_failed':
      return e.expenseSummaryFetchFailed;
    case 'expense_create_failed':
      return e.expenseCreateFailed;
    case 'expense_update_failed':
      return e.expenseUpdateFailed;
    case 'expense_delete_failed':
      return e.expenseDeleteFailed;
    case 'expense_receipts_upload_failed':
      return e.expenseReceiptsUploadFailed;
    case 'profile_fetch_failed':
      return e.profileFetchFailed;
    case 'profile_update_failed':
      return e.profileUpdateFailed;
    case 'language_update_failed':
      return e.languageUpdateFailed;
    case 'password_change_failed':
      return e.passwordChangeFailed;
    case 'account_delete_failed':
      return e.accountDeleteFailed;
    case 'profile_picture_upload_failed':
      return e.profilePictureUploadFailed;
    case 'profile_picture_delete_failed':
      return e.profilePictureDeleteFailed;
    case 'notification_count_fetch_failed':
      return e.notificationCountFetchFailed;
    case 'notifications_fetch_failed':
      return e.notificationsFetchFailed;
    case 'announcement_count_fetch_failed':
      return e.announcementCountFetchFailed;
    case 'notification_mark_read_failed':
      return e.notificationMarkReadFailed;
    case 'notifications_mark_all_read_failed':
      return e.notificationsMarkAllReadFailed;
    case 'announcement_send_failed':
      return e.announcementSendFailed;
    case 'sites_fetch_failed':
      return e.sitesFetchFailed;
    case 'site_detail_fetch_failed':
      return e.siteDetailFetchFailed;
    case 'site_buildings_fetch_failed':
      return e.siteBuildingsFetchFailed;
    case 'site_create_failed':
      return e.siteCreateFailed;
    case 'site_update_failed':
      return e.siteUpdateFailed;
    case 'site_collection_update_failed':
      return e.siteCollectionUpdateFailed;
    case 'site_delete_failed':
      return e.siteDeleteFailed;
    case 'site_building_create_failed':
      return e.siteBuildingCreateFailed;
    case 'site_expenses_fetch_failed':
      return e.siteExpensesFetchFailed;
    case 'site_expense_summary_fetch_failed':
      return e.siteExpenseSummaryFetchFailed;
    case 'site_expense_create_failed':
      return e.siteExpenseCreateFailed;
    case 'site_expense_update_failed':
      return e.siteExpenseUpdateFailed;
    case 'site_expense_delete_failed':
      return e.siteExpenseDeleteFailed;
    case 'subscription_fetch_failed':
      return e.subscriptionFetchFailed;
    case 'firebase_phone_invalid':
      return e.firebasePhoneInvalid;
    case 'firebase_phone_too_many':
      return e.firebasePhoneTooMany;
    case 'firebase_phone_timeout':
      return e.firebasePhoneTimeout;
    case 'firebase_phone_session_expired':
      return e.firebasePhoneSessionExpired;
    case 'firebase_phone_code_invalid':
      return e.firebasePhoneCodeInvalid;
    case 'firebase_phone_failed':
      return e.firebasePhoneFailed;
    case 'firebase_phone_app_verify':
      return e.firebasePhoneAppVerify;
    case 'firebase_phone_not_enabled':
      return e.firebasePhoneNotEnabled;
    case 'firebase_phone_carrier_blocked':
      return e.firebasePhoneCarrierBlocked;
    case 'invalid_expense_response':
      return e.invalidExpenseResponse;
    case 'invalid_site_expense_response':
      return e.invalidSiteExpenseResponse;
    case 'file_empty':
      return t.features.dekont.fileEmpty;
    case 'unsupported_file_type':
      return e.unsupportedFileType;
    case 'dekont_upload_failed':
      return e.dekontUploadFailed;
    case 'server_response_unreadable':
      return e.serverResponseUnreadable;
    case 'dekont_response_missing':
      return e.dekontResponseMissing;
    case 'dekont_response_parse_failed':
      return e.dekontResponseParseFailed;
    case 'dekont_file_not_found':
      return t.features.dekont.errorFileDownload;
    case 'report_file_empty':
      return e.reportFileEmpty;
    case 'network_error':
      return c.api.networkError;
    case 'unauthorized':
      return c.api.unauthorized;
    case 'not_found':
      return c.api.notFound;
    case 'server_error':
      return c.api.serverError;
    case 'validation_error':
      return c.api.validationError;
    case 'building_not_found':
      return c.api.buildingAccessDenied;
    case 'apartment_not_found':
      return c.api.notFound;
    case 'due_not_found':
      return c.api.dueNotFound;
    case 'ticket_not_found':
      return c.api.notFound;
  }
  return null;
}

String? _mapAuth(dynamic api, String raw, String msg, int? code) {
  if (_has(raw, 'kayıtlı hesap bulunamadı') || _has(raw, 'hesap bulunamadı')) {
    if (_has(raw, 'e-posta') || _has(raw, 'email')) {
      return api.accountNotFoundEmail as String;
    }
    if (_has(raw, 'telefon')) {
      return api.accountNotFoundPhone as String;
    }
    return api.notFound as String;
  }
  if (_has(raw, 'email/telefon') ||
      (_has(raw, 'şifre hatalı') && !_has(raw, 'mevcut şifre')) ||
      _has(raw, 'invalid credentials')) {
    return api.invalidCredentials as String;
  }
  if (_has(raw, 'e-posta adresi zaten') ||
      _has(raw, 'email adresi zaten') ||
      _has(raw, 'email already')) {
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
  if (_has(raw, 'saatlik limit') ||
      _has(raw, 'çok fazla giriş denemesi') ||
      _has(raw, 'doğrulama kodu isteği') ||
      _has(raw, 'çok fazla doğrulama')) {
    return api.rateLimit as String;
  }
  return null;
}

String? _mapProfile(dynamic c, dynamic api, String raw, String msg, int? code) {
  if (_has(raw, 'mevcut şifre hatalı') || _has(raw, 'current password')) {
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
  if (_has(raw, 'en az biri mutlaka bulunmalıdır') ||
      _has(raw, 'min_contact_required')) {
    return raw;
  }
  return null;
}

String? _mapBuilding(
  dynamic c,
  dynamic api,
  String raw,
  String msg,
  int? code,
) {
  if (_has(raw, 'bu iban zaten kayıtlı')) {
    return api.recordConflict as String;
  }
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

String? _mapApartment(
  dynamic c,
  dynamic api,
  String raw,
  String msg,
  int? code,
) {
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

  if (_has(raw, 'dekont yükleme limit') ||
      _has(raw, 'çok fazla yükleme') ||
      (_has(raw, 'çok fazla') && _has(raw, 'dekont'))) {
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
      (_has(raw, 'dekont dosya') ||
          _has(raw, 'dosyası bulunamadı') ||
          (_has(raw, 'dekont') && _has(raw, 'bulunamadı')))) {
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
