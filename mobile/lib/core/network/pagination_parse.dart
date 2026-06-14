import 'paginated_list_result.dart';

/// API `data` alanı: düz liste veya `{ items, nextCursor }`.
PaginatedListResult<T> parsePaginatedList<T>(
  dynamic data,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (data is List) {
    return PaginatedListResult(
      items: data
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
  if (data is Map<String, dynamic>) {
    final rawItems = data['items'];
    if (rawItems is! List) {
      return const PaginatedListResult(items: []);
    }
    return PaginatedListResult(
      items: rawItems
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      nextCursor: data['nextCursor'] as String?,
    );
  }
  return const PaginatedListResult(items: []);
}

Map<String, dynamic> paginatedQuery({
  String? cursor,
  int? limit,
  bool paginated = true,
  Map<String, dynamic>? extra,
}) {
  final query = <String, dynamic>{
    if (paginated) 'paginated': 'true',
    'limit': ?limit,
    'cursor': ?cursor,
    ...?extra,
  };
  return query;
}
