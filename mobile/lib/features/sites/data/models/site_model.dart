import '../../domain/entities/site_entity.dart';

class SiteModel {
  final String id;
  final String name;
  final String address;
  final String? city;
  final double? dueAmount;
  final int? dueDay;
  final String? currency;
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? collectionIbanLabel;
  final String? paymentReferenceTemplate;
  final int? buildingCount;
  final int? totalApartments;
  final int? occupiedApartments;
  final double? collectedAmount;
  final double? expectedAmount;
  final int? overdueCount;
  final int? pendingCount;

  const SiteModel({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.dueAmount,
    this.dueDay,
    this.currency,
    this.collectionIban,
    this.collectionAccountTitle,
    this.collectionIbanLabel,
    this.paymentReferenceTemplate,
    this.buildingCount,
    this.totalApartments,
    this.occupiedApartments,
    this.collectedAmount,
    this.expectedAmount,
    this.overdueCount,
    this.pendingCount,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      dueAmount: _toDouble(json['dueAmount']),
      dueDay: (json['dueDay'] as num?)?.toInt(),
      currency: json['currency'] as String?,
      collectionIban: json['collectionIban'] as String?,
      collectionAccountTitle: json['collectionAccountTitle'] as String?,
      collectionIbanLabel: json['collectionIbanLabel'] as String?,
      paymentReferenceTemplate: json['paymentReferenceTemplate'] as String?,
      buildingCount: (json['buildingCount'] as num?)?.toInt(),
      totalApartments: (json['totalApartments'] as num?)?.toInt(),
      occupiedApartments: (json['occupiedApartments'] as num?)?.toInt(),
      collectedAmount: _toDouble(json['collectedAmount']),
      expectedAmount: _toDouble(json['expectedAmount']),
      overdueCount: (json['overdueCount'] as num?)?.toInt(),
      pendingCount: (json['pendingCount'] as num?)?.toInt(),
    );
  }

  SiteEntity toEntity() {
    return SiteEntity(
      id: id,
      name: name,
      address: address,
      city: city ?? '',
      dueAmount: dueAmount,
      dueDay: dueDay,
      currency: currency ?? 'TRY',
      collectionIban: collectionIban,
      collectionAccountTitle: collectionAccountTitle,
      collectionIbanLabel: collectionIbanLabel,
      paymentReferenceTemplate: paymentReferenceTemplate,
      buildingCount: buildingCount ?? 0,
      totalApartments: totalApartments ?? 0,
      occupiedApartments: occupiedApartments ?? 0,
      collectedAmount: collectedAmount ?? 0,
      expectedAmount: expectedAmount ?? 0,
      overdueCount: overdueCount ?? 0,
      pendingCount: pendingCount ?? 0,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class SiteAggregationModel {
  final int month;
  final int year;
  final double collectedAmount;
  final double expectedAmount;
  final String currency;

  const SiteAggregationModel({
    required this.month,
    required this.year,
    required this.collectedAmount,
    required this.expectedAmount,
    this.currency = 'TRY',
  });

  factory SiteAggregationModel.fromJson(Map<String, dynamic> json) {
    return SiteAggregationModel(
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      collectedAmount: SiteModel._toDouble(json['collectedAmount']) ?? 0,
      expectedAmount: SiteModel._toDouble(json['expectedAmount']) ?? 0,
      currency: json['currency'] as String? ?? 'TRY',
    );
  }

  SiteAggregationEntity toEntity() {
    return SiteAggregationEntity(
      month: month,
      year: year,
      collectedAmount: collectedAmount,
      expectedAmount: expectedAmount,
      currency: currency,
    );
  }
}
