import 'package:aidatpanel/core/network/api_exception.dart';
import 'package:aidatpanel/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:aidatpanel/features/expenses/data/models/expense_model.dart';
import 'package:aidatpanel/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:aidatpanel/features/expenses/domain/entities/expense_entity.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  group('ExpenseRepositoryImpl', () {
    test('getSummary string amount parse eder', () async {
      final repo = ExpenseRepositoryImpl(remote: _FakeExpenseDs());
      final summary = await repo.getSummary('b1', month: 5, year: 2026);
      expect(summary.totalAmount, 1250.5);
      expect(summary.byCategory.length, 1);
      expect(summary.byCategory.first.count, 2);
    });

    test('createExpense receiptUrl ile gönderir', () async {
      final ds = _FakeExpenseDs();
      final repo = ExpenseRepositoryImpl(remote: ds);
      await repo.createExpense(
        'b1',
        title: 'Test',
        amount: 100,
        category: ExpenseCategory.cleaning,
        date: DateTime(2026, 5, 1),
        receiptUrl: 'https://example.com/r.pdf',
      );
      expect(ds.lastCreateReceiptUrl, 'https://example.com/r.pdf');
    });
  });
}

class _FakeExpenseDs implements ExpenseDataSource {
  String? lastCreateReceiptUrl;

  @override
  Future<ExpenseModel> createExpense(
    String buildingId, {
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
    String? receiptUrl,
  }) async {
    lastCreateReceiptUrl = receiptUrl;
    return ExpenseModel(
      id: 'e1',
      buildingId: buildingId,
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
      receiptUrl: receiptUrl,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Map<String, dynamic>> getSummary(
    String buildingId, {
    required int month,
    required int year,
  }) async {
    return {
      'month': month,
      'year': year,
      'totalAmount': '1250.50',
      'currency': 'TRY',
      'byCategory': [
        {'category': 'CLEANING', 'amount': '1250.50', 'count': 2},
      ],
    };
  }

  @override
  Future<List<ExpenseModel>> getBuildingExpenses(
    String buildingId, {
    int? month,
    int? year,
    String? category,
  }) =>
      Future.value([]);

  @override
  Future<ExpenseModel> updateExpense(
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? receiptUrl,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> deleteExpense(String expenseId) => throw UnimplementedError();

  @override
  Future<String> uploadReceipt(String expenseId, String filePath) async {
    throw NotFoundException();
  }
}
