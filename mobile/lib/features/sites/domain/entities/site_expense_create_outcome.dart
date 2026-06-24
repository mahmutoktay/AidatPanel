import 'package:equatable/equatable.dart';

import '../../../expenses/domain/entities/expense_create_outcome.dart';
import 'site_expense_entity.dart';

class SiteExpenseCreateOutcome extends Equatable {
  final ExpensePaidImpactPreview? preview;
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
