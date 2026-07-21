import 'manager_home_caches.dart';
import '../../features/buildings/presentation/providers/buildings_cache_refresh.dart';
import '../../features/dues/presentation/providers/dues_cache_refresh.dart';
import '../../features/dues/presentation/providers/dues_provider.dart';
import '../../features/sites/data/sites_store.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../../features/tickets/presentation/providers/manager_open_tickets_count_provider.dart';
import '../../features/dashboard/presentation/providers/manager_dashboard_snapshot_provider.dart';
import '../../features/dashboard/presentation/providers/manager_home_counts_provider.dart';
import '../../features/dashboard/data/providers/dashboard_provider.dart';

export 'manager_home_caches.dart' show invalidateManagerHomeCaches;

/// Bina/site oluşturma-silme sonrası abonelik kotası.
void invalidateSubscriptionQuota(dynamic ref) {
  ref.invalidate(subscriptionNotifierProvider);
}

/// Gider CRUD → aidat carry-forward + ana sayfa gider özetleri.
Future<void> invalidateExpensesRelatedCaches(dynamic ref) async {
  invalidateManagerHomeCaches(ref);
  await invalidateDuesRelatedCaches(ref);
}

/// Site gideri CRUD → site özeti + aidat + ana sayfa.
Future<void> invalidateSiteExpensesRelatedCaches(
  dynamic ref, {
  required String siteId,
}) async {
  ref.invalidate(siteDetailProvider(siteId));
  final Future<void> sites =
      ref.read(sitesStoreProvider.notifier).refreshSites();
  await Future.wait<void>([
    sites,
    invalidateExpensesRelatedCaches(ref),
  ]);
}

/// Dekont inceleme/onay → bekleyen sayaçlar + aidat.
Future<void> invalidateDekontRelatedCaches(dynamic ref) async {
  ref.invalidate(managerPendingDekontsCountProvider);
  ref.invalidate(managerPendingDekontsForBuildingProvider);
  ref.invalidate(managerPendingDekontsForScopeProvider);
  ref.invalidate(buildingDashboardSummaryProvider);
  ref.invalidate(buildingDashboardSummaryBatchProvider);
  await invalidateDuesRelatedCaches(ref);
}

/// Talep durumu → ana sayfa ticket istatistikleri + açık sayı.
void invalidateTicketsRelatedCaches(dynamic ref) {
  ref.invalidate(managerOpenTicketsCountProvider);
  ref.invalidate(managerTicketStatusStatsForScopeProvider);
  ref.invalidate(managerTicketStatusStatsProvider);
}

/// Daire / sakin mutasyonu → bina doluluk + kota.
Future<void> invalidateApartmentOccupancyCaches(dynamic ref) async {
  await syncManagerBuildingLists(ref);
  invalidateSubscriptionQuota(ref);
}

/// Bina/site envanter değişimi (ekle/sil) → listeler + kota + ana sayfa.
Future<void> invalidatePropertyInventoryCaches(dynamic ref) async {
  await syncManagerBuildingLists(ref);
  final Future<void> sites =
      ref.read(sitesStoreProvider.notifier).refreshSites();
  await sites;
  invalidateSubscriptionQuota(ref);
  invalidateManagerHomeCaches(ref);
  ref.invalidate(allBuildingsDuesProvider);
}
