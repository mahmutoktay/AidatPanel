import '../../../../core/network/api_exception.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/models/expense_model.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_create_outcome.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDataSource _remote;

  ExpenseRepositoryImpl({required ExpenseDataSource remote}) : _remote = remote;

  @override
  Future<PaginatedListResult<ExpenseEntity>> getBuildingExpenses(
    String buildingId, {
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  }) async {
    try {
      final result = await _remote.getBuildingExpenses(
        buildingId,
        month: month,
        year: year,
        category: category,
        cursor: cursor,
        paginated: paginated,
      );
      return PaginatedListResult(
        items: result.items.map((m) => m.toEntity()).toList(),
        nextCursor: result.nextCursor,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'expenses_fetch_failed');
    }
  }

  @override
  Future<PaginatedListResult<ExpenseEntity>> getMyExpenses({
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  }) async {
    try {
      final result = await _remote.getMyExpenses(
        month: month,
        year: year,
        category: category,
        cursor: cursor,
        paginated: paginated,
      );
      return PaginatedListResult(
        items: result.items.map((m) => m.toEntity()).toList(),
        nextCursor: result.nextCursor,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'expenses_fetch_failed');
    }
  }

  @override
  Future<ExpenseSummaryEntity> getSummary(
    String buildingId, {
    required int month,
    required int year,
  }) async {
    try {
      final raw = await _remote.getSummary(
        buildingId,
        month: month,
        year: year,
      );
      return _parseSummary(raw);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'expense_summary_fetch_failed');
    }
  }

  @override
  Future<int> countExpensesInMonth(
    String buildingId, {
    required int month,
    required int year,
  }) async {
    final summary = await getSummary(buildingId, month: month, year: year);
    return summary.byCategory.fold<int>(0, (sum, c) => sum + c.count);
  }

  ExpenseCarryForwardPolicyApi _mapPolicy(ExpenseCarryForwardPolicy policy) {
    switch (policy) {
      case ExpenseCarryForwardPolicy.carryToNextMonth:
        return ExpenseCarryForwardPolicyApi.carryToNextMonth;
      case ExpenseCarryForwardPolicy.warnOnly:
        return ExpenseCarryForwardPolicyApi.warnOnly;
    }
  }

  @override
  Future<ExpenseCreateOutcome> createExpense(
    String buildingId, {
    required String title,
    double? amount,
    required ExpenseCategory category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
    int splitMonths = 1,
    ExpenseCarryForwardPolicy carryForwardPolicy =
        ExpenseCarryForwardPolicy.warnOnly,
    bool confirmPaidImpact = false,
  }) async {
    try {
      return await _remote.createExpense(
        buildingId,
        title: title,
        amount: amount,
        category: ExpenseModel.categoryToApi(category),
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
        note: note,
        splitMonths: splitMonths,
        carryForwardPolicy: _mapPolicy(carryForwardPolicy),
        confirmPaidImpact: confirmPaidImpact,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'expense_create_failed');
    }
  }

  @override
  Future<ExpenseEntity> updateExpense(
    String expenseId, {
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    String? receiptUrl,
  }) async {
    try {
      final model = await _remote.updateExpense(
        expenseId,
        title: title,
        amount: amount,
        category: category != null
            ? ExpenseModel.categoryToApi(category)
            : null,
        date: date,
        note: note,
        receiptUrl: receiptUrl,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'expense_update_failed');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _remote.deleteExpense(expenseId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'expense_delete_failed');
    }
  }

  @override
  Future<ExpenseEntity> uploadReceipts(
    String expenseId,
    List<String> filePaths,
  ) async {
    try {
      final model = await _remote.uploadReceipts(expenseId, filePaths);
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'expense_receipts_upload_failed');
    }
  }

  ExpenseSummaryEntity _parseSummary(Map<String, dynamic> raw) {
    final total = double.tryParse('${raw['totalAmount']}') ?? 0;
    final byCat = <ExpenseCategorySummary>[];
    final list = raw['byCategory'];
    if (list is List) {
      for (final item in list) {
        if (item is! Map) continue;
        byCat.add(
          ExpenseCategorySummary(
            category: ExpenseModel.parseCategoryApi('${item['category']}'),
            amount: double.tryParse('${item['amount']}') ?? 0,
            count: (item['count'] as num?)?.toInt() ?? 0,
          ),
        );
      }
    }
    return ExpenseSummaryEntity(
      month: (raw['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (raw['year'] as num?)?.toInt() ?? DateTime.now().year,
      totalAmount: total,
      currency: (raw['currency'] as String?) ?? 'TRY',
      byCategory: byCat,
    );
  }
}
