import 'package:aidatpanel/core/constants/api_constants.dart';
import 'package:aidatpanel/core/network/paginated_list_result.dart';
import 'package:aidatpanel/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:aidatpanel/features/expenses/data/models/expense_model.dart';
import 'package:aidatpanel/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:aidatpanel/l10n/strings.g.dart';
import 'package:aidatpanel/shared/utils/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.tr);
  });

  group('Smoke — altyapı', () {
    test('API base URL HTTPS kullanır', () {
      expect(ApiConstants.baseUrl.startsWith('https://'), isTrue);
    });

    test('kritik auth endpoint sabitleri tanımlı', () {
      expect(ApiConstants.login, contains('/auth/login'));
      expect(ApiConstants.refresh, contains('/auth/refresh'));
      expect(ApiConstants.buildings, contains('/buildings'));
    });
  });

  group('Smoke — davet kodu (join öncesi)', () {
    test('boş davet kodu reddedilir', () {
      expect(AuthValidators.isValidInviteCode(''), isFalse);
    });

    test('geçerli format normalize edilir', () {
      expect(
        AuthValidators.normalizeInviteCode(' ap3-b12-a9f0 '),
        'AP3-B12-A9F0',
      );
    });
  });

  group('Smoke — gider özeti sayacı', () {
    test('countExpensesInMonth byCategory count toplar', () async {
      final repo = ExpenseRepositoryImpl(remote: _SummaryOnlyExpenseDs());
      final count = await repo.countExpensesInMonth('b1', month: 5, year: 2026);
      expect(count, 3);
    });
  });
}

class _SummaryOnlyExpenseDs implements ExpenseDataSource {
  @override
  Future<Map<String, dynamic>> getSummary(
    String buildingId, {
    required int month,
    required int year,
  }) async {
    return {
      'month': month,
      'year': year,
      'totalAmount': 5700,
      'currency': 'TRY',
      'byCategory': [
        {'category': 'CLEANING', 'amount': 1200, 'count': 2},
        {'category': 'ELEVATOR', 'amount': 4500, 'count': 1},
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
  }) => throw UnimplementedError();

  @override
  Future<PaginatedListResult<ExpenseModel>> getMyExpenses({
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  }) => throw UnimplementedError();

  @override
  Future<ExpenseModel> createExpense(
    String buildingId, {
    required String title,
    required String category,
    required DateTime date,
    String? note,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteExpense(String expenseId) => throw UnimplementedError();

  @override
  Future<ExpenseModel> uploadReceipts(
    String expenseId,
    List<String> filePaths,
  ) async => throw UnimplementedError();

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
}
