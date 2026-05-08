import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../domain/entities/building_entity.dart';
import 'datasources/building_remote_datasource.dart';
import 'repositories/building_repository.dart';
import 'repositories/building_repository_impl.dart';

final buildingRemoteDataSourceProvider = Provider<BuildingRemoteDataSource>((ref) {
  return BuildingRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final buildingRepositoryProvider = Provider<BuildingRepository>((ref) {
  return BuildingRepositoryImpl(
    remoteDataSource: ref.watch(buildingRemoteDataSourceProvider),
  );
});

class BuildingsNotifier
    extends StateNotifier<AsyncValue<List<BuildingEntity>>> {
  final BuildingRepository _repository;

  BuildingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBuildings();
  }

  Future<void> loadBuildings() async {
    state = const AsyncValue.loading();
    try {
      final buildings = await _repository.fetchBuildings();
      state = AsyncValue.data(buildings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
  }) async {
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
      );
      final current = state.value ?? [];
      state = AsyncValue.data([...current, building]);
      return building.id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> removeBuilding(String buildingId) async {
    try {
      await _repository.deleteBuilding(buildingId);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.where((b) => b.id != buildingId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBuilding({
    required String id,
    String? name,
    String? address,
    String? city,
  }) async {
    try {
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final buildingsStoreProvider = StateNotifierProvider<BuildingsNotifier,
    AsyncValue<List<BuildingEntity>>>(
  (ref) => BuildingsNotifier(ref.watch(buildingRepositoryProvider)),
);

final buildingsCountProvider = Provider<int>((ref) {
  return ref.watch(buildingsStoreProvider).value?.length ?? 0;
});

final totalBuildingsDuesProvider = Provider<double>((ref) {
  final buildings = ref.watch(buildingsStoreProvider).value ?? [];
  return buildings.fold<double>(0, (sum, b) => sum + b.collectedDues);
});
