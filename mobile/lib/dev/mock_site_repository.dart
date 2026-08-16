/// Dev preview — site CRUD in-memory (Bahçeli Evler showcase).
library;

import '../core/network/api_exception.dart';
import '../core/utils/iban_utils.dart';
import '../features/buildings/domain/entities/building_entity.dart';
import '../features/expenses/domain/entities/expense_entity.dart';
import '../features/sites/domain/entities/site_entity.dart';
import '../features/sites/domain/entities/site_expense_create_outcome.dart';
import '../features/sites/domain/entities/site_expense_entity.dart';
import '../features/sites/domain/repositories/site_repository.dart';
import 'dev_mocks.dart';
import 'dev_showcase_seed.dart';

const _delay = Duration(milliseconds: 200);

class MockSiteRepository implements SiteRepository {
  MockSiteRepository({
    required this.buildings,
  }) {
    _site = buildBahceliSite();
    _expenses = List.of(buildBahceliSiteExpenses());
  }

  final MockBuildingRepository buildings;

  late SiteEntity _site;
  late List<SiteExpenseEntity> _expenses;

  @override
  Future<List<SiteEntity>> fetchSites() async {
    await Future.delayed(_delay);
    return [_site];
  }

  @override
  Future<SiteDetailEntity> fetchSiteDetail(String siteId) async {
    await Future.delayed(_delay);
    if (siteId != _site.id) {
      throw ApiException(message: 'site_not_found', statusCode: 404);
    }
    final blocks = await fetchSiteBuildings(siteId);
    final now = DateTime.now();
    return SiteDetailEntity(
      site: _site,
      buildings: blocks,
      aggregation: SiteAggregationEntity(
        month: now.month,
        year: now.year,
        collectedAmount: _site.collectedAmount,
        expectedAmount: _site.expectedAmount,
        currency: 'TRY',
      ),
    );
  }

  @override
  Future<List<BuildingEntity>> fetchSiteBuildings(String siteId) async {
    await Future.delayed(_delay);
    final all = await buildings.fetchBuildings();
    return all.where((b) => b.siteId == siteId).toList(growable: false);
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
    await Future.delayed(_delay);
    throw ApiException(
      message: 'Dev preview: ek site oluşturma kapalı',
      statusCode: 400,
    );
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
    await Future.delayed(_delay);
    if (id != _site.id) {
      throw ApiException(message: 'site_not_found', statusCode: 404);
    }
    _site = _site.copyWith(
      name: name,
      address: address,
      city: city,
      dueAmount: dueAmount,
      dueDay: dueDay,
      currency: currency,
    );
    return _site;
  }

  @override
  Future<SiteEntity> patchSiteCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    String? collectionIbanLabel,
    bool updateIbanLabel = false,
    required String? paymentReferenceTemplate,
  }) async {
    await Future.delayed(_delay);
    if (id != _site.id) {
      throw ApiException(message: 'site_not_found', statusCode: 404);
    }
    final iban = collectionIban != null && collectionIban.isNotEmpty
        ? IbanUtils.normalize(collectionIban)
        : null;
    _site = _site.copyWith(
      collectionIban: iban,
      collectionAccountTitle: collectionAccountTitle,
      collectionIbanLabel: updateIbanLabel
          ? collectionIbanLabel
          : _site.collectionIbanLabel,
      paymentReferenceTemplate: paymentReferenceTemplate,
    );
    return _site;
  }

  @override
  Future<void> deleteSite(String id) async {
    await Future.delayed(_delay);
    throw ApiException(
      message: 'Dev preview: showcase site silinemez',
      statusCode: 400,
    );
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
    await Future.delayed(_delay);
    throw ApiException(
      message: 'Dev preview: ek blok oluşturma kapalı',
      statusCode: 400,
    );
  }

  @override
  Future<List<SiteExpenseEntity>> fetchSiteExpenses(
    String siteId, {
    int? month,
    int? year,
    String? category,
  }) async {
    await Future.delayed(_delay);
    var list = List<SiteExpenseEntity>.from(_expenses);
    if (month != null) {
      list = list.where((e) => e.targetMonth == month).toList();
    }
    if (year != null) {
      list = list.where((e) => e.targetYear == year).toList();
    }
    if (category != null) {
      list = list.where((e) => e.category.name.toUpperCase() == category).toList();
    }
    return list;
  }

  @override
  Future<SiteExpenseSummaryEntity> fetchSiteExpenseSummary(
    String siteId, {
    required int month,
    required int year,
  }) async {
    final list = await fetchSiteExpenses(siteId, month: month, year: year);
    var total = 0.0;
    final byCat = <ExpenseCategory, double>{};
    for (final e in list) {
      final a = e.amount ?? 0;
      total += a;
      byCat[e.category] = (byCat[e.category] ?? 0) + a;
    }
    return SiteExpenseSummaryEntity(
      siteId: siteId,
      month: month,
      year: year,
      totalAmount: total,
      currency: 'TRY',
      byCategory: [
        for (final e in byCat.entries)
          SiteExpenseCategorySummary(
            category: e.key,
            amount: e.value,
            count: list.where((x) => x.category == e.key).length,
          ),
      ],
    );
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
    String carryForwardPolicy = 'warnOnly',
    bool confirmPaidImpact = false,
  }) async {
    await Future.delayed(_delay);
    final cat = ExpenseCategory.values.firstWhere(
      (c) => c.name.toUpperCase() == category.toUpperCase(),
      orElse: () => ExpenseCategory.other,
    );
    final expense = SiteExpenseEntity(
      id: MockState.nextId('sexp'),
      siteId: siteId,
      title: title,
      amount: amount,
      category: cat,
      date: date,
      targetMonth: targetMonth,
      targetYear: targetYear,
      note: note,
      createdAt: DateTime.now(),
    );
    _expenses.insert(0, expense);
    return SiteExpenseCreateOutcome(expense: expense);
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
    await Future.delayed(_delay);
    final idx = _expenses.indexWhere((e) => e.id == expenseId);
    if (idx < 0) {
      throw ApiException(message: 'expense_not_found', statusCode: 404);
    }
    final old = _expenses[idx];
    final updated = SiteExpenseEntity(
      id: old.id,
      siteId: old.siteId,
      title: title ?? old.title,
      amount: amount ?? old.amount,
      category: category != null
          ? ExpenseCategory.values.firstWhere(
              (c) => c.name.toUpperCase() == category.toUpperCase(),
              orElse: () => old.category,
            )
          : old.category,
      date: date ?? old.date,
      targetMonth: old.targetMonth,
      targetYear: old.targetYear,
      perUnitAmount: old.perUnitAmount,
      note: note ?? old.note,
      receiptUrl: old.receiptUrl,
      receiptUrls: old.receiptUrls,
      createdAt: old.createdAt,
    );
    _expenses[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteSiteExpense(String siteId, String expenseId) async {
    await Future.delayed(_delay);
    _expenses.removeWhere((e) => e.id == expenseId);
  }
}
