import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/user_error_message.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/payment_collection_entity.dart';
import '../../domain/repositories/dekont_repository.dart';
import '../../data/datasources/dekont_remote_datasource.dart';
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
  final bool isPolling;
  final PaymentCollectionEntity? collection;
  final String? selectedDueId;
  final String? pickedFilePath;
  final DekontEntity? uploadedDekont;
  final String? error;

  const MakePaymentState({
    this.isLoadingInfo = false,
    this.isUploading = false,
    this.isPolling = false,
    this.collection,
    this.selectedDueId,
    this.pickedFilePath,
    this.uploadedDekont,
    this.error,
  });

  MakePaymentState copyWith({
    bool? isLoadingInfo,
    bool? isUploading,
    bool? isPolling,
    PaymentCollectionEntity? collection,
    String? selectedDueId,
    String? pickedFilePath,
    DekontEntity? uploadedDekont,
    String? error,
    bool clearError = false,
    bool clearFile = false,
  }) {
    return MakePaymentState(
      isLoadingInfo: isLoadingInfo ?? this.isLoadingInfo,
      isUploading: isUploading ?? this.isUploading,
      isPolling: isPolling ?? this.isPolling,
      collection: collection ?? this.collection,
      selectedDueId: selectedDueId ?? this.selectedDueId,
      pickedFilePath:
          clearFile ? null : (pickedFilePath ?? this.pickedFilePath),
      uploadedDekont: uploadedDekont ?? this.uploadedDekont,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MakePaymentNotifier extends StateNotifier<MakePaymentState> {
  final DekontRepository _repository;
  bool _isUploading = false;

  MakePaymentNotifier(this._repository) : super(const MakePaymentState());

  Future<void> loadPaymentInfo() async {
    state = state.copyWith(isLoadingInfo: true, clearError: true);
    try {
      final collection = await _repository.getPaymentCollection();
      state = state.copyWith(isLoadingInfo: false, collection: collection);
    } catch (e) {
      state = state.copyWith(
        isLoadingInfo: false,
        error: userFacingError(e),
      );
    }
  }

  void selectDue(String? dueId) {
    state = state.copyWith(selectedDueId: dueId);
  }

  void setPickedFile(String? path) {
    state = state.copyWith(pickedFilePath: path, clearError: true);
  }

  Future<DekontEntity?> upload() async {
    final path = state.pickedFilePath;
    if (path == null || path.isEmpty || _isUploading) return null;
    _isUploading = true;
    state = state.copyWith(isUploading: true, clearError: true);
    try {
      var dekont = await _repository.uploadDekont(
        filePath: path,
        dueId: state.selectedDueId,
      );
      state = state.copyWith(
        isUploading: false,
        uploadedDekont: dekont,
        clearFile: true,
      );
      _isUploading = false;
      if (dekont.isProcessing) {
        dekont = await _pollUntilSettled(dekont.id) ?? dekont;
        state = state.copyWith(uploadedDekont: dekont);
      }
      return dekont;
    } catch (e) {
      state = state.copyWith(isUploading: false, error: userFacingError(e));
      _isUploading = false;
      return null;
    }
  }

  Future<DekontEntity?> _pollUntilSettled(String id) async {
    state = state.copyWith(isPolling: true);
    try {
      for (var i = 0; i < 15; i++) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final d = await _repository.getDekont(id);
        if (!d.isProcessing &&
            d.status.apiValue != 'MATCHING' &&
            d.status.apiValue != 'PARSED') {
          return d;
        }
      }
      return await _repository.getDekont(id);
    } finally {
      state = state.copyWith(isPolling: false);
    }
  }
}

final makePaymentNotifierProvider =
    StateNotifierProvider.autoDispose<MakePaymentNotifier, MakePaymentState>(
  (ref) => MakePaymentNotifier(ref.watch(dekontRepositoryProvider)),
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
    state = state.copyWith(
      isLoading: true,
      statusFilter: status,
      clearError: true,
    );
    try {
      final list = await _repository.getMyDekonts(status: status);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(isLoading: false, dekonts: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
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

  const ManagerDekontsState({
    this.isLoading = false,
    this.dekonts = const [],
    this.statusFilter,
    this.error,
  });

  ManagerDekontsState copyWith({
    bool? isLoading,
    List<DekontEntity>? dekonts,
    String? statusFilter,
    String? error,
    bool clearError = false,
  }) {
    return ManagerDekontsState(
      isLoading: isLoading ?? this.isLoading,
      dekonts: dekonts ?? this.dekonts,
      statusFilter: statusFilter ?? this.statusFilter,
      error: clearError ? null : (error ?? this.error),
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
      state = state.copyWith(isLoading: false, dekonts: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }

  Future<bool> review({
    required String id,
    required DekontReviewDecision decision,
    String? note,
    String? dueId,
  }) async {
    if (_isReviewing) return false;
    _isReviewing = true;
    try {
      await _repository.reviewDekont(
        id: id,
        decision: decision,
        note: note,
        dueId: dueId,
      );
      return true;
    } catch (_) {
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
