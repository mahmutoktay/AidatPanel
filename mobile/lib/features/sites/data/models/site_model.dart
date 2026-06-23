import '../../domain/entities/site_entity.dart';
import '../../../buildings/data/models/building_model.dart';

class SiteModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final int buildingCount;
  final double? dueAmount;
  final int? dueDay;
  final String? currency;
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;
  final double? expectedAmount;
  final double? collectedAmount;
  final List<BuildingModel>? buildings;

  SiteModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.buildingCount = 0,
    this.dueAmount,
    this.dueDay,
    this.currency,
    this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
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

    return SiteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String? ?? '',
      buildingCount: json['buildingCount'] as int? ??
          (json['_count'] is Map
              ? (json['_count'] as Map)['buildings'] as int? ?? 0
              : 0),
      dueAmount: BuildingModel.parseDouble(json['dueAmount']),
      dueDay: json['dueDay'] as int?,
      currency: json['currency'] as String?,
      collectionIban: json['collectionIban'] as String?,
      collectionAccountTitle: json['collectionAccountTitle'] as String?,
      paymentReferenceTemplate: json['paymentReferenceTemplate'] as String?,
      expectedAmount: BuildingModel.parseDouble(json['expectedAmount']),
      collectedAmount: BuildingModel.parseDouble(json['collectedAmount']),
      buildings: buildings,
    );
  }

  SiteEntity toEntity() {
    return SiteEntity(
      id: id,
      name: name,
      address: address,
      city: city,
      buildingCount: buildingCount,
      dueAmount: dueAmount,
      dueDay: dueDay ?? 1,
      currency: currency ?? 'TRY',
      collectionIban: collectionIban,
      collectionAccountTitle: collectionAccountTitle,
      paymentReferenceTemplate: paymentReferenceTemplate,
      expectedAmount: expectedAmount ?? 0,
      collectedAmount: collectedAmount ?? 0,
    );
  }
}
