import '../../../../core/network/paginated_list_result.dart';
import '../entities/expense_create_outcome.dart';
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
