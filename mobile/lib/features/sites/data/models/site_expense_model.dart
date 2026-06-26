import '../../../expenses/data/models/expense_model.dart';
import '../../domain/entities/site_expense_entity.dart';

class SiteExpenseModel {
  final String id;
  final String siteId;
  final String title;
  final double? amount;
  final double? parsedAmount;
  final String category;
  final DateTime date;
  final int targetMonth;
  final int targetYear;
  final double? perUnitAmount;
  final String? note;
  final String? receiptUrl;
  final List<String> receiptUrls;
  final DateTime createdAt;

  const SiteExpenseModel({
    required this.id,
    required this.siteId,
    required this.title,
    this.amount,
    this.parsedAmount,
    required this.category,
    required this.date,
    this.targetMonth = 1,
    this.targetYear = 2026,
    this.perUnitAmount,
    this.note,
    this.receiptUrl,
    this.receiptUrls = const [],
    required this.createdAt,
  });

  factory SiteExpenseModel.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse('$amountRaw');

    final parsedRaw = json['parsedAmount'];
    final parsedAmount = parsedRaw is num
        ? parsedRaw.toDouble()
        : double.tryParse('$parsedRaw');

    final perUnitRaw = json['perUnitAmount'];
    final perUnitAmount = perUnitRaw is num
        ? perUnitRaw.toDouble()
        : double.tryParse('$perUnitRaw');

    final receiptUrlsRaw = json['receiptUrls'];
    final receiptUrls = receiptUrlsRaw is List
        ? receiptUrlsRaw.map((e) => '$e').toList()
        : <String>[];

    final fallbackUrls = receiptUrls.isEmpty && json['receiptUrl'] != null
        ? [json['receiptUrl'] as String]
        : receiptUrls;

    return SiteExpenseModel(
      id: (json['id'] ?? '') as String,
      siteId: (json['siteId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      amount: amount,
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
      createdAt: _parseDate(json['createdAt']),
    );
  }

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
}
