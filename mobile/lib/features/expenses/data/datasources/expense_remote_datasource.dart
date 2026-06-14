import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../../../core/network/pagination_parse.dart';
import '../models/expense_model.dart';

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

  Future<ExpenseModel> createExpense(
    String buildingId, {
    required String title,
    required String category,
    required DateTime date,
    String? note,
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
  Future<ExpenseModel> createExpense(
    String buildingId, {
    required String title,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.buildingExpenses(buildingId),
      data: {
        'title': title,
        'category': category,
        'date': date.toUtc().toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return ExpenseModel.fromJson(response.data['data'] as Map<String, dynamic>);
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
