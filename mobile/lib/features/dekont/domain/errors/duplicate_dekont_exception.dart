import '../../../../core/network/api_exception.dart';
import '../entities/dekont_entity.dart';

/// 409 — aynı dosya hash'i ile dekont zaten kayıtlı.
class DuplicateDekontException extends ApiException {
  final DekontEntity dekont;

  DuplicateDekontException({
    required this.dekont,
    required super.message,
    super.responseData,
  }) : super(statusCode: 409);
}
