import 'package:equatable/equatable.dart';

import 'expense_entity.dart';

enum ExpenseCarryForwardPolicy { carryToNextMonth, warnOnly }

class ExpensePaidImpactPreview extends Equatable {
  final String message;
  final int paidApartmentCount;
  final String perUnitAmount;
  final String totalUnpaidShare;
  final int nextMonth;
  final int nextYear;
  final bool pastMonthWarning;

  const ExpensePaidImpactPreview({
    required this.message,
    required this.paidApartmentCount,
    required this.perUnitAmount,
    required this.totalUnpaidShare,
    required this.nextMonth,
    required this.nextYear,
    this.pastMonthWarning = false,
  });

  @override
  List<Object?> get props => [
        message,
        paidApartmentCount,
        perUnitAmount,
        totalUnpaidShare,
        nextMonth,
        nextYear,
        pastMonthWarning,
      ];
}

class ExpenseCreateOutcome extends Equatable {
  final ExpensePaidImpactPreview? preview;
  final ExpenseEntity? expense;
  final List<String> warnings;
  final bool pastMonthWarning;

  const ExpenseCreateOutcome({
    this.preview,
    this.expense,
    this.warnings = const [],
    this.pastMonthWarning = false,
  });

  bool get requiresConfirmation => preview != null;
  bool get isCreated => expense != null;

  @override
  List<Object?> get props => [preview, expense, warnings, pastMonthWarning];
}
