import 'package:equatable/equatable.dart';

import '../../../../core/utils/iban_utils.dart';
<<<<<<< HEAD
=======
import '../../../buildings/domain/entities/building_entity.dart';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

class SiteEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
<<<<<<< HEAD
  final int buildingCount;
  final double? dueAmount;
  final int dueDay;
=======
  final double? dueAmount;
  final int? dueDay;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final String currency;
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;
<<<<<<< HEAD
  final double expectedAmount;
  final double collectedAmount;
=======
  final int buildingCount;
  final int totalApartments;
  final int occupiedApartments;
  final double collectedAmount;
  final double expectedAmount;
  final int overdueCount;
  final int pendingCount;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

  const SiteEntity({
    required this.id,
    required this.name,
    required this.address,
<<<<<<< HEAD
    required this.city,
    required this.buildingCount,
    this.dueAmount,
    this.dueDay = 1,
=======
    this.city = '',
    this.dueAmount,
    this.dueDay,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    this.currency = 'TRY',
    this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
<<<<<<< HEAD
    this.expectedAmount = 0,
    this.collectedAmount = 0,
=======
    this.buildingCount = 0,
    this.totalApartments = 0,
    this.occupiedApartments = 0,
    this.collectedAmount = 0,
    this.expectedAmount = 0,
    this.overdueCount = 0,
    this.pendingCount = 0,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  });

  bool get isCollectionConfigured => IbanUtils.isValidTrIban(collectionIban);

  String get displayAddress =>
      city.trim().isEmpty ? address : '$address, $city';

  double get collectionRate {
<<<<<<< HEAD
    if (expectedAmount == 0) return 0;
=======
    if (expectedAmount <= 0) return 0;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    return (collectedAmount / expectedAmount) * 100;
  }

  SiteEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
<<<<<<< HEAD
    int? buildingCount,
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
<<<<<<< HEAD
    double? expectedAmount,
    double? collectedAmount,
=======
    int? buildingCount,
    int? totalApartments,
    int? occupiedApartments,
    double? collectedAmount,
    double? expectedAmount,
    int? overdueCount,
    int? pendingCount,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  }) {
    return SiteEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
<<<<<<< HEAD
      buildingCount: buildingCount ?? this.buildingCount,
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      dueAmount: dueAmount ?? this.dueAmount,
      dueDay: dueDay ?? this.dueDay,
      currency: currency ?? this.currency,
      collectionIban: collectionIban ?? this.collectionIban,
      collectionAccountTitle:
          collectionAccountTitle ?? this.collectionAccountTitle,
      paymentReferenceTemplate:
          paymentReferenceTemplate ?? this.paymentReferenceTemplate,
<<<<<<< HEAD
      expectedAmount: expectedAmount ?? this.expectedAmount,
      collectedAmount: collectedAmount ?? this.collectedAmount,
=======
      buildingCount: buildingCount ?? this.buildingCount,
      totalApartments: totalApartments ?? this.totalApartments,
      occupiedApartments: occupiedApartments ?? this.occupiedApartments,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      overdueCount: overdueCount ?? this.overdueCount,
      pendingCount: pendingCount ?? this.pendingCount,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
<<<<<<< HEAD
        buildingCount,
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        dueAmount,
        dueDay,
        currency,
        collectionIban,
        collectionAccountTitle,
        paymentReferenceTemplate,
<<<<<<< HEAD
        expectedAmount,
        collectedAmount,
      ];
}
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
