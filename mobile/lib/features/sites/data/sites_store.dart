import 'package:flutter_riverpod/flutter_riverpod.dart';

<<<<<<< HEAD
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../core/utils/user_error_message.dart';
import '../domain/entities/site_entity.dart';
import '../../buildings/domain/entities/building_entity.dart';
import 'datasources/site_expense_remote_datasource.dart';
import 'datasources/site_remote_datasource.dart';
import 'repositories/site_repository.dart';
=======
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/user_error_message.dart';
import '../../buildings/domain/entities/building_entity.dart';
import '../domain/entities/site_entity.dart';
import '../domain/repositories/site_repository.dart';
import 'datasources/site_expense_remote_datasource.dart';
import 'datasources/site_remote_datasource.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
    expenseDataSource: ref.watch(siteExpenseRemoteDataSourceProvider),
=======
    expenseRemoteDataSource: ref.watch(siteExpenseRemoteDataSourceProvider),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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

<<<<<<< HEAD
=======
  Future<void> refreshSites() async {
    try {
      final sites = await _repository.fetchSites();
      state = AsyncValue.data(sites);
    } catch (_) {
      // Mevcut listeyi koru.
    }
  }

>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
      final current = state.value ?? [];
      state = AsyncValue.data([site, ...current]);
      return site.id;
    } catch (e) {
      return userFacingError(e);
=======
      final current =
          state.hasValue ? (state.value ?? <SiteEntity>[]) : <SiteEntity>[];
      state = AsyncValue.data([...current, site]);
      return site.id;
    } catch (e, st) {
      state = AsyncValue.error(wrapAsyncStateError(e), st);
      return null;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    } finally {
      _isCreating = false;
    }
  }

<<<<<<< HEAD
  Future<String?> removeSite(String id) async {
    try {
      await _repository.deleteSite(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((s) => s.id != id).toList());
      return null;
    } catch (e) {
      return userFacingError(e);
=======
  Future<void> updateSite({
    required String id,
    String? name,
    String? address,
    String? city,
    double? dueAmount,
    int? dueDay,
    String? currency,
  }) async {
    try {
      final updated = await _repository.updateSite(
        id: id,
        name: name,
        address: address,
        city: city,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
      );
      final current = state.asData?.value ?? <SiteEntity>[];
      state = AsyncValue.data(
        current.map((s) => s.id == id ? updated : s).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(wrapAsyncStateError(e), st);
      rethrow;
    }
  }

  Future<void> removeSite(String siteId) async {
    try {
      await _repository.deleteSite(siteId);
      final current = state.asData?.value ?? <SiteEntity>[];
      state = AsyncValue.data(
        current.where((s) => s.id != siteId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(wrapAsyncStateError(e), st);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }
}

final sitesStoreProvider =
    AsyncNotifierProvider<SitesNotifier, List<SiteEntity>>(SitesNotifier.new);

final siteDetailProvider =
<<<<<<< HEAD
    FutureProvider.autoDispose.family<SiteEntity, String>((ref, siteId) async {
  return ref.watch(siteRepositoryProvider).fetchSiteById(siteId);
=======
    FutureProvider.autoDispose.family<SiteDetailEntity, String>((ref, siteId) {
  return ref.watch(siteRepositoryProvider).fetchSiteDetail(siteId);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
});

final siteBuildingsProvider =
    FutureProvider.autoDispose.family<List<BuildingEntity>, String>(
<<<<<<< HEAD
  (ref, siteId) async {
    final model =
        await ref.watch(siteRemoteDataSourceProvider).fetchSiteById(siteId);
    return model.buildings?.map((b) => b.toEntity()).toList() ?? [];
=======
  (ref, siteId) {
    return ref.watch(siteRepositoryProvider).fetchSiteBuildings(siteId);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  },
);
