# AidatPanel — AI Asistan Kuralları

## OKUMA SIRASI (Her oturumun başında)

Her oturumda mutlaka okunacaklar:

1. Bu dosya (CLAUDE.md) — kurallar ve faz kapısı
2. `resources/FAZ_DURUMU.md` — aktif faz ve görev listesi

Göreve göre ek okuma:

| Görev türü | Okunacak dosya |
|------------|---------------|
| API / data layer / backend entegrasyonu | `resources/AIDATPANEL.md` |
| Ekran / widget / UI implementasyonu | `resources/tasarım/TASARIM_KILAVUZU.md` |

---

## ZORUNLU İLK ADIM

Her oturumun başında, herhangi bir Flutter dosyasına dokunmadan önce:

```
resources/FAZ_DURUMU.md dosyasını oku.
```

Bu adım atlanamaz. Dosyayı okumadan kod yazamazsın.

---

## FAZ KAPISI KURALLARI

### Aktif Faz Dışına Çıkma Yasağı

- Yalnızca `FAZ_DURUMU.md`'de **AKTİF** olarak işaretlenmiş fazın görevlerini yapabilirsin.
- Sonraki fazların `features/` klasörlerine dokunamazsın (okuma dahil kod üretme, refactor, yorum).
- Gelecek faz için "hazırlık" veya "altyapı" adı altında bile olsa kural geçerlidir.

### Faz Tamamlanma Koşulları (İKİSİ BİRDEN ZORUNLU)

Bir fazı tamamlanmış sayabilmek için `FAZ_DURUMU.md` içinde şunlar olmalı:

1. O faza ait tüm checklist öğeleri `[x]` işaretli olmalı
2. `ONAY: Furkan ✅` satırı mevcut olmalı

**Bu iki koşul sağlanmadan bir sonraki faza geçilemez. İstisna yok.**

### AI'ın Yapabileceği — Yapamayacağı

| Yapabilir | Yapamaz |
|-----------|---------|
| Mevcut faz görevlerini tamamla | `FAZ_DURUMU.md`'deki ONAY satırını kendisi yaz |
| Görev bitince Furkan'dan onay iste | Sonraki fazın dosyalarına doku |
| `FAZ_DURUMU.md`'deki checklist'i `[x]` yap | Faz geçişini Furkan onaysız ilan et |
| Mimari ve teknik borç sorularını yanıtla | Faz atlayarak ilerideki feature'ı kur |

---

## PROJE KURALLARI

### Mimari (Clean Architecture)

```
features/xxx/
├── domain/entities/       ← Saf Dart (Equatable, Flutter import yok)
├── domain/repositories/   ← Abstract interface
├── data/datasources/      ← Dio çağrıları
├── data/models/           ← Freezed + JSON serialization
├── data/repositories/     ← Repository impl
└── presentation/
    ├── screens/           ← Flutter Widget
    ├── widgets/           ← Ekrana özel widget
    └── providers/         ← Riverpod StateNotifier
```

**Katman kuralları:**
- `entity` → `fromJson` / `toJson` içeremez (bu model'in işi)
- `presentation` → `datasource`'u direkt çağıramaz (provider üzerinden)
- `ListView.children` kullanılamaz → `ListView.builder` kullanılacak
- Referans implementasyon: `mobile/lib/features/auth/` (tüm katmanlar eksiksiz)

### Riverpod Pattern (StateNotifier)

`@riverpod` annotation kullanılmıyor — manuel `StateNotifierProvider` pattern:

```dart
// 1. State (Freezed)
@freezed
class DuesState with _$DuesState {
  const factory DuesState({
    @Default(false) bool isLoading,
    @Default([]) List<DueEntity> dues,
    String? error,
  }) = _DuesState;
}

// 2. Notifier
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

// 3. Provider
final duesNotifierProvider = StateNotifierProvider<DuesNotifier, DuesState>((ref) {
  return DuesNotifier(ref.watch(duesRepositoryProvider));
});

// 4. Screen
class DuesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(duesNotifierProvider);
    if (state.isLoading) return const CircularProgressIndicator();
    if (state.error != null) return Text(state.error!);
    return ListView.builder(
      itemCount: state.dues.length,
      itemBuilder: (_, i) => DueTile(due: state.dues[i]),
    );
  }
}
```

### API / DataSource Pattern

API yanıt formatı her zaman: `{ "success": true, "message": "...", "data": {...} }`

```dart
// DataSource
class DuesRemoteDataSourceImpl implements DuesRemoteDataSource {
  final DioClient _client;
  DuesRemoteDataSourceImpl(this._client);

  @override
  Future<List<DueModel>> getBuildingDues(String buildingId) async {
    final response = await _client.get(ApiConstants.buildingDues(buildingId));
    final List<dynamic> data = response.data['data']; // response.data değil!
    return data.map((json) => DueModel.fromJson(json)).toList();
  }
}

// Provider (Dio direkt new'leme — asla)
final duesRemoteDataSourceProvider = Provider<DuesRemoteDataSource>((ref) {
  return DuesRemoteDataSourceImpl(ref.watch(dioClientProvider));
});
```

Yeni endpoint → `mobile/lib/core/constants/api_constants.dart`'a ekle, datasource'a string gömme.

### Tasarım (50+ yaş kullanıcılar — ZORUNLU)

- Minimum font: **16sp** (`AppTypography` değerlerine bak)
- Minimum dokunma alanı: **48×48dp**
- Hamburger menü **yasak** → Bottom Navigation Bar
- Her async işlemde görünür **loading indicator**
- Hata mesajları **sade Türkçe** (teknik terim yok)
- Animasyon: max **200ms**, `Curves.easeInOut` — Lottie / Hero yasak

### Kod Standartları

- Geri tuşu / “çift geri çıkış” / kök ekranda çıkış: **`WillPopScope` kullanılmaz** → **`PopScope`** (`canPop` + `onPopInvokedWithResult`). Güncel Android geri hattı (predictive back) ve Flutter önerisiyle uyumlu.
- String literaller UI'a yazılamaz → `context.t.xxx` ile i18n
- i18n eklemek için: her iki JSON dosyasını güncelle → `flutter pub run build_runner build --delete-conflicting-outputs`
- Token'lar loglanamaz, `SharedPreferences`'a yazılamaz (sadece `SecureStorage`)
- `LogInterceptor` yalnızca `kDebugMode`'da aktif
- 401 hataları DioClient interceptor'ı halleder — elle yakalama
- `response.data['data']` → liste parse edilirken bu katmana in

---

## REFERANS DOSYALAR

| Amaç | Dosya |
|------|-------|
| Canlı faz durumu | `resources/FAZ_DURUMU.md` |
| Tam yol haritası | `resources/yol-haritası/YOL_HARITASI.md` |
| API şeması, backend, kullanıcı rolleri | `resources/AIDATPANEL.md` |
| Ekran layout, widget'lar, renkler | `resources/tasarım/TASARIM_KILAVUZU.md` |
| Tam feature örneği | `mobile/lib/features/auth/` |
