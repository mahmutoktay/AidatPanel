import 'package:equatable/equatable.dart';

enum DueTransactionKind { payment, dekont }

enum DueTransactionSource { receipt, manual }

enum DueTransactionStatus { approved, pending, rejected }

class DueTransactionEntity extends Equatable {
  final String id;
  final DueTransactionKind kind;
  final DueTransactionSource source;
  final double? amount;
  final String currency;
  final DateTime occurredAt;
  final String? apartmentNumber;
  final String? residentName;
  final DueTransactionStatus status;
  final String? dekontId;
  final String? dueId;

  const DueTransactionEntity({
    required this.id,
    required this.kind,
    required this.source,
    required this.amount,
    required this.currency,
    required this.occurredAt,
    this.apartmentNumber,
    this.residentName,
    required this.status,
    this.dekontId,
    this.dueId,
  });

  @override
  List<Object?> get props => [
        id,
        kind,
        source,
        amount,
        currency,
        occurredAt,
        apartmentNumber,
        residentName,
        status,
        dekontId,
        dueId,
      ];
}
