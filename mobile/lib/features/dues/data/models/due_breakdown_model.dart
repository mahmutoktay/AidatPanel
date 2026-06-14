import '../../domain/entities/due_breakdown_entity.dart';

class DueBreakdownModel {
  final double baseAmount;
  final List<DueBreakdownLineModel> expenseLines;
  final double total;

  const DueBreakdownModel({
    required this.baseAmount,
    required this.expenseLines,
    required this.total,
  });

  factory DueBreakdownModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DueBreakdownModel(
        baseAmount: 0,
        expenseLines: [],
        total: 0,
      );
    }

    final linesRaw = json['expenseLines'];
    final lines = <DueBreakdownLineModel>[];
    if (linesRaw is List) {
      for (final item in linesRaw) {
        if (item is Map<String, dynamic>) {
          lines.add(DueBreakdownLineModel.fromJson(item));
        } else if (item is Map) {
          lines.add(DueBreakdownLineModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return DueBreakdownModel(
      baseAmount: _toDouble(json['baseAmount']),
      expenseLines: lines,
      total: _toDouble(json['total']),
    );
  }

  DueBreakdownEntity toEntity() => DueBreakdownEntity(
        baseAmount: baseAmount,
        expenseLines: expenseLines.map((l) => l.toEntity()).toList(),
        total: total,
      );

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class DueBreakdownLineModel {
  final String title;
  final double amount;
  final String kind;

  const DueBreakdownLineModel({
    required this.title,
    required this.amount,
    required this.kind,
  });

  factory DueBreakdownLineModel.fromJson(Map<String, dynamic> json) {
    return DueBreakdownLineModel(
      title: (json['title'] ?? '') as String,
      amount: DueBreakdownModel._toDouble(json['amount']),
      kind: (json['kind'] ?? 'EXPENSE') as String,
    );
  }

  DueBreakdownLineEntity toEntity() => DueBreakdownLineEntity(
        title: title,
        amount: amount,
        kind: kind,
      );
}
