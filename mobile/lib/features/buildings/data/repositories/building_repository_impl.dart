import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../domain/entities/building_entity.dart';
import '../../domain/entities/collection_preset_entity.dart';
import '../../domain/entities/saved_iban_delete_result.dart';
import '../datasources/building_remote_datasource.dart';
import '../datasources/local_collection_presets_store.dart';
import 'building_repository.dart';

class BuildingRepositoryImpl implements BuildingRepository {
  BuildingRepositoryImpl({
    required BuildingRemoteDataSource remoteDataSource,
    required LocalCollectionPresetsStore localPresetsStore,
  })  : _remoteDataSource = remoteDataSource,
        _localPresetsStore = localPresetsStore;

  final BuildingRemoteDataSource _remoteDataSource;
  final LocalCollectionPresetsStore _localPresetsStore;

  Future<List<CollectionPresetEntity>> _mergedPresets() async {
    final server = await _remoteDataSource.fetchCollectionPresets();
    final serverEntities = server.map((m) => m.toEntity()).toList();
    final serverKeys = serverEntities
        .map((p) => IbanUtils.normalize(p.collectionIban))
        .toSet();
    final local = await _localPresetsStore.load();
    final merged = [...serverEntities];
    for (final preset in local) {
      if (!serverKeys.contains(IbanUtils.normalize(preset.collectionIban))) {
        merged.add(preset);
      }
    }
    return merged;
  }

  Future<void> _dropLocalPresetIfOnServer(String? iban) async {
    if (iban == null || iban.isEmpty) return;
    await _localPresetsStore.remove(IbanUtils.normalize(iban));
  }

  @override
  Future<List<BuildingEntity>> fetchBuildings({bool standaloneOnly = false}) async {
    try {
      final models = await _remoteDataSource.fetchBuildings(
        standaloneOnly: standaloneOnly,
      );
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
      return _mergedPresets();
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
      await _dropLocalPresetIfOnServer(collectionIban);
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
      await _dropLocalPresetIfOnServer(collectionIban);
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
        return _updateLocalOrphanPreset(
          matchIban: key,
          collectionIban: collectionIban,
          collectionAccountTitle: collectionAccountTitle,
          paymentReferenceTemplate: paymentReferenceTemplate,
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

  Future<int> _updateLocalOrphanPreset({
    required String matchIban,
    required String? collectionIban,
    required String? collectionAccountTitle,
    required String? paymentReferenceTemplate,
  }) async {
    final local = await _localPresetsStore.load();
    final existing = local
        .where((p) => IbanUtils.normalize(p.collectionIban) == matchIban)
        .toList();
    if (existing.isEmpty) {
      throw ApiException(
        message: 'Bu IBAN için güncellenecek kayıt bulunamadı',
        statusCode: 404,
      );
    }

    final iban = (collectionIban == null || collectionIban.isEmpty)
        ? ''
        : IbanUtils.normalize(collectionIban);
    if (iban.isNotEmpty && !IbanUtils.isValidTrIban(iban)) {
      throw ApiException(message: 'Geçerli bir TR IBAN girin');
    }

    await _localPresetsStore.remove(matchIban);
    if (iban.isNotEmpty) {
      await _localPresetsStore.upsert(
        CollectionPresetEntity(
          collectionIban: iban,
          collectionAccountTitle:
              (collectionAccountTitle?.trim().isEmpty ?? true)
                  ? null
                  : collectionAccountTitle!.trim(),
          paymentReferenceTemplate:
              (paymentReferenceTemplate?.trim().isEmpty ?? true)
                  ? null
                  : paymentReferenceTemplate!.trim(),
          lastUsedAt: DateTime.now(),
          buildingCount: 0,
        ),
      );
    }
    return 0;
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
      final presets = await _mergedPresets();
      if (presets.any((p) => IbanUtils.normalize(p.collectionIban) == key)) {
        throw ApiException(message: 'Bu IBAN zaten kayıtlı');
      }

      final entity = CollectionPresetEntity(
        collectionIban: key,
        collectionAccountTitle: (collectionAccountTitle?.trim().isEmpty ?? true)
            ? null
            : collectionAccountTitle!.trim(),
        paymentReferenceTemplate:
            (paymentReferenceTemplate?.trim().isEmpty ?? true)
                ? null
                : paymentReferenceTemplate!.trim(),
        lastUsedAt: DateTime.now(),
        buildingCount: 0,
      );
      await _localPresetsStore.upsert(entity);
      return entity;
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

      final orphanPresetRemoved = await _localPresetsStore.remove(key);

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
