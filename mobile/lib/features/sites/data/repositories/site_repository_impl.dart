import '../../../../core/network/api_exception.dart';
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

class SiteRepositoryImpl implements SiteRepository {
  SiteRepositoryImpl({
    required SiteRemoteDataSource remoteDataSource,
    required SiteExpenseRemoteDataSource expenseDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _expenseDataSource = expenseDataSource;

  final SiteRemoteDataSource _remoteDataSource;
  final SiteExpenseRemoteDataSource _expenseDataSource;

  @override
  Future<List<SiteEntity>> fetchSites() async {
    try {
      final models = await _remoteDataSource.fetchSites();
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Siteler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<SiteEntity> fetchSiteById(String id) async {
    try {
      return (await _remoteDataSource.fetchSiteById(id)).toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site detayı yüklenirken hata oluştu: $e');
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
      return (await _remoteDataSource.createSite(
        name: name,
        address: address,
        city: city,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      ))
          .toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site oluşturulurken hata oluştu: $e');
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
      return (await _remoteDataSource.updateSite(
        id: id,
        name: name,
        address: address,
        city: city,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
      ))
          .toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteSite(String id) async {
    try {
      await _remoteDataSource.deleteSite(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site silinirken hata oluştu: $e');
    }
  }

  @override
  Future<BuildingEntity> createSiteBuilding({
    required String siteId,
    required String name,
    String? address,
    String? city,
    String? blockLabel,
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
      return (await _remoteDataSource.createSiteBuilding(
        siteId: siteId,
        name: name,
        address: address,
        city: city,
        blockLabel: blockLabel,
        addressExtra: addressExtra,
        totalFloors: totalFloors,
        apartmentsPerFloor: apartmentsPerFloor,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      ))
          .toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Blok oluşturulurken hata oluştu: $e');
    }
  }

  @override
  Future<List<SiteExpenseEntity>> fetchSiteExpenses(
    String siteId, {
    int? month,
    int? year,
  }) async {
    try {
      final result = await _expenseDataSource.getSiteExpenses(
        siteId,
        month: month,
        year: year,
        paginated: false,
      );
      return result.items.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site giderleri yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<SiteExpenseSummaryEntity> fetchSiteExpenseSummary(
    String siteId, {
    required int month,
    required int year,
  }) async {
    try {
      return await _expenseDataSource.getSummary(
        siteId,
        month: month,
        year: year,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Site gider özeti yüklenirken hata oluştu: $e',
      );
    }
  }

  @override
  Future<SiteExpenseCreateOutcome> createSiteExpense(
    String siteId, {
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
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
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
        note: note,
        carryForwardPolicy: carryForwardPolicy,
        confirmPaidImpact: confirmPaidImpact,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site gideri kaydedilirken hata oluştu: $e');
    }
  }

  @override
  Future<SiteExpenseEntity> updateSiteExpense(
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
        note: note,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site gideri güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteSiteExpense(String expenseId) async {
    try {
      await _expenseDataSource.deleteSiteExpense(expenseId);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site gideri silinirken hata oluştu: $e');
    }
  }
}
