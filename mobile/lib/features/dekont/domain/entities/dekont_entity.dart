import 'package:equatable/equatable.dart';

import 'dekont_status.dart';

class DekontApartmentSummary extends Equatable {
  final String id;
  final String number;

  const DekontApartmentSummary({required this.id, required this.number});

  @override
  List<Object?> get props => [id, number];
}

class DekontUserSummary extends Equatable {
  final String id;
  final String name;
  final String? email;

  const DekontUserSummary({
    required this.id,
    required this.name,
    this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}

/// Sakinin dekont yüklerken seçtiği aidat özeti.
class DekontDueAllocationSummary extends Equatable {
  final String dueId;
  final String? allocatedAmount;
  final int? month;
  final int? year;
  final String? amount;
  final String? remainingAmount;
  final String? apartmentNumber;
  final String? status;

  const DekontDueAllocationSummary({
    required this.dueId,
    this.allocatedAmount,
    this.month,
    this.year,
    this.amount,
    this.remainingAmount,
    this.apartmentNumber,
    this.status,
  });

  @override
  List<Object?> get props => [
        dueId,
        allocatedAmount,
        month,
        year,
        amount,
        remainingAmount,
        apartmentNumber,
        status,
      ];
}

class DekontEntity extends Equatable {
  final String id;
  final String buildingId;
  /// Detay API'den gelen görünen bina adı (site · blok / bina adı).
  final String? buildingName;
  final String? apartmentId;
  final String uploadedById;
  final String? dueId;
  final List<String> dueIds;
  final List<DekontDueAllocationSummary> allocations;
  final DekontStatus status;
  final String source;
  final String originalFilename;
  final String mimeType;
  final int sizeBytes;
  final bool? recipientVerified;
  final String? referenceNumber;
  final String? parsedAmount;
  final DateTime? transactionDate;
  final double? aiConfidence;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parseError;
  final String? parserProfile;
  final Map<String, dynamic>? parsedJson;
  final DekontApartmentSummary? apartment;
  final DekontUserSummary? uploadedBy;

  const DekontEntity({
    required this.id,
    required this.buildingId,
    this.buildingName,
    this.apartmentId,
    required this.uploadedById,
    this.dueId,
    this.dueIds = const [],
    this.allocations = const [],
    required this.status,
    required this.source,
    required this.originalFilename,
    required this.mimeType,
    required this.sizeBytes,
    this.recipientVerified,
    this.referenceNumber,
    this.parsedAmount,
    this.transactionDate,
    this.aiConfidence,
    this.reviewedAt,
    this.reviewNote,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.parseError,
    this.parserProfile,
    this.parsedJson,
    this.apartment,
    this.uploadedBy,
  });

  /// Onayda kullanılacak aidat id listesi (sakin seçimi).
  List<String> get targetDueIds {
    if (dueIds.isNotEmpty) return dueIds;
    if (allocations.isNotEmpty) {
      return allocations.map((a) => a.dueId).toList();
    }
    if (dueId != null && dueId!.isNotEmpty) return [dueId!];
    return const [];
  }

  bool get isTerminal => status.isTerminal;

  bool get isProcessing => status.isProcessing;

  @override
  List<Object?> get props => [
        id,
        buildingId,
        buildingName,
        apartmentId,
        uploadedById,
        dueId,
        dueIds,
        allocations,
        status,
        source,
        originalFilename,
        mimeType,
        sizeBytes,
        recipientVerified,
        referenceNumber,
        parsedAmount,
        transactionDate,
        aiConfidence,
        reviewedAt,
        reviewNote,
        rejectionReason,
        createdAt,
        updatedAt,
        parseError,
        parserProfile,
        parsedJson,
        apartment,
        uploadedBy,
      ];
}

enum DekontReviewDecision { approve, reject }
