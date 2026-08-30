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

import 'dart:typed_data';

import '../core/network/api_exception.dart';
import '../core/network/paginated_list_result.dart';
import '../features/apartments/data/repositories/apartment_repository.dart';
import '../features/apartments/domain/entities/apartment_entity.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart'
    show AuthRepository;
import '../features/auth/domain/entities/user_entity.dart';
import '../features/auth/domain/entities/saved_login_hint.dart';
import '../features/auth/domain/entities/manager_identifier_lookup.dart';
import '../features/auth/domain/entities/forgot_password_result.dart';
import '../features/buildings/data/repositories/building_repository.dart';
import '../features/buildings/domain/entities/building_entity.dart';
import '../features/buildings/domain/entities/collection_preset_entity.dart';
import '../features/buildings/domain/entities/saved_iban_delete_result.dart';
import '../core/utils/iban_utils.dart';
import '../features/dues/domain/entities/due_entity.dart';
import '../features/dues/domain/entities/due_remind_result.dart';
import '../features/dues/domain/entities/due_transaction_entity.dart';
import '../features/dues/domain/repositories/dues_repository.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/subscription/domain/entities/subscription_entity.dart';
import '../features/subscription/domain/repositories/subscription_repository.dart';
import '../features/tickets/domain/entities/ticket_entity.dart';
import '../features/tickets/domain/entities/ticket_update_entity.dart';
import '../features/tickets/domain/repositories/ticket_repository.dart';
import 'dev_showcase_seed.dart';

/// Tek bir tetikleyici noktada her mock'u sıfırlamak için.
class MockState {
  static int _counter = 0;
  static String nextId(String prefix) {
    _counter++;
    return '${prefix}_$_counter';
  }
}

const _delay = Duration(milliseconds: 200);

// Dev preview seed data: kullanıcı tarafından/backend tarafından gelen örnek veri gibi
// davranır; uygulama UI metni olmadığı için i18n anahtarına bağlanmaz.

class MockAuthRepository implements AuthRepository {
  /// null = çıkış yapılmış; splash login ekranına gider.
  static UserEntity? _sessionUser;

  static final UserEntity _devManager = UserEntity(
    id: 'dev_manager_1',
    email: 'yonetici@aidatpanel.dev',
    name: 'Ahmet Yılmaz',
    phone: '5321002030',
    role: UserRole.manager,
    language: 'tr',
  );

  /// Showcase sakin: Lale daire 8 — bu ay OVERDUE (screenshot borç kartı için).
  /// Daire 1–7 seed'de paid; 8–10 overdue.
  static final UserEntity _devResident = UserEntity(
    id: 'r_lale_8',
    email: 'cem@aidatpanel.dev',
    name: 'Cem Aydın',
    phone: '5550303008',
    role: UserRole.resident,
    language: 'tr',
    apartmentId: 'lale_a8',
  );

  @override
  Future<UserEntity?> restoreSession() async {
    await Future.delayed(_delay);
    return _sessionUser;
  }

  @override
  Future<UserEntity?> getStoredUser() async {
    await Future.delayed(_delay);
    return _sessionUser;
  }

  @override
  Future<void> persistUser(UserEntity user) async {
    await Future.delayed(_delay);
    _sessionUser = user;
  }

  @override
  Future<UserEntity> login(String identifier, String password) async {
    await Future.delayed(_delay);
    final id = identifier.trim().toLowerCase();
    if (id == 'resident@dev' || id.contains('resident')) {
      _sessionUser = _devResident;
      return _devResident;
    }
    _sessionUser = _devManager;
    return _devManager;
  }

  @override
  Future<void> register(
    String? email,
    String password,
    String name,
    String? phone,
  ) async {
    await Future.delayed(_delay);
  }

  @override
  Future<UserEntity> join(
    String inviteCode,
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    await Future.delayed(_delay);
    return _devManager;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(_delay);
    _sessionUser = null;
  }

  @override
  Future<void> logoutAllDevices() async {
    await Future.delayed(_delay);
  }

  /// İlk açılışta otomatik yönetici (isteğe bağlı). main_dev çağırır.
  static void seedManagerSession() {
    _sessionUser = _devManager;
  }

  static UserEntity? get sessionUser => _sessionUser;

  static void updateSessionUser(UserEntity user) {
    _sessionUser = user;
  }

  /// Tur 5 §10/6 — Backend her zaman 200 döner; mock da aynı davranışı
  /// gösterir, hiçbir kontrol yapmaz.
  @override
  Future<ForgotPasswordResult> forgotPassword({
    String? email,
    String? phone,
    String? channel,
  }) async {
    await Future.delayed(_delay);
    if (channel == 'sms') {
      return const ForgotPasswordResult(
        deliveredVia: 'sms',
        smsFallbackAvailable: false,
      );
    }
    if (email != null && email.isNotEmpty) {
      return const ForgotPasswordResult(
        deliveredVia: 'email',
        smsFallbackAvailable: true,
      );
    }
    return const ForgotPasswordResult(
      deliveredVia: 'sms',
      smsFallbackAvailable: false,
    );
  }

  /// Mock kabul kodu: `ABCDEF` (her şey büyük). Diğer 6 karakter kodlar
  /// 400 ile reddedilir (UI insanlaştırması test edilebilsin diye).
  @override
  Future<void> resetPassword(String token, String password) async {
    await Future.delayed(_delay);
    if (token.toUpperCase() != 'ABCDEF') {
      throw ApiException(message: 'Invalid or expired token', statusCode: 400);
    }
  }

  @override
  Future<void> sendOtp({
    String? phone,
    String? email,
    required String purpose,
    Map<String, dynamic>? payload,
  }) async {
    await Future.delayed(_delay);
  }

  @override
  Future<UserEntity> verifyOtp({
    String? phone,
    String? email,
    required String code,
    required String purpose,
    Map<String, dynamic>? payload,
    String? name,
    String? password,
    String? inviteCode,
  }) async {
    await Future.delayed(_delay);
    if (purpose.contains('resident')) {
      _sessionUser = _devResident;
      return _devResident;
    }
    _sessionUser = _devManager;
    return _devManager;
  }

  @override
  Future<UserEntity> verifyFirebasePhoneLogin({
    required String idToken,
  }) async {
    await Future.delayed(_delay);
    _sessionUser = _devResident;
    return _devResident;
  }

  @override
  Future<bool> verifyFirebasePhoneJoin({
    required String idToken,
    String? inviteCode,
  }) async {
    await Future.delayed(_delay);
    return true;
  }

  @override
  Future<void> verifyFirebasePhoneChange({
    required String idToken,
  }) async {
    await Future.delayed(_delay);
  }

  @override
  Future<String> validateInvite(String inviteCode) async {
    await Future.delayed(_delay);
    return 'Dev Site';
  }

  @override
  Future<SavedLoginHint?> getSavedLoginHint(UserRole role) async => null;

  @override
  Future<void> checkIdentifier({
    required String identifier,
    required String purpose,
  }) async {
    await Future.delayed(_delay);
  }

  @override
  Future<ManagerIdentifierLookup> checkResidentPhoneExists(String phone) async {
    await Future.delayed(_delay);
    return const ManagerIdentifierLookup(exists: false);
  }

  @override
  Future<ManagerIdentifierLookup> checkManagerIdentifierExists(
    String identifier,
  ) async {
    await Future.delayed(_delay);
    return const ManagerIdentifierLookup(
      exists: true,
      name: 'Dev Yönetici',
    );
  }

  @override
  Future<bool> verifyResidentJoinOtp({
    required String phone,
    required String code,
    String? inviteCode,
  }) async {
    await Future.delayed(_delay);
    return true;
  }

  @override
  Future<UserEntity> completeResidentJoin({
    required String phone,
    required String name,
    required String inviteCode,
  }) async {
    await Future.delayed(_delay);
    _sessionUser = _devResident;
    return _devResident;
  }

  @override
  Future<UserEntity> rejoinWithInviteCode(String inviteCode) async {
    await Future.delayed(_delay);
    _sessionUser = _devResident;
    return _devResident;
  }
}

/// Tur 5 §10/4-5 — `PUT /me/password` ve `DELETE /me` mock implementasyonu.
class MockProfileRepository implements ProfileRepository {
  /// Dev mock şifresi: `Eski123.` Bunun dışında ne girilirse 401 döner.
  String _currentPassword = 'Eski123.';

  /// Hesabı kapatma 1. denemede başarılı. Manager 409 davranışını test
  /// etmek isterseniz `forceManagerConflict` true yapın.
  bool forceManagerConflict = false;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(_delay);
    if (currentPassword != _currentPassword) {
      throw ApiException(
        message: 'Current password is incorrect',
        statusCode: 401,
      );
    }
    _currentPassword = newPassword;
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(_delay);
    if (forceManagerConflict) {
      throw ApiException(
        message:
            'You still manage one or more buildings. Delete or transfer them first.',
        statusCode: 409,
      );
    }
  }

  @override
  Future<UserEntity> getProfile() async {
    await Future.delayed(_delay);
    final user = MockAuthRepository.sessionUser;
    if (user == null) {
      throw ApiException(message: 'Unauthorized', statusCode: 401);
    }
    return user;
  }

  @override
  Future<UserEntity> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? currentPassword,
    String? otpCode,
    bool includeEmail = true,
    bool includePhone = true,
  }) async {
    await Future.delayed(_delay);
    final user = MockAuthRepository.sessionUser;
    if (user == null) {
      throw ApiException(message: 'Unauthorized', statusCode: 401);
    }
    final updated = UserEntity(
      id: user.id,
      email: email != null && email.trim().isNotEmpty
          ? email.trim()
          : user.email,
      name: name.trim(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      role: user.role,
      fcmToken: user.fcmToken,
      language: user.language,
      apartmentId: user.apartmentId,
    );
    MockAuthRepository.updateSessionUser(updated);
    return updated;
  }

  @override
  Future<UserEntity> updateLanguage(String languageCode) async {
    await Future.delayed(_delay);
    final user = MockAuthRepository.sessionUser;
    if (user == null) {
      throw ApiException(message: 'Unauthorized', statusCode: 401);
    }
    final updated = UserEntity(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
      fcmToken: user.fcmToken,
      language: languageCode,
      apartmentId: user.apartmentId,
    );
    MockAuthRepository.updateSessionUser(updated);
    return updated;
  }

  @override
  Future<UserEntity> uploadProfilePicture(String filePath) async {
    await Future.delayed(_delay);
    final user = MockAuthRepository.sessionUser;
    if (user == null) {
      throw ApiException(message: 'Unauthorized', statusCode: 401);
    }
    final updated = UserEntity(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
      fcmToken: user.fcmToken,
      language: user.language,
      apartmentId: user.apartmentId,
      profilePicture: 'avatar-${user.id}-mock.jpg',
      createdAt: user.createdAt,
    );
    MockAuthRepository.updateSessionUser(updated);
    return updated;
  }

  @override
  Future<UserEntity> deleteProfilePicture() async {
    await Future.delayed(_delay);
    final user = MockAuthRepository.sessionUser;
    if (user == null) {
      throw ApiException(message: 'Unauthorized', statusCode: 401);
    }
    final updated = UserEntity(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
      fcmToken: user.fcmToken,
      language: user.language,
      apartmentId: user.apartmentId,
      profilePicture: null,
      createdAt: user.createdAt,
    );
    MockAuthRepository.updateSessionUser(updated);
    return updated;
  }
}

class MockSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<SubscriptionEntity?> getMySubscription() async {
    await Future.delayed(_delay);
    return const SubscriptionEntity(
      id: 'sub_dev_business',
      status: SubscriptionStatus.active,
      plan: 'aidatpanel_business_monthly',
      currentPeriodEnd: null,
    );
  }
}

class MockBuildingRepository implements BuildingRepository {
  /// Yetkili olarak ApartmentRepository'yi de görüp deleteBuilding sırasında
  /// FK kontrolü yapabilmek için referans tutuyoruz.
  final MockApartmentRepository apartments;

  final List<BuildingEntity> _buildings = List.of(buildShowcaseBuildings());

  MockBuildingRepository(this.apartments) {
    // Showcase daireleri apartment repo'ya yükle.
    final seeded = buildShowcaseApartments();
    for (final entry in seeded.entries) {
      apartments.replaceSeed(entry.key, entry.value);
    }
  }

  @override
  Future<List<BuildingEntity>> fetchBuildings({bool standalone = false}) async {
    await Future.delayed(_delay);
    final list = standalone
        ? _buildings.where((b) => b.siteId == null)
        : _buildings;
    return List.unmodifiable(list);
  }

  /// Bina atanmamış örnek setler (bina ekle formu + ayarlar düzenleme).
  final List<CollectionPresetEntity> _extraPresets = [
    const CollectionPresetEntity(
      collectionIban: 'TR330006100519786457841326',
      collectionAccountTitle: 'Güneş Sitesi Yönetimi',
      paymentReferenceTemplate: 'Daire {{number}}',
      buildingCount: 0,
    ),
    const CollectionPresetEntity(
      collectionIban: 'TR760001500158007293093847',
      collectionAccountTitle: 'Apartman Yönetimi',
      paymentReferenceTemplate: 'Daire {{number}} Aidat',
      buildingCount: 0,
    ),
    const CollectionPresetEntity(
      collectionIban: 'TR560001100000000000012345',
      collectionAccountTitle: 'Bahçeşehir Konutları Yönetim',
      paymentReferenceTemplate: 'Daire {{number}} - AidatPanel',
      buildingCount: 0,
    ),
    const CollectionPresetEntity(
      collectionIban: 'TR070001500501000000000001',
      collectionAccountTitle: 'Merkez Plaza Site Yönetimi',
      paymentReferenceTemplate: 'Havale: Daire {{number}}',
      buildingCount: 0,
    ),
    const CollectionPresetEntity(
      collectionIban: 'TR120006200000000000000001',
      collectionAccountTitle: 'Deniz Manzarası Sitesi',
      paymentReferenceTemplate: '{{number}} / Aidat',
      buildingCount: 0,
    ),
  ];

  List<CollectionPresetEntity> _presetsFromBuildings() {
    final counts = <String, int>{};
    final sample = <String, BuildingEntity>{};
    for (final b in _buildings) {
      final iban = b.collectionIban;
      if (iban == null || !IbanUtils.isValidTrIban(iban)) continue;
      final key = IbanUtils.normalize(iban);
      counts[key] = (counts[key] ?? 0) + 1;
      sample.putIfAbsent(key, () => b);
    }
    final presets = counts.entries.map((e) {
      final b = sample[e.key]!;
      return CollectionPresetEntity(
        collectionIban: e.key,
        collectionAccountTitle: b.collectionAccountTitle,
        paymentReferenceTemplate: b.paymentReferenceTemplate,
        buildingCount: e.value,
      );
    }).toList();
    presets.sort((a, b) => b.buildingCount.compareTo(a.buildingCount));
    return presets;
  }

  List<CollectionPresetEntity> _mergedPresets() {
    final fromBuildings = _presetsFromBuildings();
    final keys = fromBuildings
        .map((p) => IbanUtils.normalize(p.collectionIban))
        .toSet();
    final extras = _extraPresets
        .where((p) => !keys.contains(IbanUtils.normalize(p.collectionIban)))
        .toList();
    return [...fromBuildings, ...extras];
  }

  bool _removeExtraPreset(String matchIban) {
    final key = IbanUtils.normalize(matchIban);
    final before = _extraPresets.length;
    _extraPresets.removeWhere(
      (p) => IbanUtils.normalize(p.collectionIban) == key,
    );
    return _extraPresets.length < before;
  }

  bool _hasPresetKey(String key) {
    return _mergedPresets().any(
      (p) => IbanUtils.normalize(p.collectionIban) == key,
    );
  }

  bool _updateExtraPreset({
    required String matchIban,
    required String? collectionIban,
    required String? collectionAccountTitle,
    String? collectionIbanLabel,
    bool updateIbanLabel = false,
    required String? paymentReferenceTemplate,
  }) {
    final key = IbanUtils.normalize(matchIban);
    final idx = _extraPresets.indexWhere(
      (p) => IbanUtils.normalize(p.collectionIban) == key,
    );
    if (idx == -1) return false;
    final previous = _extraPresets[idx];
    final iban = collectionIban != null && collectionIban.isNotEmpty
        ? IbanUtils.normalize(collectionIban)
        : key;
    _extraPresets[idx] = CollectionPresetEntity(
      collectionIban: iban,
      collectionAccountTitle: collectionAccountTitle?.trim().isEmpty ?? true
          ? null
          : collectionAccountTitle!.trim(),
      collectionIbanLabel: updateIbanLabel
          ? (collectionIbanLabel?.trim().isEmpty ?? true
                ? null
                : collectionIbanLabel!.trim())
          : previous.collectionIbanLabel,
      paymentReferenceTemplate: paymentReferenceTemplate?.trim().isEmpty ?? true
          ? null
          : paymentReferenceTemplate!.trim(),
      buildingCount: 0,
    );
    return true;
  }

  @override
  Future<List<CollectionPresetEntity>> fetchCollectionPresets() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_mergedPresets());
  }

  /// Backend `buildingService.createBuildingService` davranışını simüle
  /// eder: tek "transaction" içinde bina + (totalFloors × apartmentsPerFloor)
  /// daire (1A, 1B, 2A, 2B …) seed eder. Mobile artık ayrı bir fallback
  /// seed loop'u çalıştırmıyor (Tur 5 §10/2).
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
    String? collectionIban,
    String? collectionAccountTitle,
    String? collectionIbanLabel,
    String? paymentReferenceTemplate,
  }) async {
    await Future.delayed(_delay);
    final floors = totalFloors ?? 0;
    final perFloor = apartmentsPerFloor ?? 0;
    final total = floors * perFloor;
    final id = MockState.nextId('b');
    final iban = collectionIban != null && collectionIban.isNotEmpty
        ? IbanUtils.normalize(collectionIban)
        : null;
    final building = BuildingEntity(
      id: id,
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
      collectionIban: iban,
      collectionAccountTitle: collectionAccountTitle,
      paymentReferenceTemplate: paymentReferenceTemplate,
    );
    _buildings.add(building);
    apartments._seedForBuilding(
      buildingId: id,
      totalFloors: floors,
      apartmentsPerFloor: perFloor,
      monthlyDues: dueAmount ?? 0,
    );
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
      throw ApiException(message: 'building_not_found', statusCode: 404);
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
  Future<BuildingEntity> patchBuildingCollection({
    required String id,
    required String? collectionIban,
    required String? collectionAccountTitle,
    String? collectionIbanLabel,
    bool updateIbanLabel = false,
    required String? paymentReferenceTemplate,
  }) async {
    await Future.delayed(_delay);
    final idx = _buildings.indexWhere((b) => b.id == id);
    if (idx == -1) {
      throw ApiException(message: 'building_not_found', statusCode: 404);
    }
    final iban = collectionIban != null && collectionIban.isNotEmpty
        ? IbanUtils.normalize(collectionIban)
        : null;
    final updated = _buildings[idx].copyWith(
      collectionIban: iban,
      collectionAccountTitle: collectionAccountTitle?.trim().isEmpty ?? true
          ? null
          : collectionAccountTitle!.trim(),
      paymentReferenceTemplate: paymentReferenceTemplate?.trim().isEmpty ?? true
          ? null
          : paymentReferenceTemplate!.trim(),
    );
    _buildings[idx] = updated;
    return updated;
  }

  @override
  Future<CollectionPresetEntity> addCollectionPreset({
    required String collectionIban,
    String? collectionAccountTitle,
    String? collectionIbanLabel,
    String? paymentReferenceTemplate,
  }) async {
    await Future.delayed(_delay);
    final key = IbanUtils.normalize(collectionIban);
    if (!IbanUtils.isValidTrIban(key)) {
      throw ApiException(message: 'invalid_iban');
    }
    if (_hasPresetKey(key)) {
      throw ApiException(message: 'collection_iban_duplicate');
    }
    final entity = CollectionPresetEntity(
      collectionIban: key,
      collectionAccountTitle: collectionAccountTitle?.trim().isEmpty ?? true
          ? null
          : collectionAccountTitle!.trim(),
      collectionIbanLabel: collectionIbanLabel?.trim().isEmpty ?? true
          ? null
          : collectionIbanLabel!.trim(),
      paymentReferenceTemplate: paymentReferenceTemplate?.trim().isEmpty ?? true
          ? null
          : paymentReferenceTemplate!.trim(),
      buildingCount: 0,
    );
    _extraPresets.add(entity);
    return entity;
  }

  @override
  Future<SavedIbanDeleteResult> deleteCollectionPreset({
    required String matchIban,
  }) async {
    await Future.delayed(_delay);
    final key = IbanUtils.normalize(matchIban);
    var buildingsCleared = 0;
    for (var i = 0; i < _buildings.length; i++) {
      if (IbanUtils.normalize(_buildings[i].collectionIban ?? '') != key) {
        continue;
      }
      final updated = await patchBuildingCollection(
        id: _buildings[i].id,
        collectionIban: '',
        collectionAccountTitle: '',
        paymentReferenceTemplate: '',
      );
      _buildings[i] = updated;
      buildingsCleared++;
    }
    final orphanPresetRemoved = _removeExtraPreset(key);
    if (buildingsCleared == 0 && !orphanPresetRemoved) {
      throw ApiException(
        message: 'collection_preset_not_found',
        statusCode: 404,
      );
    }
    return SavedIbanDeleteResult(
      buildingsCleared: buildingsCleared,
      orphanPresetRemoved: orphanPresetRemoved,
    );
  }

  @override
  Future<SavedIbanBulkDeleteResult> deleteCollectionPresets({
    required List<String> matchIbans,
  }) async {
    await Future.delayed(_delay);
    var presetsRemoved = 0;
    var buildingsCleared = 0;
    ApiException? lastError;
    for (final raw in matchIbans.toSet()) {
      try {
        final result = await deleteCollectionPreset(matchIban: raw);
        if (result.hadEffect) presetsRemoved++;
        buildingsCleared += result.buildingsCleared;
      } on ApiException catch (e) {
        lastError = e;
      }
    }
    if (presetsRemoved == 0) {
      throw lastError ??
          ApiException(message: 'collection_preset_not_found', statusCode: 404);
    }
    return SavedIbanBulkDeleteResult(
      presetsRemoved: presetsRemoved,
      buildingsCleared: buildingsCleared,
    );
  }

  @override
  Future<int> patchBuildingsMatchingCollection({
    required String matchIban,
    required String? collectionIban,
    required String? collectionAccountTitle,
    String? collectionIbanLabel,
    bool updateIbanLabel = false,
    required String? paymentReferenceTemplate,
  }) async {
    await Future.delayed(_delay);
    final key = IbanUtils.normalize(matchIban);
    var count = 0;
    for (var i = 0; i < _buildings.length; i++) {
      if (IbanUtils.normalize(_buildings[i].collectionIban ?? '') != key) {
        continue;
      }
      final updated = await patchBuildingCollection(
        id: _buildings[i].id,
        collectionIban: collectionIban,
        collectionAccountTitle: collectionAccountTitle,
        collectionIbanLabel: collectionIbanLabel,
        updateIbanLabel: updateIbanLabel,
        paymentReferenceTemplate: paymentReferenceTemplate,
      );
      _buildings[i] = updated;
      count++;
    }
    if (count > 0) return count;

    if (_updateExtraPreset(
      matchIban: matchIban,
      collectionIban: collectionIban,
      collectionAccountTitle: collectionAccountTitle,
      collectionIbanLabel: collectionIbanLabel,
      updateIbanLabel: updateIbanLabel,
      paymentReferenceTemplate: paymentReferenceTemplate,
    )) {
      return 0;
    }

    throw ApiException(message: 'collection_preset_not_found', statusCode: 404);
  }

  @override
  Future<void> deleteBuilding(String id) async {
    await Future.delayed(_delay);
    final hasApartments = (apartments._byBuilding[id]?.isNotEmpty ?? false);
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
  final Map<String, List<ApartmentEntity>> _byBuilding = {};

  /// Showcase seed'ini yazmak için (MockBuildingRepository ctor).
  void replaceSeed(String buildingId, List<ApartmentEntity> apartments) {
    _byBuilding[buildingId] = List.of(apartments);
  }

  /// Backend `createBuildingService` ile aynı: 1'den başlayan sıralı kapı no.
  void _seedForBuilding({
    required String buildingId,
    required int totalFloors,
    required int apartmentsPerFloor,
    required double monthlyDues,
  }) {
    if (totalFloors <= 0 || apartmentsPerFloor <= 0) return;
    final list = <ApartmentEntity>[];
    var unitNumber = 1;
    for (var floor = 1; floor <= totalFloors; floor++) {
      for (var unit = 0; unit < apartmentsPerFloor; unit++) {
        list.add(
          ApartmentEntity(
            id: MockState.nextId('a'),
            buildingId: buildingId,
            apartmentNumber: '$unitNumber',
            floor: floor,
            monthlyDues: monthlyDues,
          ),
        );
        unitNumber += 1;
      }
    }
    _byBuilding[buildingId] = list;
  }

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
      throw ApiException(message: 'building_not_found', statusCode: 404);
    }
    final idx = list.indexWhere((a) => a.id == id);
    if (idx == -1) {
      throw ApiException(message: 'apartment_not_found', statusCode: 404);
    }
    final updated = list[idx].copyWith(apartmentNumber: number, floor: floor);
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
      orElse: () =>
          throw ApiException(message: 'apartment_not_found', statusCode: 404),
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

  /// Tur 5 / §3.1 — Sakini daireden çıkarır. Backend
  /// `apartmentService.removeResidentFromApartmentService` davranışını
  /// simüle eder: sakin yoksa 404, varsa `resident: null` set eder ve
  /// güncel apartment'ı döner.
  @override
  Future<ApartmentEntity> removeResident({
    required String buildingId,
    required String apartmentId,
  }) async {
    await Future.delayed(_delay);
    final list = _byBuilding[buildingId];
    if (list == null) {
      throw ApiException(message: 'building_not_found', statusCode: 404);
    }
    final idx = list.indexWhere((a) => a.id == apartmentId);
    if (idx == -1) {
      throw ApiException(message: 'apartment_not_found', statusCode: 404);
    }
    if (list[idx].resident == null) {
      throw ApiException(
        message: 'No resident assigned to this apartment',
        statusCode: 404,
      );
    }
    final updated = list[idx].copyWith(clearResident: true);
    list[idx] = updated;
    return updated;
  }
}

/// Geçmiş 6 ay × bina dairelerinin senaryolu fake aidat üretici.
/// Dashboard `collectionRate`, ay/yıl filtresi, overdue rozeti gibi UI
/// öğelerini gerçekten test edebilmek için karışık statü dağılımı içerir.
class MockDuesRepository implements DuesRepository {
  /// Bina başına in-memory dues listesi. Update senaryolarında bu listede
  /// status değiştirebilmek için final var olarak tutuyoruz.
  late final Map<String, List<DueEntity>> _byBuilding;
  late final Map<String, List<DueTransactionEntity>> _transactions;

  MockDuesRepository() {
    _byBuilding = {
      for (final e in buildShowcaseDues().entries) e.key: List.of(e.value),
    };
    _transactions = {
      for (final id in _byBuilding.keys)
        id: List.of(buildShowcaseTransactions(id)),
    };
  }

  /// Tur 5 §10/3 — server-side filtre simulasyonu. Backend
  /// `dueController.getDuesByBuildingController` aynı parametreleri
  /// uyguladığı için mock da burada client-side filtre yapar.
  @override
  Future<PaginatedListResult<DueEntity>> getBuildingDues(
    String buildingId, {
    int? month,
    int? year,
    DueStatus? status,
    String? cursor,
    bool paginated = true,
  }) async {
    await Future.delayed(_delay);
    final source = _byBuilding[buildingId] ?? const <DueEntity>[];
    final filtered = List<DueEntity>.unmodifiable(
      source.where((d) {
        if (month != null && d.month != month) return false;
        if (year != null && d.year != year) return false;
        if (status != null && d.status != status) return false;
        // Yönetici listesi: sakinli veya açık borç snapshot (boş daire PAID gizle)
        if (d.resident == null &&
            d.status != DueStatus.pending &&
            d.status != DueStatus.overdue) {
          return false;
        }
        return true;
      }),
    );
    return PaginatedListResult(items: filtered);
  }

  @override
  Future<PaginatedListResult<DueEntity>> getMyDues({
    int? month,
    int? year,
    DueStatus? status,
    String? cursor,
    bool paginated = true,
  }) async {
    await Future.delayed(_delay);
    final aptId = MockAuthRepository.sessionUser?.apartmentId;
    if (aptId == null) {
      return const PaginatedListResult(items: []);
    }
    final all = _byBuilding.values.expand((e) => e).where((d) {
      if (d.apartmentId != aptId) return false;
      if (month != null && d.month != month) return false;
      if (year != null && d.year != year) return false;
      if (status != null && d.status != status) return false;
      return true;
    }).toList();
    return PaginatedListResult(items: all);
  }

  @override
  Future<PaginatedListResult<DueTransactionEntity>> getDueTransactions(
    String buildingId, {
    String? cursor,
    bool paginated = true,
  }) async {
    await Future.delayed(_delay);
    final list = _transactions[buildingId] ?? const <DueTransactionEntity>[];
    return PaginatedListResult(items: List.unmodifiable(list));
  }

  @override
  Future<DueEntity> updateDueStatus({
    required String buildingId,
    required String dueId,
    required DueStatus status,
  }) async {
    await Future.delayed(_delay);
    final list = _byBuilding[buildingId];
    if (list == null) {
      throw ApiException(message: 'building_not_found', statusCode: 404);
    }
    final idx = list.indexWhere((d) => d.id == dueId);
    if (idx == -1) {
      throw ApiException(message: 'due_not_found', statusCode: 404);
    }
    final old = list[idx];
    final now = DateTime.now();
    final updated = DueEntity(
      id: old.id,
      apartmentId: old.apartmentId,
      apartmentNumber: old.apartmentNumber,
      apartmentFloor: old.apartmentFloor,
      resident: old.resident,
      amount: old.amount,
      currency: old.currency,
      month: old.month,
      year: old.year,
      dueDate: old.dueDate,
      status: status,
      paidAt: status == DueStatus.paid ? now : null,
      overdueDays: status == DueStatus.overdue ? old.overdueDays : 0,
      note: old.note,
      createdAt: old.createdAt,
      updatedAt: now,
      paidAmount: status == DueStatus.paid ? old.amount : 0,
      remainingAmount: status == DueStatus.paid ? 0 : old.amount,
    );
    list[idx] = updated;
    return updated;
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
    if (!affectCurrent) return;
    final list = _byBuilding[buildingId];
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      if (list[i].status == DueStatus.pending ||
          list[i].status == DueStatus.overdue) {
        final old = list[i];
        list[i] = DueEntity(
          id: old.id,
          apartmentId: old.apartmentId,
          apartmentNumber: old.apartmentNumber,
          apartmentFloor: old.apartmentFloor,
          resident: old.resident,
          amount: dueAmount,
          currency: currency ?? old.currency,
          month: old.month,
          year: old.year,
          dueDate: old.dueDate,
          status: old.status,
          paidAt: old.paidAt,
          overdueDays: old.overdueDays,
          note: old.note,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          paidAmount: old.paidAmount,
          remainingAmount: dueAmount,
        );
      }
    }
  }

  @override
  Future<DueRemindResult> remindBuildingDues(
    String buildingId, {
    List<String>? dueIds,
  }) async {
    await Future.delayed(_delay);
    final list = _byBuilding[buildingId] ?? const <DueEntity>[];
    if (dueIds == null || dueIds.isEmpty) {
      final count = list
          .where(
            (d) =>
                d.resident != null &&
                (d.status == DueStatus.pending ||
                    d.status == DueStatus.overdue),
          )
          .map((d) => d.resident!.id)
          .toSet()
          .length;
      return DueRemindResult(reminded: count);
    }
    final matches = list.where((d) => dueIds.contains(d.id));
    final count = matches.where((d) => d.resident != null).length;
    return DueRemindResult(reminded: count);
  }
}

class MockTicketRepository implements TicketRepository {
  final List<TicketEntity> _tickets = [];

  MockTicketRepository() {
    final now = DateTime.now();
    _tickets.addAll([
      TicketEntity(
        id: 'ticket_seed_1',
        apartmentId: 'vefa_a1',
        userId: 'r_vefa_1',
        buildingId: DevShowcaseIds.vefa,
        apartmentNumber: '1',
        residentName: 'Ayşe Demir',
        title: 'Asansör garip ses çıkarıyor',
        description:
            '3. kattan itibaren inerken metal sürtünme sesi duyuluyor.',
        category: TicketCategory.malfunction,
        status: TicketStatus.inProgress,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      TicketEntity(
        id: 'ticket_seed_2',
        apartmentId: 'vefa_a3',
        userId: 'r_vefa_3',
        buildingId: DevShowcaseIds.vefa,
        apartmentNumber: '3',
        residentName: 'Zeynep Kaya',
        title: 'Merdiven aydınlatması yanmıyor',
        description: '2. kat merdiven lambası iki gündür yanmıyor.',
        category: TicketCategory.request,
        status: TicketStatus.open,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      TicketEntity(
        id: 'ticket_seed_3',
        apartmentId: 'lale_a8',
        userId: 'r_lale_8',
        buildingId: DevShowcaseIds.lale,
        apartmentNumber: '8',
        residentName: 'Cem Aydın',
        title: 'Interkom çalışmıyor',
        description: 'Daire içi interkom ses vermiyor.',
        category: TicketCategory.malfunction,
        status: TicketStatus.open,
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
    ]);
  }

  @override
  Future<PaginatedListResult<TicketEntity>> getMyTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? cursor,
    bool paginated = true,
  }) async {
    await Future.delayed(_delay);
    var list = List<TicketEntity>.from(_tickets);
    if (status != null) list = list.where((t) => t.status == status).toList();
    if (category != null) {
      list = list.where((t) => t.category == category).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return PaginatedListResult(items: list);
  }

  @override
  Future<PaginatedListResult<TicketEntity>> getBuildingTickets(
    String buildingId, {
    TicketStatus? status,
    TicketCategory? category,
    String? cursor,
    bool paginated = true,
  }) async {
    await Future.delayed(_delay);
    var list = _tickets.where((t) => t.buildingId == buildingId).toList();
    if (status != null) list = list.where((t) => t.status == status).toList();
    if (category != null) {
      list = list.where((t) => t.category == category).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return PaginatedListResult(items: list);
  }

  @override
  Future<TicketEntity> getTicketById(String ticketId) async {
    await Future.delayed(_delay);
    return _tickets.firstWhere(
      (t) => t.id == ticketId,
      orElse: () => throw ApiException(message: 'ticket_not_found'),
    );
  }

  @override
  Future<TicketEntity> addManagerUpdate({
    required String ticketId,
    required String message,
  }) async {
    await Future.delayed(_delay);
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx < 0) throw ApiException(message: 'ticket_not_found');
    final old = _tickets[idx];
    final update = TicketUpdateEntity(
      id: MockState.nextId('tup'),
      ticketId: ticketId,
      message: message,
      fromRole: 'MANAGER',
      createdAt: DateTime.now(),
    );
    _tickets[idx] = TicketEntity(
      id: old.id,
      apartmentId: old.apartmentId,
      userId: old.userId,
      title: old.title,
      description: old.description,
      category: old.category,
      status: old.status,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
      apartmentNumber: old.apartmentNumber,
      buildingId: old.buildingId,
      residentName: old.residentName,
      residentPhone: old.residentPhone,
      residentEmail: old.residentEmail,
      residentProfilePicture: old.residentProfilePicture,
      creatorName: old.creatorName,
      attachmentUrl: old.attachmentUrl,
      updates: [...old.updates, update],
    );
    return _tickets[idx];
  }

  @override
  Future<TicketEntity> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
  }) async {
    await Future.delayed(_delay);
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx < 0) throw ApiException(message: 'ticket_not_found');
    final old = _tickets[idx];
    _tickets[idx] = TicketEntity(
      id: old.id,
      apartmentId: old.apartmentId,
      userId: old.userId,
      title: old.title,
      description: old.description,
      category: old.category,
      status: status,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
      apartmentNumber: old.apartmentNumber,
      buildingId: old.buildingId,
      residentName: old.residentName,
      residentPhone: old.residentPhone,
      residentEmail: old.residentEmail,
      residentProfilePicture: old.residentProfilePicture,
      creatorName: old.creatorName,
      attachmentUrl: old.attachmentUrl,
      updates: old.updates,
    );
    return _tickets[idx];
  }

  @override
  Future<TicketEntity> createTicket({
    required String apartmentId,
    required String title,
    required String description,
    required TicketCategory category,
    Uint8List? attachmentBytes,
    String? attachmentFilename,
  }) async {
    await Future.delayed(_delay);
    final now = DateTime.now();
    final entity = TicketEntity(
      id: MockState.nextId('ticket'),
      apartmentId: apartmentId,
      userId: MockAuthRepository._devResident.id,
      title: title.trim(),
      description: description.trim(),
      category: category,
      status: TicketStatus.open,
      createdAt: now,
      updatedAt: now,
    );
    _tickets.insert(0, entity);
    return entity;
  }
}
