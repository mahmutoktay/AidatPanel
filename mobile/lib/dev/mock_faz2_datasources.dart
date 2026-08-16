/// Dev preview: gider ve bildirim API'si olmadan Faz 2 ekranlarını gezmek için.
library;

import '../core/network/paginated_list_result.dart';
import '../features/expenses/data/datasources/expense_remote_datasource.dart';
import '../features/expenses/data/models/expense_model.dart';
import '../features/expenses/domain/entities/expense_create_outcome.dart';
import '../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../features/notifications/domain/entities/notification_entity.dart';
import 'dev_showcase_seed.dart';

const _delay = Duration(milliseconds: 200);

// Dev preview seed: datasource katmanında localization yok (ham örnek metin).
const _mockNotificationNewTicketTitle = 'Yeni talep';
const _mockNotificationElevatorNoiseBody =
    'Asansör garip ses çıkarıyor — Vefa Apartman';
const _mockNotificationWaterOutageTitle = 'Su kesintisi';
const _mockNotificationWaterOutageBody =
    'Lale Apartmanı: yarın 10:00–14:00 planlı bakım.';
const _mockNotificationDekontTitle = 'Dekont inceleme bekliyor';
const _mockNotificationDekontBody =
    'Cem Aydın (Lale · Daire 8) dekont yükledi.';

class MockExpenseDataSource implements ExpenseDataSource {
  final Map<String, List<ExpenseModel>> _byBuilding = {};

  /// Backend JSON şekline uygun örnek giderler (showcase bina ID'leri).
  void seedPreview() {
    final now = DateTime.now();
    _byBuilding[DevShowcaseIds.vefa] = [
      ExpenseModel(
        id: 'exp_vefa_1',
        buildingId: DevShowcaseIds.vefa,
        title: 'Merdiven temizliği',
        amount: 1800,
        category: 'CLEANING',
        date: DateTime(now.year, now.month, 3),
        targetMonth: now.month,
        targetYear: now.year,
        perUnitAmount: 225,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      ExpenseModel(
        id: 'exp_vefa_2',
        buildingId: DevShowcaseIds.vefa,
        title: 'Asansör periyodik bakım',
        amount: 3200,
        category: 'ELEVATOR',
        date: DateTime(now.year, now.month, 5),
        targetMonth: now.month,
        targetYear: now.year,
        perUnitAmount: 400,
        note: 'Yıllık sözleşme',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ExpenseModel(
        id: 'exp_vefa_3',
        buildingId: DevShowcaseIds.vefa,
        title: 'Ortak alan elektrik',
        amount: 1450,
        category: 'ELECTRICITY',
        date: DateTime(now.year, now.month, 8),
        targetMonth: now.month,
        targetYear: now.year,
        perUnitAmount: 181.25,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
    _byBuilding[DevShowcaseIds.lale] = [
      ExpenseModel(
        id: 'exp_lale_1',
        buildingId: DevShowcaseIds.lale,
        title: 'Çatı izolasyonu',
        amount: 8500,
        category: 'REPAIR',
        date: DateTime(now.year, now.month, 6),
        targetMonth: now.month,
        targetYear: now.year,
        perUnitAmount: 850,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ExpenseModel(
        id: 'exp_lale_2',
        buildingId: DevShowcaseIds.lale,
        title: 'Temizlik şirketi',
        amount: 2400,
        category: 'CLEANING',
        date: DateTime(now.year, now.month, 5),
        targetMonth: now.month,
        targetYear: now.year,
        perUnitAmount: 240,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
    _byBuilding[DevShowcaseIds.blockA] = [
      ExpenseModel(
        id: 'exp_ba_1',
        buildingId: DevShowcaseIds.blockA,
        title: 'Blok elektrik panosu',
        amount: 2100,
        category: 'ELECTRICITY',
        date: DateTime(now.year, now.month, 4),
        targetMonth: now.month,
        targetYear: now.year,
        perUnitAmount: 262.5,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<PaginatedListResult<ExpenseModel>> getBuildingExpenses(
    String buildingId, {
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  }) async {
    await Future.delayed(_delay);
    var list = List<ExpenseModel>.from(_byBuilding[buildingId] ?? []);
    if (month != null) {
      list = list.where((e) => e.targetMonth == month).toList();
    }
    if (year != null) {
      list = list.where((e) => e.targetYear == year).toList();
    }
    if (category != null) {
      list = list.where((e) => e.category == category).toList();
    }
    return PaginatedListResult(items: list);
  }

  @override
  Future<PaginatedListResult<ExpenseModel>> getMyExpenses({
    int? month,
    int? year,
    String? category,
    String? cursor,
    bool paginated = true,
  }) async {
    await Future.delayed(_delay);
    var list = List<ExpenseModel>.from(
      _byBuilding[DevShowcaseIds.lale] ?? [],
    );
    if (month != null) {
      list = list.where((e) => e.targetMonth == month).toList();
    }
    if (year != null) {
      list = list.where((e) => e.targetYear == year).toList();
    }
    if (category != null) {
      list = list.where((e) => e.category == category).toList();
    }
    return PaginatedListResult(items: list);
  }

  @override
  Future<Map<String, dynamic>> getSummary(
    String buildingId, {
    required int month,
    required int year,
  }) async {
    await Future.delayed(_delay);
    final list = await getBuildingExpenses(
      buildingId,
      month: month,
      year: year,
    );
    final byCat = <String, Map<String, dynamic>>{};
    var total = 0.0;
    for (final e in list.items) {
      total += e.amount ?? 0;
      final cat = e.category;
      byCat.putIfAbsent(
        cat,
        () => {'category': cat, 'amount': 0.0, 'count': 0},
      );
      byCat[cat]!['amount'] =
          (byCat[cat]!['amount'] as double) + (e.amount ?? 0);
      byCat[cat]!['count'] = (byCat[cat]!['count'] as int) + 1;
    }
    return {
      'month': month,
      'year': year,
      'totalAmount': total.toStringAsFixed(2),
      'currency': 'TRY',
      'byCategory': byCat.values
          .map(
            (m) => {
              'category': m['category'],
              'amount': (m['amount'] as double).toStringAsFixed(2),
              'count': m['count'],
            },
          )
          .toList(),
    };
  }

  @override
  Future<ExpenseCreateOutcome> createExpense(
    String buildingId, {
    required String title,
    double? amount,
    required String category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
    int splitMonths = 1,
    ExpenseCarryForwardPolicyApi carryForwardPolicy =
        ExpenseCarryForwardPolicyApi.warnOnly,
    bool confirmPaidImpact = false,
  }) async {
    await Future.delayed(_delay);
    final model = ExpenseModel(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      buildingId: buildingId,
      title: title,
      amount: amount,
      category: category,
      date: date,
      targetMonth: targetMonth,
      targetYear: targetYear,
      perUnitAmount: amount != null ? amount / 4 : null,
      note: note,
      receiptUrl: null,
      createdAt: DateTime.now(),
    );
    _byBuilding.putIfAbsent(buildingId, () => []).insert(0, model);
    return ExpenseCreateOutcome(expense: model.toEntity());
  }

  @override
  Future<ExpenseModel> updateExpense(
    String expenseId, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? receiptUrl,
  }) async {
    await Future.delayed(_delay);
    for (final list in _byBuilding.values) {
      final idx = list.indexWhere((e) => e.id == expenseId);
      if (idx < 0) continue;
      final old = list[idx];
      final updated = ExpenseModel(
        id: old.id,
        buildingId: old.buildingId,
        title: title ?? old.title,
        amount: amount ?? old.amount,
        category: category ?? old.category,
        date: date ?? old.date,
        note: note ?? old.note,
        receiptUrl: receiptUrl ?? old.receiptUrl,
        createdAt: old.createdAt,
      );
      list[idx] = updated;
      return updated;
    }
    throw StateError('Expense not found: $expenseId');
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await Future.delayed(_delay);
    for (final list in _byBuilding.values) {
      list.removeWhere((e) => e.id == expenseId);
    }
  }

  @override
  Future<ExpenseModel> uploadReceipts(
    String expenseId,
    List<String> filePaths,
  ) async {
    await Future.delayed(_delay);
    for (final list in _byBuilding.values) {
      final idx = list.indexWhere((e) => e.id == expenseId);
      if (idx < 0) continue;
      final old = list[idx];
      final url = filePaths.isNotEmpty
          ? 'mock://receipt/${filePaths.first}'
          : 'mock://receipt/default';
      final updated = ExpenseModel(
        id: old.id,
        buildingId: old.buildingId,
        title: old.title,
        amount: 250.0,
        parsedAmount: 250.0,
        category: old.category,
        date: old.date,
        note: old.note,
        receiptUrl: url,
        receiptUrls: filePaths.map((p) => 'mock://receipt/$p').toList(),
        createdAt: old.createdAt,
      );
      list[idx] = updated;
      return updated;
    }
    throw StateError('Expense not found: $expenseId');
  }
}

class MockNotificationDataSource implements NotificationDataSource {
  final List<NotificationEntity> _items = [];

  /// `GET /notifications` yanıtıyla uyumlu örnek kayıtlar.
  void seedPreview() {
    _items.clear();
    final now = DateTime.now();
    _items.addAll([
      NotificationEntity(
        id: 'n_seed_ticket_created',
        userId: 'dev_manager_1',
        title: _mockNotificationNewTicketTitle,
        body: _mockNotificationElevatorNoiseBody,
        type: NotificationType.ticketCreated,
        isRead: false,
        data: {
          'type': 'TICKET_CREATED',
          'ticketId': 'ticket_seed_1',
          'buildingId': DevShowcaseIds.vefa,
          'apartmentId': 'vefa_a1',
          'category': 'MALFUNCTION',
          'status': 'IN_PROGRESS',
          'route': '/manager/tickets',
        },
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationEntity(
        id: 'n_seed_dekont',
        userId: 'dev_manager_1',
        title: _mockNotificationDekontTitle,
        body: _mockNotificationDekontBody,
        type: NotificationType.system,
        isRead: false,
        data: {
          'type': 'DEKONT_NEEDS_REVIEW',
          'dekontId': 'dk_lale_8',
          'buildingId': DevShowcaseIds.lale,
          'apartmentId': 'lale_a8',
          'route': '/manager/dekonts',
        },
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationEntity(
        id: 'n_seed_announcement',
        userId: 'dev_manager_1',
        title: _mockNotificationWaterOutageTitle,
        body: _mockNotificationWaterOutageBody,
        type: NotificationType.announcement,
        isRead: true,
        data: {
          'type': 'ANNOUNCEMENT',
          'buildingId': DevShowcaseIds.lale,
          'route': '/notifications',
        },
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  @override
  Future<int> fetchUnreadCount() async {
    await Future.delayed(_delay);
    return _items.where((n) => !n.isRead).length;
  }

  @override
  Future<NotificationListResult> list({
    bool unreadOnly = false,
    int limit = 20,
    String? cursor,
  }) async {
    await Future.delayed(_delay);
    var items = List<NotificationEntity>.from(_items);
    if (unreadOnly) {
      items = items.where((n) => !n.isRead).toList();
    }
    return NotificationListResult(
      items: items,
      unreadCount: _items.where((n) => !n.isRead).length,
    );
  }

  @override
  Future<NotificationEntity> markRead(String id) async {
    await Future.delayed(_delay);
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      final n = _items[idx];
      _items[idx] = NotificationEntity(
        id: n.id,
        userId: n.userId,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: true,
        data: n.data,
        createdAt: n.createdAt,
      );
      return _items[idx];
    }
    return _items.first;
  }

  @override
  Future<int> markAllRead() async {
    await Future.delayed(_delay);
    for (var i = 0; i < _items.length; i++) {
      final n = _items[i];
      _items[i] = NotificationEntity(
        id: n.id,
        userId: n.userId,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: true,
        data: n.data,
        createdAt: n.createdAt,
      );
    }
    return _items.length;
  }

  @override
  Future<AnnouncementResultEntity> sendAnnouncement(
    String buildingId, {
    required String body,
  }) async {
    await Future.delayed(_delay);
    _items.insert(
      0,
      NotificationEntity(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'dev_manager_1',
        title: 'Duyuru',
        body: body,
        type: NotificationType.announcement,
        isRead: false,
        data: {
          'type': 'ANNOUNCEMENT',
          'buildingId': buildingId,
          'route': '/notifications',
        },
        createdAt: DateTime.now(),
      ),
    );
    return const AnnouncementResultEntity(
      created: 3,
      pushSent: 0,
      pushFailed: 0,
      pushSkipped: 3,
    );
  }
}
