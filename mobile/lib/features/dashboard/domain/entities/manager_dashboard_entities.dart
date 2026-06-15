import 'package:equatable/equatable.dart';

/// Aidat tahsilat donut grafiği için özet (daire bazlı).
class ManagerDuesCollectionStats extends Equatable {
  final int paidCount;
  final int overdueCount;
  final int pendingCount;

  const ManagerDuesCollectionStats({
    required this.paidCount,
    required this.overdueCount,
    required this.pendingCount,
  });

  int get total => paidCount + overdueCount + pendingCount;

  double get collectionRatePercent =>
      total == 0 ? 0 : (paidCount / total) * 100;

  static const empty = ManagerDuesCollectionStats(
    paidCount: 0,
    overdueCount: 0,
    pendingCount: 0,
  );

  @override
  List<Object?> get props => [paidCount, overdueCount, pendingCount];
}

/// Son 6 ay gelir/gider bar grafiği noktası.
class ManagerMonthlyFinancePoint extends Equatable {
  final int month;
  final int year;
  final String monthLabel;
  final double collectedDues;
  final double totalExpenses;
  final String currency;

  const ManagerMonthlyFinancePoint({
    required this.month,
    required this.year,
    required this.monthLabel,
    required this.collectedDues,
    required this.totalExpenses,
    this.currency = 'TRY',
  });

  @override
  List<Object?> get props => [
        month,
        year,
        monthLabel,
        collectedDues,
        totalExpenses,
        currency,
      ];
}

/// Arıza talepleri durum özeti.
class ManagerTicketStatusStats extends Equatable {
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;

  const ManagerTicketStatusStats({
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
  });

  int get total => openCount + inProgressCount + resolvedCount;

  static const empty = ManagerTicketStatusStats(
    openCount: 0,
    inProgressCount: 0,
    resolvedCount: 0,
  );

  @override
  List<Object?> get props => [openCount, inProgressCount, resolvedCount];
}

/// Geciken ödeme listesi satırı.
class ManagerOverdueApartmentItem extends Equatable {
  final String dueId;
  final String buildingId;
  final String residentName;
  final String apartmentNumber;
  final int? floor;
  final int overdueDays;
  final double amount;
  final String currency;
  final String? buildingName;

  const ManagerOverdueApartmentItem({
    required this.dueId,
    required this.buildingId,
    required this.residentName,
    required this.apartmentNumber,
    this.floor,
    required this.overdueDays,
    required this.amount,
    this.currency = 'TRY',
    this.buildingName,
  });

  @override
  List<Object?> get props => [
        dueId,
        buildingId,
        residentName,
        apartmentNumber,
        floor,
        overdueDays,
        amount,
        currency,
        buildingName,
      ];
}

/// Üst özet kartları (3×2 grid).
class ManagerDashboardSummaryStats extends Equatable {
  final int totalApartments;
  final double collectionRatePercent;
  final int overduePaymentCount;
  final int openTicketCount;
  final double monthTotalExpense;
  final String expenseCurrency;
  final int pendingDekontCount;

  const ManagerDashboardSummaryStats({
    required this.totalApartments,
    required this.collectionRatePercent,
    required this.overduePaymentCount,
    required this.openTicketCount,
    required this.monthTotalExpense,
    this.expenseCurrency = 'TRY',
    required this.pendingDekontCount,
  });

  static const empty = ManagerDashboardSummaryStats(
    totalApartments: 0,
    collectionRatePercent: 0,
    overduePaymentCount: 0,
    openTicketCount: 0,
    monthTotalExpense: 0,
    pendingDekontCount: 0,
  );

  @override
  List<Object?> get props => [
        totalApartments,
        collectionRatePercent,
        overduePaymentCount,
        openTicketCount,
        monthTotalExpense,
        expenseCurrency,
        pendingDekontCount,
      ];
}
