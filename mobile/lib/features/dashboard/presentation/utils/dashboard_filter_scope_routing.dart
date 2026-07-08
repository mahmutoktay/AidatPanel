import '../../domain/entities/dashboard_filter_scope.dart';

/// Ana Sayfa scope'unu Aidat İşlem Geçmişi route'una kodlar.
String dueTransactionsPath(DashboardFilterScope scope) {
  if (scope.isBuilding && scope.buildingId != null) {
    return '/manager-dashboard/due-transactions?buildingId=${Uri.encodeComponent(scope.buildingId!)}';
  }
  if (scope.isSite && scope.siteId != null) {
    return '/manager-dashboard/due-transactions?siteId=${Uri.encodeComponent(scope.siteId!)}';
  }
  return '/manager-dashboard/due-transactions';
}

/// Route query parametrelerinden başlangıç scope'unu çözer.
DashboardFilterScope dueTransactionsScopeFromQuery(Map<String, String> query) {
  final buildingId = query['buildingId'];
  if (buildingId != null && buildingId.isNotEmpty) {
    return DashboardFilterScope.building(buildingId);
  }
  final siteId = query['siteId'];
  if (siteId != null && siteId.isNotEmpty) {
    return DashboardFilterScope.site(siteId);
  }
  return const DashboardFilterScope.all();
}

/// Tek bina için kısa path (dekont detayı vb.).
String dueTransactionsPathForBuilding(String buildingId) {
  return dueTransactionsPath(DashboardFilterScope.building(buildingId));
}
