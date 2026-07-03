import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../../../core/network/pagination_parse.dart';
<<<<<<< HEAD
import '../../../expenses/data/datasources/expense_remote_datasource.dart';
import '../../../expenses/domain/entities/expense_create_outcome.dart';
import '../../domain/entities/site_expense_create_outcome.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../models/site_expense_model.dart';

abstract class SiteExpenseRemoteDataSource {
  Future<PaginatedListResult<SiteExpenseModel>> getSiteExpenses(
=======
import '../../domain/entities/site_expense_create_outcome.dart';
import '../models/site_expense_model.dart';

abstract class SiteExpenseRemoteDataSource {
  Future<PaginatedListResult<SiteExpenseModel>> fetchSiteExpenses(
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    String siteId, {
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  });

<<<<<<< HEAD
  Future<SiteExpenseSummaryEntity> getSummary(
=======
  Future<SiteExpenseSummaryModel> fetchSiteExpenseSummary(
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
    ExpenseCarryForwardPolicyApi carryForwardPolicy =
        ExpenseCarryForwardPolicyApi.warnOnly,
=======
    String carryForwardPolicy = 'NONE',
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    bool confirmPaidImpact = false,
  });

  Future<SiteExpenseModel> updateSiteExpense(
<<<<<<< HEAD
=======
    String siteId,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
<<<<<<< HEAD
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
=======
    String? note,
  });

  Future<void> deleteSiteExpense(String siteId, String expenseId);
}

class SiteExpenseRemoteDataSourceImpl implements SiteExpenseRemoteDataSource {
  final DioClient _dioClient;

  SiteExpenseRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<PaginatedListResult<SiteExpenseModel>> fetchSiteExpenses(
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
      extra: {
        'month': ?month,
        'year': ?year,
        'category': ?category,
      },
=======
      extra: {'month': ?month, 'year': ?year, 'category': ?category},
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    );

    final response = await _dioClient.get(
      ApiConstants.siteExpenses(siteId),
      queryParameters: query,
    );
<<<<<<< HEAD
    return parsePaginatedList(
      response.data['data'],
      SiteExpenseModel.fromJson,
    );
  }

  @override
  Future<SiteExpenseSummaryEntity> getSummary(
=======
    return parsePaginatedList(response.data['data'], SiteExpenseModel.fromJson);
  }

  @override
  Future<SiteExpenseSummaryModel> fetchSiteExpenseSummary(
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    String siteId, {
    required int month,
    required int year,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.siteExpensesSummary(siteId),
      queryParameters: {'month': month, 'year': year},
    );
<<<<<<< HEAD
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
=======
    return SiteExpenseSummaryModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
    ExpenseCarryForwardPolicyApi carryForwardPolicy =
        ExpenseCarryForwardPolicyApi.warnOnly,
=======
    String carryForwardPolicy = 'NONE',
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
        'carryForwardPolicy': carryForwardPolicy.apiValue,
=======
        'carryForwardPolicy': carryForwardPolicy,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        'confirmPaidImpact': confirmPaidImpact,
      },
    );

    final data = response.data['data'];
    if (data is! Map<String, dynamic>) {
<<<<<<< HEAD
      throw StateError('Geçersiz site gideri yanıtı');
    }

    if (data['requiresConfirmation'] == true) {
      final next = data['nextPeriod'];
      return SiteExpenseCreateOutcome(
        preview: ExpensePaidImpactPreview(
=======
      throw StateError('invalid_site_expense_response');
    }

    if (data['paidApartmentCount'] != null || data['message'] != null) {
      final next = data['nextPeriod'];
      return SiteExpenseCreateOutcome(
        preview: SiteExpensePaidImpactPreview(
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
      throw StateError('Geçersiz site gideri yanıtı');
=======
      throw StateError('invalid_site_expense_response');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
=======
    String siteId,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
<<<<<<< HEAD
    int? targetMonth,
    int? targetYear,
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    String? note,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (amount != null) body['amount'] = amount;
    if (category != null) body['category'] = category;
    if (date != null) body['date'] = date.toUtc().toIso8601String();
<<<<<<< HEAD
    if (targetMonth != null) body['targetMonth'] = targetMonth;
    if (targetYear != null) body['targetYear'] = targetYear;
    if (note != null) body['note'] = note.isEmpty ? null : note;

    final response = await _dioClient.put(
      ApiConstants.siteExpense(expenseId),
=======
    if (note != null) body['note'] = note.isEmpty ? null : note;

    final response = await _dioClient.put(
      ApiConstants.siteExpense(siteId, expenseId),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      data: body,
    );
    return SiteExpenseModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
<<<<<<< HEAD
  Future<void> deleteSiteExpense(String expenseId) async {
    await _dioClient.delete(ApiConstants.siteExpense(expenseId));
=======
  Future<void> deleteSiteExpense(String siteId, String expenseId) async {
    await _dioClient.delete(ApiConstants.siteExpense(siteId, expenseId));
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  }
}
