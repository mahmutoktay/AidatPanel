import 'package:equatable/equatable.dart';

import '../../../../core/utils/iban_utils.dart';

/// `GET /buildings/collection-presets` — son kullanılan tahsilat seti.
class CollectionPresetEntity extends Equatable {
  final String collectionIban;
  final String? collectionAccountTitle;
  final String? collectionIbanLabel;
  final String? paymentReferenceTemplate;
  final DateTime? lastUsedAt;
  final int buildingCount;
  final int siteCount;

  const CollectionPresetEntity({
    required this.collectionIban,
    this.collectionAccountTitle,
    this.collectionIbanLabel,
    this.paymentReferenceTemplate,
    this.lastUsedAt,
    this.buildingCount = 0,
    this.siteCount = 0,
  });

  /// Liste başlığı: takma ad varsa o, yoksa formatlanmış IBAN.
  String get displayTitle {
    final label = collectionIbanLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    return IbanUtils.formatDisplay(collectionIban);
  }

  bool get hasLabel {
    final label = collectionIbanLabel?.trim();
    return label != null && label.isNotEmpty;
  }

  int get usageCount => buildingCount + siteCount;

  @override
  List<Object?> get props => [
        collectionIban,
        collectionAccountTitle,
        collectionIbanLabel,
        paymentReferenceTemplate,
        lastUsedAt,
        buildingCount,
        siteCount,
      ];
}
