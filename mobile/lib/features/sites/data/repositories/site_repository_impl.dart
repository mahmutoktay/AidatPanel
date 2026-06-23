import '../../../../core/network/api_exception.dart';
import '../../domain/entities/site_entity.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../datasources/site_remote_datasource.dart';
import 'site_repository.dart';

class SiteRepositoryImpl implements SiteRepository {
  SiteRepositoryImpl({required SiteRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final SiteRemoteDataSource _remoteDataSource;

  @override
  Future<List<SiteEntity>> fetchSites() async {
    try {
      final models = await _remoteDataSource.fetchSites();
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Siteler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<SiteEntity> fetchSiteById(String id) async {
    try {
      return (await _remoteDataSource.fetchSiteById(id)).toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site detayı yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<SiteEntity> createSite({
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
    try {
      return (await _remoteDataSource.createSite(
        name: name,
        address: address,
        city: city,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      ))
          .toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site oluşturulurken hata oluştu: $e');
    }
  }

  @override
  Future<SiteEntity> updateSite({
    required String id,
    String? name,
    String? address,
    String? city,
    double? dueAmount,
    int? dueDay,
    String? currency,
  }) async {
    try {
      return (await _remoteDataSource.updateSite(
        id: id,
        name: name,
        address: address,
        city: city,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
      ))
          .toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site güncellenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteSite(String id) async {
    try {
      await _remoteDataSource.deleteSite(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Site silinirken hata oluştu: $e');
    }
  }

  @override
  Future<BuildingEntity> createSiteBuilding({
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
    try {
      return (await _remoteDataSource.createSiteBuilding(
        siteId: siteId,
        name: name,
        address: address,
        city: city,
        blockLabel: blockLabel,
        addressExtra: addressExtra,
        totalFloors: totalFloors,
        apartmentsPerFloor: apartmentsPerFloor,
        dueAmount: dueAmount,
        dueDay: dueDay,
        currency: currency,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        paymentReferenceTemplate: paymentReferenceTemplate,
      ))
          .toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Blok oluşturulurken hata oluştu: $e');
    }
  }
}
