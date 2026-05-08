import '../../domain/entities/due_entity.dart';

class DueModel {
  final String id;
  final String apartmentId;
  final String apartmentNumber;
  final double amount;
  final String currency;
  final int month;
  final int year;
  final String status;
  final DateTime? paidAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DueModel({
    required this.id,
    required this.apartmentId,
    required this.apartmentNumber,
    required this.amount,
    required this.currency,
    required this.month,
    required this.year,
    required this.status,
    this.paidAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DueModel.fromJson(Map<String, dynamic> json) {
    return DueModel(
      id: (json['id'] ?? '') as String,
      apartmentId: (json['apartmentId'] ?? '') as String,
      apartmentNumber: (json['apartmentNumber'] ?? '') as String,
      amount: _toDouble(json['amount']),
      currency: (json['currency'] ?? 'TRY') as String,
      month: (json['month'] ?? 0) as int,
      year: (json['year'] ?? 0) as int,
      status: (json['status'] ?? 'PENDING') as String,
      paidAt: _toDateTime(json['paidAt']),
      note: json['note'] as String?,
      createdAt: _toDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _toDateTime(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartmentId': apartmentId,
      'apartmentNumber': apartmentNumber,
      'amount': amount,
      'currency': currency,
      'month': month,
      'year': year,
      'status': status,
      'paidAt': paidAt?.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DueEntity toEntity() {
    return DueEntity(
      id: id,
      apartmentId: apartmentId,
      apartmentNumber: apartmentNumber,
      amount: amount,
      currency: currency,
      month: month,
      year: year,
      status: _mapStatus(status),
      paidAt: paidAt,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DueStatus _mapStatus(String value) {
    switch (value.toUpperCase()) {
      case 'PAID':
        return DueStatus.paid;
      case 'OVERDUE':
        return DueStatus.overdue;
      case 'WAIVED':
        return DueStatus.waived;
      case 'PENDING':
      default:
        return DueStatus.pending;
    }
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
