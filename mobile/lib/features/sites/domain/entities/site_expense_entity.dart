import 'package:equatable/equatable.dart';

import '../../../expenses/domain/entities/expense_entity.dart';

class SiteExpenseEntity extends Equatable {
  final String id;
  final String siteId;
  final String title;
  final double? amount;
<<<<<<< HEAD
=======
  final double? parsedAmount;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final ExpenseCategory category;
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

  const SiteExpenseEntity({
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

  @override
  List<Object?> get props => [
        id,
        siteId,
        title,
        amount,
<<<<<<< HEAD
=======
        parsedAmount,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        category,
        date,
        targetMonth,
        targetYear,
        perUnitAmount,
        note,
<<<<<<< HEAD
=======
        receiptUrl,
        receiptUrls,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        createdAt,
      ];
}

class SiteExpenseSummaryEntity extends Equatable {
<<<<<<< HEAD
=======
  final String siteId;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final int month;
  final int year;
  final double totalAmount;
  final String currency;
<<<<<<< HEAD
  final int apartmentCount;

  const SiteExpenseSummaryEntity({
=======
  final List<SiteExpenseCategorySummary> byCategory;

  const SiteExpenseSummaryEntity({
    required this.siteId,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    required this.month,
    required this.year,
    required this.totalAmount,
    required this.currency,
<<<<<<< HEAD
    required this.apartmentCount,
  });

  @override
  List<Object?> get props => [month, year, totalAmount, currency, apartmentCount];
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
}
