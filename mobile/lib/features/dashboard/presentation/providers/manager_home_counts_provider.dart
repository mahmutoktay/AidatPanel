import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../buildings/data/buildings_store.dart';
import '../../../dekont/presentation/providers/dekont_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../utils/manager_dashboard_mapper.dart';

/// Yönetici ana sayfa — bu ay tüm binalardaki gider kayıt sayısı.
/// Özet endpoint + paralel istek (tam liste çekilmez).
final managerMonthExpensesCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final buildings = ref.watch(buildingsStoreProvider).value;
  if (buildings == null || buildings.isEmpty) return 0;

  final now = DateTime.now();
  final repo = ref.watch(expenseRepositoryProvider);

  final counts = await Future.wait<int>(
    buildings.map((building) async {
      try {
        return await repo.countExpensesInMonth(
          building.id,
          month: now.month,
          year: now.year,
        );
      } catch (_) {
        return 0;
      }
    }),
  );

  return counts.fold<int>(0, (sum, n) => sum + n);
});

/// Yönetici ana sayfa — bu ay gönderilen duyuru bildirimi sayısı.
final managerMonthAnnouncementsCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final repo = ref.watch(notificationRepositoryProvider);
  try {
    return await repo.countAnnouncementsInMonth();
  } catch (_) {
    return 0;
  }
});

/// Yönetici ana sayfa — inceleme bekleyen dekont sayısı (tüm binalar).
final managerPendingDekontsCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final buildings = ref.watch(buildingsStoreProvider).value;
  if (buildings == null || buildings.isEmpty) return 0;

  final repo = ref.watch(dekontRepositoryProvider);
  var count = 0;

  for (final building in buildings) {
    try {
      final dekonts = await repo.getBuildingDekonts(
        building.id,
        paginated: false,
      );
      count += dekonts.items
          .where((d) => d.status.needsManagerApproval)
          .length;
    } catch (_) {
      // Tek bina hatası tüm sayacı düşürmez.
    }
  }

  return count;
});

/// Seçili bina için bekleyen dekont sayısı (`null` = tüm binalar).
final managerPendingDekontsForBuildingProvider =
    FutureProvider.autoDispose.family<int, String?>((ref, buildingId) async {
  final buildings = ref.watch(buildingsStoreProvider).value ?? const [];
  if (buildings.isEmpty) return 0;

  final targetBuildings = ManagerDashboardMapper.filterBuildings(
    buildings,
    buildingId,
  );
  if (targetBuildings.isEmpty) return 0;

  final repo = ref.watch(dekontRepositoryProvider);
  var count = 0;

  for (final building in targetBuildings) {
    try {
      final dekonts = await repo.getBuildingDekonts(
        building.id,
        paginated: false,
      );
      count += dekonts.items
          .where((d) => d.status.needsManagerApproval)
          .length;
    } catch (_) {
      // Tek bina hatası tüm sayacı düşürmez.
    }
  }

  return count;
});
