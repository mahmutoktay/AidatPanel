import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../data/datasources/dues_remote_datasource.dart';
import '../../data/repositories/dues_repository_impl.dart';
import '../../domain/entities/due_entity.dart';
import '../../domain/repositories/dues_repository.dart';
import '../../domain/resident_dues_list.dart';

final duesRemoteDataSourceProvider = Provider<DuesRemoteDataSource>((ref) {
  return DuesRemoteDataSourceImpl(dioClient: ref.watch(dioClientProvider));
});

final duesRepositoryProvider = Provider<DuesRepository>((ref) {
  return DuesRepositoryImpl(
    remoteDataSource: ref.watch(duesRemoteDataSourceProvider),
  );
});

class DuesState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<DueEntity> dues;
  final String? nextCursor;
  final String? error;

  const DuesState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.dues = const [],
    this.nextCursor,
    this.error,
  });

  bool get canLoadMore =>
      nextCursor != null &&
      nextCursor!.isNotEmpty &&
      !isLoading &&
      !isLoadingMore;

  DuesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<DueEntity>? dues,
    String? nextCursor,
    String? error,
    bool clearError = false,
    bool clearNextCursor = false,
  }) {
    return DuesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      dues: dues ?? this.dues,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DuesNotifier extends Notifier<DuesState> {
  DuesRepository get _repository => ref.read(duesRepositoryProvider);
  /// Submit edilen async işlemlerin (status update / due-amount update) art
  /// arda tetiklenmesini engelleyen bayraklar. UI da butonu disable ediyor;
  /// bu defansif katman.
  bool _isUpdatingStatus = false;
  bool _isUpdatingDueAmount = false;

  /// `updateBuildingDueAmount` sonrası `affectCurrent=true` ise listeyi
  /// tazelemek için son sorgu filtrelerini saklarız (kullanıcının seçili
  /// ay/yıl/status filtresi kaybolmasın diye aynı setle reload).
  int? _lastMonth;
  int? _lastYear;
  DueStatus? _lastStatus;
  String? _loadedBuildingId;
  bool _isResidentList = false;
  bool _paginated = true;
  Map<String, String> _dueBuildingIds = const {};

  Map<String, String> get dueBuildingIds => _dueBuildingIds;

  @override
  DuesState build() => const DuesState();
  Future<void> loadBuildingDues(
    String buildingId, {
    bool refresh = true,
    int? month,
    int? year,
    DueStatus? status,
    bool paginated = true,
  }) async {
    final filtersChanged =
        _loadedBuildingId != buildingId ||
        _lastMonth != month ||
        _lastYear != year ||
        _lastStatus != status ||
        _isResidentList ||
        _paginated != paginated;
    final effectiveRefresh = refresh || filtersChanged;
    if (!paginated && !effectiveRefresh) return;
    if (!effectiveRefresh && !state.canLoadMore) return;

    final buildingChanged =
        _loadedBuildingId != null && _loadedBuildingId != buildingId;
    _loadedBuildingId = buildingId;
    _isResidentList = false;
    _lastMonth = month;
    _lastYear = year;
    _lastStatus = status;
    _paginated = paginated;
    // Aynı bina + filtre yenilemede önceki listeyi tutup üstte ince yükleme
    // göstermek için veriyi silmiyoruz; bina değişince yanlış veri
    // göstermemek için listeyi temizleriz.
    state = state.copyWith(
      isLoading: effectiveRefresh,
      isLoadingMore: !effectiveRefresh,
      clearError: true,
      dues: buildingChanged ? const [] : state.dues,
      clearNextCursor: effectiveRefresh,
    );
    try {
      final result = await _repository.getBuildingDues(
        buildingId,
        month: month,
        year: year,
        status: status,
        cursor: effectiveRefresh || !paginated ? null : state.nextCursor,
        paginated: paginated,
      );
      final merged = effectiveRefresh
          ? result.items
          : [...state.dues, ...result.items];
      _dueBuildingIds = {
        for (final due in merged) due.id: buildingId,
      };
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        dues: merged,
        nextCursor: result.nextCursor,
        clearNextCursor: result.nextCursor == null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  /// Tek veya çoklu bina kapsamı — aidatlar sekmesi ile ana sayfa seçici uyumu.
  Future<void> loadScopedBuildingDues(
    List<String> buildingIds, {
    bool refresh = true,
    int? month,
    int? year,
    DueStatus? status,
    bool paginated = false,
  }) async {
    if (buildingIds.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        dues: const [],
        clearNextCursor: true,
      );
      return;
    }
    if (buildingIds.length == 1) {
      return loadBuildingDues(
        buildingIds.first,
        refresh: refresh,
        month: month,
        year: year,
        status: status,
        paginated: paginated,
      );
    }

    final filtersChanged =
        _lastMonth != month ||
        _lastYear != year ||
        _lastStatus != status ||
        _isResidentList ||
        _paginated != paginated ||
        _loadedBuildingId != buildingIds.join(',');
    final effectiveRefresh = refresh || filtersChanged;

    _loadedBuildingId = buildingIds.join(',');
    _isResidentList = false;
    _lastMonth = month;
    _lastYear = year;
    _lastStatus = status;
    _paginated = paginated;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      clearError: true,
      dues: effectiveRefresh ? const [] : state.dues,
      clearNextCursor: true,
    );

    try {
      final merged = <DueEntity>[];
      final mapping = <String, String>{};
      for (final buildingId in buildingIds) {
        final result = await _repository.getBuildingDues(
          buildingId,
          month: month,
          year: year,
          status: status,
          paginated: false,
        );
        for (final due in result.items) {
          mapping[due.id] = buildingId;
        }
        merged.addAll(result.items);
      }
      _dueBuildingIds = mapping;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        dues: merged,
        clearNextCursor: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  Future<void> loadMyDues({
    bool refresh = true,
    int? month,
    int? year,
    DueStatus? status,
  }) async {
    final filtersChanged =
        _lastMonth != month ||
        _lastYear != year ||
        _lastStatus != status ||
        !_isResidentList;
    final effectiveRefresh = refresh || filtersChanged;
    if (!effectiveRefresh && !state.canLoadMore) return;

    _isResidentList = true;
    _loadedBuildingId = null;
    _lastMonth = month;
    _lastYear = year;
    _lastStatus = status;

    state = state.copyWith(
      isLoading: effectiveRefresh,
      isLoadingMore: !effectiveRefresh,
      clearError: true,
      clearNextCursor: effectiveRefresh,
    );
    try {
      final result = await _repository.getMyDues(
        month: month,
        year: year,
        status: status,
        cursor: effectiveRefresh ? null : state.nextCursor,
      );
      final merged = effectiveRefresh
          ? result.items
          : [...state.dues, ...result.items];
      final dues = prepareResidentDuesList(merged);
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        dues: dues,
        nextCursor: result.nextCursor,
        clearNextCursor: result.nextCursor == null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  Future<void> loadMoreBuildingDues() {
    final id = _loadedBuildingId;
    if (id == null || id.isEmpty || !_paginated) return Future.value();
    return loadBuildingDues(
      id,
      refresh: false,
      month: _lastMonth,
      year: _lastYear,
      status: _lastStatus,
      paginated: true,
    );
  }

  Future<void> loadMoreMyDues() => loadMyDues(
    refresh: false,
    month: _lastMonth,
    year: _lastYear,
    status: _lastStatus,
  );

  Future<void> updateStatus({
    required String buildingId,
    required String dueId,
    required DueStatus status,
  }) async {
    if (_isUpdatingStatus) return;
    _isUpdatingStatus = true;
    state = state.copyWith(clearError: true);
    try {
      await _repository.updateDueStatus(
        buildingId: buildingId,
        dueId: dueId,
        status: status,
      );
      await loadBuildingDues(
        buildingId,
        refresh: true,
        month: _lastMonth,
        year: _lastYear,
        status: _lastStatus,
        paginated: _paginated,
      );
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
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
      // affectCurrent false olsa bile sunucu tutar / gün günceller; liste
      // her zaman aynı filtreyle yenilenir (UI bayat kalmasın).
      await loadBuildingDues(
        buildingId,
        refresh: true,
        month: _lastMonth,
        year: _lastYear,
        status: _lastStatus,
        paginated: _paginated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
      return false;
    } finally {
      _isUpdatingDueAmount = false;
    }
  }
}

final duesNotifierProvider = NotifierProvider<DuesNotifier, DuesState>(
  DuesNotifier.new,
);
/// Manager dashboard hero card için kullanılan tüm binaların dues toplamı.
/// `Map<buildingId, List<DueEntity>>` döner; bina başına filtreleme için
/// alttaki [buildingCollectionRate] / [buildingOverdueCount] helper'ları
/// kullanılır.
///
/// Backend `Building` response'unda `collectedDues` döndürmediği için
/// `BuildingEntity.collectionRate` getter'ı her zaman 0 verirdi. Bu
/// provider gerçek hesaplama için dues listesinden faydalanır.
///
/// `buildingsStoreProvider` değişince otomatik yeniden hesaplanır
/// (yeni bina eklenince ya da silinince provider tetiklenir).
final allBuildingsDuesProvider = FutureProvider<Map<String, List<DueEntity>>>((
  ref,
) async {
  final buildingsAsync = ref.watch(buildingsStoreProvider);
  final buildings = buildingsAsync.value ?? const [];
  if (buildings.isEmpty) return const {};
  final repo = ref.watch(duesRepositoryProvider);
  // Paralel çek; bir bina yüklenmese bile diğerlerinin durmaması için
  // her future'ı ayrı try/catch içinde sarıyoruz.
  final results = await Future.wait(
    buildings.map((b) async {
      try {
        final dues = await repo.getBuildingDues(b.id, paginated: false);
        return MapEntry(b.id, dues.items);
      } catch (_) {
        return MapEntry(b.id, const <DueEntity>[]);
      }
    }),
  );
  return Map.fromEntries(results);
});

/// Tüm binalardaki ödeme oranı: `PAID dues / total dues × 100`.
/// dues boşsa 0 döner. Hero card'daki "%" rozetinde kullanılır.
double globalCollectionRate(Map<String, List<DueEntity>> map) {
  final all = map.values.expand((l) => l).toList(growable: false);
  if (all.isEmpty) return 0;
  final paid = all.where((d) => d.status == DueStatus.paid).length;
  return (paid / all.length) * 100;
}

/// Tüm binalardaki gecikmiş aidat sayısı.
int globalOverdueCount(Map<String, List<DueEntity>> map) {
  return map.values
      .expand((l) => l)
      .where((d) => d.status == DueStatus.overdue)
      .length;
}

/// Tek bir binanın ödeme oranı. Bina kartlarında "Tahsilat" sütununda
/// kullanılır. Bina için dues yoksa 0 döner.
double buildingCollectionRate(
  Map<String, List<DueEntity>> map,
  String buildingId,
) {
  final dues = map[buildingId] ?? const [];
  if (dues.isEmpty) return 0;
  final paid = dues.where((d) => d.status == DueStatus.paid).length;
  return (paid / dues.length) * 100;
}

/// Tek bir binanın gecikmiş aidat sayısı.
int buildingOverdueCount(Map<String, List<DueEntity>> map, String buildingId) {
  return (map[buildingId] ?? const [])
      .where((d) => d.status == DueStatus.overdue)
      .length;
}

/// Tek bir binanın bekleyen aidat sayısı.
int buildingPendingCount(Map<String, List<DueEntity>> map, String buildingId) {
  return (map[buildingId] ?? const [])
      .where((d) => d.status == DueStatus.pending)
      .length;
}

/// Tek bir binanın ödenmiş aidat sayısı.
int buildingPaidCount(Map<String, List<DueEntity>> map, String buildingId) {
  return (map[buildingId] ?? const [])
      .where((d) => d.status == DueStatus.paid)
      .length;
}
