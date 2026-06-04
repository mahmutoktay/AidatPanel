import '../../l10n/strings.g.dart';
import '../network/api_exception.dart';
import 'api_user_message.dart';

/// Kullanıcıya gösterilecek hata metni — teknik [toString] sızdırmaz.
String userFacingError(
  Object error, {
  ApiMessageContext context = ApiMessageContext.general,
}) {
  if (error is ApiException) {
    return mapApiUserMessage(error, context: context);
  }
  if (error is String) return error;
  return LocaleSettings.instance.currentTranslations.common.api.genericError;
}

/// [AsyncValue.error] için güvenli exception — UI `userFacingError` ile uyumlu.
Object wrapAsyncStateError(
  Object error, {
  ApiMessageContext context = ApiMessageContext.general,
}) {
  if (error is ApiException) {
    return ApiException(
      message: mapApiUserMessage(error, context: context),
      statusCode: error.statusCode,
      originalException: error.originalException,
    );
  }
  return ApiException(message: userFacingError(error, context: context));
}
