import '../../../../core/utils/app_date_format.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../tickets/domain/entities/ticket_entity.dart';
import '../../domain/entities/manager_dashboard_entities.dart';

/// Gerçek domain verisinden dashboard modellerine dönüşüm.
abstract final class ManagerDashboardMapper {
  static List<DueEntity> filterDues(
    Map<String, List<DueEntity>> allDues,
    String? buildingId,
  ) {
    if (buildingId == null) {
      return allDues.values.expand((list) => list).toList(growable: false);
    }
    return List<DueEntity>.from(allDues[buildingId] ?? const []);
  }

  static List<BuildingEntity> filterBuildings(
    List<BuildingEntity> buildings,
    String? buildingId,
  ) {
    if (buildingId == null) return buildings;
    return buildings.where((b) => b.id == buildingId).toList(growable: false);
  }

  /// Site / bina / tümü kapsamına göre bina listesi.
  static List<BuildingEntity> filterBuildingsByScope(
    List<BuildingEntity> buildings, {
    String? siteId,
    String? buildingId,
  }) {
    if (buildingId != null) {
      return buildings.where((b) => b.id == buildingId).toList(growable: false);
    }
    if (siteId != null) {
      return buildings
          .where((b) => b.siteId == siteId)
          .toList(growable: false);
    }
    return buildings;
  }

  static List<DueEntity> filterDuesByScope(
    Map<String, List<DueEntity>> allDues,
    List<BuildingEntity> scopedBuildings,
  ) {
    final ids = scopedBuildings.map((b) => b.id).toSet();
    return allDues.entries
        .where((entry) => ids.contains(entry.key))
        .expand((entry) => entry.value)
        .toList(growable: false);
  }

  static Set<String> buildingIdsForScope(
    List<BuildingEntity> buildings, {
    String? siteId,
    String? buildingId,
  }) {
    return filterBuildingsByScope(
      buildings,
      siteId: siteId,
      buildingId: buildingId,
    ).map((b) => b.id).toSet();
  }

  /// Donut ve özet kartları için seçili ay/yıl aidatları.
  static List<DueEntity> filterDuesForMonth(
    List<DueEntity> dues, {
    required int month,
    required int year,
  }) =>
      dues
          .where((d) => d.month == month && d.year == year)
          .toList(growable: false);

  static ManagerDuesCollectionStats duesCollectionStats(List<DueEntity> dues) {
    final occupiedDues =
        dues.where((d) => d.resident != null).toList(growable: false);
    if (occupiedDues.isEmpty) return ManagerDuesCollectionStats.empty;

    final paid =
        occupiedDues.where((d) => d.status == DueStatus.paid).length;
    final overdue =
        occupiedDues.where((d) => d.status == DueStatus.overdue).length;
    final pending =
        occupiedDues.where((d) => d.status == DueStatus.pending).length;

    return ManagerDuesCollectionStats(
      paidCount: paid,
      overdueCount: overdue,
      pendingCount: pending,
    );
  }

  static double collectionRate(List<DueEntity> dues) {
    final occupiedDues =
        dues.where((d) => d.resident != null).toList(growable: false);
    if (occupiedDues.isEmpty) return 0;
    final paid =
        occupiedDues.where((d) => d.status == DueStatus.paid).length;
    return (paid / occupiedDues.length) * 100;
  }

  static int overdueCount(List<DueEntity> dues) {
    return dues
        .where((d) => d.status == DueStatus.overdue && d.resident != null)
        .length;
  }

  static List<ManagerOverdueApartmentItem> overdueApartments(
    List<DueEntity> dues, {
    required String buildingId,
    String? singleBuildingName,
  }) {
    final overdue = dues
        .where((d) => d.status == DueStatus.overdue && d.resident != null)
        .toList(growable: false)
      ..sort((a, b) => b.overdueDays.compareTo(a.overdueDays));

    return overdue
        .map(
          (due) => ManagerOverdueApartmentItem(
            dueId: due.id,
            buildingId: buildingId,
            residentName: due.resident!.name,
            apartmentNumber: due.apartmentNumber,
            floor: due.apartmentFloor ?? _parseFloor(due.apartmentNumber),
            overdueDays: due.overdueDays,
            amount: due.hasRemainingBalance
                ? due.remainingAmount
                : due.amount,
            currency: due.currency,
            buildingName: singleBuildingName,
          ),
        )
        .toList(growable: false);
  }

  /// Bina haritasından gecikmiş aidat satırları; tüm binalar seçiliyken satırda bina adı gösterilir.
  /// [month]/[year] verilirse yalnızca o ayın gecikmişleri (özet kart / Aidatlar ile aynı SoT).
  static List<ManagerOverdueApartmentItem> overdueApartmentsFromMap(
    Map<String, List<DueEntity>> allDues,
    Map<String, String> buildingNamesById, {
    String? buildingId,
    Set<String>? buildingIds,
    int? month,
    int? year,
  }) {
    final filterByMonth = month != null && year != null;
    final items = <ManagerOverdueApartmentItem>[];
    for (final entry in allDues.entries) {
      if (buildingId != null && entry.key != buildingId) continue;
      if (buildingIds != null && !buildingIds.contains(entry.key)) continue;
      final buildingName =
          buildingId == null ? buildingNamesById[entry.key] : null;
      final dues = filterByMonth
          ? filterDuesForMonth(entry.value, month: month, year: year)
          : entry.value;
      items.addAll(
        overdueApartments(
          dues,
          buildingId: entry.key,
          singleBuildingName: buildingName,
        ),
      );
    }
    items.sort((a, b) => b.overdueDays.compareTo(a.overdueDays));
    return items;
  }

  static ManagerTicketStatusStats ticketStatusStats(List<TicketEntity> tickets) {
    if (tickets.isEmpty) return ManagerTicketStatusStats.empty;

    return ManagerTicketStatusStats(
      openCount: tickets.where((t) => t.status == TicketStatus.open).length,
      inProgressCount:
          tickets.where((t) => t.status == TicketStatus.inProgress).length,
      resolvedCount:
          tickets.where((t) => t.status == TicketStatus.resolved).length,
    );
  }

  static List<ManagerMonthlyFinancePoint> monthlyFinancePoints({
    required List<DueEntity> dues,
    required Map<(int month, int year), double> expenseTotalsByMonth,
    required DateTime anchor,
    required String localeName,
  }) {
    final points = <ManagerMonthlyFinancePoint>[];

    for (var i = 5; i >= 0; i--) {
      final date = DateTime(anchor.year, anchor.month - i, 1);
      final month = date.month;
      final year = date.year;

      final collected = dues
          .where(
            (d) =>
                d.month == month &&
                d.year == year &&
                d.resident != null,
          )
          .fold<double>(0, (sum, d) {
            final paid = d.status == DueStatus.paid && d.paidAmount <= 0.01
                ? d.amount
                : d.paidAmount;
            return sum + paid;
          });

      final expenses = expenseTotalsByMonth[(month, year)] ?? 0;

      points.add(
        ManagerMonthlyFinancePoint(
          month: month,
          year: year,
          monthLabel: _capitalize(
            AppDateFormat.monthShort(date, languageCode: localeName),
          ),
          collectedDues: collected,
          totalExpenses: expenses,
        ),
      );
    }

    return points;
  }

  static ManagerDuesAmountSummary duesAmountSummary(List<DueEntity> dues) {
    final occupiedDues =
        dues.where((d) => d.resident != null).toList(growable: false);
    if (occupiedDues.isEmpty) return ManagerDuesAmountSummary.empty;

    var expected = 0.0;
    var collected = 0.0;
    var overdueCount = 0;

    for (final due in occupiedDues) {
      expected += due.amount;
      // PAID ama payment kaydı yoksa (eski veri / seed) tutarın tamamını tahsil say.
      final paid = due.status == DueStatus.paid && due.paidAmount <= 0.01
          ? due.amount
          : due.paidAmount;
      collected += paid;
      if (due.status == DueStatus.overdue && due.hasRemainingBalance) {
        overdueCount++;
      }
    }

    return ManagerDuesAmountSummary(
      collectedAmount: collected,
      expectedAmount: expected,
      overdueCount: overdueCount,
    );
  }

  static ManagerDashboardSummaryStats summaryStats({
    required List<BuildingEntity> buildings,
    required List<DueEntity> dues,
    required int openTicketCount,
    required double monthTotalExpense,
    required String expenseCurrency,
    required int pendingDekontCount,
  }) {
    var totalApartments = 0;
    for (final b in buildings) {
      totalApartments += b.totalApartments;
    }

    return ManagerDashboardSummaryStats(
      totalApartments: totalApartments,
      collectionRatePercent: collectionRate(dues),
      overduePaymentCount: overdueCount(dues),
      openTicketCount: openTicketCount,
      monthTotalExpense: monthTotalExpense,
      expenseCurrency: expenseCurrency,
      pendingDekontCount: pendingDekontCount,
    );
  }

  static int? _parseFloor(String apartmentNumber) {
    final match = RegExp(r'^(\d+)').firstMatch(apartmentNumber.trim());
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
