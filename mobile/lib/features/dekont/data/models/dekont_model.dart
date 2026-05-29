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
  final String? apartmentId;
  final String uploadedById;
  final String? dueId;
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

  factory DekontModel.fromJson(Map<String, dynamic> json) {
    DekontApartmentSummary? apartment;
    final apt = json['apartment'];
    if (apt is Map) {
      apartment = DekontApartmentSummary(
        id: (apt['id'] ?? '') as String,
        number: (apt['number'] ?? '') as String,
      );
    }

    DekontUserSummary? uploadedBy;
    final uploader = json['uploadedBy'];
    if (uploader is Map) {
      uploadedBy = DekontUserSummary(
        id: (uploader['id'] ?? '') as String,
        name: (uploader['name'] ?? '') as String,
        email: uploader['email'] as String?,
      );
    }

    Map<String, dynamic>? parsedJson;
    final rawParsed = json['parsedJson'];
    if (rawParsed is Map) {
      parsedJson = Map<String, dynamic>.from(rawParsed);
    }

    return DekontModel(
      id: (json['id'] ?? '') as String,
      buildingId: (json['buildingId'] ?? '') as String,
      apartmentId: json['apartmentId'] as String?,
      uploadedById: (json['uploadedById'] ?? '') as String,
      dueId: json['dueId'] as String?,
      status: (json['status'] ?? 'RECEIVED') as String,
      source: (json['source'] ?? 'RESIDENT_UPLOAD') as String,
      originalFilename: (json['originalFilename'] ?? '') as String,
      mimeType: (json['mimeType'] ?? 'application/pdf') as String,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      recipientVerified: json['recipientVerified'] as bool?,
      referenceNumber: json['referenceNumber'] as String?,
      parsedAmount: json['parsedAmount']?.toString(),
      transactionDate: _parseDate(json['transactionDate']),
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
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

  DekontEntity toEntity() {
    final parsedStatus =
        DekontStatus.fromApi(status) ?? DekontStatus.received;
    return DekontEntity(
      id: id,
      buildingId: buildingId,
      apartmentId: apartmentId,
      uploadedById: uploadedById,
      dueId: dueId,
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
