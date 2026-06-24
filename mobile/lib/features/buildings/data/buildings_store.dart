import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/user_error_message.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
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
      final current = state.value ?? [];
      state = AsyncValue.data([...current, building]);
      return building.id;
    } catch (e, st) {
      state = AsyncValue.error(wrapAsyncStateError(e), st);
      return null;
    } finally {
      _isCreating = false;
    }
  }

  /// Hata UI tarafında ele alınmalı; state'i bozarsak (AsyncValue.error)
  /// kullanıcı bina listesini tamamen kaybeder. Bu yüzden hata olursa
  /// rethrow ediyoruz, başarı durumunda listeyi yeniden yazıyoruz.
  Future<void> removeBuilding(String buildingId) async {
    await _repository.deleteBuilding(buildingId);
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.where((b) => b.id != buildingId).toList(),
    );
  }

  /// Belge §5: PUT /buildings/:id body `name?`, `address?`, `city?`.
  /// Hata olursa state'i bozmadan rethrow edilir; UI snackbar gösterir.
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
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((b) => b.id == id ? updated : b).toList(),
    );
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
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.map((b) => b.id == id ? updated : b).toList(),
    );
  }
}

final standaloneBuildingsProvider =
    FutureProvider.autoDispose<List<BuildingEntity>>((ref) async {
  return ref.watch(buildingRepositoryProvider).fetchBuildings(
        standaloneOnly: true,
      );
});

final buildingsStoreProvider =
    AsyncNotifierProvider<BuildingsNotifier, List<BuildingEntity>>(
  BuildingsNotifier.new,
);
