import '../entities/due_entity.dart';

abstract class DuesRepository {
  Future<List<DueEntity>> getBuildingDues(String buildingId);
  Future<List<DueEntity>> getMyDues();
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
}
