import 'package:equatable/equatable.dart';

<<<<<<< HEAD
import '../../../expenses/domain/entities/expense_create_outcome.dart';
import 'site_expense_entity.dart';

class SiteExpenseCreateOutcome extends Equatable {
  final ExpensePaidImpactPreview? preview;
=======
import 'site_expense_entity.dart';

class SiteExpensePaidImpactPreview extends Equatable {
  final String message;
  final int paidApartmentCount;
  final String perUnitAmount;
  final String totalUnpaidShare;
  final int nextMonth;
  final int nextYear;
  final bool pastMonthWarning;

  const SiteExpensePaidImpactPreview({
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

class SiteExpenseCreateOutcome extends Equatable {
  final SiteExpensePaidImpactPreview? preview;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final SiteExpenseEntity? expense;
  final List<String> warnings;
  final bool pastMonthWarning;

  const SiteExpenseCreateOutcome({
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
