import '../../../apartments/data/models/resident_model.dart';
import '../../../apartments/domain/entities/resident_info.dart';
import '../../domain/entities/due_entity.dart';
import 'due_breakdown_model.dart';

class DueModel {
  final String id;
  final String apartmentId;
  final String apartmentNumber;
  final int? apartmentFloor;
  final ResidentInfo? resident;
  final double amount;
  final String currency;
  final int month;
  final int year;
  final DateTime? dueDate;
  final String status;
  final DateTime? paidAt;
  final int overdueDays;
  final String? note;
  final DueBreakdownModel? breakdown;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double paidAmount;
  final double remainingAmount;

  const DueModel({
    required this.id,
    required this.apartmentId,
    required this.apartmentNumber,
    this.apartmentFloor,
    this.resident,
    required this.amount,
    required this.currency,
    required this.month,
    required this.year,
    this.dueDate,
    required this.status,
    this.paidAt,
    this.overdueDays = 0,
    this.note,
    this.breakdown,
    required this.createdAt,
    required this.updatedAt,
    this.paidAmount = 0,
    double? remainingAmount,
  }) : remainingAmount = remainingAmount ?? amount;

  factory DueModel.fromJson(Map<String, dynamic> json) {
    // Yönetici listesinde apartmentNumber düz alan; PATCH yanıtında ise
    // sadece apartment.number bulunur. İkisini de tolere et.
    String resolveApartmentNumber() {
      final flat = json['apartmentNumber'];
      if (flat is String && flat.isNotEmpty) return flat;
      final apt = json['apartment'];
      if (apt is Map && apt['number'] is String) return apt['number'] as String;
      return '';
    }

    int? resolveApartmentFloor() {
      final apt = json['apartment'];
      if (apt is Map && apt['floor'] != null) {
        return _toInt(apt['floor']);
      }
      return null;
    }

    ResidentInfo? resolveResident() {
      final residentJson = json['resident'];
      if (residentJson is Map<String, dynamic>) {
        return ResidentModel.fromJson(residentJson).toEntity();
      }
      return null;
    }

    return DueModel(
      id: (json['id'] ?? '') as String,
      apartmentId: (json['apartmentId'] ?? '') as String,
      apartmentNumber: resolveApartmentNumber(),
      apartmentFloor: resolveApartmentFloor(),
      resident: resolveResident(),
      amount: _toDouble(json['amount']),
      currency: (json['currency'] ?? 'TRY') as String,
      month: _toInt(json['month']),
      year: _toInt(json['year']),
      dueDate: _toDateTime(json['dueDate']),
      status: (json['status'] ?? 'PENDING') as String,
      paidAt: _toDateTime(json['paidAt']),
      overdueDays: _toInt(json['overdueDays']),
      note: json['note'] as String?,
      breakdown: json['breakdown'] is Map
          ? DueBreakdownModel.fromJson(
              Map<String, dynamic>.from(json['breakdown'] as Map),
            )
          : null,
      createdAt: _toDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _toDateTime(json['updatedAt']) ?? DateTime.now(),
      paidAmount: json['paidAmount'] != null
          ? _toDouble(json['paidAmount'])
          : 0,
      remainingAmount: json['remainingAmount'] != null
          ? _toDouble(json['remainingAmount'])
          : null,
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
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'paidAt': paidAt?.toIso8601String(),
      'overdueDays': overdueDays,
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
      apartmentFloor: apartmentFloor,
      resident: resident,
      amount: amount,
      currency: currency,
      month: month,
      year: year,
      dueDate: dueDate,
      status: _mapStatus(status),
      paidAt: paidAt,
      overdueDays: overdueDays,
      note: note,
      breakdown: breakdown?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
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

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
