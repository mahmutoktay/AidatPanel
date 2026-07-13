import '../../domain/entities/collection_preset_entity.dart';

class CollectionPresetModel {
  final String collectionIban;
  final String? collectionAccountTitle;
  final String? collectionIbanLabel;
  final String? paymentReferenceTemplate;
  final DateTime? lastUsedAt;
  final int buildingCount;
  final int siteCount;

  CollectionPresetModel({
    required this.collectionIban,
    this.collectionAccountTitle,
    this.collectionIbanLabel,
    this.paymentReferenceTemplate,
    this.lastUsedAt,
    this.buildingCount = 0,
    this.siteCount = 0,
  });

  factory CollectionPresetModel.fromJson(Map<String, dynamic> json) {
    DateTime? lastUsedAt;
    final raw = json['lastUsedAt'];
    if (raw is String && raw.isNotEmpty) {
      lastUsedAt = DateTime.tryParse(raw);
    }
    return CollectionPresetModel(
      collectionIban: (json['collectionIban'] ?? '') as String,
      collectionAccountTitle: json['collectionAccountTitle'] as String?,
      collectionIbanLabel: json['collectionIbanLabel'] as String?,
      paymentReferenceTemplate: json['paymentReferenceTemplate'] as String?,
      lastUsedAt: lastUsedAt,
      buildingCount: json['buildingCount'] is int
          ? json['buildingCount'] as int
          : int.tryParse('${json['buildingCount']}') ?? 0,
      siteCount: json['siteCount'] is int
          ? json['siteCount'] as int
          : int.tryParse('${json['siteCount']}') ?? 0,
    );
  }

  CollectionPresetEntity toEntity() => CollectionPresetEntity(
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        collectionIbanLabel: collectionIbanLabel,
        paymentReferenceTemplate: paymentReferenceTemplate,
        lastUsedAt: lastUsedAt,
        buildingCount: buildingCount,
        siteCount: siteCount,
      );
}
