import 'package:equatable/equatable.dart';

import '../../../../core/utils/iban_utils.dart';

class SiteEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final int buildingCount;
  final double? dueAmount;
  final int dueDay;
  final String currency;
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;
  final double expectedAmount;
  final double collectedAmount;

  const SiteEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.buildingCount,
    this.dueAmount,
    this.dueDay = 1,
    this.currency = 'TRY',
    this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
    this.expectedAmount = 0,
    this.collectedAmount = 0,
  });

  bool get isCollectionConfigured => IbanUtils.isValidTrIban(collectionIban);

  String get displayAddress =>
      city.trim().isEmpty ? address : '$address, $city';

  double get collectionRate {
    if (expectedAmount == 0) return 0;
    return (collectedAmount / expectedAmount) * 100;
  }

  SiteEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    int? buildingCount,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
    double? expectedAmount,
    double? collectedAmount,
  }) {
    return SiteEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      buildingCount: buildingCount ?? this.buildingCount,
      dueAmount: dueAmount ?? this.dueAmount,
      dueDay: dueDay ?? this.dueDay,
      currency: currency ?? this.currency,
      collectionIban: collectionIban ?? this.collectionIban,
      collectionAccountTitle:
          collectionAccountTitle ?? this.collectionAccountTitle,
      paymentReferenceTemplate:
          paymentReferenceTemplate ?? this.paymentReferenceTemplate,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      collectedAmount: collectedAmount ?? this.collectedAmount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        buildingCount,
        dueAmount,
        dueDay,
        currency,
        collectionIban,
        collectionAccountTitle,
        paymentReferenceTemplate,
        expectedAmount,
        collectedAmount,
      ];
}
