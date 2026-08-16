/// main_dev showcase seed — Play Store / canlı demo ile aynı dilde gerçekçi veri.
/// UI string değil; yalnızca in-memory repository seed’i.
library;

import '../features/apartments/domain/entities/apartment_entity.dart';
import '../features/apartments/domain/entities/resident_info.dart';
import '../features/buildings/domain/entities/building_entity.dart';
import '../features/dues/domain/entities/due_entity.dart';
import '../features/dues/domain/entities/due_transaction_entity.dart';
import '../features/sites/domain/entities/site_entity.dart';
import '../features/sites/domain/entities/site_expense_entity.dart';
import '../features/expenses/domain/entities/expense_entity.dart';

abstract final class DevShowcaseIds {
  static const siteBahceli = 'site_bahceli';
  static const vefa = 'b_vefa';
  static const lale = 'b_lale';
  static const blockA = 'b_a';
  static const blockB = 'b_b';
  static const blockC = 'b_c';
}

class _ResidentSeed {
  const _ResidentSeed(this.id, this.name, this.phone);
  final String id;
  final String name;
  final String phone;
}

class _AptSeed {
  const _AptSeed({
    required this.id,
    required this.number,
    required this.floor,
    this.resident,
  });
  final String id;
  final String number;
  final int floor;
  final _ResidentSeed? resident;
}

List<_AptSeed> _layout({
  required String buildingKey,
  required int floors,
  required int perFloor,
  required List<_ResidentSeed?> residents,
}) {
  final apts = <_AptSeed>[];
  var unit = 1;
  var ri = 0;
  for (var f = 1; f <= floors; f++) {
    for (var u = 0; u < perFloor; u++) {
      apts.add(
        _AptSeed(
          id: '${buildingKey}_a$unit',
          number: '$unit',
          floor: f,
          resident: ri < residents.length ? residents[ri] : null,
        ),
      );
      unit++;
      ri++;
    }
  }
  return apts;
}

final Map<String, List<_AptSeed>> _aptSeeds = {
  DevShowcaseIds.vefa: _layout(
    buildingKey: 'vefa',
    floors: 4,
    perFloor: 2,
    residents: const [
      _ResidentSeed('r_vefa_1', 'Ayşe Demir', '5550101002'),
      _ResidentSeed('r_vefa_2', 'Mehmet Yılmaz', '5550101003'),
      _ResidentSeed('r_vefa_3', 'Zeynep Kaya', '5550101004'),
      _ResidentSeed('r_vefa_4', 'Ali Çelik', '5550101005'),
      _ResidentSeed('r_vefa_5', 'Fatma Arslan', '5550101006'),
      _ResidentSeed('r_vefa_6', 'Emre Şahin', '5550101007'),
      null,
      null,
    ],
  ),
  DevShowcaseIds.lale: _layout(
    buildingKey: 'lale',
    floors: 5,
    perFloor: 2,
    residents: const [
      _ResidentSeed('r_lale_1', 'Seda Koç', '5550303001'),
      _ResidentSeed('r_lale_2', 'Onur Akar', '5550303002'),
      _ResidentSeed('r_lale_3', 'Pınar Er', '5550303003'),
      _ResidentSeed('r_lale_4', 'Rıza Demirtaş', '5550303004'),
      _ResidentSeed('r_lale_5', 'Sibel Öztürk', '5550303005'),
      _ResidentSeed('r_lale_6', 'Tolga Yavuz', '5550303006'),
      _ResidentSeed('r_lale_7', 'Hande Polat', '5550303007'),
      _ResidentSeed('r_lale_8', 'Cem Aydın', '5550303008'),
      _ResidentSeed('r_lale_9', 'Ece Yılmaz', '5550303009'),
      _ResidentSeed('r_lale_10', 'Barış Tekin', '5550303010'),
    ],
  ),
  DevShowcaseIds.blockA: _layout(
    buildingKey: 'ba',
    floors: 4,
    perFloor: 2,
    residents: const [
      _ResidentSeed('r_ba_1', 'Elif Aksoy', '5550202001'),
      _ResidentSeed('r_ba_2', 'Burak Özkan', '5550202002'),
      _ResidentSeed('r_ba_3', 'Selin Aydın', '5550202003'),
      _ResidentSeed('r_ba_4', 'Can Yıldız', '5550202004'),
      _ResidentSeed('r_ba_5', 'Deniz Kara', '5550202005'),
      _ResidentSeed('r_ba_6', 'Gülşen Mutlu', '5550202006'),
      null,
      null,
    ],
  ),
  DevShowcaseIds.blockB: _layout(
    buildingKey: 'bb',
    floors: 4,
    perFloor: 2,
    residents: const [
      _ResidentSeed('r_bb_1', 'Hakan Erdem', '5550202007'),
      _ResidentSeed('r_bb_2', 'İrem Taş', '5550202008'),
      _ResidentSeed('r_bb_3', 'Kemal Uçar', '5550202009'),
      _ResidentSeed('r_bb_4', 'Leyla Bilgin', '5550202010'),
      null,
      null,
      null,
      null,
    ],
  ),
  DevShowcaseIds.blockC: _layout(
    buildingKey: 'bc',
    floors: 3,
    perFloor: 2,
    residents: const [
      _ResidentSeed('r_bc_1', 'Murat Sezer', '5550202011'),
      _ResidentSeed('r_bc_2', 'Nazan Güler', '5550202012'),
      _ResidentSeed('r_bc_3', 'Okan Demir', '5550202013'),
      _ResidentSeed('r_bc_4', 'Pelin Koç', '5550202014'),
      null,
      null,
    ],
  ),
};

ResidentInfo? _toResident(_ResidentSeed? r) {
  if (r == null) return null;
  return ResidentInfo(
    id: r.id,
    name: r.name,
    phone: r.phone,
    email: '${r.id}@aidatpanel.dev',
    role: 'RESIDENT',
  );
}

Map<String, List<ApartmentEntity>> buildShowcaseApartments() {
  return {
    for (final entry in _aptSeeds.entries)
      entry.key: [
        for (final a in entry.value)
          ApartmentEntity(
            id: a.id,
            buildingId: entry.key,
            apartmentNumber: a.number,
            floor: a.floor,
            resident: _toResident(a.resident),
            monthlyDues: _dueAmountFor(entry.key),
            paymentStatus: PaymentStatus.pending,
          ),
      ],
  };
}

double _dueAmountFor(String buildingId) {
  switch (buildingId) {
    case DevShowcaseIds.vefa:
      return 500;
    case DevShowcaseIds.lale:
      return 1250;
    case DevShowcaseIds.blockA:
      return 850;
    case DevShowcaseIds.blockB:
      return 900;
    case DevShowcaseIds.blockC:
      return 800;
    default:
      return 750;
  }
}

int _dueDayFor(String buildingId) {
  switch (buildingId) {
    case DevShowcaseIds.vefa:
      return 5;
    case DevShowcaseIds.lale:
      return 10;
    default:
      return 1;
  }
}

List<BuildingEntity> buildShowcaseBuildings() {
  final apts = buildShowcaseApartments();
  final dues = buildShowcaseDues();

  BuildingEntity make({
    required String id,
    required String name,
    required String address,
    required String city,
    String? siteId,
    String? blockLabel,
    String? siteName,
    required String iban,
    required String accountTitle,
  }) {
    final list = apts[id] ?? const <ApartmentEntity>[];
    final occupied = list.where((a) => a.resident != null).length;
    final amount = _dueAmountFor(id);
    final buildingDues = dues[id] ?? const <DueEntity>[];
    final now = DateTime.now();
    final thisMonth = buildingDues.where(
      (d) => d.month == now.month && d.year == now.year && d.resident != null,
    );
    final collected = thisMonth.fold<double>(0, (s, d) => s + d.paidAmount);
    return BuildingEntity(
      id: id,
      name: name,
      address: address,
      city: city,
      totalApartments: list.length,
      occupiedApartments: occupied,
      totalMonthlyDues: amount * list.length,
      collectedDues: collected,
      dueAmount: amount,
      dueDay: _dueDayFor(id),
      currency: 'TRY',
      collectionIban: iban,
      collectionAccountTitle: accountTitle,
      paymentReferenceTemplate: 'Daire {{number}} aidat',
      siteId: siteId,
      blockLabel: blockLabel,
      siteName: siteName,
      effectiveDueAmount: amount,
      effectiveDueDay: _dueDayFor(id),
      effectiveCurrency: 'TRY',
      effectiveCollectionIban: iban,
      effectiveCollectionAccountTitle: accountTitle,
      effectiveAddress: address,
      effectiveCity: city,
    );
  }

  return [
    make(
      id: DevShowcaseIds.vefa,
      name: 'Vefa Apartman',
      address: 'Fatih Mah. Vefa Cad. No:14',
      city: 'İstanbul',
      iban: 'TR190001500158007357665813',
      accountTitle: 'Vefa Apartman Yönetimi',
    ),
    make(
      id: DevShowcaseIds.lale,
      name: 'Lale Apartmanı',
      address: 'Caddebostan Mah. Bağdat Cad. No:120',
      city: 'İstanbul',
      iban: 'TR460006400000112345678901',
      accountTitle: 'Lale Apt. Yönetimi',
    ),
    make(
      id: DevShowcaseIds.blockA,
      name: 'A Blok',
      address: 'Bahçelievler Mah. 15. Cadde No:8',
      city: 'İstanbul',
      siteId: DevShowcaseIds.siteBahceli,
      blockLabel: 'A Blok',
      siteName: 'Bahçeli Evler Sitesi',
      iban: 'TR330006100519786457841326',
      accountTitle: 'Bahçeli Evler Yönetimi',
    ),
    make(
      id: DevShowcaseIds.blockB,
      name: 'B Blok',
      address: 'Bahçelievler Mah. 15. Cadde No:8',
      city: 'İstanbul',
      siteId: DevShowcaseIds.siteBahceli,
      blockLabel: 'B Blok',
      siteName: 'Bahçeli Evler Sitesi',
      iban: 'TR330006100519786457841326',
      accountTitle: 'Bahçeli Evler Yönetimi',
    ),
    make(
      id: DevShowcaseIds.blockC,
      name: 'C Blok',
      address: 'Bahçelievler Mah. 15. Cadde No:8',
      city: 'İstanbul',
      siteId: DevShowcaseIds.siteBahceli,
      blockLabel: 'C Blok',
      siteName: 'Bahçeli Evler Sitesi',
      iban: 'TR330006100519786457841326',
      accountTitle: 'Bahçeli Evler Yönetimi',
    ),
  ];
}

/// Bu ay için hedeflenen ödeme oranı (sakinli daireler).
double _paidRatioFor(String buildingId) {
  switch (buildingId) {
    case DevShowcaseIds.vefa:
      return 0.75;
    case DevShowcaseIds.lale:
      return 0.70;
    case DevShowcaseIds.blockA:
      return 0.62;
    case DevShowcaseIds.blockB:
      return 0.50;
    case DevShowcaseIds.blockC:
      return 0.83;
    default:
      return 0.6;
  }
}

Map<String, List<DueEntity>> buildShowcaseDues() {
  final now = DateTime.now();
  final map = <String, List<DueEntity>>{};

  for (final entry in _aptSeeds.entries) {
    final buildingId = entry.key;
    final amount = _dueAmountFor(buildingId);
    final dueDay = _dueDayFor(buildingId);
    final occupied = entry.value.where((a) => a.resident != null).toList();
    final targetPaid = (occupied.length * _paidRatioFor(buildingId)).round();
    final list = <DueEntity>[];

    for (var ai = 0; ai < entry.value.length; ai++) {
      final apt = entry.value[ai];
      final resident = _toResident(apt.resident);
      // Boş daire: yalnız bu ay (görünürlük için değil; oran hesabı dışı)
      final monthsBack = resident != null ? 5 : 0;

      for (var i = 0; i <= monthsBack; i++) {
        final dt = DateTime(now.year, now.month - i, 1);
        DueStatus status;
        if (resident == null) {
          status = DueStatus.pending;
        } else if (i == 0) {
          final occupiedIndex = occupied.indexWhere((a) => a.id == apt.id);
          status = occupiedIndex >= 0 && occupiedIndex < targetPaid
              ? DueStatus.paid
              : DueStatus.overdue;
        } else {
          // Geçmiş aylar: screenshot / özet tutarlılığı için hep ödenmiş
          status = DueStatus.paid;
        }

        final dueDate = DateTime(dt.year, dt.month, dueDay);
        final overdueDays = status == DueStatus.overdue
            ? now.difference(dueDate).inDays.clamp(1, 60)
            : 0;
        final paidAt = status == DueStatus.paid
            ? DateTime(dt.year, dt.month, (dueDay + 2).clamp(1, 28))
            : null;
        final paidAmount = status == DueStatus.paid ? amount : 0.0;
        final remaining = status == DueStatus.paid ? 0.0 : amount;

        list.add(
          DueEntity(
            id: '${apt.id}_${dt.year}_${dt.month}',
            apartmentId: apt.id,
            apartmentNumber: apt.number,
            apartmentFloor: apt.floor,
            resident: resident,
            amount: amount,
            currency: 'TRY',
            month: dt.month,
            year: dt.year,
            dueDate: dueDate,
            status: status,
            paidAt: paidAt,
            overdueDays: overdueDays,
            createdAt: DateTime(dt.year, dt.month, 1),
            updatedAt: paidAt ?? DateTime(dt.year, dt.month, 1),
            paidAmount: paidAmount,
            remainingAmount: remaining,
          ),
        );
      }
    }
    map[buildingId] = list;
  }
  return map;
}

List<DueTransactionEntity> buildShowcaseTransactions(String buildingId) {
  final dues = buildShowcaseDues()[buildingId] ?? const <DueEntity>[];
  final now = DateTime.now();
  final thisMonth = dues
      .where(
        (d) =>
            d.month == now.month &&
            d.year == now.year &&
            d.resident != null &&
            (d.status == DueStatus.paid || d.status == DueStatus.overdue),
      )
      .toList()
    ..sort((a, b) => a.apartmentNumber.compareTo(b.apartmentNumber));

  final txs = <DueTransactionEntity>[];
  for (var i = 0; i < thisMonth.length; i++) {
    final d = thisMonth[i];
    final isDekont = i % 3 == 0;
    final approved = d.status == DueStatus.paid;
    txs.add(
      DueTransactionEntity(
        id: 'tx_${d.id}',
        kind: isDekont
            ? DueTransactionKind.dekont
            : DueTransactionKind.payment,
        source: isDekont
            ? DueTransactionSource.receipt
            : DueTransactionSource.manual,
        amount: d.amount,
        currency: 'TRY',
        occurredAt: approved
            ? (d.paidAt ?? now.subtract(Duration(days: 2 + i)))
            : now.subtract(Duration(hours: 4 + i)),
        apartmentNumber: d.apartmentNumber,
        residentName: d.resident?.name,
        status: approved
            ? DueTransactionStatus.approved
            : (isDekont
                ? DueTransactionStatus.pending
                : DueTransactionStatus.approved),
        dekontId: isDekont ? 'dk_${buildingId}_${d.apartmentNumber}' : null,
        dueId: d.id,
      ),
    );
  }
  txs.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  return txs;
}

SiteEntity buildBahceliSite() {
  final buildings = buildShowcaseBuildings()
      .where((b) => b.siteId == DevShowcaseIds.siteBahceli)
      .toList();
  final now = DateTime.now();
  final dues = buildShowcaseDues();
  var collected = 0.0;
  var expected = 0.0;
  var overdue = 0;
  var pending = 0;
  var occupied = 0;
  var totalApts = 0;
  for (final b in buildings) {
    totalApts += b.totalApartments;
    occupied += b.occupiedApartments;
    for (final d in dues[b.id] ?? const <DueEntity>[]) {
      if (d.month != now.month || d.year != now.year || d.resident == null) {
        continue;
      }
      expected += d.amount;
      collected += d.paidAmount;
      if (d.status == DueStatus.overdue) overdue++;
      if (d.status == DueStatus.pending) pending++;
    }
  }
  return SiteEntity(
    id: DevShowcaseIds.siteBahceli,
    name: 'Bahçeli Evler Sitesi',
    address: 'Bahçelievler Mah. 15. Cadde No:8',
    city: 'İstanbul',
    dueAmount: 850,
    dueDay: 1,
    currency: 'TRY',
    collectionIban: 'TR330006100519786457841326',
    collectionAccountTitle: 'Bahçeli Evler Yönetimi',
    collectionIbanLabel: 'İş Bankası',
    paymentReferenceTemplate: 'Daire {{number}} aidat',
    buildingCount: buildings.length,
    totalApartments: totalApts,
    occupiedApartments: occupied,
    collectedAmount: collected,
    expectedAmount: expected,
    overdueCount: overdue,
    pendingCount: pending,
  );
}

List<SiteExpenseEntity> buildBahceliSiteExpenses() {
  final now = DateTime.now();
  final siteId = DevShowcaseIds.siteBahceli;
  final aptCount = buildShowcaseBuildings()
      .where((b) => b.siteId == siteId)
      .fold<int>(0, (s, b) => s + b.totalApartments);
  return [
    SiteExpenseEntity(
      id: 'sexp_1',
      siteId: siteId,
      title: 'Site bahçe bakımı',
      amount: 4800,
      category: ExpenseCategory.garden,
      date: DateTime(now.year, now.month, 2),
      targetMonth: now.month,
      targetYear: now.year,
      perUnitAmount: aptCount > 0 ? 4800 / aptCount : null,
      createdAt: now.subtract(const Duration(days: 5)),
    ),
    SiteExpenseEntity(
      id: 'sexp_2',
      siteId: siteId,
      title: 'Site güvenlik',
      amount: 12000,
      category: ExpenseCategory.other,
      date: DateTime(now.year, now.month, 3),
      targetMonth: now.month,
      targetYear: now.year,
      perUnitAmount: aptCount > 0 ? 12000 / aptCount : null,
      createdAt: now.subtract(const Duration(days: 4)),
    ),
    SiteExpenseEntity(
      id: 'sexp_3',
      siteId: siteId,
      title: 'Havuz kimyasal ve temizlik',
      amount: 3600,
      category: ExpenseCategory.cleaning,
      date: DateTime(now.year, now.month, 7),
      targetMonth: now.month,
      targetYear: now.year,
      perUnitAmount: aptCount > 0 ? 3600 / aptCount : null,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
  ];
}
