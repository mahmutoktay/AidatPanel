import '../../../../core/network/paginated_list_result.dart';
import '../entities/dekont_entity.dart';
import '../entities/dekont_upload_result.dart';
import '../entities/payment_collection_entity.dart';

abstract class DekontRepository {
  Future<PaymentCollectionEntity> getPaymentCollection();

  Future<DekontUploadResult> uploadDekont({
    required String fileName,
    required List<int> fileBytes,
    String? filePath,
    String? dueId,
    List<String>? dueIds,
  });

  Future<DekontEntity> getDekont(String id);

  Future<PaginatedListResult<DekontEntity>> getMyDekonts({
    String? status,
    String? cursor,
    bool paginated = true,
  });

  Future<PaginatedListResult<DekontEntity>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
    String? cursor,
    bool paginated = true,
  });

  Future<DekontEntity> reviewDekont({
    required String id,
    required DekontReviewDecision decision,
    String? note,
    String? dueId,
    List<String>? dueIds,
    double? amount,
  });

  Future<List<int>> getDekontFileBytes(String id, {bool download = false});
}
