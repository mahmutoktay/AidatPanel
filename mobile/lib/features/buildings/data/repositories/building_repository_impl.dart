import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../domain/entities/building_entity.dart';
import '../../domain/entities/collection_preset_entity.dart';
import '../../domain/entities/saved_iban_delete_result.dart';
import '../datasources/building_remote_datasource.dart';
import 'building_repository.dart';

class BuildingRepositoryImpl implements BuildingRepository {
  final BuildingRemoteDataSource _remoteDataSource;

  BuildingRepositoryImpl({required BuildingRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<BuildingEntity>> fetchBuildings() async {
    try {
      final models = await _remoteDataSource.fetchBuildings();
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Binalar yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<List<CollectionPresetEntity>> fetchCollectionPresets() async {
    try {
      final models = await _remoteDataSource.fetchCollectionPresets();
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Tahsilat önerileri yüklenirken hata oluştu: $e',
      );
    }
  }

  @override
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
  }) async {
    try {
      final model = await _remoteDataSource.createBuilding(
        name: name,
        address: address,
        city: city,
        totalFloors: totalFloors,
        apartmentsPerFloor: apartmentsPerFloor,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Bina eklenirken hata oluştu: $e');
    }
  }

  @override
  Future<BuildingEntity> updateBuilding({
    required String id,
    String? name,
    String? address,
    String? city,
  }) async {
    try {
      final model = await _remoteDataSource.updateBuilding(
        id: id,
        name: name,
        address: address,
        city: city,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Bina güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<BuildingEntity> patchBuildingCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    required String? paymentReferenceTemplate,
  }) async {
    try {
      final model = await _remoteDataSource.patchBuildingCollection(
        id: id,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Tahsilat bilgileri güncellenirken hata oluştu: $e',
      );
    }
  }

  @override
  Future<int> patchBuildingsMatchingCollection({
    required String matchIban,
    required String? collectionIban,
    required String? collectionAccountTitle,
    required String? paymentReferenceTemplate,
  }) async {
    try {
      final key = IbanUtils.normalize(matchIban);
      final buildings = await fetchBuildings();
      final matched = buildings
          .where(
            (b) => IbanUtils.normalize(b.collectionIban ?? '') == key,
          )
          .toList();
      if (matched.isEmpty) {
        throw ApiException(
          message: 'Bu IBAN için güncellenecek bina bulunamadı',
          statusCode: 404,
        );
      }
      for (final b in matched) {
        await patchBuildingCollection(
          id: b.id,
          collectionIban: collectionIban,
          collectionAccountTitle: collectionAccountTitle,
          paymentReferenceTemplate: paymentReferenceTemplate,
        );
      }
      return matched.length;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Tahsilat bilgileri güncellenirken hata oluştu: $e',
      );
    }
  }

  @override
  Future<CollectionPresetEntity> addCollectionPreset({
    required String collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  }) async {
    try {
      final key = IbanUtils.normalize(collectionIban);
      if (!IbanUtils.isValidTrIban(key)) {
        throw ApiException(message: 'Geçerli bir TR IBAN girin');
      }
      final presets = await fetchCollectionPresets();
      if (presets.any((p) => IbanUtils.normalize(p.collectionIban) == key)) {
        throw ApiException(message: 'Bu IBAN zaten kayıtlı');
      }
      final model = await _remoteDataSource.createCollectionPreset(
        collectionIban: key,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'IBAN kaydedilirken hata oluştu: $e');
    }
  }

  @override
  Future<SavedIbanDeleteResult> deleteCollectionPreset({
    required String matchIban,
  }) async {
    try {
      final key = IbanUtils.normalize(matchIban);
      final buildings = await fetchBuildings();
      var buildingsCleared = 0;
      for (final b in buildings) {
        if (IbanUtils.normalize(b.collectionIban ?? '') != key) continue;
        await patchBuildingCollection(
          id: b.id,
          collectionIban: '',
          collectionAccountTitle: '',
          paymentReferenceTemplate: '',
        );
        buildingsCleared++;
      }

      var orphanPresetRemoved = false;
      if (buildingsCleared == 0) {
        await _remoteDataSource.deleteCollectionPreset(key);
        orphanPresetRemoved = true;
      } else {
        try {
          await _remoteDataSource.deleteCollectionPreset(key);
          orphanPresetRemoved = true;
        } on ApiException catch (e) {
          if (e.statusCode != 404) rethrow;
        }
      }

      if (buildingsCleared == 0 && !orphanPresetRemoved) {
        throw ApiException(
          message: 'Silinecek IBAN kaydı bulunamadı',
          statusCode: 404,
        );
      }

      return SavedIbanDeleteResult(
        buildingsCleared: buildingsCleared,
        orphanPresetRemoved: orphanPresetRemoved,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'IBAN silinirken hata oluştu: $e');
    }
  }

  @override
  Future<SavedIbanBulkDeleteResult> deleteCollectionPresets({
    required List<String> matchIbans,
  }) async {
    var presetsRemoved = 0;
    var buildingsCleared = 0;
    ApiException? lastError;
    for (final raw in matchIbans.toSet()) {
      try {
        final result = await deleteCollectionPreset(matchIban: raw);
        if (result.hadEffect) presetsRemoved++;
        buildingsCleared += result.buildingsCleared;
      } on ApiException catch (e) {
        lastError = e;
      }
    }
    if (presetsRemoved == 0) {
      throw lastError ??
          ApiException(
            message: 'Silinecek IBAN kaydı bulunamadı',
            statusCode: 404,
          );
    }
    return SavedIbanBulkDeleteResult(
      presetsRemoved: presetsRemoved,
      buildingsCleared: buildingsCleared,
    );
  }

  @override
  Future<void> deleteBuilding(String id) async {
    try {
      await _remoteDataSource.deleteBuilding(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Bina silinirken hata oluştu: $e');
    }
  }
}
