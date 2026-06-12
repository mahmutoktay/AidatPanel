import '../../../../core/network/api_exception.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/models/expense_model.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDataSource _remote;

  ExpenseRepositoryImpl({required ExpenseDataSource remote}) : _remote = remote;

  @override
  Future<List<ExpenseEntity>> getBuildingExpenses(
    String buildingId, {
    int? month,
    int? year,
    String? category,
  }) async {
    try {
      final models = await _remote.getBuildingExpenses(
        buildingId,
        month: month,
        year: year,
        category: category,
      );
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gider listesi alınırken bir hata oluştu');
    }
  }

  @override
  Future<List<ExpenseEntity>> getMyExpenses({
    int? month,
    int? year,
    String? category,
  }) async {
    try {
      final models = await _remote.getMyExpenses(
        month: month,
        year: year,
        category: category,
      );
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gider listesi alınırken bir hata oluştu');
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
      throw ApiException(message: 'Gider özeti alınırken bir hata oluştu');
    }
  }

  @override
  Future<int> countExpensesInMonth(
    String buildingId, {
    required int month,
    required int year,
  }) async {
    final summary = await getSummary(
      buildingId,
      month: month,
      year: year,
    );
    return summary.byCategory.fold<int>(0, (sum, c) => sum + c.count);
  }

  @override
  Future<ExpenseEntity> createExpense(
    String buildingId, {
    required String title,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
  }) async {
    try {
      final model = await _remote.createExpense(
        buildingId,
        title: title,
        category: ExpenseModel.categoryToApi(category),
        date: date,
        note: note,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gider kaydedilirken bir hata oluştu');
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
        category:
            category != null ? ExpenseModel.categoryToApi(category) : null,
        date: date,
        note: note,
        receiptUrl: receiptUrl,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gider güncellenirken bir hata oluştu');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _remote.deleteExpense(expenseId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Gider silinirken bir hata oluştu');
    }
  }

  @override
  Future<ExpenseEntity> uploadReceipts(String expenseId, List<String> filePaths) async {
    try {
      final model = await _remote.uploadReceipts(expenseId, filePaths);
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Makbuzlar yüklenirken bir hata oluştu');
    }
  }

  ExpenseSummaryEntity _parseSummary(Map<String, dynamic> raw) {
    final total = double.tryParse('${raw['totalAmount']}') ?? 0;
    final byCat = <ExpenseCategorySummary>[];
    final list = raw['byCategory'];
    if (list is List) {
      for (final item in list) {
        if (item is! Map) continue;
        byCat.add(ExpenseCategorySummary(
          category: ExpenseModel.parseCategoryApi('${item['category']}'),
          amount: double.tryParse('${item['amount']}') ?? 0,
          count: (item['count'] as num?)?.toInt() ?? 0,
        ));
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
