import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/dues_remote_datasource.dart';
import '../../data/repositories/dues_repository_impl.dart';
import '../../domain/entities/due_entity.dart';
import '../../domain/repositories/dues_repository.dart';

final duesRemoteDataSourceProvider = Provider<DuesRemoteDataSource>((ref) {
  return DuesRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final duesRepositoryProvider = Provider<DuesRepository>((ref) {
  return DuesRepositoryImpl(
    remoteDataSource: ref.watch(duesRemoteDataSourceProvider),
  );
});

class DuesState {
  final bool isLoading;
  final List<DueEntity> dues;
  final String? error;

  const DuesState({
    this.isLoading = false,
    this.dues = const [],
    this.error,
  });

  DuesState copyWith({
    bool? isLoading,
    List<DueEntity>? dues,
    String? error,
    bool clearError = false,
  }) {
    return DuesState(
      isLoading: isLoading ?? this.isLoading,
      dues: dues ?? this.dues,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DuesNotifier extends StateNotifier<DuesState> {
  final DuesRepository _repository;

  DuesNotifier(this._repository) : super(const DuesState());

  Future<void> loadBuildingDues(String buildingId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dues = await _repository.getBuildingDues(buildingId);
      state = state.copyWith(isLoading: false, dues: dues);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Aidatlar yüklenemedi');
    }
  }

  Future<void> loadApartmentDues(String apartmentId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dues = await _repository.getApartmentDues(apartmentId);
      state = state.copyWith(isLoading: false, dues: dues);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, error: 'Daire aidatları yüklenemedi');
    }
  }

  Future<void> loadMyDues() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dues = await _repository.getMyDues();
      state = state.copyWith(isLoading: false, dues: dues);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, error: 'Aidat geçmişi yüklenemedi');
    }
  }

  Future<void> updateStatus({
    required String dueId,
    required DueStatus status,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _repository.updateDueStatus(
        dueId: dueId,
        status: status,
      );
      final next = state.dues
          .map((item) => item.id == dueId ? updated : item)
          .toList(growable: false);
      state = state.copyWith(isLoading: false, dues: next);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Aidat durumu güncellenemedi',
      );
    }
  }

  Future<void> createBulk({
    required String buildingId,
    required double amount,
    required int month,
    required int year,
    String currency = 'TRY',
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final created = await _repository.createBulkDues(
        buildingId: buildingId,
        amount: amount,
        month: month,
        year: year,
        currency: currency,
        note: note,
      );
      state = state.copyWith(
        isLoading: false,
        dues: [...state.dues, ...created],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Toplu aidat oluşturulamadı',
      );
    }
  }
}

final duesNotifierProvider = StateNotifierProvider<DuesNotifier, DuesState>(
  (ref) => DuesNotifier(ref.watch(duesRepositoryProvider)),
);
