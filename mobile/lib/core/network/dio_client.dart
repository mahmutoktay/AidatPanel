import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';
import 'safe_log_interceptor.dart';
import 'token_refresh_service.dart';

class DioClient {
  late Dio _dio;
  late Dio _refreshDio;
  late TokenRefreshService _tokenRefresh;
  final SecureStorage _secureStorage;

  DioClient({required SecureStorage secureStorage})
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

  bool _isPublicPath(String path) =>
      _publicPaths.any((p) => path.endsWith(p));

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

    if (error.response?.statusCode == 401 && !isPublicAuthRequest) {
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

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
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
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkException();
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;

      String message = 'Bir hata oluştu';
      try {
        if (error.response!.data is Map<String, dynamic>) {
          message = error.response!.data['message'] as String? ?? message;
        }
      } catch (_) {}

      switch (statusCode) {
        case 401:
          return UnauthorizedException(message: message);
        case 404:
          return NotFoundException(message: message);
        case 422:
          return ValidationException(message: message);
        case 500:
          return ServerException(message: message);
        default:
          return ApiException(message: message, statusCode: statusCode);
      }
    }

    return NetworkException();
  }
}
