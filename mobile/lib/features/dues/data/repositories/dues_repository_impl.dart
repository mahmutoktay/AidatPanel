import '../../../../core/network/api_exception.dart';
import '../../domain/entities/due_entity.dart';
import '../../domain/repositories/dues_repository.dart';
import '../datasources/dues_remote_datasource.dart';

class DuesRepositoryImpl implements DuesRepository {
  final DuesRemoteDataSource _remoteDataSource;

  DuesRepositoryImpl({required DuesRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<DueEntity>> getBuildingDues(String buildingId) async {
    try {
      final models = await _remoteDataSource.getBuildingDues(buildingId);
      return models.map((model) => model.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Aidat listesi alınırken bir hata oluştu');
    }
  }

  @override
  Future<List<DueEntity>> getApartmentDues(String apartmentId) async {
    try {
      final models = await _remoteDataSource.getApartmentDues(apartmentId);
      return models.map((model) => model.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Daire aidatları alınırken bir hata oluştu');
    }
  }

  @override
  Future<List<DueEntity>> getMyDues() async {
    try {
      final models = await _remoteDataSource.getMyDues();
      return models.map((model) => model.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Aidatlarınız alınırken bir hata oluştu');
    }
  }

  @override
  Future<DueEntity> updateDueStatus({
    required String dueId,
    required DueStatus status,
  }) async {
    try {
      final model = await _remoteDataSource.updateDueStatus(
        dueId: dueId,
        status: _toApiStatus(status),
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Aidat durumu güncellenirken bir hata oluştu');
    }
  }

  @override
  Future<List<DueEntity>> createBulkDues({
    required String buildingId,
    required double amount,
    required int month,
    required int year,
    String currency = 'TRY',
    String? note,
  }) async {
    try {
      final models = await _remoteDataSource.createBulkDues(
        buildingId: buildingId,
        amount: amount,
        month: month,
        year: year,
        currency: currency,
        note: note,
      );
      return models.map((model) => model.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Toplu aidat oluşturulurken bir hata oluştu');
    }
  }

  String _toApiStatus(DueStatus status) {
    switch (status) {
      case DueStatus.paid:
        return 'PAID';
      case DueStatus.overdue:
        return 'OVERDUE';
      case DueStatus.waived:
        return 'WAIVED';
      case DueStatus.pending:
        return 'PENDING';
    }
  }
}
