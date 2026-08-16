import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../debug/dekont_debug_log.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/errors/duplicate_dekont_exception.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/payment_collection_entity.dart';
import '../../domain/repositories/dekont_repository.dart';
import '../utils/dekont_labels.dart';
import '../../data/datasources/dekont_remote_datasource.dart';
import '../../data/dekont_preview_cache.dart';
import '../../data/repositories/dekont_repository_impl.dart';

final dekontRemoteDataSourceProvider = Provider<DekontRemoteDataSource>((ref) {
  return DekontRemoteDataSourceImpl(dioClient: ref.watch(dioClientProvider));
});

final dekontRepositoryProvider = Provider<DekontRepository>((ref) {
  return DekontRepositoryImpl(
    remote: ref.watch(dekontRemoteDataSourceProvider),
  );
});

/// Yükleme sonrası yerel önizleme — sunucu dosyası henüz hazır değilse kullanılır.
/// autoDispose kullanılmaz; detay ekranına geçince önbellek silinmesin.
class DekontLocalPreviewNotifier extends Notifier<Map<String, Uint8List>> {
  @override
  Map<String, Uint8List> build() => {};

  void upsert(String dekontId, Uint8List bytes) {
    state = {...state, dekontId: bytes};
  }

  void clearAll() => state = {};
}

final dekontLocalPreviewProvider =
    NotifierProvider<DekontLocalPreviewNotifier, Map<String, Uint8List>>(
  DekontLocalPreviewNotifier.new,
);
final paymentCollectionProvider =
    FutureProvider.autoDispose<PaymentCollectionEntity>((ref) async {
      return ref.watch(dekontRepositoryProvider).getPaymentCollection();
    });

final dekontDetailProvider = FutureProvider.autoDispose
    .family<DekontEntity, String>((ref, id) async {
      return ref.watch(dekontRepositoryProvider).getDekont(id);
    });

class MakePaymentState {
  final bool isLoadingInfo;
  final bool isUploading;
  final PaymentCollectionEntity? collection;
  final Set<String> selectedDueIds;
  final String? pickedFileName;
  final List<int>? pickedFileBytes;
  final String? pickedFilePath;
  final DekontEntity? uploadedDekont;
  final bool uploadWasDuplicate;
  final bool uploadWasRecovered;
  final String? error;

  const MakePaymentState({
    this.isLoadingInfo = false,
    this.isUploading = false,
    this.collection,
    this.selectedDueIds = const {},
    this.pickedFileName,
    this.pickedFileBytes,
    this.pickedFilePath,
    this.uploadedDekont,
    this.uploadWasDuplicate = false,
    this.uploadWasRecovered = false,
    this.error,
  });

  String? get selectedDueId =>
      selectedDueIds.isEmpty ? null : selectedDueIds.first;

  MakePaymentState copyWith({
    bool? isLoadingInfo,
    bool? isUploading,
    PaymentCollectionEntity? collection,
    Set<String>? selectedDueIds,
    String? pickedFileName,
    List<int>? pickedFileBytes,
    String? pickedFilePath,
    DekontEntity? uploadedDekont,
    bool? uploadWasDuplicate,
    bool? uploadWasRecovered,
    String? error,
    bool clearError = false,
    bool clearFile = false,
  }) {
    return MakePaymentState(
      isLoadingInfo: isLoadingInfo ?? this.isLoadingInfo,
      isUploading: isUploading ?? this.isUploading,
      collection: collection ?? this.collection,
      selectedDueIds: selectedDueIds ?? this.selectedDueIds,
      pickedFileName: clearFile
          ? null
          : (pickedFileName ?? this.pickedFileName),
      pickedFileBytes: clearFile
          ? null
          : (pickedFileBytes ?? this.pickedFileBytes),
      pickedFilePath: clearFile
          ? null
          : (pickedFilePath ?? this.pickedFilePath),
      uploadedDekont: uploadedDekont ?? this.uploadedDekont,
      uploadWasDuplicate: uploadWasDuplicate ?? this.uploadWasDuplicate,
      uploadWasRecovered: uploadWasRecovered ?? this.uploadWasRecovered,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

Future<void> _cacheLocalPreview(
  Ref ref,
  String dekontId,
  List<int> bytes,
) async {
  final copy = Uint8List.fromList(bytes);
  ref.read(dekontLocalPreviewProvider.notifier).upsert(dekontId, copy);
  await DekontPreviewCache.save(dekontId, copy);
}

class MakePaymentNotifier extends Notifier<MakePaymentState> {
  DekontRepository get _repository => ref.read(dekontRepositoryProvider);

  bool _isUploading = false;

  @override
  MakePaymentState build() => const MakePaymentState();
  /// Detay ekranına geçildiğinde veya ödeme ekranına dönüldüğünde yükleme kilidini kaldırır.
  void endUploadSession() {
    _isUploading = false;
    state = state.copyWith(
      isUploading: false,
      clearFile: true,
      clearError: true,
    );
  }

  /// Ekran yeniden görünür olduğunda takılı kalan busy bayraklarını temizler.
  void ensureIdleOnScreen() {
    if (_isUploading) return;
    if (!state.isUploading) return;
    endUploadSession();
  }

  Future<void> loadPaymentInfo() async {
    dekontDebugLog('provider.loadPaymentInfo start');
    state = state.copyWith(isLoadingInfo: true, clearError: true);
    try {
      final collection = await _repository.getPaymentCollection();
      dekontDebugLog('provider.loadPaymentInfo ok', {
        'configured': collection.isCollectionConfigured,
        'buildingId': collection.buildingId,
      });
      state = state.copyWith(isLoadingInfo: false, collection: collection);
    } catch (e, st) {
      dekontDebugLog('provider.loadPaymentInfo fail', '$e\n$st');
      state = state.copyWith(
        isLoadingInfo: false,
        error: userFacingError(e, context: ApiMessageContext.dekont),
      );
    }
  }

  void selectDue(String? dueId) {
    if (dueId == null || dueId.isEmpty) {
      state = state.copyWith(selectedDueIds: {});
      return;
    }
    state = state.copyWith(selectedDueIds: {dueId});
  }

  void toggleDue(String dueId) {
    final next = Set<String>.from(state.selectedDueIds);
    if (next.contains(dueId)) {
      next.remove(dueId);
    } else {
      next.add(dueId);
    }
    state = state.copyWith(selectedDueIds: next);
  }

  void setSelectedDueIds(Set<String> dueIds) {
    state = state.copyWith(selectedDueIds: dueIds);
  }

  void setPickedReceipt({
    required String fileName,
    required List<int> fileBytes,
    String? filePath,
  }) {
    state = state.copyWith(
      pickedFileName: fileName,
      pickedFileBytes: fileBytes,
      pickedFilePath: filePath,
      clearError: true,
    );
  }

  void clearPickedReceipt() {
    state = state.copyWith(clearFile: true, clearError: true);
  }

  Future<DekontEntity?> upload() async {
    if (_isUploading) return null; // Double-tap race condition önlemi

    final bytes = state.pickedFileBytes;
    final name = state.pickedFileName;
    if (bytes == null || bytes.isEmpty || name == null) {
      state = state.copyWith(
        error: LocaleSettings
            .instance
            .currentTranslations
            .features
            .dekont
            .errorNoFileSelected,
      );
      return null;
    }
    if (state.selectedDueIds.isEmpty) {
      state = state.copyWith(
        error: LocaleSettings
            .instance
            .currentTranslations
            .features
            .dekont
            .errorNoDueSelected,
      );
      return null;
    }
    _isUploading = true;
    state = state.copyWith(
      isUploading: true,
      clearError: true,
      uploadWasDuplicate: false,
      uploadWasRecovered: false,
    );
    final dueIds = state.selectedDueIds.toList();
    dekontDebugLog('provider.upload start', {
      'file': name,
      'dueIds': dueIds,
    });
    try {
      final result = await _repository.uploadDekont(
        fileName: name,
        fileBytes: bytes,
        filePath: state.pickedFilePath,
        dueId: dueIds.first,
        dueIds: dueIds,
      );
      final dekont = result.dekont;
      await _cacheLocalPreview(ref, dekont.id, bytes);
      ref.invalidate(myDekontsNotifierProvider);
      state = state.copyWith(
        isUploading: false,
        uploadedDekont: dekont,
        uploadWasDuplicate: false,
        uploadWasRecovered: result.recovered,
        clearFile: true,
        clearError: true,
      );
      _isUploading = false;
      return dekont;
    } on DuplicateDekontException catch (e) {
      dekontDebugLog('provider.upload duplicate', e.dekont.id);
      await _cacheLocalPreview(ref, e.dekont.id, bytes);
      ref.invalidate(myDekontsNotifierProvider);
      state = state.copyWith(
        isUploading: false,
        uploadedDekont: e.dekont,
        uploadWasDuplicate: true,
        uploadWasRecovered: false,
        clearFile: true,
        clearError: true,
      );
      _isUploading = false;
      return e.dekont;
    } catch (e, st) {
      dekontDebugLog('provider.upload fail', '$e\n$st');
      state = state.copyWith(
        isUploading: false,
        error: userFacingError(e, context: ApiMessageContext.dekont),
      );
      _isUploading = false;
      return null;
    }
  }
}

final makePaymentNotifierProvider =
    NotifierProvider.autoDispose<MakePaymentNotifier, MakePaymentState>(
  MakePaymentNotifier.new,
);
class MyDekontsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<DekontEntity> dekonts;
  final String? statusFilter;
  final String? nextCursor;
  final String? error;

  const MyDekontsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.dekonts = const [],
    this.statusFilter,
    this.nextCursor,
    this.error,
  });

  bool get canLoadMore =>
      (statusFilter == null || statusFilter!.isEmpty) &&
      nextCursor != null &&
      nextCursor!.isNotEmpty &&
      !isLoading &&
      !isLoadingMore;

  MyDekontsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<DekontEntity>? dekonts,
    String? statusFilter,
    String? nextCursor,
    String? error,
    bool clearError = false,
    bool clearNextCursor = false,
  }) {
    return MyDekontsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      dekonts: dekonts ?? this.dekonts,
      statusFilter: statusFilter ?? this.statusFilter,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyDekontsNotifier extends Notifier<MyDekontsState> {
  DekontRepository get _repository => ref.read(dekontRepositoryProvider);

  @override
  MyDekontsState build() => const MyDekontsState();
  Future<void> load({String? filterKey, bool refresh = true}) async {
    final effectiveRefresh = refresh || state.statusFilter != filterKey;
    if (!effectiveRefresh && !state.canLoadMore) return;
    final useClientFilter = filterKey != null && filterKey.isNotEmpty;
    dekontDebugLog('provider.myDekonts.load', 'filterKey=$filterKey');
    state = state.copyWith(
      isLoading: effectiveRefresh,
      isLoadingMore: !effectiveRefresh,
      statusFilter: filterKey,
      clearError: true,
      clearNextCursor: effectiveRefresh,
    );
    try {
      final result = await _repository.getMyDekonts(
        cursor: useClientFilter || effectiveRefresh ? null : state.nextCursor,
        paginated: !useClientFilter,
      );
      final merged = effectiveRefresh
          ? result.items
          : [...state.dekonts, ...result.items];
      final visible = filterDekontsByUiKey(merged, filterKey);
      dekontDebugLog('provider.myDekonts.ok', 'count=${visible.length}');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        dekonts: visible,
        nextCursor: useClientFilter ? null : result.nextCursor,
        clearNextCursor: useClientFilter || result.nextCursor == null,
      );
    } catch (e, st) {
      dekontDebugLog('provider.myDekonts.fail', '$e\n$st');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e, context: ApiMessageContext.dekont),
      );
    }
  }

  Future<void> loadMore() => load(filterKey: state.statusFilter, refresh: false);
}

final myDekontsNotifierProvider =
    NotifierProvider.autoDispose<MyDekontsNotifier, MyDekontsState>(
  MyDekontsNotifier.new,
);
class ManagerDekontsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<DekontEntity> dekonts;
  final String? statusFilter;
  final String? nextCursor;
  final String? error;
  final String? reviewError;

  const ManagerDekontsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.dekonts = const [],
    this.statusFilter,
    this.nextCursor,
    this.error,
    this.reviewError,
  });

  bool get canLoadMore =>
      (statusFilter == null || statusFilter!.isEmpty) &&
      nextCursor != null &&
      nextCursor!.isNotEmpty &&
      !isLoading &&
      !isLoadingMore;

  ManagerDekontsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<DekontEntity>? dekonts,
    String? statusFilter,
    String? nextCursor,
    String? error,
    String? reviewError,
    bool clearError = false,
    bool clearReviewError = false,
    bool clearNextCursor = false,
  }) {
    return ManagerDekontsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      dekonts: dekonts ?? this.dekonts,
      statusFilter: statusFilter ?? this.statusFilter,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      error: clearError ? null : (error ?? this.error),
      reviewError: clearReviewError ? null : (reviewError ?? this.reviewError),
    );
  }
}

class ManagerDekontsNotifier extends Notifier<ManagerDekontsState> {
  DekontRepository get _repository => ref.read(dekontRepositoryProvider);

  bool _isReviewing = false;
  String? _buildingId;
  String? _apartmentId;

  @override
  ManagerDekontsState build() => const ManagerDekontsState();
  Future<void> loadBuilding(
    String buildingId, {
    String? filterKey,
    String? apartmentId,
    bool refresh = true,
  }) async {
    final effectiveRefresh =
        refresh ||
        _buildingId != buildingId ||
        _apartmentId != apartmentId ||
        state.statusFilter != filterKey;
    if (!effectiveRefresh && !state.canLoadMore) return;
    final useClientFilter = filterKey != null && filterKey.isNotEmpty;
    _buildingId = buildingId;
    _apartmentId = apartmentId;
    dekontDebugLog('provider.managerDekonts.load', {
      'buildingId': buildingId,
      'filterKey': filterKey,
    });
    state = state.copyWith(
      isLoading: effectiveRefresh,
      isLoadingMore: !effectiveRefresh,
      statusFilter: filterKey,
      clearError: true,
      clearNextCursor: effectiveRefresh,
    );
    try {
      final result = await _repository.getBuildingDekonts(
        buildingId,
        apartmentId: apartmentId,
        cursor: useClientFilter || effectiveRefresh ? null : state.nextCursor,
        paginated: !useClientFilter,
      );
      final merged = effectiveRefresh
          ? result.items
          : [...state.dekonts, ...result.items];
      final visible = filterDekontsByUiKey(merged, filterKey);
      dekontDebugLog('provider.managerDekonts.ok', 'count=${visible.length}');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        dekonts: visible,
        nextCursor: useClientFilter ? null : result.nextCursor,
        clearNextCursor: useClientFilter || result.nextCursor == null,
      );
    } catch (e, st) {
      dekontDebugLog('provider.managerDekonts.fail', '$e\n$st');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e, context: ApiMessageContext.dekont),
      );
    }
  }

  Future<void> loadMore() {
    final id = _buildingId;
    if (id == null || id.isEmpty) return Future.value();
    return loadBuilding(
      id,
      filterKey: state.statusFilter,
      apartmentId: _apartmentId,
      refresh: false,
    );
  }

  Future<bool> review({
    required String id,
    required DekontReviewDecision decision,
    String? note,
    String? dueId,
    List<String>? dueIds,
    double? amount,
  }) async {
    if (_isReviewing) {
      dekontDebugLog('provider.review skip', 'already in flight');
      return false;
    }
    _isReviewing = true;
    state = state.copyWith(clearReviewError: true);
    dekontDebugLog('provider.review start', {
      'id': id,
      'decision': decision.name,
      'dueId': dueId,
      'dueIds': dueIds,
      'amount': amount,
    });
    try {
      await _repository.reviewDekont(
        id: id,
        decision: decision,
        note: note,
        dueId: dueId,
        dueIds: dueIds,
        amount: amount,
      );
      // Aidat önbellek yenilemesi sheet'i bloklamasın — çağıran taraf tetikler.
      dekontDebugLog('provider.review ok');
      return true;
    } catch (e, st) {
      dekontDebugLog('provider.review fail', '$e\n$st');
      if (ref.mounted) {
        state = state.copyWith(
          reviewError: userFacingError(e, context: ApiMessageContext.dekont),
        );
      }
      return false;
    } finally {
      _isReviewing = false;
    }
  }
}

final managerDekontsNotifierProvider =
    NotifierProvider.autoDispose<ManagerDekontsNotifier, ManagerDekontsState>(
  ManagerDekontsNotifier.new,
);