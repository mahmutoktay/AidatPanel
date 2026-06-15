import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/paginated_list_result.dart';
import '../../../../core/network/pagination_parse.dart';
import '../models/due_model.dart';

abstract class DuesRemoteDataSource {
  /// Tur 5 / §10/3 — backend `dueController.getDuesByBuildingController`
  /// `month`, `year`, `status` query parametrelerini destekler. Tüm
  /// filtreler opsiyonel ve null gelirse sunucu tüm dues'u döner.
  Future<PaginatedListResult<DueModel>> getBuildingDues(
    String buildingId, {
    int? month,
    int? year,
    String? status,
    String? cursor,
    bool paginated = true,
  });

  /// Belge §7: `GET /me/dues?month=&year=&status=` — sakin tarafında
  /// aynı filtre setini kabul eder.
  Future<PaginatedListResult<DueModel>> getMyDues({
    int? month,
    int? year,
    String? status,
    String? cursor,
    bool paginated = true,
  });

  Future<DueModel> updateDueStatus({
    required String buildingId,
    required String dueId,
    required String status,
  });
  Future<void> updateBuildingDueAmount({
    required String buildingId,
    required double dueAmount,
    int? dueDay,
    String? currency,
    bool affectCurrent = false,
  });
  Future<int> remindBuildingDues(
    String buildingId, {
    List<String>? dueIds,
  });
}

class DuesRemoteDataSourceImpl implements DuesRemoteDataSource {
  final DioClient _dioClient;

  DuesRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  Map<String, dynamic> _buildDuesQuery({
    int? month,
    int? year,
    String? status,
    String? cursor,
    required bool paginated,
  }) {
    return paginatedQuery(
      cursor: cursor,
      limit: paginated ? AppConstants.pageSize : null,
      paginated: paginated,
      extra: {
        'month': ?month,
        'year': ?year,
        'status': ?status,
      },
    );
  }

  @override
  Future<PaginatedListResult<DueModel>> getBuildingDues(
    String buildingId, {
    int? month,
    int? year,
    String? status,
    String? cursor,
    bool paginated = true,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.buildingDues(buildingId),
      queryParameters: _buildDuesQuery(
        month: month,
        year: year,
        status: status,
        cursor: cursor,
        paginated: paginated,
      ),
    );
    return parsePaginatedList(response.data['data'], DueModel.fromJson);
  }

  @override
  Future<PaginatedListResult<DueModel>> getMyDues({
    int? month,
    int? year,
    String? status,
    String? cursor,
    bool paginated = true,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.myDues,
      queryParameters: _buildDuesQuery(
        month: month,
        year: year,
        status: status,
        cursor: cursor,
        paginated: paginated,
      ),
    );
    return parsePaginatedList(response.data['data'], DueModel.fromJson);
  }

  @override
  Future<DueModel> updateDueStatus({
    required String buildingId,
    required String dueId,
    required String status,
  }) async {
    final response = await _dioClient.patch(
      ApiConstants.buildingDueStatus(buildingId, dueId),
      data: {'status': status},
    );
    return DueModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateBuildingDueAmount({
    required String buildingId,
    required double dueAmount,
    int? dueDay,
    String? currency,
    bool affectCurrent = false,
  }) async {
    await _dioClient.patch(
      ApiConstants.buildingDueAmount(buildingId),
      data: {
        'dueAmount': dueAmount,
        'dueDay': ?dueDay,
        if (currency != null && currency.isNotEmpty) 'currency': currency,
        'affectCurrent': affectCurrent,
      },
    );
  }

  @override
  Future<int> remindBuildingDues(
    String buildingId, {
    List<String>? dueIds,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.buildingDuesRemind(buildingId),
      data: dueIds != null && dueIds.isNotEmpty ? {'dueIds': dueIds} : {},
    );
    final data = response.data['data'];
    if (data is Map && data['reminded'] != null) {
      return _toInt(data['reminded']);
    }
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
