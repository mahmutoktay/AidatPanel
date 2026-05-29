import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getBuildingExpenses(
    String buildingId, {
    int? month,
    int? year,
    String? category,
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
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? note,
    String? receiptUrl,
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

  Future<String> uploadReceipt(String expenseId, String filePath);
}
