import '../../../../core/network/api_exception.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../domain/entities/due_entity.dart';
import '../../domain/entities/due_remind_result.dart';
import '../../domain/entities/due_transaction_entity.dart';
import '../../domain/repositories/dues_repository.dart';
import '../datasources/dues_remote_datasource.dart';

class DuesRepositoryImpl implements DuesRepository {
  final DuesRemoteDataSource _remoteDataSource;

  DuesRepositoryImpl({required DuesRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<PaginatedListResult<DueEntity>> getBuildingDues(
    String buildingId, {
    int? month,
    int? year,
    DueStatus? status,
    String? cursor,
    bool paginated = true,
  }) async {
    try {
      final result = await _remoteDataSource.getBuildingDues(
        buildingId,
        month: month,
        year: year,
        status: status != null ? _toApiStatus(status) : null,
        cursor: cursor,
        paginated: paginated,
      );
      return PaginatedListResult(
        items: result.items.map((model) => model.toEntity()).toList(),
        nextCursor: result.nextCursor,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'building_dues_fetch_failed');
    }
  }

  @override
  Future<PaginatedListResult<DueEntity>> getMyDues({
    int? month,
    int? year,
    DueStatus? status,
    String? cursor,
    bool paginated = true,
  }) async {
    try {
      final result = await _remoteDataSource.getMyDues(
        month: month,
        year: year,
        status: status != null ? _toApiStatus(status) : null,
        cursor: cursor,
        paginated: paginated,
      );
      return PaginatedListResult(
        items: result.items.map((model) => model.toEntity()).toList(),
        nextCursor: result.nextCursor,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'my_dues_fetch_failed');
    }
  }

  @override
  Future<DueEntity> updateDueStatus({
    required String buildingId,
    required String dueId,
    required DueStatus status,
  }) async {
    try {
      final model = await _remoteDataSource.updateDueStatus(
        buildingId: buildingId,
        dueId: dueId,
        status: _toApiStatus(status),
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'due_status_update_failed');
    }
  }

  @override
  Future<void> updateBuildingDueAmount({
    required String buildingId,
    required double dueAmount,
    int? dueDay,
    String? currency,
    bool affectCurrent = false,
  }) async {
    try {
      await _remoteDataSource.updateBuildingDueAmount(
        buildingId: buildingId,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        affectCurrent: affectCurrent,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'due_amount_update_failed');
    }
  }

  @override
  Future<DueRemindResult> remindBuildingDues(
    String buildingId, {
    List<String>? dueIds,
  }) async {
    try {
      return await _remoteDataSource.remindBuildingDues(
        buildingId,
        dueIds: dueIds,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'due_reminder_failed');
    }
  }

  @override
  Future<PaginatedListResult<DueTransactionEntity>> getDueTransactions(
    String buildingId, {
    String? cursor,
    bool paginated = true,
  }) async {
    try {
      final result = await _remoteDataSource.getDueTransactions(
        buildingId,
        cursor: cursor,
        paginated: paginated,
      );
      return PaginatedListResult(
        items: result.items.map((model) => model.toEntity()).toList(),
        nextCursor: result.nextCursor,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'due_transactions_fetch_failed');
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
