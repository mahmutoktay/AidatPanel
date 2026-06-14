import 'package:equatable/equatable.dart';

class DueBreakdownLineEntity extends Equatable {
  final String title;
  final double amount;
  final String kind;

  const DueBreakdownLineEntity({
    required this.title,
    required this.amount,
    required this.kind,
  });

  @override
  List<Object?> get props => [title, amount, kind];
}

class DueBreakdownEntity extends Equatable {
  final double baseAmount;
  final List<DueBreakdownLineEntity> expenseLines;
  final double total;

  const DueBreakdownEntity({
    required this.baseAmount,
    required this.expenseLines,
    required this.total,
  });

  bool get hasExtras => expenseLines.isNotEmpty;

  @override
  List<Object?> get props => [baseAmount, expenseLines, total];
}
