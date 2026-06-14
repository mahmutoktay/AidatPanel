import 'package:aidatpanel/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:aidatpanel/features/expenses/data/models/expense_model.dart';
import 'package:aidatpanel/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:aidatpanel/core/network/paginated_list_result.dart';
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

    test('uploadReceipts makbuzları gönderir', () async {
      final ds = _FakeExpenseDs();
      final repo = ExpenseRepositoryImpl(remote: ds);
      await repo.uploadReceipts('e1', ['/path/to/receipt.jpg']);
      expect(ds.lastUploadExpenseId, 'e1');
      expect(ds.lastUploadFilePaths, ['/path/to/receipt.jpg']);
    });
  });
}

class _FakeExpenseDs implements ExpenseDataSource {
  String? lastUploadExpenseId;
  List<String>? lastUploadFilePaths;

  @override
  Future<ExpenseModel> createExpense(
    String buildingId, {
    required String title,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    return ExpenseModel(
      id: 'e1',
      buildingId: buildingId,
      title: title,
      amount: null,
      category: category,
      date: date,
      note: note,
      receiptUrl: null,
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
  Future<PaginatedListResult<ExpenseModel>> getBuildingExpenses(
    String buildingId, {
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  }) => Future.value(const PaginatedListResult(items: []));

  @override
  Future<PaginatedListResult<ExpenseModel>> getMyExpenses({
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  }) => Future.value(const PaginatedListResult(items: []));

  @override
  Future<ExpenseModel> updateExpense(
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? receiptUrl,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteExpense(String expenseId) => throw UnimplementedError();

  @override
  Future<ExpenseModel> uploadReceipts(
    String expenseId,
    List<String> filePaths,
  ) async {
    lastUploadExpenseId = expenseId;
    lastUploadFilePaths = filePaths;
    return ExpenseModel(
      id: expenseId,
      buildingId: 'b1',
      title: 'Test',
      amount: 150,
      category: 'CLEANING',
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}
