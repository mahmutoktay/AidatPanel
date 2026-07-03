import '../../../expenses/data/models/expense_model.dart';
<<<<<<< HEAD
import '../../../expenses/domain/entities/expense_entity.dart';
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
import '../../domain/entities/site_expense_entity.dart';

class SiteExpenseModel {
  final String id;
  final String siteId;
  final String title;
  final double? amount;
<<<<<<< HEAD
=======
  final double? parsedAmount;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final String category;
  final DateTime date;
  final int targetMonth;
  final int targetYear;
  final double? perUnitAmount;
  final String? note;
<<<<<<< HEAD
=======
  final String? receiptUrl;
  final List<String> receiptUrls;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final DateTime createdAt;

  const SiteExpenseModel({
    required this.id,
    required this.siteId,
    required this.title,
    this.amount,
<<<<<<< HEAD
=======
    this.parsedAmount,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    required this.category,
    required this.date,
    this.targetMonth = 1,
    this.targetYear = 2026,
    this.perUnitAmount,
    this.note,
<<<<<<< HEAD
=======
    this.receiptUrl,
    this.receiptUrls = const [],
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    required this.createdAt,
  });

  factory SiteExpenseModel.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse('$amountRaw');

<<<<<<< HEAD
=======
    final parsedRaw = json['parsedAmount'];
    final parsedAmount = parsedRaw is num
        ? parsedRaw.toDouble()
        : double.tryParse('$parsedRaw');

>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    final perUnitRaw = json['perUnitAmount'];
    final perUnitAmount = perUnitRaw is num
        ? perUnitRaw.toDouble()
        : double.tryParse('$perUnitRaw');

<<<<<<< HEAD
=======
    final receiptUrlsRaw = json['receiptUrls'];
    final receiptUrls = receiptUrlsRaw is List
        ? receiptUrlsRaw.map((e) => '$e').toList()
        : <String>[];

    final fallbackUrls = receiptUrls.isEmpty && json['receiptUrl'] != null
        ? [json['receiptUrl'] as String]
        : receiptUrls;

>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    return SiteExpenseModel(
      id: (json['id'] ?? '') as String,
      siteId: (json['siteId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      amount: amount,
<<<<<<< HEAD
      category: (json['category'] ?? 'OTHER') as String,
      date: _parseDate(json['date']),
      targetMonth:
          (json['targetMonth'] as num?)?.toInt() ?? _parseDate(json['date']).month,
      targetYear:
          (json['targetYear'] as num?)?.toInt() ?? _parseDate(json['date']).year,
      perUnitAmount: perUnitAmount,
      note: json['note'] as String?,
=======
      parsedAmount: parsedAmount,
      category: (json['category'] ?? 'OTHER') as String,
      date: _parseDate(json['date']),
      targetMonth:
          (json['targetMonth'] as num?)?.toInt() ?? DateTime.now().month,
      targetYear:
          (json['targetYear'] as num?)?.toInt() ?? DateTime.now().year,
      perUnitAmount: perUnitAmount,
      note: json['note'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      receiptUrls: fallbackUrls,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      createdAt: _parseDate(json['createdAt']),
    );
  }

<<<<<<< HEAD
  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  SiteExpenseEntity toEntity() => SiteExpenseEntity(
        id: id,
        siteId: siteId,
        title: title,
        amount: amount,
        category: ExpenseModel.parseCategoryApi(category),
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
        perUnitAmount: perUnitAmount,
        note: note,
        createdAt: createdAt,
      );

  static String categoryToApi(ExpenseCategory category) =>
      ExpenseModel.categoryToApi(category);
=======
  SiteExpenseEntity toEntity() {
    return SiteExpenseEntity(
      id: id,
      siteId: siteId,
      title: title,
      amount: amount,
      parsedAmount: parsedAmount,
      category: ExpenseModel.parseCategoryApi(category),
      date: date,
      targetMonth: targetMonth,
      targetYear: targetYear,
      perUnitAmount: perUnitAmount,
      note: note,
      receiptUrl: receiptUrl,
      receiptUrls: receiptUrls,
      createdAt: createdAt,
    );
  }
}

class SiteExpenseSummaryModel {
  final String siteId;
  final int month;
  final int year;
  final double totalAmount;
  final String currency;
  final List<SiteExpenseCategorySummaryModel> byCategory;

  const SiteExpenseSummaryModel({
    required this.siteId,
    required this.month,
    required this.year,
    required this.totalAmount,
    required this.currency,
    required this.byCategory,
  });

  factory SiteExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    // Backend artık totalAmount (numeric) veya eski total (string) dönebilir.
    // Geçiş döneminde her ikisini de tolere et.
    final totalRaw = json['totalAmount'] ?? json['total'];
    final total = totalRaw is num
        ? totalRaw.toDouble()
        : double.tryParse('$totalRaw') ?? 0;

    final byCategoryRaw = json['byCategory'];
    final byCategory = byCategoryRaw is List
        ? byCategoryRaw
            .map(
              (e) => SiteExpenseCategorySummaryModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList()
        : <SiteExpenseCategorySummaryModel>[];

    return SiteExpenseSummaryModel(
      siteId: (json['siteId'] ?? '') as String,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      totalAmount: total,
      currency: json['currency'] as String? ?? 'TRY',
      byCategory: byCategory,
    );
  }

  SiteExpenseSummaryEntity toEntity() {
    return SiteExpenseSummaryEntity(
      siteId: siteId,
      month: month,
      year: year,
      totalAmount: totalAmount,
      currency: currency,
      byCategory: byCategory.map((c) => c.toEntity()).toList(),
    );
  }
}

class SiteExpenseCategorySummaryModel {
  final String category;
  final double amount;
  final int count;

  const SiteExpenseCategorySummaryModel({
    required this.category,
    required this.amount,
    required this.count,
  });

  factory SiteExpenseCategorySummaryModel.fromJson(Map<String, dynamic> json) {
    // Backend numeric döner; eski string formatını da toleransla parse et.
    final amountRaw = json['amount'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse('$amountRaw') ?? 0;

    return SiteExpenseCategorySummaryModel(
      category: (json['category'] ?? 'OTHER') as String,
      amount: amount,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  SiteExpenseCategorySummary toEntity() {
    return SiteExpenseCategorySummary(
      category: ExpenseModel.parseCategoryApi(category),
      amount: amount,
      count: count,
    );
  }
}

DateTime _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
}
