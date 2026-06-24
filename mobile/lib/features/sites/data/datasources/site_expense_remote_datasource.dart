import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../../../core/network/pagination_parse.dart';
import '../../../expenses/data/datasources/expense_remote_datasource.dart';
import '../../../expenses/domain/entities/expense_create_outcome.dart';
import '../../domain/entities/site_expense_create_outcome.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../models/site_expense_model.dart';

abstract class SiteExpenseRemoteDataSource {
  Future<PaginatedListResult<SiteExpenseModel>> getSiteExpenses(
    String siteId, {
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  });

  Future<SiteExpenseSummaryEntity> getSummary(
    String siteId, {
    required int month,
    required int year,
  });

  Future<SiteExpenseCreateOutcome> createSiteExpense(
    String siteId, {
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
    int splitMonths = 1,
    ExpenseCarryForwardPolicyApi carryForwardPolicy =
        ExpenseCarryForwardPolicyApi.warnOnly,
    bool confirmPaidImpact = false,
  });

  Future<SiteExpenseModel> updateSiteExpense(
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    int? targetMonth,
    int? targetYear,
    String? note,
  });

  Future<void> deleteSiteExpense(String expenseId);
}

class SiteExpenseRemoteDataSourceImpl implements SiteExpenseRemoteDataSource {
  SiteExpenseRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<PaginatedListResult<SiteExpenseModel>> getSiteExpenses(
    String siteId, {
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  }) async {
    final query = paginatedQuery(
      cursor: cursor,
      limit: AppConstants.pageSize,
      paginated: paginated,
      extra: {
        'month': ?month,
        'year': ?year,
        'category': ?category,
      },
    );

    final response = await _dioClient.get(
      ApiConstants.siteExpenses(siteId),
      queryParameters: query,
    );
    return parsePaginatedList(
      response.data['data'],
      SiteExpenseModel.fromJson,
    );
  }

  @override
  Future<SiteExpenseSummaryEntity> getSummary(
    String siteId, {
    required int month,
    required int year,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.siteExpensesSummary(siteId),
      queryParameters: {'month': month, 'year': year},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final totalRaw = data['totalAmount'];
    final total = totalRaw is num
        ? totalRaw.toDouble()
        : double.tryParse('$totalRaw') ?? 0;
    return SiteExpenseSummaryEntity(
      month: (data['month'] as num?)?.toInt() ?? month,
      year: (data['year'] as num?)?.toInt() ?? year,
      totalAmount: total,
      currency: (data['currency'] ?? 'TRY') as String,
      apartmentCount: (data['apartmentCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<SiteExpenseCreateOutcome> createSiteExpense(
    String siteId, {
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
    int splitMonths = 1,
    ExpenseCarryForwardPolicyApi carryForwardPolicy =
        ExpenseCarryForwardPolicyApi.warnOnly,
    bool confirmPaidImpact = false,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.siteExpenses(siteId),
      data: {
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toUtc().toIso8601String(),
        'targetMonth': targetMonth,
        'targetYear': targetYear,
        if (note != null && note.isNotEmpty) 'note': note,
        'splitMonths': splitMonths,
        'carryForwardPolicy': carryForwardPolicy.apiValue,
        'confirmPaidImpact': confirmPaidImpact,
      },
    );

    final data = response.data['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Geçersiz site gideri yanıtı');
    }

    if (data['requiresConfirmation'] == true) {
      final next = data['nextPeriod'];
      return SiteExpenseCreateOutcome(
        preview: ExpensePaidImpactPreview(
          message: (data['message'] ?? '') as String,
          paidApartmentCount:
              (data['paidApartmentCount'] as num?)?.toInt() ?? 0,
          perUnitAmount: '${data['perUnitAmount'] ?? '0'}',
          totalUnpaidShare: '${data['totalUnpaidShare'] ?? '0'}',
          nextMonth: next is Map ? (next['month'] as num?)?.toInt() ?? 1 : 1,
          nextYear: next is Map
              ? (next['year'] as num?)?.toInt() ?? DateTime.now().year
              : DateTime.now().year,
          pastMonthWarning: data['pastMonthWarning'] == true,
        ),
      );
    }

    final expenseJson = data['expense'] ?? data;
    if (expenseJson is! Map<String, dynamic>) {
      throw StateError('Geçersiz site gideri yanıtı');
    }

    final warningsRaw = data['warnings'];
    final warnings = warningsRaw is List
        ? warningsRaw.map((e) => '$e').toList()
        : const <String>[];

    return SiteExpenseCreateOutcome(
      expense: SiteExpenseModel.fromJson(expenseJson).toEntity(),
      warnings: warnings,
      pastMonthWarning: data['pastMonthWarning'] == true,
    );
  }

  @override
  Future<SiteExpenseModel> updateSiteExpense(
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    int? targetMonth,
    int? targetYear,
    String? note,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (amount != null) body['amount'] = amount;
    if (category != null) body['category'] = category;
    if (date != null) body['date'] = date.toUtc().toIso8601String();
    if (targetMonth != null) body['targetMonth'] = targetMonth;
    if (targetYear != null) body['targetYear'] = targetYear;
    if (note != null) body['note'] = note.isEmpty ? null : note;

    final response = await _dioClient.put(
      ApiConstants.siteExpense(expenseId),
      data: body,
    );
    return SiteExpenseModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteSiteExpense(String expenseId) async {
    await _dioClient.delete(ApiConstants.siteExpense(expenseId));
  }
}
