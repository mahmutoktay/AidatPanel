import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../domain/entities/apartment_entity.dart';
import 'datasources/apartment_remote_datasource.dart';
import 'repositories/apartment_repository.dart';
import 'repositories/apartment_repository_impl.dart';

final apartmentRemoteDataSourceProvider =
    Provider<ApartmentRemoteDataSource>((ref) {
  return ApartmentRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final apartmentRepositoryProvider = Provider<ApartmentRepository>((ref) {
  return ApartmentRepositoryImpl(
    remoteDataSource: ref.watch(apartmentRemoteDataSourceProvider),
  );
});

class ApartmentsNotifier
    extends StateNotifier<AsyncValue<List<ApartmentEntity>>> {
  final ApartmentRepository _repository;
  final String buildingId;

  ApartmentsNotifier(this._repository, this.buildingId)
      : super(const AsyncValue.loading()) {
    loadApartments();
  }

  Future<void> loadApartments() async {
    state = const AsyncValue.loading();
    try {
      final apartments = await _repository.fetchApartments(buildingId);
      state = AsyncValue.data(apartments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addApartment({required String number, int? floor}) async {
    try {
      final apartment = await _repository.createApartment(
        buildingId: buildingId,
        number: number,
        floor: floor,
      );
      final current = state.value ?? [];
      state = AsyncValue.data([...current, apartment]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeApartment(String apartmentId) async {
    try {
      await _repository.deleteApartment(
        buildingId: buildingId,
        id: apartmentId,
      );
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.where((a) => a.id != apartmentId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final apartmentsStoreProvider = StateNotifierProvider.family<ApartmentsNotifier,
    AsyncValue<List<ApartmentEntity>>, String>(
  (ref, buildingId) => ApartmentsNotifier(
    ref.watch(apartmentRepositoryProvider),
    buildingId,
  ),
);

final apartmentCountProvider = Provider.family<int, String>((ref, buildingId) {
  return ref.watch(apartmentsStoreProvider(buildingId)).value?.length ?? 0;
});

final occupiedCountProvider = Provider.family<int, String>((ref, buildingId) {
  final apartments =
      ref.watch(apartmentsStoreProvider(buildingId)).value ?? [];
  return apartments.where((a) => a.isOccupied).length;
});

final paidCountProvider = Provider.family<int, String>((ref, buildingId) {
  final apartments =
      ref.watch(apartmentsStoreProvider(buildingId)).value ?? [];
  return apartments
      .where((a) => a.paymentStatus == PaymentStatus.paid)
      .length;
});
