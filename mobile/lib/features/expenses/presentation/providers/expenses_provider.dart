import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';

final expenseRemoteDataSourceProvider = Provider<ExpenseDataSource>((ref) {
  return ExpenseRemoteDataSource(dioClient: ref.watch(dioClientProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    remote: ref.watch(expenseRemoteDataSourceProvider),
  );
});

/// Geriye uyumluluk — dev mock override bu provider üzerinden çalışır.
@Deprecated('Use expenseRemoteDataSourceProvider')
final expenseDataSourceProvider = expenseRemoteDataSourceProvider;

class ExpensesState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<ExpenseEntity> expenses;
  final ExpenseSummaryEntity? summary;
  final String? nextCursor;
  final String? error;
  final String? buildingId;
  final int? month;
  final int? year;

  const ExpensesState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.expenses = const [],
    this.summary,
    this.nextCursor,
    this.error,
    this.buildingId,
    this.month,
    this.year,
  });

  bool get canLoadMore =>
      nextCursor != null &&
      nextCursor!.isNotEmpty &&
      !isLoading &&
      !isLoadingMore;

  ExpensesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ExpenseEntity>? expenses,
    ExpenseSummaryEntity? summary,
    String? nextCursor,
    String? error,
    String? buildingId,
    int? month,
    int? year,
    bool clearError = false,
    bool clearSummary = false,
    bool clearNextCursor = false,
  }) {
    return ExpensesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      expenses: expenses ?? this.expenses,
      summary: clearSummary ? null : (summary ?? this.summary),
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      error: clearError ? null : (error ?? this.error),
      buildingId: buildingId ?? this.buildingId,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

class ExpensesNotifier extends Notifier<ExpensesState> {
  ExpenseRepository get _repository => ref.read(expenseRepositoryProvider);

  @override
  ExpensesState build() => const ExpensesState();
  Future<void> load(
    String buildingId, {
    bool refresh = true,
    int? month,
    int? year,
  }) async {
    final filtersChanged =
        state.buildingId != buildingId ||
        state.month != month ||
        state.year != year;
    final effectiveRefresh = refresh || filtersChanged;
    if (!effectiveRefresh && !state.canLoadMore) return;
    state = state.copyWith(
      isLoading: effectiveRefresh,
      isLoadingMore: !effectiveRefresh,
      clearError: true,
      buildingId: buildingId,
      month: month,
      year: year,
      clearNextCursor: effectiveRefresh,
    );
    try {
      final result = await _repository.getBuildingExpenses(
        buildingId,
        month: month,
        year: year,
        cursor: effectiveRefresh ? null : state.nextCursor,
      );
      ExpenseSummaryEntity? summary;
      if (effectiveRefresh && month != null && year != null) {
        summary = await _repository.getSummary(
          buildingId,
          month: month,
          year: year,
        );
      }
      final merged = effectiveRefresh
          ? result.items
          : [...state.expenses, ...result.items];
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        expenses: merged,
        summary: summary,
        nextCursor: result.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  Future<void> loadMyExpenses({
    bool refresh = true,
    int? month,
    int? year,
  }) async {
    final filtersChanged =
        state.buildingId != null || state.month != month || state.year != year;
    final effectiveRefresh = refresh || filtersChanged;
    if (!effectiveRefresh && !state.canLoadMore) return;
    state = state.copyWith(
      isLoading: effectiveRefresh,
      isLoadingMore: !effectiveRefresh,
      clearError: true,
      buildingId: null,
      month: month,
      year: year,
      clearNextCursor: effectiveRefresh,
    );
    try {
      final result = await _repository.getMyExpenses(
        month: month,
        year: year,
        cursor: effectiveRefresh ? null : state.nextCursor,
      );
      final merged = effectiveRefresh
          ? result.items
          : [...state.expenses, ...result.items];
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        expenses: merged,
        clearSummary: true,
        nextCursor: result.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  Future<void> loadMore() async {
    final id = state.buildingId;
    if (id == null) {
      await loadMyExpenses(
        refresh: false,
        month: state.month,
        year: state.year,
      );
      return;
    }
    await load(id, refresh: false, month: state.month, year: state.year);
  }

  Future<void> reload() async {
    final id = state.buildingId;
    if (id == null) {
      await loadMyExpenses(month: state.month, year: state.year);
    } else {
      await load(id, month: state.month, year: state.year);
    }
  }

  Future<({bool success, String? receiptWarning, bool receiptUploadDeferred})>
  create({
    required String buildingId,
    required String title,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
    List<String>? receiptFilePaths,
  }) async {
    try {
      final entity = await _repository.createExpense(
        buildingId,
        title: title,
        category: category,
        date: date,
        note: note,
      );
      final upload = await _tryUploadReceipts(entity.id, receiptFilePaths);
      await load(buildingId, month: state.month, year: state.year);
      return (
        success: true,
        receiptWarning: upload.warning,
        receiptUploadDeferred: upload.deferred,
      );
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return (
        success: false,
        receiptWarning: null,
        receiptUploadDeferred: false,
      );
    }
  }

  Future<({bool success, String? receiptWarning, bool receiptUploadDeferred})>
  update({
    required String expenseId,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    String? receiptUrl,
    List<String>? receiptFilePaths,
  }) async {
    try {
      await _repository.updateExpense(
        expenseId,
        title: title,
        amount: amount,
        category: category,
        date: date,
        note: note,
        receiptUrl: receiptUrl,
      );
      final upload = await _tryUploadReceipts(expenseId, receiptFilePaths);
      await reload();
      return (
        success: true,
        receiptWarning: upload.warning,
        receiptUploadDeferred: upload.deferred,
      );
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return (
        success: false,
        receiptWarning: null,
        receiptUploadDeferred: false,
      );
    }
  }

  /// Makbuz dosyası: canlı API'de `/proof` yoksa gider kaydı kalır, `deferred` döner.
  Future<({String? warning, bool deferred})> _tryUploadReceipts(
    String expenseId,
    List<String>? receiptFilePaths,
  ) async {
    if (receiptFilePaths == null || receiptFilePaths.isEmpty) {
      return (warning: null, deferred: false);
    }
    try {
      await _repository.uploadReceipts(expenseId, receiptFilePaths);
      return (warning: null, deferred: false);
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 405) {
        return (warning: null, deferred: true);
      }
      return (warning: userFacingError(e), deferred: false);
    } catch (e) {
      return (warning: userFacingError(e), deferred: false);
    }
  }

  Future<bool> delete(String expenseId) async {
    try {
      await _repository.deleteExpense(expenseId);
      await reload();
      return true;
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return false;
    }
  }
}

final expensesNotifierProvider =
    NotifierProvider<ExpensesNotifier, ExpensesState>(ExpensesNotifier.new);