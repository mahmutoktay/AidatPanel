import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../../../core/network/pagination_parse.dart';
import '../models/expense_model.dart';
import '../../domain/entities/expense_create_outcome.dart';

enum ExpenseCarryForwardPolicyApi { carryToNextMonth, warnOnly }

extension ExpenseCarryForwardPolicyApiX on ExpenseCarryForwardPolicyApi {
  String get apiValue => switch (this) {
        ExpenseCarryForwardPolicyApi.carryToNextMonth => 'CARRY_TO_NEXT_MONTH',
        ExpenseCarryForwardPolicyApi.warnOnly => 'WARN_ONLY',
      };
}

abstract class ExpenseDataSource {
  Future<PaginatedListResult<ExpenseModel>> getBuildingExpenses(
    String buildingId, {
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  });

  Future<PaginatedListResult<ExpenseModel>> getMyExpenses({
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  });

  Future<Map<String, dynamic>> getSummary(
    String buildingId, {
    required int month,
    required int year,
  });

  Future<ExpenseCreateOutcome> createExpense(
    String buildingId, {
    required String title,
    double? amount,
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

  Future<ExpenseModel> updateExpense(
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? receiptUrl,
  });

  Future<void> deleteExpense(String expenseId);

  /// Makbuz fotoğrafları — `POST /expenses/{id}/proof` (multipart array).
  Future<ExpenseModel> uploadReceipts(String expenseId, List<String> filePaths);
}

class ExpenseRemoteDataSource implements ExpenseDataSource {
  final DioClient _dioClient;

  ExpenseRemoteDataSource({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<PaginatedListResult<ExpenseModel>> getBuildingExpenses(
    String buildingId, {
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
      ApiConstants.buildingExpenses(buildingId),
      queryParameters: query,
    );
    return parsePaginatedList(response.data['data'], ExpenseModel.fromJson);
  }

  @override
  Future<PaginatedListResult<ExpenseModel>> getMyExpenses({
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
      ApiConstants.myExpenses,
      queryParameters: query,
    );
    return parsePaginatedList(response.data['data'], ExpenseModel.fromJson);
  }

  @override
  Future<Map<String, dynamic>> getSummary(
    String buildingId, {
    required int month,
    required int year,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.buildingExpensesSummary(buildingId),
      queryParameters: {'month': month, 'year': year},
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<ExpenseCreateOutcome> createExpense(
    String buildingId, {
    required String title,
    double? amount,
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
      ApiConstants.buildingExpenses(buildingId),
      data: {
        'title': title,
        'amount': ?amount,
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
      throw StateError('Geçersiz gider yanıtı');
    }

    if (data['requiresConfirmation'] == true) {
      final next = data['nextPeriod'];
      return ExpenseCreateOutcome(
        preview: ExpensePaidImpactPreview(
          message: (data['message'] ?? '') as String,
          paidApartmentCount: (data['paidApartmentCount'] as num?)?.toInt() ?? 0,
          perUnitAmount: '${data['perUnitAmount'] ?? '0'}',
          totalUnpaidShare: '${data['totalUnpaidShare'] ?? '0'}',
          nextMonth: next is Map ? (next['month'] as num?)?.toInt() ?? 1 : 1,
          nextYear: next is Map ? (next['year'] as num?)?.toInt() ?? DateTime.now().year : DateTime.now().year,
          pastMonthWarning: data['pastMonthWarning'] == true,
        ),
      );
    }

    final expenseJson = data['expense'] ?? data;
    if (expenseJson is! Map<String, dynamic>) {
      throw StateError('Geçersiz gider yanıtı');
    }

    final warningsRaw = data['warnings'];
    final warnings = warningsRaw is List
        ? warningsRaw.map((e) => '$e').toList()
        : const <String>[];

    return ExpenseCreateOutcome(
      expense: ExpenseModel.fromJson(expenseJson).toEntity(),
      warnings: warnings,
      pastMonthWarning: data['pastMonthWarning'] == true,
    );
  }

  @override
  Future<ExpenseModel> updateExpense(
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? receiptUrl,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (amount != null) data['amount'] = amount;
    if (category != null) data['category'] = category;
    if (date != null) data['date'] = date.toUtc().toIso8601String();
    if (note != null) data['note'] = note.isEmpty ? null : note;
    if (receiptUrl != null) {
      data['receiptUrl'] = receiptUrl.isEmpty ? null : receiptUrl;
    }

    final response = await _dioClient.put(
      ApiConstants.expense(expenseId),
      data: data,
    );
    return ExpenseModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _dioClient.delete(ApiConstants.expense(expenseId));
  }

  @override
  Future<ExpenseModel> uploadReceipts(
    String expenseId,
    List<String> filePaths,
  ) async {
    Future<FormData> buildForm() async {
      final form = FormData();
      for (final path in filePaths) {
        final segments = path.replaceAll('\\', '/').split('/');
        final fileName = segments.isNotEmpty ? segments.last : 'receipt.jpg';
        form.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }
      return form;
    }

    final response = await _dioClient.postMultipart(
      ApiConstants.expenseProof(expenseId),
      data: await buildForm(),
      rebuildFormData: buildForm,
    );

    return ExpenseModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
