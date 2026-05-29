import '../../domain/entities/collection_preset_entity.dart';

class CollectionPresetModel {
  final String collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;
  final DateTime? lastUsedAt;
  final int buildingCount;

  CollectionPresetModel({
    required this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
    this.lastUsedAt,
    this.buildingCount = 0,
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
      paymentReferenceTemplate: json['paymentReferenceTemplate'] as String?,
      lastUsedAt: lastUsedAt,
      buildingCount: json['buildingCount'] is int
          ? json['buildingCount'] as int
          : int.tryParse('${json['buildingCount']}') ?? 0,
    );
  }

  CollectionPresetEntity toEntity() => CollectionPresetEntity(
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
        lastUsedAt: lastUsedAt,
        buildingCount: buildingCount,
      );
}
