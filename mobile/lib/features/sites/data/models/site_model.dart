import '../../domain/entities/site_entity.dart';
<<<<<<< HEAD
import '../../../buildings/data/models/building_model.dart';
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

class SiteModel {
  final String id;
  final String name;
  final String address;
<<<<<<< HEAD
  final String city;
  final int buildingCount;
=======
  final String? city;
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final double? dueAmount;
  final int? dueDay;
  final String? currency;
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;
<<<<<<< HEAD
  final double? expectedAmount;
  final double? collectedAmount;
  final List<BuildingModel>? buildings;

  SiteModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.buildingCount = 0,
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    this.dueAmount,
    this.dueDay,
    this.currency,
    this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
<<<<<<< HEAD
    this.expectedAmount,
    this.collectedAmount,
    this.buildings,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    List<BuildingModel>? buildings;
    final rawBuildings = json['buildings'];
    if (rawBuildings is List) {
      buildings = rawBuildings
          .map((e) => BuildingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

=======
    this.buildingCount,
    this.totalApartments,
    this.occupiedApartments,
    this.collectedAmount,
    this.expectedAmount,
    this.overdueCount,
    this.pendingCount,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    return SiteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
<<<<<<< HEAD
      city: json['city'] as String? ?? '',
      buildingCount: json['buildingCount'] as int? ??
          (json['_count'] is Map
              ? (json['_count'] as Map)['buildings'] as int? ?? 0
              : 0),
      dueAmount: BuildingModel.parseDouble(json['dueAmount']),
      dueDay: json['dueDay'] as int?,
=======
      city: json['city'] as String?,
      dueAmount: _toDouble(json['dueAmount']),
      dueDay: (json['dueDay'] as num?)?.toInt(),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      currency: json['currency'] as String?,
      collectionIban: json['collectionIban'] as String?,
      collectionAccountTitle: json['collectionAccountTitle'] as String?,
      paymentReferenceTemplate: json['paymentReferenceTemplate'] as String?,
<<<<<<< HEAD
      expectedAmount: BuildingModel.parseDouble(json['expectedAmount']),
      collectedAmount: BuildingModel.parseDouble(json['collectedAmount']),
      buildings: buildings,
=======
      buildingCount: (json['buildingCount'] as num?)?.toInt(),
      totalApartments: (json['totalApartments'] as num?)?.toInt(),
      occupiedApartments: (json['occupiedApartments'] as num?)?.toInt(),
      collectedAmount: _toDouble(json['collectedAmount']),
      expectedAmount: _toDouble(json['expectedAmount']),
      overdueCount: (json['overdueCount'] as num?)?.toInt(),
      pendingCount: (json['pendingCount'] as num?)?.toInt(),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    );
  }

  SiteEntity toEntity() {
    return SiteEntity(
      id: id,
      name: name,
      address: address,
<<<<<<< HEAD
      city: city,
      buildingCount: buildingCount,
      dueAmount: dueAmount,
      dueDay: dueDay ?? 1,
=======
      city: city ?? '',
      dueAmount: dueAmount,
      dueDay: dueDay,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      currency: currency ?? 'TRY',
      collectionIban: collectionIban,
      collectionAccountTitle: collectionAccountTitle,
      paymentReferenceTemplate: paymentReferenceTemplate,
<<<<<<< HEAD
      expectedAmount: expectedAmount ?? 0,
      collectedAmount: collectedAmount ?? 0,
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    );
  }
}
