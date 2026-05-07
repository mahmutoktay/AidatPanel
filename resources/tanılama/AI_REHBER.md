# AidatPanel — AI Geliştirici Rehberi

**Versiyon:** 1.0  
**Tarih:** 2026-05-07  
**Hedef:** Bu projeyle çalışacak her AI asistanının (Claude, Gemini, GPT, vb.) hata yapmadan katkı sağlaması için gereken bilgileri içerir.

---

## 1. Proje Kimliği

AidatPanel, Türk apartman ve site yöneticileri için geliştirilmiş bir Flutter mobil uygulamasıdır. Yöneticiler binaları ve aidatları yönetir; sakinler kendi ödeme durumlarını görür.

- **Platform:** Flutter (iOS + Android)
- **Backend:** Node.js + Express + Prisma + PostgreSQL
- **API:** `https://api.aidatpanel.com/api/v1`
- **Geliştirici:** Furkan (tek kişi)
- **Ana Branch:** `mobile/app` → PR hedefi: `main`
- **Flutter Root:** `C:\AidatPanel\mobile\` (pubspec.yaml buradadır)
- **Dil:** Türkçe birincil, İngilizce ikincil (i18n hazır)

---

## 2. Klasör Yapısı

```
C:\AidatPanel\
├── mobile/                    # Flutter uygulaması — TÜM DART KODU BURADA
│   ├── lib/
│   │   ├── core/              # Paylaşılan altyapı
│   │   │   ├── constants/     # AppConstants, ApiConstants
│   │   │   ├── network/       # DioClient, ApiException
│   │   │   ├── router/        # GoRouter config
│   │   │   ├── storage/       # SecureStorage
│   │   │   ├── theme/         # AppColors, AppSizes, AppTypography
│   │   │   ├── providers/     # locale_provider
│   │   │   └── utils/         # input_validators
│   │   ├── features/          # Feature modülleri (Clean Architecture)
│   │   │   ├── auth/          # ✅ Tam
│   │   │   ├── buildings/     # ✅ Tam
│   │   │   ├── apartments/    # ✅ Tam
│   │   │   ├── dues/          # Boş (scaffold hazır)
│   │   │   ├── dashboard/     # Boş (scaffold hazır)
│   │   │   ├── notifications/ # Boş
│   │   │   ├── expenses/      # Boş
│   │   │   ├── tickets/       # Boş
│   │   │   ├── reports/       # Boş
│   │   │   └── subscription/  # Boş
│   │   ├── shared/            # Paylaşılan widget'lar ve utility'ler
│   │   └── l10n/              # i18n dosyaları (Slang)
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
└── resources/                 # Dokümantasyon (kod değil)
    ├── AIDATPANEL.md          # Kapsamlı proje referansı
    ├── GOREVDAGILIMI.md       # Görev dağılımı (eski, referans amaçlı)
    ├── yol-haritası/
    │   └── YOL_HARITASI.md    # Güncel geliştirme yol haritası
    ├── tanılama/
    │   └── AI_REHBER.md       # Bu dosya
    └── prompt/                # AI prompt dosyaları (değiştirme)
```

---

## 3. Clean Architecture Kuralları

Her `features/xxx/` modülü şu katmanlara ayrılır:

```
features/xxx/
├── domain/
│   ├── entities/         # Saf Dart sınıfları, Equatable extend eder
│   ├── repositories/     # Soyut interface (abstract class)
│   └── usecases/         # (opsiyonel) İş mantığı adımları
├── data/
│   ├── datasources/      # RemoteDataSource — Dio çağrıları burada
│   ├── models/           # JSON model'ler (Freezed + json_serializable)
│   └── repositories/     # Repository implementasyonu
└── presentation/
    ├── screens/          # Flutter Widget'ları (ekranlar)
    ├── widgets/          # Ekrana özel küçük widget'lar
    └── providers/        # Riverpod StateNotifier + Provider tanımları
```

### Katman Kuralları

- **Domain katmanı** Flutter veya Dio'yu import edemez — saf Dart
- **Data katmanı** sadece domain'deki abstract repo'yu implemente eder
- **Presentation katmanı** sadece provider üzerinden data'ya erişir, doğrudan datasource çağırmaz
- Entity'ler `Equatable` extend eder (`props` listesi zorunlu)
- Model'ler `Freezed` + `@JsonSerializable` ile üretilir

### Referans: Çalışan Örnek

Auth feature'ın tam implementasyonu referans alınabilir:
- Entity: `mobile/lib/features/auth/domain/entities/user_entity.dart`
- Model: `mobile/lib/features/auth/data/models/login_response.dart`
- DataSource: `mobile/lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Repository: `mobile/lib/features/auth/data/repositories/auth_repository_impl.dart`
- Provider + Notifier: `mobile/lib/features/auth/presentation/providers/auth_provider.dart`
- Screen: `mobile/lib/features/auth/presentation/screens/login_screen.dart`

---

## 4. Riverpod Kod Kalıpları

Bu projede Riverpod 2.5 kullanılıyor. `@riverpod` annotation değil, manuel `StateNotifierProvider` pattern'i kullanılıyor.

### State sınıfı
```dart
// Freezed ile
@freezed
class DuesState with _$DuesState {
  const factory DuesState({
    @Default(false) bool isLoading,
    @Default([]) List<DueEntity> dues,
    String? error,
  }) = _DuesState;
}
```

### Notifier
```dart
class DuesNotifier extends StateNotifier<DuesState> {
  final DuesRepository _repository;

  DuesNotifier(this._repository) : super(const DuesState());

  Future<void> loadDues(String buildingId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dues = await _repository.getBuildingDues(buildingId);
      state = state.copyWith(isLoading: false, dues: dues);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }
}
```

### Provider tanımı
```dart
final duesRepositoryProvider = Provider<DuesRepository>((ref) {
  final dataSource = ref.watch(duesRemoteDataSourceProvider);
  return DuesRepositoryImpl(dataSource);
});

final duesNotifierProvider = StateNotifierProvider<DuesNotifier, DuesState>((ref) {
  final repository = ref.watch(duesRepositoryProvider);
  return DuesNotifier(repository);
});
```

### Screen'de kullanım
```dart
class DuesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(duesNotifierProvider);
    
    if (state.isLoading) return const CircularProgressIndicator();
    if (state.error != null) return Text(state.error!);
    
    return ListView.builder(
      itemCount: state.dues.length,
      itemBuilder: (context, index) => DueTile(due: state.dues[index]),
    );
  }
}
```

---

## 5. API Entegrasyon Kalıbı

### DioClient kullanımı

Asla `Dio()` direkt oluşturma. Her zaman `dioClientProvider` kullan:

```dart
final duesRemoteDataSourceProvider = Provider<DuesRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DuesRemoteDataSourceImpl(dioClient);
});
```

### DataSource implementasyonu

```dart
class DuesRemoteDataSourceImpl implements DuesRemoteDataSource {
  final DioClient _client;
  DuesRemoteDataSourceImpl(this._client);

  @override
  Future<List<DueModel>> getBuildingDues(String buildingId) async {
    final response = await _client.get(
      ApiConstants.buildingDues(buildingId),
    );
    final List<dynamic> data = response.data['data'];
    return data.map((json) => DueModel.fromJson(json)).toList();
  }
}
```

### Endpoint sabitlerini nereden al

Tüm endpoint'ler `mobile/lib/core/constants/api_constants.dart` içinde tanımlı. Yeni endpoint eklerken MUTLAKA bu dosyaya ekle, string'i datasource içine gömme.

```dart
// api_constants.dart içine ekle
static String buildingDues(String id) => '$_base/buildings/$id/dues';
static String dueStatus(String id) => '$_base/dues/$id/status';
```

### Hata yakalama

Catch bloğunda `ApiException` kullan, genel `Exception` değil:

```dart
} on ApiException catch (e) {
  state = state.copyWith(error: e.message);
} on DioException catch (e) {
  state = state.copyWith(error: 'Bağlantı hatası. Lütfen tekrar deneyin.');
}
```

---

## 6. i18n Kullanım Kuralları

Bu proje **Slang** kullanıyor (ARB değil, flutter_localizations değil).

### Dil dosyaları
- `mobile/lib/l10n/strings_tr.i18n.json` — Türkçe (base)
- `mobile/lib/l10n/strings_en.i18n.json` — İngilizce

### Yeni string ekleme adımları

1. Her iki JSON dosyasına aynı key'i ekle
2. `flutter pub run build_runner build` ile `strings.g.dart`'ı yeniden üret
3. Kodda `context.t.keyName` ile kullan

### Kullanım

```dart
// context.t.xxx formatı — BUNU KULLAN
Text(context.t.features.dues.title)
Text(context.t.common.loading)

// String'i doğrudan kodun içine gömme — BUNU YAPMA
Text('Aidat Listesi') // YANLIŞ
```

### JSON yapısı

```json
{
  "common": {
    "loading": "Yükleniyor...",
    "error": "Bir hata oluştu"
  },
  "features": {
    "dues": {
      "title": "Aidat Listesi",
      "paid": "Ödendi",
      "pending": "Bekliyor"
    }
  }
}
```

---

## 7. Güvenlik Gereksinimleri

Bu kuralları HİÇBİR ZAMAN ihlal etme:

### Token yönetimi
- Token'ları ASLA `SharedPreferences` veya local file'a yazma
- Her zaman `SecureStorage` kullan: `mobile/lib/core/storage/secure_storage.dart`
- Token'ı `print()` veya `debugPrint()` ile loglama

### Loglama
```dart
// DOĞRU — sadece debug modda logla
if (kDebugMode) {
  print('Debug bilgisi: $bilgi');
}

// YANLIŞ — prodda da loglar
print('Token: $accessToken'); // asla yapma
LogInterceptor(); // kDebugMode koşulsuz ekleme
```

### Hata mesajları
```dart
// DOĞRU — kullanıcıya sade mesaj
state = state.copyWith(error: e.message); // ApiException.message Türkçe

// YANLIŞ — teknik detay gösterme
state = state.copyWith(error: e.toString()); // stack trace sızdırır
```

### Cleartext HTTP
- API çağrısı her zaman HTTPS olmalı
- `http://` ile başlayan URL hiç kullanma
- `network_security_config.xml` cleartext kapalı, değiştirme

---

## 8. Tasarım Kısıtları (50+ Yaş Kullanıcılar)

Bu kısıtlar zorunludur, ihlal etme:

| Kısıt | Kural | Kontrol Yeri |
|-------|-------|--------------|
| Font boyutu | Minimum 16sp | `AppTypography` değerleri |
| Dokunma alanı | Minimum 48×48dp | Her buton/ikon/liste öğesi |
| Navigasyon | Bottom Navigation Bar | Hamburger menü asla kullanma |
| Renk kontrastı | Koyu metin, açık arka plan | `AppColors` |
| Loading state | Her async işlemde görünür | CircularProgressIndicator |
| Hata gösterimi | Toast veya snackbar (teknik terim yok) | `ToastOverlay` widget'ı |

```dart
// DOĞRU — yeterli dokunma alanı
InkWell(
  onTap: () {},
  child: Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(context.t.common.confirm, style: AppTypography.body1), // 16sp+
  ),
)

// YANLIŞ — çok küçük
IconButton(iconSize: 20, onPressed: () {}, icon: Icon(Icons.delete)) // 20px küçük
```

---

## 9. YAPMA Listesi — Sık Yapılan Hatalar

### Mimari hatalar
- Presentation katmanından direkt `DataSource` çağırma (Provider üzerinden git)
- Domain entity'ye `fromJson` / `toJson` ekleme (bu Model'ın işi)
- `StatefulWidget` içinde Riverpod kullanmak için `ConsumerStatefulWidget` yerine `StatefulWidget` + `ProviderContainer` açma

### Performans hataları
- `ListView.children` ile uzun liste render etme → `ListView.builder` kullan
- Provider'da `autoDispose` olmadan büyük state tutma
- `ref.read` yerine `ref.watch` kullanarak gereksiz rebuild tetikleme

### API hataları
- Endpoint URL'ini datasource içine string olarak gömmek (`ApiConstants` kullan)
- Response parsing'de `response.data` yerine `response.data['data']` demeyi unutmak
  - API yanıt formatı: `{ "success": true, "message": "...", "data": {...} }`
- 401 hatalarını elle ele almaya çalışmak (DioClient interceptor halleder)

### i18n hataları
- Hardcoded Türkçe string UI'a yazmak
- Sadece bir dil dosyasını güncellemek (her ikisi birlikte güncellenmeli)
- `build_runner` çalıştırmadan `strings.g.dart`'ın güncellendiğini sanmak

### Git hataları
- Doğrudan `main`'e push etmek (her zaman `mobile/app`'te çalış, PR ile main'e geç)
- `--no-verify` ile hook'u atlamak

---

## 10. Sıradaki Özellik: Dues (Aidat) Modülü

Şu an en öncelikli iş `features/dues/` modülünün sıfırdan yazılması.

### Başlangıç noktası
1. `mobile/lib/features/auth/` klasörünü referans al — aynı pattern
2. `mobile/lib/core/constants/api_constants.dart` içinde dues endpoint'leri zaten tanımlı
3. Entity → Model → DataSource → Repository → Notifier → Screen sırasıyla yaz

### İlgili API endpoint'leri (api_constants.dart'ta mevcut)
```
GET  /buildings/{id}/dues         → bina aidat listesi
GET  /apartments/{id}/dues        → daire aidat listesi
GET  /me/dues                     → sakin kendi aidatları
PATCH /dues/{id}/status           → ödeme durumu güncelle
POST /buildings/{id}/dues/bulk    → toplu aidat oluştur
```

### Model alanları (backend şemasından)
```dart
@freezed
class DueEntity with _$DueEntity {
  const factory DueEntity({
    required String id,
    required String buildingId,
    required String apartmentId,
    required double amount,
    required DateTime dueDate,
    required String status,       // 'PAID' | 'PENDING' | 'OVERDUE'
    DateTime? paidAt,
    String? description,
  }) = _DueEntity;
}
```

---

## 11. Faydalı Referanslar

| Ne aradığın | Nereye bak |
|-------------|------------|
| Tüm API endpoint'leri | `mobile/lib/core/constants/api_constants.dart` |
| HTTP client + interceptor | `mobile/lib/core/network/dio_client.dart` |
| Token kaydetme/okuma | `mobile/lib/core/storage/secure_storage.dart` |
| Renk paleti | `mobile/lib/core/theme/app_colors.dart` |
| Font boyutları | `mobile/lib/core/theme/app_typography.dart` |
| Spacing/boyutlar | `mobile/lib/core/theme/app_sizes.dart` |
| Tüm Türkçe string'ler | `mobile/lib/l10n/strings_tr.i18n.json` |
| Route tanımları | `mobile/lib/core/router/app_router.dart` |
| Input validation | `mobile/lib/core/utils/input_validators.dart` |
| Toast gösterme | `mobile/lib/shared/widgets/toast_overlay.dart` |
| Tam feature örneği | `mobile/lib/features/auth/` (tüm katmanlar) |
| Proje genel bakış | `resources/AIDATPANEL.md` |
| Güncel yol haritası | `resources/yol-haritası/YOL_HARITASI.md` |

---

## 12. Build & Kod Üretme

Freezed model veya Slang dosyası değiştirdikten sonra MUTLAKA çalıştır:

```bash
# mobile/ klasöründen:
flutter pub run build_runner build --delete-conflicting-outputs
```

Çıktılar:
- `*.freezed.dart` — Freezed modeller
- `*.g.dart` — JSON serialization
- `lib/l10n/strings.g.dart` — i18n string'leri

Bu dosyalar `.gitignore`'a alınmamış, commit'e dahil edilmeli.

---

*Bu dosya AidatPanel projesinde çalışan AI asistanların referans noktasıdır. Projenin gerçek durumu değişirse bu dosyayı güncelle.*
