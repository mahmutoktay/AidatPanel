import 'package:equatable/equatable.dart';

import '../../../../core/utils/iban_utils.dart';

class BuildingEntity extends Equatable {
  final String id;
  final String name;
  final String address;

  /// Şehir; backend'de ayrı bir alan (Belge §2.3). UI'da `displayAddress`
  /// üzerinden adresle birleşik gösterilir, böylece düzenleme ekranı
  /// `address` ve `city`'yi ayrı tutabilir.
  final String city;

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

  /// Tahsilat IBAN (TR + 24 rakam, boşluksuz saklanır).
  final String? collectionIban;

  /// Hesap sahibi / alıcı unvanı.
  final String? collectionAccountTitle;

  /// Havale açıklama şablonu; `{{number}}` → daire no.
  final String? paymentReferenceTemplate;

  /// Site altı bina ise dolu; tekil binalarda null.
  final String? siteId;
  final String? blockLabel;
  final String? addressExtra;
  final String? siteName;

  const BuildingEntity({
    required this.id,
    required this.name,
    required this.address,
    this.city = '',
    required this.totalApartments,
    required this.occupiedApartments,
    required this.totalMonthlyDues,
    required this.collectedDues,
    this.dueAmount,
    this.dueDay,
    this.currency = 'TRY',
    this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
    this.siteId,
    this.blockLabel,
    this.addressExtra,
    this.siteName,
  });

  bool get isStandalone => siteId == null || siteId!.isEmpty;

  /// Geçerli TR IBAN tanımlı mı (`^TR\d{24}$`).
  bool get isCollectionConfigured => IbanUtils.isValidTrIban(collectionIban);

  /// Liste/kart görünümünde gösterilecek tam adres ("Adres, Şehir").
  String get displayAddress =>
      city.trim().isEmpty ? address : '$address, $city';

  double get collectionRate {
    if (totalMonthlyDues == 0) return 0;
    return (collectedDues / totalMonthlyDues) * 100;
  }

  BuildingEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    int? totalApartments,
    int? occupiedApartments,
    double? totalMonthlyDues,
    double? collectedDues,
    double? dueAmount,
    int? dueDay,
    String? currency,
    String? collectionIban,
    String? collectionAccountTitle,
    String? paymentReferenceTemplate,
    String? siteId,
    String? blockLabel,
    String? addressExtra,
    String? siteName,
  }) {
    return BuildingEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      totalApartments: totalApartments ?? this.totalApartments,
      occupiedApartments: occupiedApartments ?? this.occupiedApartments,
      totalMonthlyDues: totalMonthlyDues ?? this.totalMonthlyDues,
      collectedDues: collectedDues ?? this.collectedDues,
      dueAmount: dueAmount ?? this.dueAmount,
      dueDay: dueDay ?? this.dueDay,
      currency: currency ?? this.currency,
      collectionIban: collectionIban ?? this.collectionIban,
      collectionAccountTitle:
          collectionAccountTitle ?? this.collectionAccountTitle,
      paymentReferenceTemplate:
          paymentReferenceTemplate ?? this.paymentReferenceTemplate,
      siteId: siteId ?? this.siteId,
      blockLabel: blockLabel ?? this.blockLabel,
      addressExtra: addressExtra ?? this.addressExtra,
      siteName: siteName ?? this.siteName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        totalApartments,
        occupiedApartments,
        totalMonthlyDues,
        collectedDues,
        dueAmount,
        dueDay,
        currency,
        collectionIban,
        collectionAccountTitle,
        paymentReferenceTemplate,
        siteId,
        blockLabel,
        addressExtra,
        siteName,
      ];
}
