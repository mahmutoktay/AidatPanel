import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/user_error_message.dart';
import '../../sites/data/sites_store.dart';
import '../domain/entities/building_entity.dart';
import '../domain/entities/collection_preset_entity.dart';
import 'datasources/building_remote_datasource.dart';
import 'datasources/local_collection_presets_store.dart';
import 'repositories/building_repository.dart';
import 'repositories/building_repository_impl.dart';

final buildingRemoteDataSourceProvider = Provider<BuildingRemoteDataSource>((ref) {
  return BuildingRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final localCollectionPresetsStoreProvider =
    Provider<LocalCollectionPresetsStore>((ref) {
  return LocalCollectionPresetsStore(ref.watch(secureStorageProvider));
});

final buildingRepositoryProvider = Provider<BuildingRepository>((ref) {
  return BuildingRepositoryImpl(
    remoteDataSource: ref.watch(buildingRemoteDataSourceProvider),
    localPresetsStore: ref.watch(localCollectionPresetsStoreProvider),
    siteRemoteDataSource: ref.watch(siteRemoteDataSourceProvider),
  );
});

/// Yeni bina formunda IBAN focus → son kullanılan tahsilat setleri.
final collectionPresetsProvider =
    FutureProvider.autoDispose<List<CollectionPresetEntity>>((ref) async {
  return ref.watch(buildingRepositoryProvider).fetchCollectionPresets();
});

class BuildingsNotifier extends AsyncNotifier<List<BuildingEntity>> {
  BuildingRepository get _repository => ref.read(buildingRepositoryProvider);

  /// Submit anında butona art arda basılırsa (50+ kullanıcı için yaygın)
  /// aynı bina N kez oluşturulmasın diye in-flight guard. UI tarafında
  /// da buton disable ediliyor; bu defansif katman.
  bool _isCreating = false;

  @override
  Future<List<BuildingEntity>> build() async {
    return _repository.fetchBuildings();
  }

  Future<void> loadBuildings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchBuildings);
  }

  /// PATCH aidat tutarı / gün sonrası vb.: `AsyncValue.loading` atlamadan
  /// bina listesini sunucudan yeniler. Böylece Binalar sekmesindeki
  /// `dueAmount` rozeti bayat kalmaz.
  Future<void> refreshBuildings() async {
    try {
      final buildings = await _repository.fetchBuildings();
      state = AsyncValue.data(buildings);
    } catch (_) {
      // Mevcut listeyi koru; aidat ekranında işlem zaten tamamlandı.
    }
  }

  /// Yerel listeyi loading flicker olmadan günceller (kardeş store senkronu).
  void applyLocalList(List<BuildingEntity> buildings) {
    state = AsyncValue.data(buildings);
  }

  /// Ana liste mutasyonunu Binalar sekmesinin `standalone` store'una yansıtır.
  void _mirrorStandalone({
    BuildingEntity? upsert,
    String? removeId,
  }) {
    if (this is StandaloneBuildingsNotifier) return;

    final standaloneNotifier =
        ref.read(standaloneBuildingsStoreProvider.notifier);
    final current =
        ref.read(standaloneBuildingsStoreProvider).asData?.value;
    if (current == null) {
      unawaited(standaloneNotifier.refreshBuildings());
      return;
    }

    if (removeId != null) {
      standaloneNotifier.applyLocalList(
        current.where((b) => b.id != removeId).toList(growable: false),
      );
      return;
    }

    if (upsert == null) return;

    // Site altı bloklar Binalar sekmesinde gösterilmez.
    if (upsert.siteId != null) {
      standaloneNotifier.applyLocalList(
        current.where((b) => b.id != upsert.id).toList(growable: false),
      );
      return;
    }

    final index = current.indexWhere((b) => b.id == upsert.id);
    if (index < 0) {
      standaloneNotifier.applyLocalList([...current, upsert]);
      return;
    }
    final next = List<BuildingEntity>.of(current);
    next[index] = upsert;
    standaloneNotifier.applyLocalList(next);
  }

  Future<String?> addBuilding({
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
    if (_isCreating) return null;
    _isCreating = true;
    try {
      final building = await _repository.createBuilding(
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
      final current = state.hasValue ? (state.value ?? <BuildingEntity>[]) : <BuildingEntity>[];
      state = AsyncValue.data([...current, building]);
      _mirrorStandalone(upsert: building);
      return building.id;
    } catch (e, st) {
      state = AsyncValue.error(wrapAsyncStateError(e), st);
      return null;
    } finally {
      _isCreating = false;
    }
  }

  Future<void> removeBuilding(String buildingId) async {
    await _repository.deleteBuilding(buildingId);
    final current = state.asData?.value ?? <BuildingEntity>[];
    state = AsyncValue.data(
      current.where((b) => b.id != buildingId).toList(),
    );
    _mirrorStandalone(removeId: buildingId);
  }

  Future<void> updateBuilding({
    required String id,
    String? name,
    String? address,
    String? city,
  }) async {
    final updated = await _repository.updateBuilding(
      id: id,
      name: name,
      address: address,
      city: city,
    );
    final current = state.hasValue ? (state.value ?? <BuildingEntity>[]) : <BuildingEntity>[];
    state = AsyncValue.data(
      current.map((b) => b.id == id ? updated : b).toList(),
    );
    _mirrorStandalone(upsert: updated);
  }

  Future<void> patchBuildingCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    required String? paymentReferenceTemplate,
  }) async {
    final updated = await _repository.patchBuildingCollection(
      id: id,
      collectionIban: collectionIban,
      collectionAccountTitle: collectionAccountTitle,
      paymentReferenceTemplate: paymentReferenceTemplate,
    );
    final current = state.hasValue ? (state.value ?? <BuildingEntity>[]) : <BuildingEntity>[];
    state = AsyncValue.data(
      current.map((b) => b.id == id ? updated : b).toList(),
    );
    _mirrorStandalone(upsert: updated);
  }
}

final buildingsStoreProvider =
    AsyncNotifierProvider<BuildingsNotifier, List<BuildingEntity>>(
  BuildingsNotifier.new,
);

/// Siteye bağlı olmayan binalar — API `standalone=true` ile yüklenir.
class StandaloneBuildingsNotifier extends BuildingsNotifier {
  Future<List<BuildingEntity>> _fetchStandalone() =>
      _repository.fetchBuildings(standalone: true);

  @override
  Future<List<BuildingEntity>> build() => _fetchStandalone();

  @override
  Future<void> loadBuildings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchStandalone);
  }

  @override
  Future<void> refreshBuildings() async {
    try {
      final buildings = await _fetchStandalone();
      state = AsyncValue.data(buildings);
    } catch (_) {
      // Mevcut listeyi koru.
    }
  }
}

final standaloneBuildingsStoreProvider =
    AsyncNotifierProvider<StandaloneBuildingsNotifier, List<BuildingEntity>>(
  StandaloneBuildingsNotifier.new,
);
