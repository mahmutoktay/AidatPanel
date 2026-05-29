import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../buildings/data/buildings_store.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

/// Yönetici ana sayfa — bu ay tüm binalardaki gider kayıt sayısı.
/// Özet endpoint + paralel istek (tam liste çekilmez).
final managerMonthExpensesCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
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
final managerMonthAnnouncementsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  try {
    return await repo.countAnnouncementsInMonth();
  } catch (_) {
    return 0;
  }
});
