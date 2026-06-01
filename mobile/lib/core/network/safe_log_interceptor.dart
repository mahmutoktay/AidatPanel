import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

/// Debug-only log; auth gövdelerinde şifre/token alanlarını maskele.
class SafeLogInterceptor extends Interceptor {
  static const _sensitivePaths = {
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.join,
    ApiConstants.refresh,
    ApiConstants.resetPassword,
    ApiConstants.forgotPassword,
  };

  static const _redactedKeys = {
    'password',
    'refreshToken',
    'accessToken',
    'token',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final sensitive = _sensitivePaths.any((p) => options.path.endsWith(p));
      debugPrint(
        '[DIO] → ${options.method} ${options.uri}'
        '${sensitive ? ' (body redacted)' : ''}',
      );
      if (!sensitive && options.data != null) {
        debugPrint('[DIO] req: ${_safeData(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[DIO] ← ${response.statusCode} ${response.requestOptions.uri}');
      final sensitive =
          _sensitivePaths.any((p) => response.requestOptions.path.endsWith(p));
      if (!sensitive && response.data != null) {
        debugPrint('[DIO] res: ${_safeData(response.data)}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[DIO] ✗ ${err.requestOptions.method} ${err.requestOptions.uri}'
        ' ${err.response?.statusCode ?? err.type}',
      );
    }
    handler.next(err);
  }

  static String _safeData(dynamic data) {
    if (data is Map) {
      final copy = <String, dynamic>{};
      for (final entry in data.entries) {
        final key = entry.key.toString();
        copy[key] = _redactedKeys.contains(key) ? '***' : entry.value;
      }
      return copy.toString();
    }
    return data.toString();
  }
}
