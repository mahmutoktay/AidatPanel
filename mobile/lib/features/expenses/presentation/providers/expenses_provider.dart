import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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
  final List<ExpenseEntity> expenses;
  final ExpenseSummaryEntity? summary;
  final String? error;
  final String? buildingId;
  final int? month;
  final int? year;

  const ExpensesState({
    this.isLoading = false,
    this.expenses = const [],
    this.summary,
    this.error,
    this.buildingId,
    this.month,
    this.year,
  });

  ExpensesState copyWith({
    bool? isLoading,
    List<ExpenseEntity>? expenses,
    ExpenseSummaryEntity? summary,
    String? error,
    String? buildingId,
    int? month,
    int? year,
    bool clearError = false,
    bool clearSummary = false,
  }) {
    return ExpensesState(
      isLoading: isLoading ?? this.isLoading,
      expenses: expenses ?? this.expenses,
      summary: clearSummary ? null : (summary ?? this.summary),
      error: clearError ? null : (error ?? this.error),
      buildingId: buildingId ?? this.buildingId,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

class ExpensesNotifier extends StateNotifier<ExpensesState> {
  final ExpenseRepository _repository;

  ExpensesNotifier(this._repository) : super(const ExpensesState());

  Future<void> load(
    String buildingId, {
    int? month,
    int? year,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      buildingId: buildingId,
      month: month,
      year: year,
    );
    try {
      final expenses = await _repository.getBuildingExpenses(
        buildingId,
        month: month,
        year: year,
      );
      ExpenseSummaryEntity? summary;
      if (month != null && year != null) {
        summary = await _repository.getSummary(
          buildingId,
          month: month,
          year: year,
        );
      }
      state = state.copyWith(
        isLoading: false,
        expenses: expenses,
        summary: summary,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e),
      );
    }
  }

  Future<void> reload() async {
    final id = state.buildingId;
    if (id == null) return;
    await load(id, month: state.month, year: state.year);
  }

  Future<({bool success, String? receiptWarning, bool receiptUploadDeferred})>
      create({
    required String buildingId,
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
    String? receiptUrl,
    String? receiptFilePath,
  }) async {
    try {
      final entity = await _repository.createExpense(
        buildingId,
        title: title,
        amount: amount,
        category: category,
        date: date,
        note: note,
        receiptUrl: receiptUrl,
      );
      final upload = await _tryUploadReceipt(
        entity.id,
        receiptFilePath,
      );
      await load(buildingId, month: state.month, year: state.year);
      return (
        success: true,
        receiptWarning: upload.warning,
        receiptUploadDeferred: upload.deferred,
      );
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return (success: false, receiptWarning: null, receiptUploadDeferred: false);
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
    String? receiptFilePath,
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
      final upload = await _tryUploadReceipt(
        expenseId,
        receiptFilePath,
      );
      await reload();
      return (
        success: true,
        receiptWarning: upload.warning,
        receiptUploadDeferred: upload.deferred,
      );
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return (success: false, receiptWarning: null, receiptUploadDeferred: false);
    }
  }

  /// Makbuz dosyası: canlı API'de `/proof` yoksa gider kaydı kalır, `deferred` döner.
  Future<({String? warning, bool deferred})> _tryUploadReceipt(
    String expenseId,
    String? receiptFilePath,
  ) async {
    if (receiptFilePath == null || receiptFilePath.isEmpty) {
      return (warning: null, deferred: false);
    }
    try {
      await _repository.uploadReceipt(expenseId, receiptFilePath);
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
    StateNotifierProvider<ExpensesNotifier, ExpensesState>((ref) {
  return ExpensesNotifier(ref.watch(expenseRepositoryProvider));
});
