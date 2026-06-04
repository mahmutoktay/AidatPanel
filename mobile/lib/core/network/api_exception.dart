class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? originalException;

  /// Sunucu JSON gövdesi (`success`, `message`, `data`) — 409 duplicate vb.
  final Map<String, dynamic>? responseData;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalException,
    this.responseData,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Ağ bağlantısı hatası'});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    super.message = 'Yetkisiz erişim',
    super.responseData,
  }) : super(statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException({
    super.message = 'Kaynak bulunamadı',
    super.responseData,
  }) : super(statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({
    super.message = 'Sunucu hatası',
    super.responseData,
    int? statusCode,
  }) : super(statusCode: statusCode ?? 500);
}

class ValidationException extends ApiException {
  ValidationException({
    super.message = 'Doğrulama hatası',
    super.responseData,
  }) : super(statusCode: 422);
}

