import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../buildings/data/models/building_model.dart';
import '../models/site_model.dart';

abstract class SiteRemoteDataSource {
  Future<List<SiteModel>> fetchSites();

  Future<Map<String, dynamic>> fetchSiteDetail(String siteId);

  Future<List<BuildingModel>> fetchSiteBuildings(String siteId);

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

  Future<SiteModel> patchSiteCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    String? collectionIbanLabel,
    bool updateIbanLabel = false,
    required String? paymentReferenceTemplate,
  });

  Future<void> deleteSite(String id);

  Future<BuildingModel> createSiteBuilding({
    required String siteId,
    required String blockLabel,
    String? name,
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
    String? collectionIbanLabel,
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
    if (collectionIbanLabel != null) {
      final t = collectionIbanLabel.trim();
      body['collectionIbanLabel'] = t.isEmpty ? null : t;
    }
    if (paymentReferenceTemplate != null) {
      final t = paymentReferenceTemplate.trim();
      body['paymentReferenceTemplate'] = t.isEmpty ? null : t;
    }
    return body.isEmpty ? null : body;
  }

  List<SiteModel> _parseSiteList(dynamic data) {
    if (data is List) {
      return data
          .map((json) => SiteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List) {
        return items
            .map((json) => SiteModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  @override
  Future<List<SiteModel>> fetchSites() async {
    final response = await _dioClient.get(ApiConstants.sites);
    return _parseSiteList(response.data['data']);
  }

  @override
  Future<Map<String, dynamic>> fetchSiteDetail(String siteId) async {
    final response = await _dioClient.get(ApiConstants.siteDetail(siteId));
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<List<BuildingModel>> fetchSiteBuildings(String siteId) async {
    final response =
        await _dioClient.get(ApiConstants.siteBuildings(siteId));
    final data = response.data['data'];
    if (data is List) {
      return data
          .map((json) => BuildingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
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
      'name': name,
      'address': address,
      'city': city,
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
      'name': ?name,
      'address': ?address,
      'city': ?city,
      'dueAmount': ?dueAmount,
      'dueDay': ?dueDay,
      'currency': ?currency,
    };
    final response =
        await _dioClient.put(ApiConstants.siteDetail(id), data: body);
    return SiteModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<SiteModel> patchSiteCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    String? collectionIbanLabel,
    bool updateIbanLabel = false,
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
    if (updateIbanLabel) {
      body['collectionIbanLabel'] =
          (collectionIbanLabel?.trim().isEmpty ?? true)
              ? null
              : collectionIbanLabel!.trim();
    }
    final response = await _dioClient.patch(
      ApiConstants.siteCollection(id),
      data: body,
    );
    return SiteModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSite(String id) async {
    await _dioClient.delete(ApiConstants.siteDetail(id));
  }

  @override
  Future<BuildingModel> createSiteBuilding({
    required String siteId,
    required String blockLabel,
    String? name,
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
      'blockLabel': blockLabel,
      'name': ?name,
      'addressExtra': ?addressExtra,
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

    final response = await _dioClient.post(
      ApiConstants.siteBuildings(siteId),
      data: body,
    );
    return BuildingModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
