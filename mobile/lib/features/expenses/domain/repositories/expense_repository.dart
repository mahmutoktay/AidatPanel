import '../../../../core/network/paginated_list_result.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<PaginatedListResult<ExpenseEntity>> getBuildingExpenses(
    String buildingId, {
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  });

  Future<PaginatedListResult<ExpenseEntity>> getMyExpenses({
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  });

  Future<ExpenseSummaryEntity> getSummary(
    String buildingId, {
    required int month,
    required int year,
  });

  /// Bu ayki gider kayıt sayısı (özet endpoint — tam liste çekilmez).
  Future<int> countExpensesInMonth(
    String buildingId, {
    required int month,
    required int year,
  });

  Future<ExpenseEntity> createExpense(
    String buildingId, {
    required String title,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
  });

  Future<ExpenseEntity> updateExpense(
    String expenseId, {
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    String? receiptUrl,
  });

  Future<void> deleteExpense(String expenseId);

  Future<ExpenseEntity> uploadReceipts(
    String expenseId,
    List<String> filePaths,
  );
}
