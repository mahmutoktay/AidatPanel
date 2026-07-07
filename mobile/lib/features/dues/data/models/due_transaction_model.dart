import '../../domain/entities/due_transaction_entity.dart';

class DueTransactionModel {
  final String id;
  final String kind;
  final String source;
  final double? amount;
  final String currency;
  final DateTime occurredAt;
  final String? apartmentNumber;
  final String? residentName;
  final String status;
  final String? dekontId;
  final String? dueId;

  const DueTransactionModel({
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

  factory DueTransactionModel.fromJson(Map<String, dynamic> json) {
    return DueTransactionModel(
      id: json['id'] as String,
      kind: json['kind'] as String? ?? 'PAYMENT',
      source: json['source'] as String? ?? 'MANUAL',
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'TRY',
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      apartmentNumber: json['apartmentNumber'] as String?,
      residentName: json['residentName'] as String?,
      status: json['status'] as String? ?? 'APPROVED',
      dekontId: json['dekontId'] as String?,
      dueId: json['dueId'] as String?,
    );
  }

  DueTransactionEntity toEntity() {
    return DueTransactionEntity(
      id: id,
      kind: kind == 'DEKONT'
          ? DueTransactionKind.dekont
          : DueTransactionKind.payment,
      source: source == 'RECEIPT'
          ? DueTransactionSource.receipt
          : DueTransactionSource.manual,
      amount: amount,
      currency: currency,
      occurredAt: occurredAt,
      apartmentNumber: apartmentNumber,
      residentName: residentName,
      status: _mapStatus(status),
      dekontId: dekontId,
      dueId: dueId,
    );
  }

  static DueTransactionStatus _mapStatus(String value) {
    switch (value) {
      case 'PENDING':
        return DueTransactionStatus.pending;
      case 'REJECTED':
        return DueTransactionStatus.rejected;
      default:
        return DueTransactionStatus.approved;
    }
  }
}
