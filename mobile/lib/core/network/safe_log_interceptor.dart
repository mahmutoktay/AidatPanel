import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

/// Debug-only log; hassas endpoint body/response'larını maskeler.
/// KVKK: şifre, token, email, telefon, IBAN, ödeme referansı loglanmaz.
class SafeLogInterceptor extends Interceptor {
  /// Hassas path'leri içerir. Statik string eşleşmelerin yanı sıra
  /// dinamik segment değişkenleri (ör. /dekonts/{id}/review) de `_sensitivePathMatchers`
  /// ile regex eşleşmesine tabi tutulur.
  static const _sensitivePaths = {
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.join,
    ApiConstants.refresh,
    ApiConstants.resetPassword,
    ApiConstants.forgotPassword,
    ApiConstants.changePassword,
    ApiConstants.profile,
    ApiConstants.profilePicture,
    ApiConstants.fcmToken,
    ApiConstants.myPaymentCollection,
    ApiConstants.sessions,
    ApiConstants.myDekonts,
    ApiConstants.dekontUpload,
    ApiConstants.myExpenses,
    ApiConstants.myDues,
    ApiConstants.myTickets,
    ApiConstants.notifications,
    ApiConstants.notificationsUnreadCount,
    ApiConstants.notificationsReadAll,
    ApiConstants.subscription,
  };

  /// Dinamik endpoint eşleşmeleri — ID, binaID gibi değişken segmentler içeren yollar.
  /// Örn: /dekonts/{id}, /dekonts/{id}/file, /dekonts/{id}/review,
  ///      /buildings/{id}/dekonts, /buildings/{id}/expenses, /buildings/{id}/expenses/summary,
  ///      /expenses/{id}/proof, /notifications/{id}/read, /me/sessions/{id}
  static final List<RegExp> _sensitivePathMatchers = [
    RegExp(r'/dekonts/[^/]+(/file|/review)?$'),
    RegExp(r'/buildings/[^/]+/(dekonts|expenses|expenses/summary|dues|tickets|announcements|dashboard-summary|collection|reports)$'),
    RegExp(r'/buildings/[^/]+/(apartments|dues/[^/]+/status)$'),
    RegExp(r'/expenses/[^/]+(/proof|/file|/file/[^/]+)?$'),
    RegExp(r'/notifications/[^/]+/read$'),
    RegExp(r'/me/sessions/[^/]+$'),
    RegExp(r'/sites/[^/]+/(expenses|expenses/summary|buildings|collection|aggregation|reports)$'),
    RegExp(r'/tickets/[^/]+(/updates|/status)?$'),
  ];

  static const _redactedKeys = {
    'password',
    'currentPassword',
    'newPassword',
    'refreshToken',
    'accessToken',
    'token',
    'email',
    'phone',
    'fcmToken',
    'collectionIban',
    'collectionAccountTitle',
    'paymentReference',
    'paymentReferenceTemplate',
    'iban',
  };

  static bool _isSensitivePath(String path) {
    if (_sensitivePaths.any((p) => path.endsWith(p))) return true;
    for (final pattern in _sensitivePathMatchers) {
      if (pattern.hasMatch(path)) return true;
    }
    return false;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final sensitive = _isSensitivePath(options.path);
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
      final sensitive = _isSensitivePath(response.requestOptions.path);
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

  /// Recursive redaction — iç içe Map/List yapılarında da hassas alanlar maskelenir.
  static String _safeData(dynamic data) {
    return _redactRecursive(data);
  }

  static String _redactRecursive(dynamic value) {
    if (value is Map) {
      final copy = <String, dynamic>{};
      for (final entry in value.entries) {
        final key = entry.key.toString();
        copy[key] = _redactedKeys.contains(key)
            ? '***'
            : _redactRecursive(entry.value);
      }
      return copy.toString();
    }
    if (value is List) {
      return value.map((e) => _redactRecursive(e)).toList().toString();
    }
    return value.toString();
  }
}
