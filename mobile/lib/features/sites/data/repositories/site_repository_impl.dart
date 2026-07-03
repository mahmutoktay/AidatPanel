import '../../../../core/network/api_exception.dart';
<<<<<<< HEAD
import '../../domain/entities/site_entity.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../datasources/site_expense_remote_datasource.dart';
import '../datasources/site_remote_datasource.dart';
import '../../domain/entities/site_expense_create_outcome.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../../../expenses/data/datasources/expense_remote_datasource.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import 'site_repository.dart';
=======
import '../../../buildings/data/models/building_model.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../domain/entities/site_entity.dart';
import '../../domain/entities/site_expense_create_outcome.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../../domain/repositories/site_repository.dart';
import '../datasources/site_expense_remote_datasource.dart';
import '../datasources/site_remote_datasource.dart';
import '../models/site_model.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

class SiteRepositoryImpl implements SiteRepository {
  SiteRepositoryImpl({
    required SiteRemoteDataSource remoteDataSource,
<<<<<<< HEAD
    required SiteExpenseRemoteDataSource expenseDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _expenseDataSource = expenseDataSource;

  final SiteRemoteDataSource _remoteDataSource;
  final SiteExpenseRemoteDataSource _expenseDataSource;
=======
    required SiteExpenseRemoteDataSource expenseRemoteDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _expenseRemoteDataSource = expenseRemoteDataSource;

  final SiteRemoteDataSource _remoteDataSource;
  final SiteExpenseRemoteDataSource _expenseRemoteDataSource;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

  @override
  Future<List<SiteEntity>> fetchSites() async {
    try {
      final models = await _remoteDataSource.fetchSites();
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
<<<<<<< HEAD
      throw ApiException(message: 'Siteler yüklenirken hata oluştu: $e');
=======
      throw ApiException(message: 'sites_fetch_failed');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }

  @override
<<<<<<< HEAD
  Future<SiteEntity> fetchSiteById(String id) async {
    try {
      return (await _remoteDataSource.fetchSiteById(id)).toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site detayı yüklenirken hata oluştu: $e');
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
      return (await _remoteDataSource.createSite(
=======
      final model = await _remoteDataSource.createSite(
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        name: name,
        address: address,
        city: city,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
<<<<<<< HEAD
      ))
          .toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site oluşturulurken hata oluştu: $e');
=======
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_create_failed');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
      return (await _remoteDataSource.updateSite(
=======
      final model = await _remoteDataSource.updateSite(
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        id: id,
        name: name,
        address: address,
        city: city,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
<<<<<<< HEAD
      ))
          .toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site güncellenirken hata oluştu: $e');
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }

  @override
  Future<void> deleteSite(String id) async {
    try {
      await _remoteDataSource.deleteSite(id);
    } on ApiException {
      rethrow;
    } catch (e) {
<<<<<<< HEAD
      throw ApiException(message: 'Site silinirken hata oluştu: $e');
=======
      throw ApiException(message: 'site_delete_failed');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }

  @override
  Future<BuildingEntity> createSiteBuilding({
    required String siteId,
<<<<<<< HEAD
    required String name,
    String? address,
    String? city,
    String? blockLabel,
=======
    required String blockLabel,
    String? name,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
      return (await _remoteDataSource.createSiteBuilding(
        siteId: siteId,
        name: name,
        address: address,
        city: city,
        blockLabel: blockLabel,
=======
      final model = await _remoteDataSource.createSiteBuilding(
        siteId: siteId,
        blockLabel: blockLabel,
        name: name,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        addressExtra: addressExtra,
        totalFloors: totalFloors,
        apartmentsPerFloor: apartmentsPerFloor,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
<<<<<<< HEAD
      ))
          .toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Blok oluşturulurken hata oluştu: $e');
=======
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_building_create_failed');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }

  @override
  Future<List<SiteExpenseEntity>> fetchSiteExpenses(
    String siteId, {
    int? month,
    int? year,
<<<<<<< HEAD
  }) async {
    try {
      final result = await _expenseDataSource.getSiteExpenses(
        siteId,
        month: month,
        year: year,
=======
    String? category,
  }) async {
    try {
      final result = await _expenseRemoteDataSource.fetchSiteExpenses(
        siteId,
        month: month,
        year: year,
        category: category,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        paginated: false,
      );
      return result.items.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
<<<<<<< HEAD
      throw ApiException(message: 'Site giderleri yüklenirken hata oluştu: $e');
=======
      throw ApiException(message: 'site_expenses_fetch_failed');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }

  @override
  Future<SiteExpenseSummaryEntity> fetchSiteExpenseSummary(
    String siteId, {
    required int month,
    required int year,
  }) async {
    try {
<<<<<<< HEAD
      return await _expenseDataSource.getSummary(
=======
      final model = await _expenseRemoteDataSource.fetchSiteExpenseSummary(
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        siteId,
        month: month,
        year: year,
      );
<<<<<<< HEAD
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Site gider özeti yüklenirken hata oluştu: $e',
      );
=======
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_expense_summary_fetch_failed');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }

  @override
  Future<SiteExpenseCreateOutcome> createSiteExpense(
    String siteId, {
    required String title,
    required double amount,
<<<<<<< HEAD
    required ExpenseCategory category,
=======
    required String category,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
<<<<<<< HEAD
    ExpenseCarryForwardPolicyApi carryForwardPolicy =
        ExpenseCarryForwardPolicyApi.warnOnly,
    bool confirmPaidImpact = false,
  }) async {
    try {
      return await _expenseDataSource.createSiteExpense(
        siteId,
        title: title,
        amount: amount,
        category: ExpenseModel.categoryToApi(category),
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
        note: note,
<<<<<<< HEAD
=======
        splitMonths: splitMonths,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        carryForwardPolicy: carryForwardPolicy,
        confirmPaidImpact: confirmPaidImpact,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
<<<<<<< HEAD
      throw ApiException(message: 'Site gideri kaydedilirken hata oluştu: $e');
=======
      throw ApiException(message: 'site_expense_create_failed');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }

  @override
  Future<SiteExpenseEntity> updateSiteExpense(
<<<<<<< HEAD
    String expenseId, {
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    int? targetMonth,
    int? targetYear,
    String? note,
  }) async {
    try {
      final model = await _expenseDataSource.updateSiteExpense(
        expenseId,
        title: title,
        amount: amount,
        category:
            category == null ? null : ExpenseModel.categoryToApi(category),
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        note: note,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
<<<<<<< HEAD
      throw ApiException(message: 'Site gideri güncellenirken hata oluştu: $e');
=======
      throw ApiException(message: 'site_expense_update_failed');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }

  @override
<<<<<<< HEAD
  Future<void> deleteSiteExpense(String expenseId) async {
    try {
      await _expenseDataSource.deleteSiteExpense(expenseId);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site gideri silinirken hata oluştu: $e');
=======
  Future<void> deleteSiteExpense(String siteId, String expenseId) async {
    try {
      await _expenseRemoteDataSource.deleteSiteExpense(siteId, expenseId);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'site_expense_delete_failed');
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    }
  }
}
