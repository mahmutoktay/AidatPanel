import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/manager_dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../repositories/dashboard_repository_impl.dart';

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSourceImpl>((ref) {
  return DashboardRemoteDataSourceImpl(
    dioClient: ref.read(dioClientProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    remote: ref.watch(dashboardRemoteDataSourceProvider),
  );
});

/// Tek bina dashboard özeti (backend aggregasyon endpoint'i).
final buildingDashboardSummaryProvider = FutureProvider.autoDispose
    .family<ManagerDashboardSummaryStats, String>((ref, buildingId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchBuildingSummary(buildingId);
});

/// Tek bina tahsilat durumu (donut grafiği).
final buildingDuesCollectionStatsProvider = FutureProvider.autoDispose
    .family<ManagerDuesCollectionStats, String>((ref, buildingId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchDuesCollectionStats(buildingId);
});

/// Çoklu bina dashboard özeti — tüm binalar görünümünde tek API çağrısı.
/// N+1 sorununu çözer. `null` dönerse henüz veri yok (fallback eski yöntem).
final buildingDashboardSummaryBatchProvider = FutureProvider.autoDispose
    .family<Map<String, ManagerDashboardSummaryStats>, List<String>>(
        (ref, buildingIds) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchBatchSummary(buildingIds);
});
