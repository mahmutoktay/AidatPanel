import 'package:equatable/equatable.dart';

import '../../../expenses/domain/entities/expense_entity.dart';

class SiteExpenseEntity extends Equatable {
  final String id;
  final String siteId;
  final String title;
  final double? amount;
  final ExpenseCategory category;
  final DateTime date;
  final int targetMonth;
  final int targetYear;
  final double? perUnitAmount;
  final String? note;
  final DateTime createdAt;

  const SiteExpenseEntity({
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

  @override
  List<Object?> get props => [
        id,
        siteId,
        title,
        amount,
        category,
        date,
        targetMonth,
        targetYear,
        perUnitAmount,
        note,
        createdAt,
      ];
}

class SiteExpenseSummaryEntity extends Equatable {
  final int month;
  final int year;
  final double totalAmount;
  final String currency;
  final int apartmentCount;

  const SiteExpenseSummaryEntity({
    required this.month,
    required this.year,
    required this.totalAmount,
    required this.currency,
    required this.apartmentCount,
  });

  @override
  List<Object?> get props => [month, year, totalAmount, currency, apartmentCount];
}
