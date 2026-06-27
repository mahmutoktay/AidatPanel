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
  NetworkException({super.message = 'network_error'});
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'unauthorized', super.responseData})
    : super(statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException({super.message = 'not_found', super.responseData})
    : super(statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({
    super.message = 'server_error',
    super.responseData,
    int? statusCode,
  }) : super(statusCode: statusCode ?? 500);
}

class ValidationException extends ApiException {
  ValidationException({super.message = 'validation_error', super.responseData})
    : super(statusCode: 422);
}
