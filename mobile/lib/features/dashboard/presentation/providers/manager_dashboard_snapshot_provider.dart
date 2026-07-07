import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';
import '../../../tickets/presentation/providers/tickets_provider.dart';
import '../../data/providers/dashboard_provider.dart';
import '../../domain/entities/dashboard_filter_scope.dart';
import '../../domain/entities/manager_dashboard_entities.dart';
import '../utils/manager_dashboard_mapper.dart';

List<BuildingEntity> _scopedBuildings(
  List<BuildingEntity> buildings,
  DashboardFilterScope scope,
) {
  return ManagerDashboardMapper.filterBuildingsByScope(
    buildings,
    siteId: scope.siteId,
    buildingId: scope.buildingId,
  );
}

/// Site / bina / tümü kapsamına göre arıza talebi durum dağılımı.
final managerTicketStatusStatsForScopeProvider =
    FutureProvider.autoDispose.family<ManagerTicketStatusStats, DashboardFilterScope>((
  ref,
  scope,
) async {
  if (scope.isBuilding) {
    return ref.watch(managerTicketStatusStatsProvider(scope.buildingId).future);
  }

  final buildings = ref.watch(buildingsStoreProvider).value ?? const [];
  final targetBuildings = _scopedBuildings(buildings, scope);
  if (targetBuildings.isEmpty) return ManagerTicketStatusStats.empty;

  final repo = ref.watch(ticketRepositoryProvider);
  final tickets = <TicketEntity>[];

  for (final building in targetBuildings) {
    try {
      final result = await repo.getBuildingTickets(
        building.id,
        paginated: false,
      );
      tickets.addAll(result.items);
    } catch (_) {
      // Tek bina hatası diğerlerini etkilemez.
    }
  }

  return ManagerDashboardMapper.ticketStatusStats(tickets);
});

/// Site / bina / tümü kapsamına göre bu ay toplam gider tutarı.
final managerMonthExpenseTotalForScopeProvider =
    FutureProvider.autoDispose.family<double, DashboardFilterScope>((ref, scope) async {
  if (scope.isBuilding) {
    return ref.watch(managerMonthExpenseTotalProvider(scope.buildingId).future);
  }

  final buildings = ref.watch(buildingsStoreProvider).value ?? const [];
  final targetBuildings = _scopedBuildings(buildings, scope);
  if (targetBuildings.isEmpty) return 0;

  final now = DateTime.now();
  final repo = ref.watch(expenseRepositoryProvider);

  final totals = await Future.wait<double>(
    targetBuildings.map((building) async {
      try {
        final summary = await repo.getSummary(
          building.id,
          month: now.month,
          year: now.year,
        );
        return summary.totalAmount;
      } catch (_) {
        return 0;
      }
    }),
  );

  return totals.fold<double>(0, (sum, value) => sum + value);
});

/// Son 6 ay gider toplamları — site/bina kapsamı destekli.
final managerSixMonthExpenseTotalsForScopeProvider =
    FutureProvider.autoDispose.family<Map<(int, int), double>, DashboardFilterScope>((
  ref,
  scope,
) async {
  final buildings = ref.watch(buildingsStoreProvider).value ?? const [];
  if (buildings.isEmpty) return const {};

  final targetBuildings = _scopedBuildings(buildings, scope);
  if (targetBuildings.isEmpty) return const {};

  final now = DateTime.now();
  final repo = ref.watch(expenseRepositoryProvider);
  final totals = <(int, int), double>{};

  for (var i = 5; i >= 0; i--) {
    final date = DateTime(now.year, now.month - i, 1);
    final key = (date.month, date.year);
    var monthTotal = 0.0;

    for (final building in targetBuildings) {
      try {
        final summary = await repo.getSummary(
          building.id,
          month: date.month,
          year: date.year,
        );
        monthTotal += summary.totalAmount;
      } catch (_) {
        // Ay/bina hatası atlanır.
      }
    }

    totals[key] = monthTotal;
  }

  return totals;
});

/// Seçili bina için arıza talebi durum dağılımı (`null` = tüm binalar).
/// Tek bina seçiliyken dashboard-summary endpoint'inden `openTicketCount`
/// alınır, böylece tüm ticket listesini çekmek gerekmez (N+1 önlenir).
final managerTicketStatusStatsProvider =
    FutureProvider.autoDispose.family<ManagerTicketStatusStats, String?>((
  ref,
  buildingId,
) async {
  // Tek bina → dashboard-summary kullan (N+1 yok).
  if (buildingId != null) {
    final summary =
        await ref.watch(buildingDashboardSummaryProvider(buildingId).future);
    return ManagerTicketStatusStats(
      openCount: summary.openTicketCount,
      inProgressCount: 0,
      resolvedCount: 0,
    );
  }

  // Tüm binalar görünümü — eski yöntem korunur (backend aggregation yok).
  final buildings = ref.watch(buildingsStoreProvider).value ?? const [];
  if (buildings.isEmpty) return ManagerTicketStatusStats.empty;

  final repo = ref.watch(ticketRepositoryProvider);
  final tickets = <TicketEntity>[];

  for (final building in buildings) {
    try {
      final result = await repo.getBuildingTickets(
        building.id,
        paginated: false,
      );
      tickets.addAll(result.items);
    } catch (_) {
      // Tek bina hatası diğerlerini etkilemez.
    }
  }

  return ManagerDashboardMapper.ticketStatusStats(tickets);
});

/// Seçili bina için bu ay toplam gider tutarı (`null` = tüm binalar).
/// Tek bina seçiliyse mutlaka dashboard-summary endpoint'ini kullanır —
/// fallback eski yönteme düşmez, böylece N+1 garantili engellenir.
/// Çok bina görünümünde eski yöntem korunur.
final managerMonthExpenseTotalProvider =
    FutureProvider.autoDispose.family<double, String?>((ref, buildingId) async {
  if (buildingId != null) {
    final summary = await ref.watch(buildingDashboardSummaryProvider(buildingId).future);
    return summary.monthTotalExpense;
  }

  final buildings = ref.watch(buildingsStoreProvider).value ?? const [];
  if (buildings.isEmpty) return 0;

  final now = DateTime.now();
  final repo = ref.watch(expenseRepositoryProvider);

  final totals = await Future.wait<double>(
    buildings.map((building) async {
      try {
        final summary = await repo.getSummary(
          building.id,
          month: now.month,
          year: now.year,
        );
        return summary.totalAmount;
      } catch (_) {
        return 0;
      }
    }),
  );

  return totals.fold<double>(0, (sum, value) => sum + value);
});

/// Son 6 ay gider toplamları — bar grafiğin turuncu sütunları.
final managerSixMonthExpenseTotalsProvider =
    FutureProvider.autoDispose.family<Map<(int, int), double>, String?>((
  ref,
  buildingId,
) async {
  final buildings = ref.watch(buildingsStoreProvider).value ?? const [];
  if (buildings.isEmpty) return const {};

  final targetBuildings = ManagerDashboardMapper.filterBuildings(
    buildings,
    buildingId,
  );
  if (targetBuildings.isEmpty) return const {};

  final now = DateTime.now();
  final repo = ref.watch(expenseRepositoryProvider);
  final totals = <(int, int), double>{};

  for (var i = 5; i >= 0; i--) {
    final date = DateTime(now.year, now.month - i, 1);
    final key = (date.month, date.year);
    var monthTotal = 0.0;

    for (final building in targetBuildings) {
      try {
        final summary = await repo.getSummary(
          building.id,
          month: date.month,
          year: date.year,
        );
        monthTotal += summary.totalAmount;
      } catch (_) {
        // Ay/bina hatası atlanır.
      }
    }

    totals[key] = monthTotal;
  }

  return totals;
});
