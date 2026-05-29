import '../../domain/entities/building_entity.dart';
import '../../domain/entities/collection_preset_entity.dart';
import '../../domain/entities/saved_iban_delete_result.dart';

abstract class BuildingRepository {
  Future<List<BuildingEntity>> fetchBuildings();
  Future<List<CollectionPresetEntity>> fetchCollectionPresets();
  Future<BuildingEntity> createBuilding({
    required String name,
    required String address,
    required String city,
    int? totalFloors,
    int? apartmentsPerFloor,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  });
  Future<BuildingEntity> updateBuilding({
    required String id,
    String? name,
    String? address,
    String? city,
  });
  Future<BuildingEntity> patchBuildingCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    required String? paymentReferenceTemplate,
  });

  /// [matchIban] ile eşleşen tüm binaların tahsilat alanlarını günceller.
  /// Dönen değer: güncellenen bina sayısı (0 = yalnızca mock öneri kaydı).
  Future<int> patchBuildingsMatchingCollection({
    required String matchIban,
    required String? collectionIban,
    required String? collectionAccountTitle,
    required String? paymentReferenceTemplate,
  });

  Future<CollectionPresetEntity> addCollectionPreset({
    required String collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  });

  Future<SavedIbanDeleteResult> deleteCollectionPreset({
    required String matchIban,
  });

  Future<SavedIbanBulkDeleteResult> deleteCollectionPresets({
    required List<String> matchIbans,
  });

  Future<void> deleteBuilding(String id);
}
