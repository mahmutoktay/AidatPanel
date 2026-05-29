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

class DekontEntity extends Equatable {
  final String id;
  final String buildingId;
  final String? apartmentId;
  final String uploadedById;
  final String? dueId;
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
    this.apartmentId,
    required this.uploadedById,
    this.dueId,
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

  bool get isTerminal => status.isTerminal;

  bool get isProcessing => status.isProcessing;

  @override
  List<Object?> get props => [
        id,
        buildingId,
        apartmentId,
        uploadedById,
        dueId,
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
