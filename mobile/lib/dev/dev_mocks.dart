/// Sunucu yokken (offline / dev preview) UI'ı test edebilmek için kullanılan
/// in-memory mock repository'ler. Sadece `lib/main_dev.dart` ile çalışan
/// dev preview build'inde inject edilir; production main.dart bu dosyayı
/// import etmez.
///
/// Belge §5/§6 sözleşmesini yansıtan minimal davranış:
///   - createBuilding/createApartment yeni id ile listeye ekler
///   - update kısmi alan günceller
///   - delete listeden çıkarır (FK simülasyonu için
///     [MockBuildingRepository.deleteBuilding] içinde "daire varsa hata" var)
///
/// Hızlı tepki için 200ms suni gecikme eklenmiştir; loading state'leri
/// gerçekçi görünsün diye.
library;

import '../core/network/api_exception.dart';
import '../features/apartments/data/repositories/apartment_repository.dart';
import '../features/apartments/domain/entities/apartment_entity.dart';
import '../features/apartments/domain/entities/resident_info.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart'
    show AuthRepository;
import '../features/auth/domain/entities/user_entity.dart';
import '../features/buildings/data/repositories/building_repository.dart';
import '../features/buildings/domain/entities/building_entity.dart';
import '../features/dues/domain/entities/due_entity.dart';
import '../features/dues/domain/repositories/dues_repository.dart';

/// Tek bir tetikleyici noktada her mock'u sıfırlamak için.
class MockState {
  static int _counter = 0;
  static String nextId(String prefix) {
    _counter++;
    return '${prefix}_$_counter';
  }
}

const _delay = Duration(milliseconds: 200);

class MockAuthRepository implements AuthRepository {
  static final UserEntity _devManager = UserEntity(
    id: 'dev_manager_1',
    email: 'dev@aidatpanel.com',
    name: 'Dev Yönetici',
    phone: '+905551112233',
    role: UserRole.manager,
    language: 'tr',
  );

  @override
  Future<UserEntity?> restoreSession() async {
    await Future.delayed(_delay);
    return _devManager;
  }

  @override
  Future<UserEntity> login(String identifier, String password) async {
    await Future.delayed(_delay);
    return _devManager;
  }

  @override
  Future<void> register(
      String email, String password, String name, String? phone) async {
    await Future.delayed(_delay);
  }

  @override
  Future<UserEntity> join(String inviteCode, String email, String password,
      String name, String? phone) async {
    await Future.delayed(_delay);
    return _devManager;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(_delay);
  }

  @override
  Future<UserEntity?> getStoredUser() async => _devManager;
}

class MockBuildingRepository implements BuildingRepository {
  /// Yetkili olarak ApartmentRepository'yi de görüp deleteBuilding sırasında
  /// FK kontrolü yapabilmek için referans tutuyoruz.
  final MockApartmentRepository apartments;

  final List<BuildingEntity> _buildings = [
    const BuildingEntity(
      id: 'b1',
      name: 'Çamlık Apartmanı',
      address: 'Atatürk Cad. No:42',
      city: 'İstanbul',
      totalApartments: 12,
      occupiedApartments: 0,
      totalMonthlyDues: 7200,
      collectedDues: 0,
      dueAmount: 600,
      dueDay: 5,
      currency: 'TRY',
    ),
    const BuildingEntity(
      id: 'b2',
      name: 'Yıldız Sitesi A Blok',
      address: 'Bağdat Cad. No:117',
      city: 'İstanbul',
      totalApartments: 8,
      occupiedApartments: 0,
      totalMonthlyDues: 6000,
      collectedDues: 0,
      dueAmount: 750,
      dueDay: 1,
      currency: 'TRY',
    ),
  ];

  MockBuildingRepository(this.apartments);

  @override
  Future<List<BuildingEntity>> fetchBuildings() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_buildings);
  }

  @override
  Future<BuildingEntity> createBuilding({
    required String name,
    required String address,
    required String city,
    int? totalFloors,
    int? apartmentsPerFloor,
    double? dueAmount,
    int? dueDay,
    String? currency,
  }) async {
    await Future.delayed(_delay);
    final total = (totalFloors ?? 0) * (apartmentsPerFloor ?? 0);
    final building = BuildingEntity(
      id: MockState.nextId('b'),
      name: name,
      address: address,
      city: city,
      totalApartments: total,
      occupiedApartments: 0,
      totalMonthlyDues: (dueAmount ?? 0) * total,
      collectedDues: 0,
      dueAmount: dueAmount,
      dueDay: dueDay,
      currency: currency ?? 'TRY',
    );
    _buildings.add(building);
    return building;
  }

  @override
  Future<BuildingEntity> updateBuilding({
    required String id,
    String? name,
    String? address,
    String? city,
  }) async {
    await Future.delayed(_delay);
    final idx = _buildings.indexWhere((b) => b.id == id);
    if (idx == -1) {
      throw ApiException(message: 'Bina bulunamadı', statusCode: 404);
    }
    final updated = _buildings[idx].copyWith(
      name: name,
      address: address,
      city: city,
    );
    _buildings[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteBuilding(String id) async {
    await Future.delayed(_delay);
    final hasApartments =
        (apartments._byBuilding[id]?.isNotEmpty ?? false);
    if (hasApartments) {
      // Belge §5: bina sakin/aidat varsa silinemez. UI bu hatayı insanlaştırır.
      throw ApiException(
        message: 'Cannot delete building: still has apartments',
        statusCode: 400,
      );
    }
    _buildings.removeWhere((b) => b.id == id);
  }
}

class MockApartmentRepository implements ApartmentRepository {
  /// Bina başına mock daire listesi.
  final Map<String, List<ApartmentEntity>> _byBuilding = {
    'b1': [
      const ApartmentEntity(
        id: 'a1_1',
        buildingId: 'b1',
        apartmentNumber: '1A',
        floor: 1,
        resident: ResidentInfo(
          id: 'r1',
          name: 'Ayşe Yılmaz',
          email: 'ayse@example.com',
          phone: '+905551112201',
          role: 'RESIDENT',
        ),
        monthlyDues: 600,
        paymentStatus: PaymentStatus.paid,
      ),
      const ApartmentEntity(
        id: 'a1_2',
        buildingId: 'b1',
        apartmentNumber: '1B',
        floor: 1,
        resident: ResidentInfo(
          id: 'r2',
          name: 'Mehmet Demir',
          email: 'mehmet@example.com',
          role: 'RESIDENT',
        ),
        monthlyDues: 600,
        paymentStatus: PaymentStatus.pending,
      ),
      ApartmentEntity(
        id: 'a1_3',
        buildingId: 'b1',
        apartmentNumber: '2A',
        floor: 2,
        monthlyDues: 600,
        paymentStatus: PaymentStatus.pending,
      ),
      ApartmentEntity(
        id: 'a1_4',
        buildingId: 'b1',
        apartmentNumber: '2B',
        floor: 2,
        monthlyDues: 600,
        paymentStatus: PaymentStatus.pending,
      ),
    ],
    'b2': [
      const ApartmentEntity(
        id: 'a2_1',
        buildingId: 'b2',
        apartmentNumber: '1',
        floor: 1,
        resident: ResidentInfo(
          id: 'r3',
          name: 'Zeynep Kaya',
          email: 'zeynep@example.com',
          phone: '+905551112202',
          role: 'RESIDENT',
        ),
        monthlyDues: 750,
        paymentStatus: PaymentStatus.overdue,
      ),
      ApartmentEntity(
        id: 'a2_2',
        buildingId: 'b2',
        apartmentNumber: '2',
        floor: 2,
        monthlyDues: 750,
        paymentStatus: PaymentStatus.pending,
      ),
    ],
  };

  @override
  Future<List<ApartmentEntity>> fetchApartments(String buildingId) async {
    await Future.delayed(_delay);
    return List.unmodifiable(_byBuilding[buildingId] ?? const []);
  }

  @override
  Future<ApartmentEntity> createApartment({
    required String buildingId,
    required String number,
    int? floor,
  }) async {
    await Future.delayed(_delay);
    final apt = ApartmentEntity(
      id: MockState.nextId('a'),
      buildingId: buildingId,
      apartmentNumber: number,
      floor: floor,
    );
    _byBuilding.update(
      buildingId,
      (list) => [...list, apt],
      ifAbsent: () => [apt],
    );
    return apt;
  }

  @override
  Future<ApartmentEntity> updateApartment({
    required String buildingId,
    required String id,
    String? number,
    int? floor,
  }) async {
    await Future.delayed(_delay);
    final list = _byBuilding[buildingId];
    if (list == null) {
      throw ApiException(message: 'Bina bulunamadı', statusCode: 404);
    }
    final idx = list.indexWhere((a) => a.id == id);
    if (idx == -1) {
      throw ApiException(message: 'Daire bulunamadı', statusCode: 404);
    }
    final updated = list[idx].copyWith(
      apartmentNumber: number,
      floor: floor,
    );
    list[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteApartment({
    required String buildingId,
    required String id,
  }) async {
    await Future.delayed(_delay);
    final list = _byBuilding[buildingId];
    if (list == null) return;
    final apt = list.firstWhere(
      (a) => a.id == id,
      orElse: () => throw ApiException(
        message: 'Daire bulunamadı',
        statusCode: 404,
      ),
    );
    if (apt.resident != null) {
      // Belge §6: sakin atanmış daire silinince FK ihlali (dues vs.) gelebilir.
      // Mock olarak bu davranışı simüle ediyoruz; UI insanlaştırılmış mesaj basar.
      throw ApiException(
        message: 'Cannot delete apartment: resident still assigned',
        statusCode: 400,
      );
    }
    list.removeWhere((a) => a.id == id);
  }
}

class MockDuesRepository implements DuesRepository {
  @override
  Future<List<DueEntity>> getBuildingDues(String buildingId) async {
    await Future.delayed(_delay);
    return const [];
  }

  @override
  Future<List<DueEntity>> getMyDues() async {
    await Future.delayed(_delay);
    return const [];
  }

  @override
  Future<DueEntity> updateDueStatus({
    required String buildingId,
    required String dueId,
    required DueStatus status,
  }) async {
    await Future.delayed(_delay);
    throw ApiException(message: 'Mock: not implemented');
  }

  @override
  Future<void> updateBuildingDueAmount({
    required String buildingId,
    required double dueAmount,
    int? dueDay,
    String? currency,
    bool affectCurrent = false,
  }) async {
    await Future.delayed(_delay);
  }
}
