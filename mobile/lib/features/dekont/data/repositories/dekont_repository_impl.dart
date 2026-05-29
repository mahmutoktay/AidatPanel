import '../../../../core/network/api_exception.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/payment_collection_entity.dart';
import '../../domain/repositories/dekont_repository.dart';
import '../datasources/dekont_remote_datasource.dart';

class DekontRepositoryImpl implements DekontRepository {
  final DekontRemoteDataSource _remote;

  DekontRepositoryImpl({required DekontRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<PaymentCollectionEntity> getPaymentCollection() async {
    try {
      return (await _remote.getPaymentCollection()).toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Ödeme bilgileri alınamadı: $e');
    }
  }

  @override
  Future<DekontEntity> uploadDekont({
    required String filePath,
    String? dueId,
  }) async {
    try {
      return (await _remote.uploadDekont(filePath: filePath, dueId: dueId))
          .toEntity();
    } on ApiException catch (e) {
      throw ApiException(
        message: _humanizeFromApi(e),
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw ApiException(message: 'Dekont yüklenemedi: $e');
    }
  }

  @override
  Future<DekontEntity> getDekont(String id) async {
    try {
      return (await _remote.getDekont(id)).toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Dekont detayı alınamadı: $e');
    }
  }

  @override
  Future<List<DekontEntity>> getMyDekonts({String? status}) async {
    try {
      final list = await _remote.getMyDekonts(status: status);
      return list.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Dekont listesi alınamadı: $e');
    }
  }

  @override
  Future<List<DekontEntity>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
  }) async {
    try {
      final list = await _remote.getBuildingDekonts(
        buildingId,
        status: status,
        apartmentId: apartmentId,
      );
      return list.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Bina dekontları alınamadı: $e');
    }
  }

  @override
  Future<DekontEntity> reviewDekont({
    required String id,
    required DekontReviewDecision decision,
    String? note,
    String? dueId,
  }) async {
    try {
      final apiDecision =
          decision == DekontReviewDecision.approve ? 'APPROVE' : 'REJECT';
      return (await _remote.reviewDekont(
        id: id,
        decision: apiDecision,
        note: note,
        dueId: dueId,
      ))
          .toEntity();
    } on ApiException catch (e) {
      throw ApiException(
        message: _humanizeFromApi(e),
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw ApiException(message: 'İnceleme kaydedilemedi: $e');
    }
  }

  @override
  Future<List<int>> getDekontFileBytes(String id, {bool download = false}) async {
    try {
      return await _remote.getDekontFileBytes(id, download: download);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Dosya indirilemedi: $e');
    }
  }

  String _humanizeFromApi(ApiException e) {
    final code = e.statusCode;
    final msg = e.message.toLowerCase();
    if (code == 409) {
      if (msg.contains('hash') || msg.contains('duplicate')) {
        return 'Bu dekont daha önce yüklenmiş';
      }
      return 'Bu dekont zaten işlenmiş';
    }
    if (code == 429) {
      return 'Çok fazla yükleme yaptınız. Lütfen bir süre sonra tekrar deneyin';
    }
    if (code == 400 && msg.contains('dueid')) {
      return 'Onay için aidat seçimi gerekli';
    }
    return e.message;
  }
}
