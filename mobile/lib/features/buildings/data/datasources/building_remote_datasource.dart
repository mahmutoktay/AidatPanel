import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/iban_utils.dart';
import '../models/building_model.dart';
import '../models/collection_preset_model.dart';

abstract class BuildingRemoteDataSource {
  Future<List<BuildingModel>> fetchBuildings();
  Future<List<CollectionPresetModel>> fetchCollectionPresets();
  Future<BuildingModel> createBuilding({
    required String name,
    required String address,
    required String city,
    int? totalFloors,
    int? apartmentsPerFloor,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  });
  Future<BuildingModel> updateBuilding({
    required String id,
    String? name,
    String? address,
    String? city,
  });
  Future<BuildingModel> patchBuildingCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    required String? paymentReferenceTemplate,
  });
  Future<void> deleteBuilding(String id);
  Future<CollectionPresetModel> createCollectionPreset({
    required String collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  });
  Future<void> deleteCollectionPreset(String normalizedIban);
}

class BuildingRemoteDataSourceImpl implements BuildingRemoteDataSource {
  final DioClient _dioClient;

  BuildingRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  Map<String, dynamic>? _collectionBody({
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  }) {
    final body = <String, dynamic>{};
    if (collectionIban != null) {
      body['collectionIban'] = collectionIban.isEmpty
          ? null
          : IbanUtils.normalize(collectionIban);
    }
    if (collectionAccountTitle != null) {
      final t = collectionAccountTitle.trim();
      body['collectionAccountTitle'] = t.isEmpty ? null : t;
    }
    if (paymentReferenceTemplate != null) {
      final t = paymentReferenceTemplate.trim();
      body['paymentReferenceTemplate'] = t.isEmpty ? null : t;
    }
    return body.isEmpty ? null : body;
  }

  @override
  Future<List<BuildingModel>> fetchBuildings() async {
    final response = await _dioClient.get(ApiConstants.buildings);
    final data = response.data['data'] as List;
    return data
        .map((json) => BuildingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CollectionPresetModel>> fetchCollectionPresets() async {
    final response =
        await _dioClient.get(ApiConstants.buildingsCollectionPresets);
    final data = response.data['data'] as List;
    return data
        .map((json) =>
            CollectionPresetModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BuildingModel> createBuilding({
    required String name,
    required String address,
    required String city,
    int? totalFloors,
    int? apartmentsPerFloor,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'address': address,
      'city': city,
      'totalFloors': ?totalFloors,
      'apartmentsPerFloor': ?apartmentsPerFloor,
      'dueAmount': ?dueAmount,
      'dueDay': ?dueDay,
      'currency': ?currency,
    };
    final collection = _collectionBody(
      collectionIban: collectionIban,
      collectionAccountTitle: collectionAccountTitle,
      paymentReferenceTemplate: paymentReferenceTemplate,
    );
    if (collection != null) body.addAll(collection);

    final response = await _dioClient.post(ApiConstants.buildings, data: body);
    return BuildingModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<BuildingModel> updateBuilding({
    required String id,
    String? name,
    String? address,
    String? city,
  }) async {
    final body = <String, dynamic>{
      'name': ?name,
      'address': ?address,
      'city': ?city,
    };
    final response =
        await _dioClient.put(ApiConstants.buildingDetail(id), data: body);
    return BuildingModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<BuildingModel> patchBuildingCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    required String? paymentReferenceTemplate,
  }) async {
    final body = <String, dynamic>{
      'collectionIban': (collectionIban == null || collectionIban.isEmpty)
          ? null
          : IbanUtils.normalize(collectionIban),
      'collectionAccountTitle':
          (collectionAccountTitle?.trim().isEmpty ?? true)
              ? null
              : collectionAccountTitle!.trim(),
      'paymentReferenceTemplate':
          (paymentReferenceTemplate?.trim().isEmpty ?? true)
              ? null
              : paymentReferenceTemplate!.trim(),
    };
    final response = await _dioClient.patch(
      ApiConstants.buildingCollection(id),
      data: body,
    );
    return BuildingModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBuilding(String id) async {
    await _dioClient.delete(ApiConstants.buildingDetail(id));
  }

  @override
  Future<CollectionPresetModel> createCollectionPreset({
    required String collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  }) async {
    final body = <String, dynamic>{
      'collectionIban': IbanUtils.normalize(collectionIban),
      'collectionAccountTitle':
          (collectionAccountTitle?.trim().isEmpty ?? true)
              ? null
              : collectionAccountTitle!.trim(),
      'paymentReferenceTemplate':
          (paymentReferenceTemplate?.trim().isEmpty ?? true)
              ? null
              : paymentReferenceTemplate!.trim(),
    };

    final response = await _dioClient.post(
      ApiConstants.buildingsCollectionPresets,
      data: body,
    );
    return CollectionPresetModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteCollectionPreset(String normalizedIban) async {
    await _dioClient.delete(
      ApiConstants.buildingCollectionPreset(normalizedIban),
    );
  }
}
