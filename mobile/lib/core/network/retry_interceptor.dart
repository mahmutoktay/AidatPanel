import 'package:dio/dio.dart';

/// Transient network hataları ve 502/503/504 için exponential backoff retry.
///
/// **Kullanım:** Yalnızca `_dio` (ana HTTP client) üzerine eklenir.
/// `_uploadDio` (multipart upload) üzerine EKLENMEZ — duplicate upload riski.
///
/// Retry koşulları:
/// - HTTP 502, 503, 504 (gateway/server transient hata)
/// - Network error (statusCode == null, bağlantı yok)
/// - Max 2 retry, exponential backoff (500ms → 1000ms)
/// - FormData (multipart) istekleri RETRY EDİLMEZ
/// - Cancel edilmiş istekler RETRY EDİLMEZ
/// - Auth yazma uçları (register/login/join/otp…) RETRY EDİLMEZ —
///   sunucu isteği işlemiş ama yanıt gelmemişse tekrar kayıt "telefon
///   kullanılıyor" gibi yanıltıcı 409 üretir.
class RetryInterceptor extends Interceptor {
  static const int _maxRetries = 2;
  static const Set<int> _retryableStatuses = {502, 503, 504};
  static const Duration _baseDelay = Duration(milliseconds: 500);

  /// Tekrarlanınca yan etki / çift kayıt riski olan auth path'leri.
  static const Set<String> _nonRetryablePathFragments = {
    '/auth/register',
    '/auth/login',
    '/auth/join',
    '/auth/otp/send',
    '/auth/otp/verify',
    '/auth/otp/complete-resident-join',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/check-identifier',
  };

  final Dio _dio;

  RetryInterceptor(this._dio);

  static bool _isNonRetryableAuthWrite(RequestOptions options) {
    final method = options.method.toUpperCase();
    if (method == 'GET' || method == 'HEAD' || method == 'OPTIONS') {
      return false;
    }
    final path = options.path;
    for (final fragment in _nonRetryablePathFragments) {
      if (path.contains(fragment)) return true;
    }
    return false;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retries = err.requestOptions.extra['_retries'] as int? ?? 0;
    final statusCode = err.response?.statusCode;

    final isRetryable =
        retries < _maxRetries &&
        (statusCode == null || _retryableStatuses.contains(statusCode)) &&
        err.type != DioExceptionType.cancel &&
        err.requestOptions.data is! FormData &&
        !_isNonRetryableAuthWrite(err.requestOptions);

    if (!isRetryable) return handler.next(err);

    // Exponential backoff: 500ms, 1000ms
    final delay = _baseDelay * (retries + 1);
    await Future.delayed(delay);

    // Retry sayacını güncelle
    err.requestOptions.extra = {
      ...err.requestOptions.extra,
      '_retries': retries + 1,
    };

    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
