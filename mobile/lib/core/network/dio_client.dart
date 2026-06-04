import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import '../utils/jwt_utils.dart';
import 'api_exception.dart';
import 'safe_log_interceptor.dart';
import 'token_refresh_service.dart';

class DioClient {
  late Dio _dio;
  late Dio _refreshDio;
  late TokenRefreshService _tokenRefresh;
  final SecureStorage _secureStorage;
  final SessionExpiredCallback? Function()? onSessionExpiredGetter;

  final Map<String, ({Response<dynamic> response, DateTime expiry})> _cache = {};

  /// `logout-all-devices` vb. sırasında paralel 401'lerin eski refresh ile
  /// clearAuth tetiklemesini engeller.
  int _sessionMutationDepth = 0;

  bool get _blockRefreshOn401 => _sessionMutationDepth > 0;

  /// Oturum token çifti değişirken 401 interceptor refresh'i kapalı tutar.
  void beginSessionMutation() {
    _sessionMutationDepth++;
    _cache.clear();
  }

  void endSessionMutation() {
    if (_sessionMutationDepth > 0) {
      _sessionMutationDepth--;
    }
    _cache.clear();
  }

  /// Giriş / çıkış sonrası önceki oturumun GET önbelleğini temizler.
  void clearResponseCache() => _cache.clear();

  Future<String> _getCacheKey(
    String path,
    Map<String, dynamic>? queryParameters,
  ) async {
    final token = await _secureStorage.getToken();
    final session = JwtUtils.sessionCacheSuffix(token);
    return '$session|$path?${queryParameters?.toString() ?? ''}';
  }

  DioClient({required SecureStorage secureStorage, this.onSessionExpiredGetter})
    : _secureStorage = secureStorage {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        contentType: 'application/json',
      ),
    );

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        contentType: 'application/json',
      ),
    );

    _tokenRefresh = TokenRefreshService(
      refreshDio: _refreshDio,
      secureStorage: _secureStorage,
      onSessionExpiredGetter: onSessionExpiredGetter,
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(SafeLogInterceptor());
    }
  }

  static const _publicPaths = {
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.join,
    ApiConstants.refresh,
    ApiConstants.forgotPassword,
    ApiConstants.resetPassword,
  };

  bool _isPublicPath(String path) => _publicPaths.any((p) => path.endsWith(p));

  Future<String?> _ensureValidAccessToken() async {
    var token = await _secureStorage.getToken();

    // Access yok ama refresh var → önce yenile (FCM upload iptal olmasın).
    if (token == null || token.isEmpty) {
      final refreshed = await _tokenRefresh.refreshAndPersist();
      return refreshed?.accessToken;
    }

    if (!await _secureStorage.needsTokenRefresh()) {
      return token;
    }

    final refreshed = await _tokenRefresh.refreshAndPersist();
    return refreshed?.accessToken;
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicPath(options.path)) {
      return handler.next(options);
    }

    final token = await _ensureValidAccessToken();
    if (token == null || token.isEmpty) {
      return handler.next(options);
    }

    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    return handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final requestPath = error.requestOptions.path;
    final isPublicAuthRequest = _isPublicPath(requestPath);

    if (error.response?.statusCode == 401 &&
        !_blockRefreshOn401 &&
        !isPublicAuthRequest) {
      // Multipart gövdesi tek kullanımlık — 401 sonrası aynı FormData ile retry takılır.
      if (error.requestOptions.data is FormData) {
        return handler.reject(error);
      }

      final refreshed = await _tokenRefresh.refreshAndPersist();
      if (refreshed != null) {
        final opts = error.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
        try {
          final retryResponse = await _dio.request<dynamic>(
            opts.path,
            options: Options(method: opts.method, headers: opts.headers),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );
          return handler.resolve(retryResponse);
        } on DioException catch (retryError) {
          return handler.reject(retryError);
        }
      }

      return handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          error: 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
          type: DioExceptionType.cancel,
        ),
      );
    }

    return handler.reject(error);
  }

  bool _shouldCacheGet(String path, ResponseType? responseType) {
    if (responseType == ResponseType.bytes) return false;
    if (path.contains('/dekonts') || path.contains('/me/dekonts')) {
      return false;
    }
    return true;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final responseType = options?.responseType ?? ResponseType.json;
    final useCache = _shouldCacheGet(path, responseType);
    final cacheKey = await _getCacheKey(path, queryParameters);
    if (useCache) {
      final cached = _cache[cacheKey];
      if (cached != null && DateTime.now().isBefore(cached.expiry)) {
        if (cached.response is Response<T>) {
          return cached.response as Response<T>;
        }
      }
    }

    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      if (useCache &&
          response.statusCode == 200 &&
          responseType != ResponseType.bytes) {
        _cache[cacheKey] = (
          response: response,
          expiry: DateTime.now().add(const Duration(seconds: 30)),
        );
      }
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData data,
    FormData Function()? rebuildFormData,
    Map<String, dynamic>? queryParameters,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) async {
    const defaultUploadTimeout = Duration(minutes: 3);
    final effectiveSend = sendTimeout ?? defaultUploadTimeout;
    final effectiveReceive = receiveTimeout ?? defaultUploadTimeout;

    await _ensureValidAccessToken();

    try {
      return await _postMultipartOnce<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        effectiveSend: effectiveSend,
        effectiveReceive: effectiveReceive,
      );
    } on DioException catch (e) {
      final canRetry401 = e.response?.statusCode == 401 &&
          !_blockRefreshOn401 &&
          rebuildFormData != null;
      if (!canRetry401) {
        throw _handleException(e);
      }
      final refreshed = await _tokenRefresh.refreshAndPersist();
      if (refreshed == null) {
        throw _handleException(e);
      }
      try {
        return await _postMultipartOnce<T>(
          path,
          data: rebuildFormData(),
          queryParameters: queryParameters,
          effectiveSend: effectiveSend,
          effectiveReceive: effectiveReceive,
          accessToken: refreshed.accessToken,
        );
      } on DioException catch (retryError) {
        throw _handleException(retryError);
      }
    }
  }

  Future<Response<T>> _postMultipartOnce<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    required Duration effectiveSend,
    required Duration effectiveReceive,
    String? accessToken,
  }) async {
    final prevReceive = _dio.options.receiveTimeout;
    final prevSend = _dio.options.sendTimeout;
    final prevConnect = _dio.options.connectTimeout;
    _cache.clear();
    try {
      _dio.options.receiveTimeout = effectiveReceive;
      _dio.options.sendTimeout = effectiveSend;
      _dio.options.connectTimeout = effectiveReceive;
      final headers = <String, dynamic>{};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: effectiveSend,
          receiveTimeout: effectiveReceive,
          connectTimeout: effectiveReceive,
          responseType: ResponseType.json,
          headers: headers.isEmpty ? null : headers,
        ),
      );
    } finally {
      _dio.options.receiveTimeout = prevReceive;
      _dio.options.sendTimeout = prevSend;
      _dio.options.connectTimeout = prevConnect;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _cache.clear();
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _cache.clear();
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _cache.clear();
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _cache.clear();
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  ApiException _handleException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException();
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = _extractResponseMap(error.response!.data);
      final message = _extractErrorMessage(error.response!.data);

      switch (statusCode) {
        case 401:
          return UnauthorizedException(
            message: message,
            responseData: responseData,
          );
        case 404:
          return NotFoundException(
            message: message,
            responseData: responseData,
          );
        case 422:
          return ValidationException(
            message: message,
            responseData: responseData,
          );
        case 500:
        case 502:
        case 503:
          return ServerException(
            message: message,
            responseData: responseData,
            statusCode: statusCode,
          );
        default:
          return ApiException(
            message: message,
            statusCode: statusCode,
            responseData: responseData,
          );
      }
    }

    return NetworkException();
  }

  Map<String, dynamic>? _extractResponseMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    if (data is List<int> && data.isNotEmpty && data.first == 0x7b) {
      try {
        final decoded = jsonDecode(utf8.decode(data));
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  String _extractErrorMessage(dynamic data) {
    const fallback = 'Bir hata oluştu';

    if (data is List<int>) {
      if (data.isEmpty) return fallback;
      if (data.first == 0x7b || data.first == 0x5b) {
        try {
          final decoded = jsonDecode(utf8.decode(data));
          if (decoded is Map<String, dynamic>) {
            return _extractErrorMessage(decoded);
          }
        } catch (_) {
          return fallback;
        }
      }
      return fallback;
    }

    if (data is Map<String, dynamic>) {
      final direct = data['message'];
      if (direct is String && direct.trim().isNotEmpty) {
        return direct;
      }
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map) {
          final nested = first['message'];
          if (nested is String && nested.trim().isNotEmpty) {
            return nested;
          }
        }
      }
      return fallback;
    }

    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return _extractErrorMessage(decoded);
        }
      } catch (_) {
        if (data.length < 200 && !data.contains('<html')) {
          return data;
        }
      }
    }

    return fallback;
  }
}
