import '../../../expenses/data/models/expense_model.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../domain/entities/site_expense_entity.dart';

class SiteExpenseModel {
  final String id;
  final String siteId;
  final String title;
  final double? amount;
  final String category;
  final DateTime date;
  final int targetMonth;
  final int targetYear;
  final double? perUnitAmount;
  final String? note;
  final DateTime createdAt;

  const SiteExpenseModel({
    required this.id,
    required this.siteId,
    required this.title,
    this.amount,
    required this.category,
    required this.date,
    this.targetMonth = 1,
    this.targetYear = 2026,
    this.perUnitAmount,
    this.note,
    required this.createdAt,
  });

  factory SiteExpenseModel.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    final amount = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse('$amountRaw');

    final perUnitRaw = json['perUnitAmount'];
    final perUnitAmount = perUnitRaw is num
        ? perUnitRaw.toDouble()
        : double.tryParse('$perUnitRaw');

    return SiteExpenseModel(
      id: (json['id'] ?? '') as String,
      siteId: (json['siteId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      amount: amount,
      category: (json['category'] ?? 'OTHER') as String,
      date: _parseDate(json['date']),
      targetMonth:
          (json['targetMonth'] as num?)?.toInt() ?? _parseDate(json['date']).month,
      targetYear:
          (json['targetYear'] as num?)?.toInt() ?? _parseDate(json['date']).year,
      perUnitAmount: perUnitAmount,
      note: json['note'] as String?,
      createdAt: _parseDate(json['createdAt']),
    );
  }

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
}
