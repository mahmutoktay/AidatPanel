import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_provider.dart';
import '../../../core/utils/user_error_message.dart';
import '../domain/entities/site_entity.dart';
import '../../buildings/domain/entities/building_entity.dart';
import 'datasources/site_expense_remote_datasource.dart';
import 'datasources/site_remote_datasource.dart';
import 'repositories/site_repository.dart';
import 'repositories/site_repository_impl.dart';

final siteRemoteDataSourceProvider = Provider<SiteRemoteDataSource>((ref) {
  return SiteRemoteDataSourceImpl(dioClient: ref.watch(dioClientProvider));
});

final siteExpenseRemoteDataSourceProvider =
    Provider<SiteExpenseRemoteDataSource>((ref) {
  return SiteExpenseRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final siteRepositoryProvider = Provider<SiteRepository>((ref) {
  return SiteRepositoryImpl(
    remoteDataSource: ref.watch(siteRemoteDataSourceProvider),
    expenseDataSource: ref.watch(siteExpenseRemoteDataSourceProvider),
  );
});

class SitesNotifier extends AsyncNotifier<List<SiteEntity>> {
  SiteRepository get _repository => ref.read(siteRepositoryProvider);

  bool _isCreating = false;

  @override
  Future<List<SiteEntity>> build() async {
    return _repository.fetchSites();
  }

  Future<void> loadSites() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchSites);
  }

  Future<String?> addSite({
    required String name,
    required String address,
    required String city,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  }) async {
    if (_isCreating) return null;
    _isCreating = true;
    try {
      final site = await _repository.createSite(
        name: name,
        address: address,
        city: city,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      );
      final current = state.value ?? [];
      state = AsyncValue.data([site, ...current]);
      return site.id;
    } catch (e) {
      return userFacingError(e);
    } finally {
      _isCreating = false;
    }
  }

  Future<String?> removeSite(String id) async {
    try {
      await _repository.deleteSite(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((s) => s.id != id).toList());
      return null;
    } catch (e) {
      return userFacingError(e);
    }
  }
}

final sitesStoreProvider =
    AsyncNotifierProvider<SitesNotifier, List<SiteEntity>>(SitesNotifier.new);

final siteDetailProvider =
    FutureProvider.autoDispose.family<SiteEntity, String>((ref, siteId) async {
  return ref.watch(siteRepositoryProvider).fetchSiteById(siteId);
});

final siteBuildingsProvider =
    FutureProvider.autoDispose.family<List<BuildingEntity>, String>(
  (ref, siteId) async {
    final model =
        await ref.watch(siteRemoteDataSourceProvider).fetchSiteById(siteId);
    return model.buildings?.map((b) => b.toEntity()).toList() ?? [];
  },
);
