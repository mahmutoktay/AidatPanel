import '../entities/due_entity.dart';

abstract class DuesRepository {
  Future<List<DueEntity>> getBuildingDues(String buildingId);
  Future<List<DueEntity>> getApartmentDues(String apartmentId);
  Future<List<DueEntity>> getMyDues();
  Future<DueEntity> updateDueStatus({
    required String dueId,
    required DueStatus status,
  });
  Future<List<DueEntity>> createBulkDues({
    required String buildingId,
    required double amount,
    required int month,
    required int year,
    String currency,
    String? note,
  });
}
