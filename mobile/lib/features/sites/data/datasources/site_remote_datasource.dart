import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../buildings/data/models/building_model.dart';
import '../models/site_model.dart';

abstract class SiteRemoteDataSource {
  Future<List<SiteModel>> fetchSites();
  Future<SiteModel> fetchSiteById(String id);
  Future<SiteModel> createSite({
    required String name,
    required String address,
    required String city,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  });
  Future<SiteModel> updateSite({
    required String id,
    String? name,
    String? address,
    String? city,
    double? dueAmount,
    int? dueDay,
    String? currency,
  });
  Future<void> deleteSite(String id);
  Future<BuildingModel> createSiteBuilding({
    required String siteId,
    required String name,
    String? address,
    String? city,
    String? blockLabel,
    String? addressExtra,
    int? totalFloors,
    int? apartmentsPerFloor,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  });
}

class SiteRemoteDataSourceImpl implements SiteRemoteDataSource {
  final DioClient _dioClient;

  SiteRemoteDataSourceImpl({required DioClient dioClient})
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
  Future<List<SiteModel>> fetchSites() async {
    final response = await _dioClient.get(ApiConstants.sites);
    final data = response.data['data'] as List;
    return data
        .map((json) => SiteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SiteModel> fetchSiteById(String id) async {
    final response = await _dioClient.get(ApiConstants.siteDetail(id));
    return SiteModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SiteModel> createSite({
    required String name,
    required String address,
    required String city,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'address': address.trim(),
      'city': city.trim(),
      if (dueAmount != null) 'dueAmount': dueAmount,
      if (dueDay != null) 'dueDay': dueDay,
      if (currency != null) 'currency': currency,
      ...?_collectionBody(
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      ),
    };
    final response = await _dioClient.post(ApiConstants.sites, data: body);
    return SiteModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SiteModel> updateSite({
    required String id,
    String? name,
    String? address,
    String? city,
    double? dueAmount,
    int? dueDay,
    String? currency,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (address != null) 'address': address.trim(),
      if (city != null) 'city': city.trim(),
      if (dueAmount != null) 'dueAmount': dueAmount,
      if (dueDay != null) 'dueDay': dueDay,
      if (currency != null) 'currency': currency,
    };
    final response =
        await _dioClient.put(ApiConstants.siteDetail(id), data: body);
    return SiteModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSite(String id) async {
    await _dioClient.delete(ApiConstants.siteDetail(id));
  }

  @override
  Future<BuildingModel> createSiteBuilding({
    required String siteId,
    required String name,
    String? address,
    String? city,
    String? blockLabel,
    String? addressExtra,
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
      'name': name.trim(),
      if (address != null && address.trim().isNotEmpty) 'address': address.trim(),
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      if (blockLabel != null) 'blockLabel': blockLabel.trim().isEmpty ? null : blockLabel.trim(),
      if (addressExtra != null) 'addressExtra': addressExtra.trim().isEmpty ? null : addressExtra.trim(),
      if (totalFloors != null) 'totalFloors': totalFloors,
      if (apartmentsPerFloor != null) 'apartmentsPerFloor': apartmentsPerFloor,
      if (dueAmount != null) 'dueAmount': dueAmount,
      if (dueDay != null) 'dueDay': dueDay,
      if (currency != null) 'currency': currency,
      ...?_collectionBody(
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      ),
    };
    final response = await _dioClient.post(
      ApiConstants.siteBuildings(siteId),
      data: body,
    );
    return BuildingModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
