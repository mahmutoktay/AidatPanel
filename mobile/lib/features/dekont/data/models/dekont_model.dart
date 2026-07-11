import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/dekont_status.dart';
import '../../domain/entities/payment_collection_entity.dart';

class PaymentCollectionModel {
  final String buildingId;
  final String buildingName;
  final String apartmentNumber;
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;
  final String? paymentReference;
  final bool isCollectionConfigured;

  const PaymentCollectionModel({
    required this.buildingId,
    required this.buildingName,
    required this.apartmentNumber,
    this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
    this.paymentReference,
    this.isCollectionConfigured = false,
  });

  factory PaymentCollectionModel.fromJson(Map<String, dynamic> json) {
    return PaymentCollectionModel(
      buildingId: (json['buildingId'] ?? '') as String,
      buildingName: (json['buildingName'] ?? '') as String,
      apartmentNumber: (json['apartmentNumber'] ?? '') as String,
      collectionIban: json['collectionIban'] as String?,
      collectionAccountTitle: json['collectionAccountTitle'] as String?,
      paymentReferenceTemplate: json['paymentReferenceTemplate'] as String?,
      paymentReference: json['paymentReference'] as String?,
      isCollectionConfigured: json['isCollectionConfigured'] == true,
    );
  }

  PaymentCollectionEntity toEntity() => PaymentCollectionEntity(
        buildingId: buildingId,
        buildingName: buildingName,
        apartmentNumber: apartmentNumber,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
        paymentReference: paymentReference,
        isCollectionConfigured: isCollectionConfigured,
      );
}

class DekontModel {
  final String id;
  final String buildingId;
  final String? buildingName;
  final String? apartmentId;
  final String uploadedById;
  final String? dueId;
  final List<String> dueIds;
  final List<DekontDueAllocationSummary> allocations;
  final String status;
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

  const DekontModel({
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

  factory DekontModel.fromJson(Map<String, dynamic> json) {
    DekontApartmentSummary? apartment;
    final apt = json['apartment'];
    if (apt is Map) {
      apartment = DekontApartmentSummary(
        id: _asString(apt['id']),
        number: _asString(apt['number']),
      );
    }

    DekontUserSummary? uploadedBy;
    final uploader = json['uploadedBy'];
    if (uploader is Map) {
      uploadedBy = DekontUserSummary(
        id: _asString(uploader['id']),
        name: _asString(uploader['name']),
        email: uploader['email'] as String?,
      );
    }

    Map<String, dynamic>? parsedJson;
    final rawParsed = json['parsedJson'];
    if (rawParsed is Map) {
      parsedJson = Map<String, dynamic>.from(rawParsed);
    }

    final dueIds = <String>[];
    final rawDueIds = json['dueIds'];
    if (rawDueIds is List) {
      for (final id in rawDueIds) {
        if (id != null && id.toString().isNotEmpty) {
          dueIds.add(id.toString());
        }
      }
    }

    final allocations = <DekontDueAllocationSummary>[];
    final rawAlloc = json['allocations'];
    if (rawAlloc is List) {
      for (final item in rawAlloc) {
        if (item is! Map) continue;
        final dueId = _asString(item['dueId']);
        if (dueId.isEmpty) continue;
        allocations.add(
          DekontDueAllocationSummary(
            dueId: dueId,
            allocatedAmount: item['allocatedAmount']?.toString(),
            month: item['month'] is num ? (item['month'] as num).toInt() : null,
            year: item['year'] is num ? (item['year'] as num).toInt() : null,
            amount: item['amount']?.toString(),
            remainingAmount: item['remainingAmount']?.toString(),
            apartmentNumber: item['apartmentNumber']?.toString(),
            status: item['status']?.toString(),
          ),
        );
        if (!dueIds.contains(dueId)) dueIds.add(dueId);
      }
    }

    final primaryDueId = json['dueId'] as String?;
    if (primaryDueId != null &&
        primaryDueId.isNotEmpty &&
        !dueIds.contains(primaryDueId)) {
      dueIds.insert(0, primaryDueId);
    }

    return DekontModel(
      id: _asString(json['id']),
      buildingId: _asString(json['buildingId']),
      buildingName: _optionalTrimmedString(json['buildingName']),
      apartmentId: json['apartmentId'] as String?,
      uploadedById: _asString(json['uploadedById']),
      dueId: primaryDueId,
      dueIds: dueIds,
      allocations: allocations,
      status: _asString(json['status'], fallback: 'RECEIVED'),
      source: _asString(json['source'], fallback: 'RESIDENT_UPLOAD'),
      originalFilename: _asString(json['originalFilename']),
      mimeType: _asString(json['mimeType'], fallback: 'application/pdf'),
      sizeBytes: _asInt(json['sizeBytes']),
      recipientVerified: _asBool(json['recipientVerified']),
      referenceNumber: json['referenceNumber'] as String?,
      parsedAmount: json['parsedAmount']?.toString(),
      transactionDate: _parseDate(json['transactionDate']),
      aiConfidence: _asDouble(json['aiConfidence']),
      reviewedAt: _parseDate(json['reviewedAt']),
      reviewNote: json['reviewNote'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
      parseError: json['parseError'] as String?,
      parserProfile: json['parserProfile'] as String?,
      parsedJson: parsedJson,
      apartment: apartment,
      uploadedBy: uploadedBy,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  static String? _optionalTrimmedString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final l = value.toLowerCase();
      if (l == 'true' || l == '1') return true;
      if (l == 'false' || l == '0') return false;
    }
    return null;
  }

  DekontEntity toEntity() {
    final parsedStatus =
        DekontStatus.fromApi(status) ?? DekontStatus.received;
    return DekontEntity(
      id: id,
      buildingId: buildingId,
      buildingName: buildingName,
      apartmentId: apartmentId,
      uploadedById: uploadedById,
      dueId: dueId,
      dueIds: dueIds,
      allocations: allocations,
      status: parsedStatus,
      source: source,
      originalFilename: originalFilename,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      recipientVerified: recipientVerified,
      referenceNumber: referenceNumber,
      parsedAmount: parsedAmount,
      transactionDate: transactionDate,
      aiConfidence: aiConfidence,
      reviewedAt: reviewedAt,
      reviewNote: reviewNote,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      parseError: parseError,
      parserProfile: parserProfile,
      parsedJson: parsedJson,
      apartment: apartment,
      uploadedBy: uploadedBy,
    );
  }

  static List<DekontModel> parseList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => DekontModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((e) => DekontModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
