import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../debug/dekont_debug_log.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/errors/duplicate_dekont_exception.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/payment_collection_entity.dart';
import '../../domain/repositories/dekont_repository.dart';
import '../../data/datasources/dekont_remote_datasource.dart';
import '../../data/dekont_preview_cache.dart';
import '../../data/repositories/dekont_repository_impl.dart';

final dekontRemoteDataSourceProvider = Provider<DekontRemoteDataSource>((ref) {
  return DekontRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final dekontRepositoryProvider = Provider<DekontRepository>((ref) {
  return DekontRepositoryImpl(
    remote: ref.watch(dekontRemoteDataSourceProvider),
  );
});

/// Yükleme sonrası yerel önizleme — sunucu dosyası henüz hazır değilse kullanılır.
/// autoDispose kullanılmaz; detay ekranına geçince önbellek silinmesin.
final dekontLocalPreviewProvider =
    StateProvider<Map<String, Uint8List>>((ref) => {});

final paymentCollectionProvider =
    FutureProvider.autoDispose<PaymentCollectionEntity>((ref) async {
  return ref.watch(dekontRepositoryProvider).getPaymentCollection();
});

final dekontDetailProvider =
    FutureProvider.autoDispose.family<DekontEntity, String>((ref, id) async {
  return ref.watch(dekontRepositoryProvider).getDekont(id);
});

class MakePaymentState {
  final bool isLoadingInfo;
  final bool isUploading;
  final PaymentCollectionEntity? collection;
  final String? selectedDueId;
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
    this.selectedDueId,
    this.pickedFileName,
    this.pickedFileBytes,
    this.pickedFilePath,
    this.uploadedDekont,
    this.uploadWasDuplicate = false,
    this.uploadWasRecovered = false,
    this.error,
  });

  MakePaymentState copyWith({
    bool? isLoadingInfo,
    bool? isUploading,
    PaymentCollectionEntity? collection,
    String? selectedDueId,
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
      selectedDueId: selectedDueId ?? this.selectedDueId,
      pickedFileName: clearFile ? null : (pickedFileName ?? this.pickedFileName),
      pickedFileBytes: clearFile ? null : (pickedFileBytes ?? this.pickedFileBytes),
      pickedFilePath: clearFile ? null : (pickedFilePath ?? this.pickedFilePath),
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
  ref.read(dekontLocalPreviewProvider.notifier).update(
        (cache) => {
          ...cache,
          dekontId: copy,
        },
      );
  await DekontPreviewCache.save(dekontId, copy);
}

class MakePaymentNotifier extends StateNotifier<MakePaymentState> {
  final DekontRepository _repository;
  final Ref _ref;
  bool _isUploading = false;

  MakePaymentNotifier(this._repository, this._ref)
      : super(const MakePaymentState());

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
    state = state.copyWith(selectedDueId: dueId);
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
    final bytes = state.pickedFileBytes;
    final name = state.pickedFileName;
    if (bytes == null || bytes.isEmpty || name == null || _isUploading) {
      state = state.copyWith(
        error: LocaleSettings
            .instance.currentTranslations.features.dekont.errorNoFileSelected,
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
    dekontDebugLog('provider.upload start', {
      'file': name,
      'dueId': state.selectedDueId,
    });
    try {
      final result = await _repository.uploadDekont(
        fileName: name,
        fileBytes: bytes,
        filePath: state.pickedFilePath,
        dueId: state.selectedDueId,
      );
      final dekont = result.dekont;
      await _cacheLocalPreview(_ref, dekont.id, bytes);
      _ref.invalidate(myDekontsNotifierProvider);
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
      await _cacheLocalPreview(_ref, e.dekont.id, bytes);
      _ref.invalidate(myDekontsNotifierProvider);
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
    StateNotifierProvider.autoDispose<MakePaymentNotifier, MakePaymentState>(
  (ref) => MakePaymentNotifier(ref.watch(dekontRepositoryProvider), ref),
);

class MyDekontsState {
  final bool isLoading;
  final List<DekontEntity> dekonts;
  final String? statusFilter;
  final String? error;

  const MyDekontsState({
    this.isLoading = false,
    this.dekonts = const [],
    this.statusFilter,
    this.error,
  });

  MyDekontsState copyWith({
    bool? isLoading,
    List<DekontEntity>? dekonts,
    String? statusFilter,
    String? error,
    bool clearError = false,
  }) {
    return MyDekontsState(
      isLoading: isLoading ?? this.isLoading,
      dekonts: dekonts ?? this.dekonts,
      statusFilter: statusFilter ?? this.statusFilter,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MyDekontsNotifier extends StateNotifier<MyDekontsState> {
  final DekontRepository _repository;

  MyDekontsNotifier(this._repository) : super(const MyDekontsState());

  Future<void> load({String? status}) async {
    dekontDebugLog('provider.myDekonts.load', 'status=$status');
    state = state.copyWith(
      isLoading: true,
      statusFilter: status,
      clearError: true,
    );
    try {
      final list = await _repository.getMyDekonts(status: status);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      dekontDebugLog('provider.myDekonts.ok', 'count=${list.length}');
      state = state.copyWith(isLoading: false, dekonts: list);
    } catch (e, st) {
      dekontDebugLog('provider.myDekonts.fail', '$e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e, context: ApiMessageContext.dekont),
      );
    }
  }
}

final myDekontsNotifierProvider =
    StateNotifierProvider.autoDispose<MyDekontsNotifier, MyDekontsState>(
  (ref) => MyDekontsNotifier(ref.watch(dekontRepositoryProvider)),
);

class ManagerDekontsState {
  final bool isLoading;
  final List<DekontEntity> dekonts;
  final String? statusFilter;
  final String? error;
  final String? reviewError;

  const ManagerDekontsState({
    this.isLoading = false,
    this.dekonts = const [],
    this.statusFilter,
    this.error,
    this.reviewError,
  });

  ManagerDekontsState copyWith({
    bool? isLoading,
    List<DekontEntity>? dekonts,
    String? statusFilter,
    String? error,
    String? reviewError,
    bool clearError = false,
    bool clearReviewError = false,
  }) {
    return ManagerDekontsState(
      isLoading: isLoading ?? this.isLoading,
      dekonts: dekonts ?? this.dekonts,
      statusFilter: statusFilter ?? this.statusFilter,
      error: clearError ? null : (error ?? this.error),
      reviewError: clearReviewError ? null : (reviewError ?? this.reviewError),
    );
  }
}

class ManagerDekontsNotifier extends StateNotifier<ManagerDekontsState> {
  final DekontRepository _repository;
  bool _isReviewing = false;

  ManagerDekontsNotifier(this._repository) : super(const ManagerDekontsState());

  Future<void> loadBuilding(
    String buildingId, {
    String? status,
    String? apartmentId,
  }) async {
    dekontDebugLog('provider.managerDekonts.load', {
      'buildingId': buildingId,
      'status': status,
    });
    state = state.copyWith(
      isLoading: true,
      statusFilter: status,
      clearError: true,
    );
    try {
      final list = await _repository.getBuildingDekonts(
        buildingId,
        status: status,
        apartmentId: apartmentId,
      );
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      dekontDebugLog('provider.managerDekonts.ok', 'count=${list.length}');
      state = state.copyWith(isLoading: false, dekonts: list);
    } catch (e, st) {
      dekontDebugLog('provider.managerDekonts.fail', '$e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e, context: ApiMessageContext.dekont),
      );
    }
  }

  Future<bool> review({
    required String id,
    required DekontReviewDecision decision,
    String? note,
    String? dueId,
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
    });
    try {
      await _repository.reviewDekont(
        id: id,
        decision: decision,
        note: note,
        dueId: dueId,
      );
      dekontDebugLog('provider.review ok');
      return true;
    } catch (e, st) {
      dekontDebugLog('provider.review fail', '$e\n$st');
      state = state.copyWith(
        reviewError: userFacingError(e, context: ApiMessageContext.dekont),
      );
      return false;
    } finally {
      _isReviewing = false;
    }
  }
}

final managerDekontsNotifierProvider =
    StateNotifierProvider.autoDispose<ManagerDekontsNotifier, ManagerDekontsState>(
  (ref) => ManagerDekontsNotifier(ref.watch(dekontRepositoryProvider)),
);
