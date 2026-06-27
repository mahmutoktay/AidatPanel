import '../../../../core/network/api_exception.dart';
import '../../../buildings/data/models/building_model.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../domain/entities/site_entity.dart';
import '../../domain/entities/site_expense_create_outcome.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../../domain/repositories/site_repository.dart';
import '../datasources/site_expense_remote_datasource.dart';
import '../datasources/site_remote_datasource.dart';
import '../models/site_model.dart';

class SiteRepositoryImpl implements SiteRepository {
  SiteRepositoryImpl({
    required SiteRemoteDataSource remoteDataSource,
    required SiteExpenseRemoteDataSource expenseRemoteDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _expenseRemoteDataSource = expenseRemoteDataSource;

  final SiteRemoteDataSource _remoteDataSource;
  final SiteExpenseRemoteDataSource _expenseRemoteDataSource;

  @override
  Future<List<SiteEntity>> fetchSites() async {
    try {
      final models = await _remoteDataSource.fetchSites();
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'sites_fetch_failed');
    }
  }

  @override
  Future<SiteDetailEntity> fetchSiteDetail(String siteId) async {
    try {
      final json = await _remoteDataSource.fetchSiteDetail(siteId);
      final site = SiteModel.fromJson(json).toEntity();
      final buildingsRaw = json['buildings'];
      final buildings = buildingsRaw is List
          ? buildingsRaw
                .map(
                  (b) => BuildingModel.fromJson(
                    b as Map<String, dynamic>,
                  ).toEntity(),
                )
                .toList()
          : <BuildingEntity>[];
      final aggregationRaw = json['aggregation'];
      final aggregation = aggregationRaw is Map<String, dynamic>
          ? SiteAggregationModel.fromJson(aggregationRaw).toEntity()
          : SiteAggregationEntity(
              month: DateTime.now().month,
              year: DateTime.now().year,
              collectedAmount: site.collectedAmount,
              expectedAmount: site.expectedAmount,
              currency: site.currency,
            );
      return SiteDetailEntity(
        site: site,
        buildings: buildings,
        aggregation: aggregation,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_detail_fetch_failed');
    }
  }

  @override
  Future<List<BuildingEntity>> fetchSiteBuildings(String siteId) async {
    try {
      final models = await _remoteDataSource.fetchSiteBuildings(siteId);
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_buildings_fetch_failed');
    }
  }

  @override
  Future<SiteEntity> createSite({
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
    try {
      final model = await _remoteDataSource.createSite(
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
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_create_failed');
    }
  }

  @override
  Future<SiteEntity> updateSite({
    required String id,
    String? name,
    String? address,
    String? city,
    double? dueAmount,
    int? dueDay,
    String? currency,
  }) async {
    try {
      final model = await _remoteDataSource.updateSite(
        id: id,
        name: name,
        address: address,
        city: city,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_update_failed');
    }
  }

  @override
  Future<SiteEntity> patchSiteCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    required String? paymentReferenceTemplate,
  }) async {
    try {
      final model = await _remoteDataSource.patchSiteCollection(
        id: id,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_collection_update_failed');
    }
  }

  @override
  Future<void> deleteSite(String id) async {
    try {
      await _remoteDataSource.deleteSite(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_delete_failed');
    }
  }

  @override
  Future<BuildingEntity> createSiteBuilding({
    required String siteId,
    required String blockLabel,
    String? name,
    String? addressExtra,
    int? totalFloors,
    int? apartmentsPerFloor,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  }) async {
    try {
      final model = await _remoteDataSource.createSiteBuilding(
        siteId: siteId,
        blockLabel: blockLabel,
        name: name,
        addressExtra: addressExtra,
        totalFloors: totalFloors,
        apartmentsPerFloor: apartmentsPerFloor,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_building_create_failed');
    }
  }

  @override
  Future<List<SiteExpenseEntity>> fetchSiteExpenses(
    String siteId, {
    int? month,
    int? year,
    String? category,
  }) async {
    try {
      final result = await _expenseRemoteDataSource.fetchSiteExpenses(
        siteId,
        month: month,
        year: year,
        category: category,
        paginated: false,
      );
      return result.items.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_expenses_fetch_failed');
    }
  }

  @override
  Future<SiteExpenseSummaryEntity> fetchSiteExpenseSummary(
    String siteId, {
    required int month,
    required int year,
  }) async {
    try {
      final model = await _expenseRemoteDataSource.fetchSiteExpenseSummary(
        siteId,
        month: month,
        year: year,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_expense_summary_fetch_failed');
    }
  }

  @override
  Future<SiteExpenseCreateOutcome> createSiteExpense(
    String siteId, {
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
    int splitMonths = 1,
    String carryForwardPolicy = 'NONE',
    bool confirmPaidImpact = false,
  }) async {
    try {
      return await _expenseRemoteDataSource.createSiteExpense(
        siteId,
        title: title,
        amount: amount,
        category: category,
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
        note: note,
        splitMonths: splitMonths,
        carryForwardPolicy: carryForwardPolicy,
        confirmPaidImpact: confirmPaidImpact,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_expense_create_failed');
    }
  }

  @override
  Future<SiteExpenseEntity> updateSiteExpense(
    String siteId,
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
  }) async {
    try {
      final model = await _expenseRemoteDataSource.updateSiteExpense(
        siteId,
        expenseId,
        title: title,
        amount: amount,
        category: category,
        date: date,
        note: note,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_expense_update_failed');
    }
  }

  @override
  Future<void> deleteSiteExpense(String siteId, String expenseId) async {
    try {
      await _expenseRemoteDataSource.deleteSiteExpense(siteId, expenseId);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_expense_delete_failed');
    }
  }
}
