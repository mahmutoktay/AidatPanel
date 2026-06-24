import '../../domain/entities/site_entity.dart';
import '../../domain/entities/site_expense_create_outcome.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../expenses/data/datasources/expense_remote_datasource.dart';
import '../../../expenses/domain/entities/expense_entity.dart';

abstract class SiteRepository {
  Future<List<SiteEntity>> fetchSites();
  Future<SiteEntity> fetchSiteById(String id);
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
  Future<void> deleteSite(String id);
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
  });
  Future<List<SiteExpenseEntity>> fetchSiteExpenses(
    String siteId, {
    int? month,
    int? year,
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
    required ExpenseCategory category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
    ExpenseCarryForwardPolicyApi carryForwardPolicy =
        ExpenseCarryForwardPolicyApi.warnOnly,
    bool confirmPaidImpact = false,
  });
  Future<SiteExpenseEntity> updateSiteExpense(
    String expenseId, {
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    int? targetMonth,
    int? targetYear,
    String? note,
  });
  Future<void> deleteSiteExpense(String expenseId);
}
