import '../entities/dekont_entity.dart';
import '../entities/payment_collection_entity.dart';

abstract class DekontRepository {
  Future<PaymentCollectionEntity> getPaymentCollection();

  Future<DekontEntity> uploadDekont({
    required String filePath,
    String? dueId,
  });

  Future<DekontEntity> getDekont(String id);

  Future<List<DekontEntity>> getMyDekonts({String? status});

  Future<List<DekontEntity>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
  });

  Future<DekontEntity> reviewDekont({
    required String id,
    required DekontReviewDecision decision,
    String? note,
    String? dueId,
  });

  Future<List<int>> getDekontFileBytes(String id, {bool download = false});
}
