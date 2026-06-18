import '../../../../core/network/paginated_list_result.dart';
import '../entities/due_entity.dart';
import '../entities/due_remind_result.dart';

abstract class DuesRepository {
  /// Tur 5 / §10/3 — server-side filtreleme.
  /// Tüm parametreler opsiyonel; null geçilirse sunucu tüm dues'u döner.
  Future<PaginatedListResult<DueEntity>> getBuildingDues(
    String buildingId, {
    int? month,
    int? year,
    DueStatus? status,
    String? cursor,
    bool paginated = true,
  });

  Future<PaginatedListResult<DueEntity>> getMyDues({
    int? month,
    int? year,
    DueStatus? status,
    String? cursor,
    bool paginated = true,
  });

  Future<DueEntity> updateDueStatus({
    required String buildingId,
    required String dueId,
    required DueStatus status,
  });
  Future<void> updateBuildingDueAmount({
    required String buildingId,
    required double dueAmount,
    int? dueDay,
    String? currency,
    bool affectCurrent = false,
  });
  Future<DueRemindResult> remindBuildingDues(
    String buildingId, {
    List<String>? dueIds,
  });
}
