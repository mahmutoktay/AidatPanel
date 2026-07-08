import '../../../buildings/domain/entities/building_entity.dart';
import '../../domain/entities/dashboard_filter_scope.dart';
import 'manager_dashboard_mapper.dart';

String _scopeQuery(DashboardFilterScope scope) {
  if (scope.isBuilding && scope.buildingId != null) {
    return '?buildingId=${Uri.encodeComponent(scope.buildingId!)}';
  }
  if (scope.isSite && scope.siteId != null) {
    return '?siteId=${Uri.encodeComponent(scope.siteId!)}';
  }
  return '';
}

/// Route query parametrelerinden başlangıç scope'unu çözer.
DashboardFilterScope dashboardFilterScopeFromQuery(Map<String, String> query) {
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

/// Ana Sayfa scope'unu Aidat İşlem Geçmişi route'una kodlar.
String dueTransactionsPath(DashboardFilterScope scope) {
  return '/manager-dashboard/due-transactions${_scopeQuery(scope)}';
}

/// Ana Sayfa scope'unu Talepler ekranına kodlar.
String ticketsPath(DashboardFilterScope scope) {
  return '/manager-dashboard/tickets${_scopeQuery(scope)}';
}

/// Ana Sayfa scope'unu Giderler ekranına kodlar.
String expensesPath(DashboardFilterScope scope) {
  return '/manager-dashboard/expenses${_scopeQuery(scope)}';
}

/// Ana Sayfa scope'unu geciken daireler listesine kodlar.
String overdueApartmentsPath(DashboardFilterScope scope) {
  return '/manager-dashboard/overdue-apartments${_scopeQuery(scope)}';
}

/// Route query parametrelerinden başlangıç scope'unu çözer (aidat işlemleri).
DashboardFilterScope dueTransactionsScopeFromQuery(Map<String, String> query) =>
    dashboardFilterScopeFromQuery(query);

/// Tek bina için kısa path (dekont detayı vb.).
String dueTransactionsPathForBuilding(String buildingId) {
  return dueTransactionsPath(DashboardFilterScope.building(buildingId));
}

/// Site/bina kapsamından tek bina seçimi (talepler/giderler ekranları).
String? resolveScopeBuildingId(
  DashboardFilterScope scope,
  List<BuildingEntity> buildings,
) {
  if (scope.isBuilding) return scope.buildingId;

  final scoped = ManagerDashboardMapper.filterBuildingsByScope(
    buildings,
    siteId: scope.siteId,
    buildingId: scope.buildingId,
  );
  if (scoped.isEmpty) return null;

  final sorted = [...scoped]..sort((a, b) => a.name.compareTo(b.name));
  return sorted.first.id;
}
