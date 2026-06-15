import '../../domain/entities/building_entity.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../utils/building_collection_status.dart';

/// Bina listesi kartında gösterilen özet veri modeli.
class BuildingListItemModel {
  final String id;
  final String name;
  final String address;
  final int unitCount;
  final int paidUnitCount;
  final int pendingCount;
  final int overdueCount;
  final double collectionRate;
  final double monthlyDues;
  final double? perUnitDues;

  const BuildingListItemModel({
    required this.id,
    required this.name,
    required this.address,
    required this.unitCount,
    required this.paidUnitCount,
    required this.pendingCount,
    required this.overdueCount,
    required this.collectionRate,
    required this.monthlyDues,
    this.perUnitDues,
  });

  factory BuildingListItemModel.fromEntity({
    required BuildingEntity building,
    required Map<String, List<DueEntity>> allDues,
  }) {
    final dues = allDues[building.id] ?? const <DueEntity>[];
    
    // Filter dues for the current month and year to avoid historical aggregation mismatch
    final now = DateTime.now();
    List<DueEntity> targetDues = dues.where((d) => d.month == now.month && d.year == now.year).toList();
    
    // Fallback to the latest month's dues if the current month's dues haven't been generated yet
    if (targetDues.isEmpty && dues.isNotEmpty) {
      final maxYear = dues.map((d) => d.year).reduce((a, b) => a > b ? a : b);
      final maxMonth = dues.where((d) => d.year == maxYear).map((d) => d.month).reduce((a, b) => a > b ? a : b);
      targetDues = dues.where((d) => d.year == maxYear && d.month == maxMonth).toList();
    }

    final paid = targetDues.where((d) => d.status == DueStatus.paid).length;
    final pending = targetDues.where((d) => d.status == DueStatus.pending).length;
    final overdue = targetDues.where((d) => d.status == DueStatus.overdue).length;
    final rate = targetDues.isEmpty ? 0.0 : (paid / targetDues.length) * 100;
    
    final unitCount =
        building.totalApartments > 0 ? building.totalApartments : targetDues.length;

    return BuildingListItemModel(
      id: building.id,
      name: building.name,
      address: building.displayAddress,
      unitCount: unitCount,
      paidUnitCount: paid,
      pendingCount: pending,
      overdueCount: overdue,
      collectionRate: rate,
      monthlyDues: building.totalMonthlyDues,
      perUnitDues: building.dueAmount ??
          (unitCount > 0 ? building.totalMonthlyDues / unitCount : null),
    );
  }

  /// Tasarım önizlemesi / widget testleri için örnek veriler.
  static const List<BuildingListItemModel> samples = [
    BuildingListItemModel(
      id: 'sample-critical',
      name: 'Cepe',
      address: 'Çaylı Mah, Dörtyol / Hatay',
      unitCount: 10,
      paidUnitCount: 0,
      pendingCount: 0,
      overdueCount: 10,
      collectionRate: 0,
      monthlyDues: 30000,
      perUnitDues: 3000,
    ),
    BuildingListItemModel(
      id: 'sample-warning',
      name: 'Lale Sitesi',
      address: 'Merkez Mah, Antakya / Hatay',
      unitCount: 12,
      paidUnitCount: 7,
      pendingCount: 3,
      overdueCount: 2,
      collectionRate: 58,
      monthlyDues: 36000,
      perUnitDues: 3000,
    ),
    BuildingListItemModel(
      id: 'sample-healthy',
      name: 'Güneş Apartmanı',
      address: 'Atatürk Cad, İskenderun / Hatay',
      unitCount: 6,
      paidUnitCount: 6,
      pendingCount: 0,
      overdueCount: 0,
      collectionRate: 100,
      monthlyDues: 18000,
      perUnitDues: 3000,
    ),
  ];
}

List<BuildingListItemModel> sortBuildingListItems(
  List<BuildingListItemModel> items,
  BuildingListSort sort,
) {
  final sorted = List<BuildingListItemModel>.from(items);
  switch (sort) {
    case BuildingListSort.byOverdue:
      sorted.sort((a, b) {
        final overdueCompare = b.overdueCount.compareTo(a.overdueCount);
        if (overdueCompare != 0) return overdueCompare;
        return a.collectionRate.compareTo(b.collectionRate);
      });
    case BuildingListSort.byCollectionRate:
      sorted.sort((a, b) {
        final rateCompare = b.collectionRate.compareTo(a.collectionRate);
        if (rateCompare != 0) return rateCompare;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    case BuildingListSort.byName:
      sorted.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
  }
  return sorted;
}

/// Özet şerit toplamları.
class BuildingsSummaryTotals {
  final int buildingCount;
  final int unitCount;
  final int overdueCount;
  final double collectionRate;

  const BuildingsSummaryTotals({
    required this.buildingCount,
    required this.unitCount,
    required this.overdueCount,
    required this.collectionRate,
  });

  factory BuildingsSummaryTotals.fromItems(List<BuildingListItemModel> items) {
    if (items.isEmpty) {
      return const BuildingsSummaryTotals(
        buildingCount: 0,
        unitCount: 0,
        overdueCount: 0,
        collectionRate: 0,
      );
    }
    final totalUnits = items.fold<int>(0, (sum, item) => sum + item.unitCount);
    final totalPaid =
        items.fold<int>(0, (sum, item) => sum + item.paidUnitCount);
    final totalOverdue =
        items.fold<int>(0, (sum, item) => sum + item.overdueCount);

    return BuildingsSummaryTotals(
      buildingCount: items.length,
      unitCount: totalUnits,
      overdueCount: totalOverdue,
      collectionRate: totalUnits == 0 ? 0 : (totalPaid / totalUnits) * 100,
    );
  }
}
