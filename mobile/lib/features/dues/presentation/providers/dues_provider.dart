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

  /// Submit edilen async işlemlerin (status update / due-amount update) art
  /// arda tetiklenmesini engelleyen bayraklar. UI da butonu disable ediyor;
  /// bu defansif katman.
  bool _isUpdatingStatus = false;
  bool _isUpdatingDueAmount = false;

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
    required String buildingId,
    required String dueId,
    required DueStatus status,
  }) async {
    if (_isUpdatingStatus) return;
    _isUpdatingStatus = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _repository.updateDueStatus(
        buildingId: buildingId,
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
    } finally {
      _isUpdatingStatus = false;
    }
  }

  Future<bool> updateBuildingDueAmount({
    required String buildingId,
    required double dueAmount,
    int? dueDay,
    String? currency,
    bool affectCurrent = false,
  }) async {
    if (_isUpdatingDueAmount) return false;
    _isUpdatingDueAmount = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateBuildingDueAmount(
        buildingId: buildingId,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        affectCurrent: affectCurrent,
      );
      // affectCurrent true ise mevcut PENDING tutarları değişti; listeyi tazele.
      if (affectCurrent) {
        final dues = await _repository.getBuildingDues(buildingId);
        state = state.copyWith(isLoading: false, dues: dues);
      } else {
        state = state.copyWith(isLoading: false);
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Aidat tutarı güncellenemedi',
      );
      return false;
    } finally {
      _isUpdatingDueAmount = false;
    }
  }
}

final duesNotifierProvider = StateNotifierProvider<DuesNotifier, DuesState>(
  (ref) => DuesNotifier(ref.watch(duesRepositoryProvider)),
);
