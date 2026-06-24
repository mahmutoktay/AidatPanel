import '../../domain/entities/building_entity.dart';

/// Belge §2.3: Prisma `Building` alanları.
/// `dueAmount` Decimal olduğu için JSON'da string gelir (örn. "600.00")
/// — güvenli parse için `_toDouble` kullanılır.
class BuildingModel {
  final String id;
  final String name;
  final String address;
  final String? city;
  final int? totalFloors;
  final int? apartmentsPerFloor;
  final String managerId;
  final double? dueAmount;
  final int? dueDay;
  final String? currency;

  /// `GET /buildings` yanıtında Prisma `_count.apartments` (§2.3).
  /// Yoksa (ör. `POST /buildings` yanıtı) `toEntity` kat × daire tahminini kullanır.
  final int? apartmentCountFromApi;
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;
  final bool? isCollectionConfiguredFromApi;
  final int? occupiedApartmentsFromApi;
  final String? siteId;
  final String? blockLabel;
  final String? addressExtra;
  final double? effectiveDueAmount;
  final int? effectiveDueDay;
  final String? effectiveCurrency;
  final String? effectiveCollectionIban;
  final String? effectiveCollectionAccountTitle;
  final String? effectivePaymentReferenceTemplate;
  final String? effectiveAddress;
  final String? effectiveCity;
  final String? displayNameFromApi;
  final String? siteName;

  BuildingModel({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.totalFloors,
    this.apartmentsPerFloor,
    required this.managerId,
    this.dueAmount,
    this.dueDay,
    this.currency,
    this.apartmentCountFromApi,
    this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
    this.isCollectionConfiguredFromApi,
    this.occupiedApartmentsFromApi,
    this.siteId,
    this.blockLabel,
    this.addressExtra,
    this.effectiveDueAmount,
    this.effectiveDueDay,
    this.effectiveCurrency,
    this.effectiveCollectionIban,
    this.effectiveCollectionAccountTitle,
    this.effectivePaymentReferenceTemplate,
    this.effectiveAddress,
    this.effectiveCity,
    this.displayNameFromApi,
    this.siteName,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    int? apartmentCountFromApi;
    final rawCount = json['_count'];
    if (rawCount is Map<String, dynamic>) {
      final n = rawCount['apartments'];
      if (n is int) apartmentCountFromApi = n;
    }
    return BuildingModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      totalFloors: json['totalFloors'] as int?,
      apartmentsPerFloor: json['apartmentsPerFloor'] as int?,
      managerId: json['managerId'] as String,
      dueAmount: _toDouble(json['dueAmount']),
      dueDay: json['dueDay'] as int?,
      currency: json['currency'] as String?,
      apartmentCountFromApi: apartmentCountFromApi,
      collectionIban: json['collectionIban'] as String?,
      collectionAccountTitle: json['collectionAccountTitle'] as String?,
      paymentReferenceTemplate: json['paymentReferenceTemplate'] as String?,
      isCollectionConfiguredFromApi: json['isCollectionConfigured'] as bool?,
      occupiedApartmentsFromApi: json['occupiedApartments'] as int?,
      siteId: json['siteId'] as String?,
      blockLabel: json['blockLabel'] as String?,
      addressExtra: json['addressExtra'] as String?,
      effectiveDueAmount: _toDouble(json['effectiveDueAmount']),
      effectiveDueDay: (json['effectiveDueDay'] as num?)?.toInt(),
      effectiveCurrency: json['effectiveCurrency'] as String?,
      effectiveCollectionIban: json['effectiveCollectionIban'] as String?,
      effectiveCollectionAccountTitle:
          json['effectiveCollectionAccountTitle'] as String?,
      effectivePaymentReferenceTemplate:
          json['effectivePaymentReferenceTemplate'] as String?,
      effectiveAddress: json['effectiveAddress'] as String?,
      effectiveCity: json['effectiveCity'] as String?,
      displayNameFromApi: json['displayName'] as String?,
      siteName: json['siteName'] as String?,
    );
  }

  BuildingEntity toEntity() {
    final total = apartmentCountFromApi ??
        ((totalFloors ?? 0) * (apartmentsPerFloor ?? 0));
    final resolvedDue = effectiveDueAmount ?? dueAmount;
    final monthly = (resolvedDue ?? 0) * total;
    final resolvedName = displayNameFromApi?.trim().isNotEmpty == true
        ? displayNameFromApi!.trim()
        : name;
    return BuildingEntity(
      id: id,
      name: resolvedName,
      address: effectiveAddress ?? address,
      city: effectiveCity ?? city ?? '',
      totalApartments: total,
      occupiedApartments: occupiedApartmentsFromApi ?? 0,
      totalMonthlyDues: monthly,
      collectedDues: 0.0,
      dueAmount: dueAmount,
      dueDay: dueDay,
      currency: currency ?? 'TRY',
      collectionIban: collectionIban,
      collectionAccountTitle: collectionAccountTitle,
      paymentReferenceTemplate: paymentReferenceTemplate,
      siteId: siteId,
      blockLabel: blockLabel,
      addressExtra: addressExtra,
      effectiveDueAmount: effectiveDueAmount,
      effectiveDueDay: effectiveDueDay,
      effectiveCurrency: effectiveCurrency,
      effectiveCollectionIban: effectiveCollectionIban,
      effectiveCollectionAccountTitle: effectiveCollectionAccountTitle,
      effectivePaymentReferenceTemplate: effectivePaymentReferenceTemplate,
      effectiveAddress: effectiveAddress,
      effectiveCity: effectiveCity,
      siteName: siteName,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
