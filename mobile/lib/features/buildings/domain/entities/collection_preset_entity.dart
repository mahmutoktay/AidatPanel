import 'package:equatable/equatable.dart';

/// `GET /buildings/collection-presets` — son kullanılan tahsilat seti.
class CollectionPresetEntity extends Equatable {
  final String collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;
  final DateTime? lastUsedAt;
  final int buildingCount;

  const CollectionPresetEntity({
    required this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
    this.lastUsedAt,
    this.buildingCount = 0,
  });

  @override
  List<Object?> get props => [
        collectionIban,
        collectionAccountTitle,
        paymentReferenceTemplate,
        lastUsedAt,
        buildingCount,
      ];
}
