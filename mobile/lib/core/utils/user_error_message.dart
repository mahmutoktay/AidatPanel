import '../../l10n/strings.g.dart';
import '../network/api_exception.dart';

/// Kullanıcıya gösterilecek hata metni — teknik [toString] sızdırmaz.
String userFacingError(Object error) {
  if (error is ApiException) return error.message;
  return LocaleSettings.instance.currentTranslations.common.unexpectedError;
}

/// [AsyncValue.error] için güvenli exception — UI `userFacingError` ile uyumlu.
Object wrapAsyncStateError(Object error) {
  if (error is ApiException) return error;
  return ApiException(message: userFacingError(error));
}