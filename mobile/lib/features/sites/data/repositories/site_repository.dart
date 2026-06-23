import '../../domain/entities/site_entity.dart';
import '../../../buildings/domain/entities/building_entity.dart';

abstract class SiteRepository {
  Future<List<SiteEntity>> fetchSites();
  Future<SiteEntity> fetchSiteById(String id);
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
  });
  Future<SiteEntity> updateSite({
    required String id,
    String? name,
    String? address,
    String? city,
    double? dueAmount,
    int? dueDay,
    String? currency,
  });
  Future<void> deleteSite(String id);
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
  });
}
