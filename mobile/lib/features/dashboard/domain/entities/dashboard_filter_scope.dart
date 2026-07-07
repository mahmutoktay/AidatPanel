import 'package:equatable/equatable.dart';

/// Yönetici paneli bina/site seçim kapsamı.
class DashboardFilterScope extends Equatable {
  final String? siteId;
  final String? buildingId;

  const DashboardFilterScope({
    this.siteId,
    this.buildingId,
  });

  const DashboardFilterScope.all() : siteId = null, buildingId = null;

  const DashboardFilterScope.site(this.siteId) : buildingId = null;

  const DashboardFilterScope.building(this.buildingId) : siteId = null;

  bool get isAll => siteId == null && buildingId == null;

  bool get isSite => siteId != null && buildingId == null;

  bool get isBuilding => buildingId != null;

  @override
  List<Object?> get props => [siteId, buildingId];
}
