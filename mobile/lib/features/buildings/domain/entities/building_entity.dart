import 'package:equatable/equatable.dart';

class BuildingEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final int totalApartments;
  final int occupiedApartments;
  final double totalMonthlyDues;
  final double collectedDues;

  /// Backend'in bina bazlı sabit aylık aidat bedeli (Belge §2.3 / §5).
  /// Bina kurulurken `dueAmount` verilmediyse null olabilir.
  final double? dueAmount;

  /// Aidat günü (1-28).
  final int? dueDay;

  /// 3 harf para birimi (`TRY`, `USD` vb.). Default: `TRY`.
  final String currency;

  const BuildingEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.totalApartments,
    required this.occupiedApartments,
    required this.totalMonthlyDues,
    required this.collectedDues,
    this.dueAmount,
    this.dueDay,
    this.currency = 'TRY',
  });

  double get collectionRate {
    if (totalMonthlyDues == 0) return 0;
    return (collectedDues / totalMonthlyDues) * 100;
  }

  BuildingEntity copyWith({
    String? id,
    String? name,
    String? address,
    int? totalApartments,
    int? occupiedApartments,
    double? totalMonthlyDues,
    double? collectedDues,
    double? dueAmount,
    int? dueDay,
    String? currency,
  }) {
    return BuildingEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      totalApartments: totalApartments ?? this.totalApartments,
      occupiedApartments: occupiedApartments ?? this.occupiedApartments,
      totalMonthlyDues: totalMonthlyDues ?? this.totalMonthlyDues,
      collectedDues: collectedDues ?? this.collectedDues,
      dueAmount: dueAmount ?? this.dueAmount,
      dueDay: dueDay ?? this.dueDay,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        totalApartments,
        occupiedApartments,
        totalMonthlyDues,
        collectedDues,
        dueAmount,
        dueDay,
        currency,
      ];
}
