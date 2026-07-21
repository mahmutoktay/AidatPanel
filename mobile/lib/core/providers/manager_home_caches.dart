import '../../features/dashboard/data/providers/dashboard_provider.dart';
import '../../features/dashboard/presentation/providers/manager_dashboard_snapshot_provider.dart';
import '../../features/dashboard/presentation/providers/manager_home_counts_provider.dart';

/// Yönetici Ana Sayfa özet kartları / sayaçları.
/// Ayrı dosya: dues ↔ list_cache_refresh döngüsel import olmasın diye.
void invalidateManagerHomeCaches(dynamic ref) {
  ref.invalidate(managerMonthExpensesCountForScopeProvider);
  ref.invalidate(managerMonthExpensesCountProvider);
  ref.invalidate(managerMonthAnnouncementsCountProvider);
  ref.invalidate(managerPendingDekontsCountProvider);
  ref.invalidate(managerPendingDekontsForBuildingProvider);
  ref.invalidate(managerPendingDekontsForScopeProvider);
  ref.invalidate(managerTicketStatusStatsForScopeProvider);
  ref.invalidate(managerTicketStatusStatsProvider);
  ref.invalidate(managerMonthExpenseTotalForScopeProvider);
  ref.invalidate(managerMonthExpenseTotalProvider);
  ref.invalidate(managerSixMonthExpenseTotalsForScopeProvider);
  ref.invalidate(managerSixMonthExpenseTotalsProvider);
  ref.invalidate(buildingDashboardSummaryProvider);
  ref.invalidate(buildingDashboardSummaryBatchProvider);
}
