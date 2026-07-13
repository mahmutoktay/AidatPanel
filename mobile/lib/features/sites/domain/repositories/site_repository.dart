import '../../../buildings/domain/entities/building_entity.dart';
import '../entities/site_entity.dart';
import '../entities/site_expense_create_outcome.dart';
import '../entities/site_expense_entity.dart';

abstract class SiteRepository {
  Future<List<SiteEntity>> fetchSites();

  Future<SiteDetailEntity> fetchSiteDetail(String siteId);

  Future<List<BuildingEntity>> fetchSiteBuildings(String siteId);

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
  });

  Future<SiteEntity> updateSite({
    required String id,
    String? name,
    String? address,
    String? city,
    double? dueAmount,
    int? dueDay,
    String? currency,
  });

  Future<SiteEntity> patchSiteCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    String? collectionIbanLabel,
    bool updateIbanLabel = false,
    required String? paymentReferenceTemplate,
  });

  Future<void> deleteSite(String id);

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
  });

  Future<List<SiteExpenseEntity>> fetchSiteExpenses(
    String siteId, {
    int? month,
    int? year,
    String? category,
  });

  Future<SiteExpenseSummaryEntity> fetchSiteExpenseSummary(
    String siteId, {
    required int month,
    required int year,
  });

  Future<SiteExpenseCreateOutcome> createSiteExpense(
    String siteId, {
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
    int splitMonths,
    String carryForwardPolicy,
    bool confirmPaidImpact,
  });

  Future<SiteExpenseEntity> updateSiteExpense(
    String siteId,
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
  });

  Future<void> deleteSiteExpense(String siteId, String expenseId);
}
