import 'package:equatable/equatable.dart';

import '../../../../core/utils/iban_utils.dart';
import '../../../buildings/domain/entities/building_entity.dart';

class SiteEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final double? dueAmount;
  final int? dueDay;
  final String currency;
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? collectionIbanLabel;
  final String? paymentReferenceTemplate;
  final int buildingCount;
  final int totalApartments;
  final int occupiedApartments;
  final double collectedAmount;
  final double expectedAmount;
  final int overdueCount;
  final int pendingCount;

  const SiteEntity({
    required this.id,
    required this.name,
    required this.address,
    this.city = '',
    this.dueAmount,
    this.dueDay,
    this.currency = 'TRY',
    this.collectionIban,
    this.collectionAccountTitle,
    this.collectionIbanLabel,
    this.paymentReferenceTemplate,
    this.buildingCount = 0,
    this.totalApartments = 0,
    this.occupiedApartments = 0,
    this.collectedAmount = 0,
    this.expectedAmount = 0,
    this.overdueCount = 0,
    this.pendingCount = 0,
  });

  bool get isCollectionConfigured => IbanUtils.isValidTrIban(collectionIban);

  String get displayAddress =>
      city.trim().isEmpty ? address : '$address, $city';

  double get collectionRate {
    if (expectedAmount <= 0) return 0;
    return (collectedAmount / expectedAmount) * 100;
  }

  SiteEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? collectionIbanLabel,
    String? paymentReferenceTemplate,
    int? buildingCount,
    int? totalApartments,
    int? occupiedApartments,
    double? collectedAmount,
    double? expectedAmount,
    int? overdueCount,
    int? pendingCount,
  }) {
    return SiteEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      dueAmount: dueAmount ?? this.dueAmount,
      dueDay: dueDay ?? this.dueDay,
      currency: currency ?? this.currency,
      collectionIban: collectionIban ?? this.collectionIban,
      collectionAccountTitle:
          collectionAccountTitle ?? this.collectionAccountTitle,
      collectionIbanLabel: collectionIbanLabel ?? this.collectionIbanLabel,
      paymentReferenceTemplate:
          paymentReferenceTemplate ?? this.paymentReferenceTemplate,
      buildingCount: buildingCount ?? this.buildingCount,
      totalApartments: totalApartments ?? this.totalApartments,
      occupiedApartments: occupiedApartments ?? this.occupiedApartments,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      overdueCount: overdueCount ?? this.overdueCount,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        dueAmount,
        dueDay,
        currency,
        collectionIban,
        collectionAccountTitle,
        collectionIbanLabel,
        paymentReferenceTemplate,
        buildingCount,
        totalApartments,
        occupiedApartments,
        collectedAmount,
        expectedAmount,
        overdueCount,
        pendingCount,
      ];
}

class SiteAggregationEntity extends Equatable {
  final int month;
  final int year;
  final double collectedAmount;
  final double expectedAmount;
  final String currency;

  const SiteAggregationEntity({
    required this.month,
    required this.year,
    required this.collectedAmount,
    required this.expectedAmount,
    this.currency = 'TRY',
  });

  double get collectionRate {
    if (expectedAmount <= 0) return 0;
    return (collectedAmount / expectedAmount) * 100;
  }

  @override
  List<Object?> get props =>
      [month, year, collectedAmount, expectedAmount, currency];
}

class SiteDetailEntity extends Equatable {
  final SiteEntity site;
  final List<BuildingEntity> buildings;
  final SiteAggregationEntity aggregation;

  const SiteDetailEntity({
    required this.site,
    required this.buildings,
    required this.aggregation,
  });

  @override
  List<Object?> get props => [site, buildings, aggregation];
}
