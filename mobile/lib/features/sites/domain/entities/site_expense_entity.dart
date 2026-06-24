import 'package:equatable/equatable.dart';

import '../../../expenses/domain/entities/expense_entity.dart';

class SiteExpenseEntity extends Equatable {
  final String id;
  final String siteId;
  final String title;
  final double? amount;
  final double? parsedAmount;
  final ExpenseCategory category;
  final DateTime date;
  final int targetMonth;
  final int targetYear;
  final double? perUnitAmount;
  final String? note;
  final String? receiptUrl;
  final List<String> receiptUrls;
  final DateTime createdAt;

  const SiteExpenseEntity({
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

  @override
  List<Object?> get props => [
        id,
        siteId,
        title,
        amount,
        parsedAmount,
        category,
        date,
        targetMonth,
        targetYear,
        perUnitAmount,
        note,
        receiptUrl,
        receiptUrls,
        createdAt,
      ];
}

class SiteExpenseSummaryEntity extends Equatable {
  final String siteId;
  final int month;
  final int year;
  final double totalAmount;
  final String currency;
  final List<SiteExpenseCategorySummary> byCategory;

  const SiteExpenseSummaryEntity({
    required this.siteId,
    required this.month,
    required this.year,
    required this.totalAmount,
    required this.currency,
    required this.byCategory,
  });

  @override
  List<Object?> get props =>
      [siteId, month, year, totalAmount, currency, byCategory];
}

class SiteExpenseCategorySummary extends Equatable {
  final ExpenseCategory category;
  final double amount;
  final int count;

  const SiteExpenseCategorySummary({
    required this.category,
    required this.amount,
    required this.count,
  });

  @override
  List<Object?> get props => [category, amount, count];
}
