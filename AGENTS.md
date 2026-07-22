# AidatPanel — Project Skills & Context (Machine-Readable Profile)

*Target LLM: Autonomous AI Agent (Implementation-capable)*
*Source Material: `FAZ_DURUMU.md` (tek kaynak), `AIDATPANEL.md`, `backend/README.md`, Codebase Analysis*
*Son güncelleme: 2026-07-22*

---

## 0. Dokümantasyon Hiyerarşisi ve Senkronizasyon (ZORUNLU)

AI ajanı her oturumda dokümantasyonu **güncel tutmakla** yükümlüdür. Kod değişikliği yapıldığında ilgili dokümanlar **aynı oturumda** güncellenir; ayrı talep beklenmez.

### 0.1 Tek Kaynaklar (Source of Truth)

| Dosya | Rol | Ne zaman güncellenir |
|-------|-----|----------------------|
| `resources/yol-haritası/FAZ_DURUMU.md` | Faz durumu, checklist, onaylar, teknik borç | Görev tamamlanınca, faz değişince, onay alınınca |
| `resources/AIDATPANEL.md` | API sözleşmesi, şema, roller, deployment | Yeni/değişen endpoint, model, env, deploy adımı |
| `AGENTS.md` | AI ajan profili (özet + kurallar) | Mimari, stack, faz, feature veya kural değişince |
| `backend/README.md` | Backend geliştirme notları | Backend kurulum, script, env değişince |
| `backend/.env.example` | Ortam değişkeni şablonu | Yeni `process.env` anahtarı eklenince |

### 0.2 Oturum Başlangıcı Kontrol Listesi

```
1. resources/yol-haritası/FAZ_DURUMU.md dosyasını OKU (aktif fazları belirle).
2. AGENTS.md §5 ile FAZ_DURUMU.md faz tablosunu karşılaştır; uyumsuzluk varsa AGENTS.md'yi düzelt.
3. Yapılacak işin kapsamı API/model içeriyorsa resources/AIDATPANEL.md'yi kontrol et.
```

### 0.3 Oturum Sonu Senkronizasyon Kuralları

Aşağıdaki değişikliklerden **herhangi biri** yapıldıysa ilgili dokümanlar güncellenir:

| Değişiklik türü | Güncellenecek dosyalar |
|-----------------|------------------------|
| Faz görevi tamamlandı / yeni görev | `FAZ_DURUMU.md` |
| Yeni API endpoint / Prisma model / enum | `AIDATPANEL.md`, gerekirse `api_constants.dart` |
| Yeni `mobile/lib/features/` modülü | `AGENTS.md` §3.2, `FAZ_DURUMU.md` |
| Paket versiyonu (`pubspec.yaml` / `package.json`) | `AGENTS.md` §2 |
| Yeni env değişkeni | `backend/.env.example`, `AIDATPANEL.md` |
| Deploy / PM2 / sunucu yolu değişikliği | `AGENTS.md` §6.2, `AIDATPANEL.md`, `deploy.config.example.json` |
| Mimari pattern değişikliği | `AGENTS.md` §3, referans implementasyon §6.9 |
| Test sayısı anlamlı değişti (`npm test`) | `AGENTS.md` §2.1, `FAZ_DURUMU.md` teknik borç tablosu |

### 0.4 AGENTS.md Güncelleme Tetikleyicileri

`AGENTS.md` şu durumlarda **mutlaka** güncellenir:
- Aktif faz sayısı veya faz kapsamı değiştiğinde
- `mobile/lib/features/` altına yeni klasör eklendiğinde veya yeniden adlandırıldığında
- Riverpod, deploy, i18n veya faz kapısı kuralları değiştiğinde
- Backend kritik servis listesi genişlediğinde

> **Kural:** Dokümantasyon güncellemesi "sonra yapılır" diye ertelenmez; kod PR/commit ile birlikte aynı oturumda tamamlanır.

---

## 1. Proje Topolojisi ve Özeti

- **Proje Amacı:** Türk apartman/site yöneticileri için mobil aidat yönetim platformu. Aidat, gider, tahsilat (dekont/OCR) ve arıza bildirim (ticket) süreçlerini dijitalleştirir. Multi-tenant desteklidir.
- **Hedef Kitle:** 50+ yaş apartman yöneticileri ve sakinleri. Tüm UI/UX kararları bu kullanıcı kitlesine uyarlanmıştır.
- **Kullanıcı Rolleri (RBAC):** `MANAGER` (Yönetici - abonelik kısıtlamalarına tabi) ve `RESIDENT` (Sakin - sadece kendi dairesi).
- **Abonelik Sistemi:** RevenueCat ile yönetilen aylık/yıllık abonelik. `aidatpanel_monthly` (₺99/ay) ve `aidatpanel_annual` (₺799/yıl). Kota: **toplam bina sayısı** (site altı bloklar dahil).
- **Topoloji:**
  - **Backend:** Node.js + Express RESTful API + WebSocket Realtime servisi.
 - **Mobile:** Flutter uygulaması (iOS & Android). Güncel sürüm: `0.6.13+2000000016` (`pubspec.yaml`).
  - **Web:** Statik landing page (yardımcı araç, uygulamanın ana parçası değil).
  - **İletişim:** REST (JSON `{success, message, data}`) + WebSocket (`wss://api.aidatpanel.com/api/v1/realtime?token=JWT`) + FCM Push Notifications.
  - **Domain:** `aidatpanel.com` (Cloudflare). API: `api.aidatpanel.com` (Contabo VPS / CloudPanel reverse proxy, PM2 ile yönetiliyor).

---

## 2. Teknoloji Yığını (Tech Stack)

### 2.1 Backend Stack

| Kategori | Teknoloji | Versiyon | Açıklama |
|----------|-----------|----------|----------|
| Runtime | Node.js | 20+ | ES Modules (`type: "module"`) |
| Framework | Express.js | ^5.2.1 | REST API + middleware pipeline |
| ORM | Prisma | ^7.8.0 | Type-safe query builder, migration yönetimi |
| Veritabanı | PostgreSQL | 15+ | Neon serverless destekli (`@prisma/adapter-neon`, `@prisma/adapter-pg`) |
| Auth | JWT + bcryptjs | jsonwebtoken ^9.0.3, bcryptjs ^3.0.3 | Access 15dk, Refresh 30 gün, SHA-256 replay attack koruması |
| Güvenlik | helmet, cors, express-rate-limit | helmet ^8.0.0, cors ^2.8.5, rate-limit ^7.4.0 | 4 katmanlı rate limiting (hesap bazlı key) |
| Realtime | ws | ^8.18.0 | WebSocket server (JWT auth ile) |
| Push | firebase-admin | ^13.0.0 | FCM push bildirimleri |
| Dosya İşleme | multer, sharp, pdfjs-dist, pdfkit | multer ^2.1.1, sharp ^0.33.5, pdfjs-dist ^4.0.379, pdfkit ^0.16.0 | Multipart upload, image resize, PDF OCR + PDF üretimi |
| Validasyon | zod | ^3.23.8 | Request schema validation (route middleware) |
| Loglama | pino, pino-pretty | pino ^9.3.2, pino-pretty ^11.2.2 | Structured JSON logging (console.* yerine) |
| Test | jest, supertest | jest ^29.7.0, supertest ^7.0.0 | Backend unit test (~95+ test, 20+ suite — `npm test` ile doğrula) |
| Deploy | PM2, nodemon | — | Process manager + dev watcher |

### 2.2 Mobile Stack (Flutter)

| Kategori | Teknoloji | Versiyon | Açıklama |
|----------|-----------|----------|----------|
| SDK | Flutter + Dart | SDK ^3.11.5 | Cross-platform mobil uygulama |
| State Management | flutter_riverpod | ^3.3.1 | Manuel `Notifier` / `NotifierProvider` pattern (CodeGen kullanılmaz) |
| Navigation | go_router | ^17.3.0 | Deep link desteği, role-based routing |
| Network | dio, web_socket_channel | dio ^5.4.0, ws_channel ^3.0.2 | HTTP/HTTPS + WebSocket istemcisi |
| Güvenlik | flutter_secure_storage | ^10.3.1 | JWT token saklama (SecureStorage, SharedPreferences yasak) |
| i18n | slang + slang_flutter | ^4.15.0 | Type-safe TR/EN çeviri sistemi (Slang JSON) |
| Firebase | firebase_core, **firebase_auth** (sakin Phone Auth), firebase_messaging, firebase_analytics, firebase_crashlytics | firebase_core ^4.10.0, auth ^6.5.6, messaging ^16.3.0, analytics ^12.0.0, crashlytics ^5.0.0 | FCM push, sakin telefon doğrulama, analytics, crash reporting |
| Bildirim (yerel) | flutter_local_notifications, permission_handler | ^22.0.1, ^12.0.3 | Ön plan bildirim + izin yönetimi |
| Abonelik | purchases_flutter | ^10.2.3 | RevenueCat SDK entegrasyonu |
| UI/Utils | equatable, freezed, json_serializable, google_fonts, fl_chart, pdfx, cached_network_image, share_plus, image_picker, file_picker, intl, path_provider, crypto, receive_sharing_intent, gal, image, url_launcher, package_info_plus, device_info_plus | — | Entity modeling, grafik, PDF, dosya işleme, dekont paylaşımı |
| Build | build_runner, slang_build_runner, flutter_launcher_icons | build_runner ^2.12.2 | Freezed/JSON codegen + Slang + asset processing |
| Test | flutter_test, mocktail, integration_test | — | Unit, widget, integration test iskeleti |

---

## 3. Mimari Desenler (Architecture & Patterns)

### 3.1 Backend Mimari Deseni (Layered Service Architecture)

```
src/
├── routes/           # HTTP route tanımları, Zod validator middleware bağlantıları
├── controllers/      # İstek-yanıt döngüsü, asyncHandler ile hata yakalama
├── services/         # İş kuralları (SRP prensibi ile modüller ayrılmış)
│   ├── me/           # /me endpoint'lerine özel modüller (meProfileHelpers vb.)
│   ├── dekont*/      # Dekont pipeline: storage → OCR → verification → payment
│   ├── site*/        # Site CRUD, site gideri, kota, aggregation (FAZ 8)
│   ├── notification* # Bildirim dağıtımı: realtimeHub + FCM
│   └── ...
├── middlewares/      # Rate limit, auth (JWT), error handling
├── validators/       # Zod schema tanımları (feature bazlı modüller)
├── utils/            # asyncHandler, logger, verifyAccessToken vb.
├── config/           # logger.js, rate limit constants
├── realtime/         # WebSocket hub + gateway
├── workers/          # OCR worker thread
├── jobs/             # OVERDUE job, background tasks
└── scripts/          # notificationDemo, test scripts
```

**Veri Akışı:** `Route → Controller → Service → Prisma → PostgreSQL`

**Kritik Servis Modülleri:**
- `dueExpenseRecalcService.js` — Gider → aidat dağılımı yeniden hesaplama
- `dekontPipelineQueue.js` — Dekont işleme kuyruğu (upload → OCR → verification → business rules)
- `notificationDeliveryService.js` — WebSocket + FCM dual-channel delivery
- `reportDataService.js` + `reportPdfService.js` — PDF rapor üretimi (aylık + yıllık; bina + site)
- `meService.js` (ve `me/` alt modülleri) — Profil, dil, şifre işlemleri
- `siteService.js` — Site CRUD, site altı bina, effective config
- `siteExpenseService.js` + `siteExpenseAllocationService.js` — Site ortak gideri dairelere paylaştırma
- `siteAggregationService.js` — Site/bina toplanan/beklenen tutar özeti
- `buildingQuotaService.js` — Abonelik bina kotası (toplam bina sayımı)

### 3.2 Mobile Mimari Deseni (Feature-First Clean Architecture)

```
mobile/lib/
├── core/                      # Uygulama geneli paylaşılan kod
│   ├── constants/             # api_constants.dart, app_constants.dart
│   ├── theme/                 # app_theme.dart, app_colors.dart, app_typography.dart
│   ├── router/                # app_router.dart (GoRouter tanımları)
│   ├── network/               # dio_client.dart (interceptor, cert pinning), api_exception.dart
│   ├── storage/               # secure_storage.dart (flutter_secure_storage wrapper)
│   ├── utils/                 # date_utils.dart, currency_utils.dart
│   └── notifications/         # FCM + WebSocket + Polling coordinator
├── l10n/                      # Slang TR/EN i18n JSON dosyaları
├── features/                  # Feature-first yapı (referans: auth/)
│   ├── auth/                  # Giriş, kayıt, OTP, onboarding (sakin: telefon→Firebase Phone Auth→login|isim+davet; deep link `aidatpanel://join?code=`)
│   ├── dashboard/             # Manager + Resident dashboard; ManagerPropertiesTab (Siteler|Binalar)
│   ├── sites/                 # Site CRUD, site gideri, site raporu (FAZ 8)
│   ├── buildings/             # Bina CRUD, davet kodu, IBAN
│   ├── apartments/            # Daire CRUD + sakin atama
│   ├── dues/                  # Aidat listesi, filtreleme, durum güncelleme, breakdown
│   ├── expenses/              # Gider listesi + form + OCR makbuz
│   ├── tickets/               # Arıza/talep CRUD + update
│   ├── notifications/         # Bildirim listesi + detay sheet
│   ├── profile/               # Profil, şifre, dil, aktif oturumlar
│   ├── reports/               # PDF indirme + paylaşma (bina + site)
│   ├── dekont/                # Tahsilat dekontları (sakin + yönetici)
│   └── subscription/          # Abonelik ekranı + paywall
├── shared/
│   └── widgets/               # password_field.dart, empty_state_widget.dart, friendly_error_screen.dart vb.
└── main.dart / main_dev.dart  # Entry points (flavor: dev / prod)
```

**Katman Kuralları:**
- `domain/entities/` → Saf Dart (Equatable extend eder, Flutter widget veya `fromJson`/`toJson` barındıramaz).
- `domain/repositories/` → Abstract interface tanımları.
- `data/models/` → Freezed + json_serializable DTO'lar. `.toEntity()` metodu içerir.
- `data/datasources/` → Dio çağrıları. Response `response.data['data']` katmanından çözümlenir.
- `data/repositories/` → Domain interface implementasyonları.
- `presentation/` → Screens, widgets, Riverpod provider'ları. **DATASOURCE'A DOĞRUDAN ERİŞEMEZ** (provider üzerinden erişir).

### 3.3 Riverpod Pattern (Manuel NotifierProvider — CodeGen KULLANILMAZ)

> `StateNotifier` / `StateNotifierProvider` **kullanılmaz** — Riverpod 3.x `Notifier` / `NotifierProvider` standardıdır (FAZ 5 migrasyonu tamamlandı).

```dart
// 1. State (immutable sınıf veya Freezed)
class DuesState {
  final bool isLoading;
  final List<DueEntity> dues;
  final String? error;
  const DuesState({this.isLoading = false, this.dues = const [], this.error});
  DuesState copyWith({bool? isLoading, List<DueEntity>? dues, String? error}) => ...;
}

// 2. Notifier
class DuesNotifier extends Notifier<DuesState> {
  DuesRepository get _repository => ref.read(duesRepositoryProvider);

  @override
  DuesState build() => const DuesState();

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
final duesNotifierProvider = NotifierProvider<DuesNotifier, DuesState>(
  DuesNotifier.new,
);

// 4. Screen
class DuesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(duesNotifierProvider);
    // ...
  }
}
```

**Referans:** `mobile/lib/features/dues/presentation/providers/dues_provider.dart`, `mobile/lib/features/auth/presentation/providers/auth_provider.dart`

### 3.4 Dekont (Banka Dekontu) Pipeline Mimarisi

```
Resident Upload → DekontStorageService (multer, hash duplicate check)
                → dekontOcrRunner / expenseOcrService (pdfjs-dist, Tesseract)
                → dekontVerificationService (IBAN, referans no, tutar eşleştirme)
                → dekontBusinessRulesService (MATCHED / NEEDS_REVIEW / REJECTED)
                → dekontPaymentService (DuePayment oluşturma)
                → dekontNotificationService (FCM push)
```

**Dekont Durumları (DekontStatus enum):** RECEIVED → EXTRACTING → (EXTRACT_FAILED | PARSED | PARSE_LOW_CONFIDENCE) → MATCHING → (MATCHED | MATCH_AMBIGUOUS | UNMATCHED | NEEDS_MANAGER_REVIEW) → (PAYMENT_APPLIED | PAYMENT_PARTIAL | REJECTED | RECIPIENT_MISMATCH)

### 3.5 Site Yönetimi Mimarisi (FAZ 8)

```
Site (varsayılan aidat, IBAN, adres)
  └── Building[] (blockLabel zorunlu, site varsayılanlarını inherit/override eder)
        └── Apartment[] → Due[]

SiteExpense → siteExpenseAllocationService → tüm site dairelerine eşit pay (perUnitAmount)
            → dueExpenseRecalcService → DueExpenseCarryforward (siteExpenseId?)

Abonelik kotası: buildingQuotaService → toplam bina sayısı (tekil + site altı bloklar)
```

**Mobil giriş noktaları:** `features/sites/`, `dashboard/ManagerPropertiesTab` (Siteler | Binalar sekmeleri), genişleyen FAB (Yeni Site / Yeni Bina).

---

## 4. Bağımlılık Ağacı ve 3. Parti Servisler

### Backend Bağımlılıkları

| Paket | Çözdüğü Problem |
|-------|----------------|
| `@prisma/client`, `@prisma/adapter-neon`, `@prisma/adapter-pg` | Type-safe veritabanı erişimi, migration yönetimi, Neon serverless destek |
| `jsonwebtoken` + `bcryptjs` | JWT tabanlı auth (access/refresh) + şifre hash |
| `express-rate-limit` | API rate limiting (4 katmanlı: global, auth, sensitive, upload) |
| `firebase-admin` | FCM push bildirimleri (açık/kapalı app için) |
| `ws` | WebSocket realtime hub (notification broadcast) |
| `multer` + `sharp` + `file-type` | Multipart file upload + thumbnail/image processing + MIME doğrulama |
| `pdfjs-dist` | PDF'ten metin çıkarma (OCR pipeline) |
| `pdfkit` | Aylık/yıllık aidat raporu PDF üretimi |
| `zod` | Request validation schema (Zod → route middleware) |
| `pino` | Structured JSON logging (production-grade) |
| `helmet` + `cors` + `cookie-parser` | Security headers + CORS whitelist + cookie parsing |
| `pg` | PostgreSQL driver (Prisma adapter ile) |

### Mobil Bağımlılıkları

| Paket | Çözdüğü Problem |
|-------|----------------|
| `flutter_riverpod` | State management (`NotifierProvider` pattern) |
| `go_router` | Deep-link destekli navigation |
| `dio` | HTTP/HTTPS istemcisi (certificate pinning, interceptor) |
| `flutter_secure_storage` | JWT token güvenli saklama (Keychain/Keystore) |
| `slang` + `slang_flutter` | Type-safe TR/EN i18n (`dart run slang` ile codegen) |
| `web_socket_channel` | WebSocket realtime notification (app açıkken) |
| `firebase_messaging` + `flutter_local_notifications` | FCM push + ön plan bildirim |
| `permission_handler` | Bildirim ve medya izinleri |
| `purchases_flutter` | RevenueCat iOS/Android abonelik entegrasyonu |
| `freezed` + `json_serializable` | Immutable entity + DTO modeling + JSON serialization |
| `fl_chart` | Dashboard özet grafikleri |
| `pdfx` | PDF raporu görüntüleme |
| `share_plus` | PDF raporu paylaşma |
| `receive_sharing_intent` + `gal` | Dekont paylaşım intent'i + galeri kaydetme |
| `file_picker` + `image_picker` | Dekont yükleme + makbuz fotoğrafı seçimi |
| `google_fonts` | Nunito fontu (yaşlı kullanıcılar için okunabilirlik) |

### 3. Parti Servisler

| Servis | Amaç |
|--------|------|
| RevenueCat | iOS/Android in-app subscription, receipt validation, webhook |
| Firebase Admin SDK | FCM push notification gönderimi |
| Resend | İşlemsel e-postalar (şifre sıfırlama) |
| Twilio / NetGsm | Şifre sıfırlama SMS (sakin telefon OTP Firebase Auth Phone) |
| Cloudflare | DNS + CDN (aidatpanel.com) |
| CloudPanel | Reverse proxy + SSL (api.aidatpanel.com → VPS port 4200) |
| Contabo VPS | Sunucu alanı (`aidapanel-api` PM2 süreci) |

---

## 5. Gelecek Vizyonu ve Roadmap

> **Tek kaynak:** `resources/yol-haritası/FAZ_DURUMU.md` — bu bölüm özet niteliğindedir; çelişki durumunda FAZ_DURUMU.md geçerlidir.

### Aktif Fazlar

#### FAZ 7 — v1.0.0 Lansman (▶ AKTİF, hedef ~2026-07-14)

| Görev | Durum |
|-------|-------|
| App Store & Google Play submit | Bekliyor |
| Landing page güncelleme | Bekliyor |
| Firebase Analytics & Crashlytics | ✅ Tamamlandı |
| v1.0.0 release tag | Bekliyor |

#### FAZ 8 — Site Yönetimi (▶ AKTİF, hedef ~2026-08)

Site → bina hiyerarşisi; tekil binalar korunur. Backend ve mobil implementasyon büyük ölçüde tamamlandı.

| Görev | Durum |
|-------|-------|
| Backend: Site/SiteExpense modelleri + API + servisler | ✅ Tamamlandı |
| Mobil: `features/sites/` + ManagerPropertiesTab + FAB | ✅ Tamamlandı |
| Mevcut modül güncellemeleri (BuildingEntity, davet, IBAN, abonelik özeti) | ✅ Tamamlandı |
| Canlı E2E: site → blok → ortak gider → breakdown → site PDF | Bekliyor |
| `ONAY: Furkan ✅` | Bekliyor |

**FAZ 0–6:** Kilitli ve onaylı. Yalnızca aktif faz checklist'lerinde `[ ]` kalan görevlere odaklan.

### Teknik Borçlar (Bilinen Eksikler)

| # | Konu | Platform | Öncelik | Açıklama |
|---|------|----------|---------|----------|
| 1 | Test kapsamı %30+ | Mobil | 🟡 | Auth/Dio/widget testleri var; genişletilecek |
| 2 | OCR performansı | Backend | 🟡 | Worker thread kısmi; kuyruk sistemi ölçeklenmeli |
| 3 | FAZ 8 canlı E2E | Fullstack | 🟡 | Site akışı uçtan uca doğrulanacak |
| 4 | Online ödeme | Fullstack | 🔴 | İyzico/PayTR sanal POS (Faz 9+) |
| 5 | Multi-manager | Backend | 🔴 | Personel atama sistemi (Faz 9+) |
| 6 | Aidat geçmişi trend grafikleri | Mobil | 🟡 | Dashboard'da özet grafik var; geçmiş trend/istatistik genişletilecek |

### Gelecek Planlar (Faz 9+)
- İyzico / PayTR ile online tahsilat
- Çoklu yönetici (personel atama)
- Aidat geçmişi trend / istatistik dashboard (mevcut özet grafiklerin ötesinde)
- Belge paylaşımı (yönetim kararları, toplantı tutanakları)
- WhatsApp bildirimleri (NetGsm/Twilio)

---

## 6. AI Geliştirici Yönergeleri (Core AI Directives)

*Bu bölümü okuyan her AI ajanı bu kurallara mutlaka uymalıdır.*

### 6.1 Faz Kapısı Kuralları (EN YÜKSEK ÖNCELİK)

```
1. Her oturum başında resources/yol-haritası/FAZ_DURUMU.md dosyasını OKU.
2. SADECE "AKTİF" (▶) olarak işaretlenmiş fazların checklist görevlerini yap.
3. Onaylı (✅) ve kilitli fazların kapsamına geri dönme; yalnızca aktif fazlardaki [ ] görevlere odaklan.
4. features/ klasörü faz bazlı ayrılmaz; aktif fazın görevleri hangi feature'ı gerektiriyorsa ona dokun.
5. Faz tamamlanması için İKİ koşul BİRDEN ZORUNLU:
   a) Tüm checklist öğeleri [x] işaretli
   b) "ONAY: Furkan ✅" satırı mevcut
6. Bu koşullar sağlanmadan sonraki faza geçilemez. İstisna YOK.
```

### 6.2 Backend Deploy Kuralı (ZORUNLU)

```
- backend/ klasöründe HANGİ DOSYA değiştirilirse değiştirilsin deploy ZORUNLU.
- Kullanıcı "deploy etme" demediği durumlarda bile oturum bitmeden deploy yap.
- Komut: bash backend/scripts/deploy.sh (Git Bash) veya powershell -ExecutionPolicy Bypass -File backend/scripts/deploy.ps1
- PM2 süreç adı: aidapanel-api (t harfi yok, aidatpanel-api DEĞİL)
- Prisma schema değişikliği → npx prisma migrate deploy çalıştırılır.
- .env, uploads/dekonts/, Firebase JSON DOSYALARI ASLA ÜZERİNE YAZILMAZ.
- Deploy sonrası yanıtın EN ALTINA dipnot ekle:
  > **Sunucu:** Değişiklikler api.aidatpanel.com üzerine yüklendi, aidapanel-api yeniden başlatıldı ve doğrulandı.
```

### 6.3 API Response Contract

Backend'den dönen her yanıt şu formatta olmalıdır:
```json
{ "success": true, "message": "...", "data": { ... } }
```
- Başarılı: `success: true`, `data` nesne/array/null olabilir.
- Hata: `success: false`, `message` kullanıcı dostu Türkçe, `data` null.
- Liste parse edilirken: `response.data['data']` katmanından itibaren `List<dynamic>` olarak çözümlenir.

### 6.4 Kod Standartları ve Konvansiyonlar

**Mobil:**
- `ListView.children` KULLANILAMAZ → `ListView.builder` ZORUNLU.
- `WillPopScope` KULLANILAMAZ → `PopScope` (`canPop` + `onPopInvokedWithResult`) ZORUNLU.
- String literalleri UI'da YASAK → `context.t.xxx` (Slang i18n) ZORUNLU.
- i18n ekleme: TR + EN JSON güncelle → `dart run slang` (Slang codegen)
- Freezed/model codegen: `dart run build_runner build --delete-conflicting-outputs`
- `StateNotifier` / `StateNotifierProvider` KULLANILAMAZ → `Notifier` / `NotifierProvider` ZORUNLU.
- Token'lar loglanamaz, `SharedPreferences`'a yazılamaz → `flutter_secure_storage` ZORUNLU.
- `LogInterceptor` sadece `kDebugMode`'da aktif.
- 401 hataları DioClient interceptor tarafından otomatik yönetilir; elle yakalama YASAK.
- Yeni endpoint → `mobile/lib/core/constants/api_constants.dart`'a ekle, datasource'a string GÖME.
- `_uploadDio` (ayrı Dio instance) kullanılır — 3 dk timeout.

**Backend:**
- Tüm async route handler'ları `asyncHandler()` ile sarmalanmalı (try-catch wrapper).
- Route validasyonu Zod schema ile yapılır.
- Console logları yerine `pino` logger kullanılır.
- Rate limiting 4 katmanlı (global, auth, sensitive, upload).
- `multer` ile dosya upload → `uploads/dekonts/` klasörüne kaydedilir.
- 409 Prisma P2014 hatası (relation violation) özel olarak yakalanır.

### 6.5 Tasarım Kısıtları (50+ Yaş Kullanıcıları — ZORUNLU)

| Kural | Değer |
|-------|-------|
| Minimum font boyutu | 16sp (`AppTypography`) |
| Minimum dokunma alanı | 48×48dp |
| Navigasyon | BottomNavigationBar (ikon + yazı birlikte, hamburger YASAK) |
| Loading göstergesi | Her async işlemde görünür (CircularProgressIndicator) |
| Hata mesajları | `context.t` ile kullanıcı dilinde (TR/EN); teknik terim YOK |
| Animasyon | Maksimum 200ms, `Curves.easeInOut` |
| Lottie / Hero animasyon | YASAK |
| textScaleFactor | Hiçbir yerde kısıtlanamaz |
| Buton yüksekliği | Primary: 56dp, Secondary: 48dp |

### 6.6 Google Play AAB Kuralı

```
1. pubspec.yaml version: satırında "+" sonrası build code'u 1 artır.
2. flutter build appbundle --release --flavor prod -t lib/main.dart --dart-define=REVENUECAT_ANDROID_KEY=goog_...
3. Çıktı: mobile/build/app/outputs/bundle/prodRelease/app-prod-release.aab
- NOT: Sürüm adı (ör. 0.6.x) sadece kullanıcı açıkça isterse değişir; build code her AAB'de artar.
- RevenueCat anahtarı olmadan satın alma devre dışı kalır.
- prodRelease: AGP 8.13.2; R8 minify + optimized resource shrink + class repackaging açık (`proguard-rules.pro`); mapping → build/app/outputs/mapping/prodRelease/mapping.txt (Crashlytics upload görevi + Play deobfuscation).
- Dart obfuscation ayrı/opsiyonel: --obfuscate --split-debug-info=build/debug-info
```

### 6.7 Veritabanı Şema Kısıtları

- Prisma schema değişikliği → migration oluştur → `npx prisma migrate deploy`
- `@@index` tanımları performans gerektiğinde kullanılır (ör: `[userId, isRead, createdAt]`, `[apartmentId, year, month]`)
- KVKK uyumu: `deletedAt` dolu kullanıcılar oturum reddedilir, kayıt silinmez (PII maskelenir).
- `refreshTokenVersion` her çıkışta artırılır; mevcut refresh token'lar geçersiz olur.

### 6.8 Bildirim Sistemi Mimarisi

```
Olay → notificationService (DB kaydı)
     → notificationDeliveryService
           ├─ realtimeHub (WebSocket) → açık app'ler
           └─ FCM push (firebase-admin) → kapalı/tray app'ler

Mobil → NotificationDeliveryCoordinator
           ├─ WebSocketNotificationRealtimeSource  (açık)
           ├─ FcmNotificationRealtimeSource         (tray + ön plan)
           └─ PollingNotificationRealtimeSource     (yedek)
```

- WebSocket: `wss://api.aidatpanel.com/api/v1/realtime?token=ACCESS_JWT`
- `REALTIME_WS_ENABLED=true` env değişkeni ile kontrol edilir.
- Nginx reverse proxy WebSocket upgrade header'larını (`Upgrade`, `Connection "upgrade"`) geçirmelidir.

### 6.9 Referans Implementasyon

- Tam feature örneği (tüm katmanlar eksiksiz): `mobile/lib/features/auth/`
- Site yönetimi örneği (FAZ 8): `mobile/lib/features/sites/`
- Riverpod Notifier örneği: `mobile/lib/features/dues/presentation/providers/dues_provider.dart`
- Backend route + controller + service örneği: `src/routes/authRoutes.js` + `src/controllers/authController.js` + `src/services/authService.js`
- API şeması + kullanıcı rolleri: `resources/AIDATPANEL.md`
- Faz durumu + roadmap: `resources/yol-haritası/FAZ_DURUMU.md`

### 6.10 Yapılacak İş (Task Kanban Formatı)

Tüm görevler `FAZ_DURUMU.md` içinde `[ ]` / `[x]` olarak işaretlenir. AI ajanı:
- Aktif fazların `[ ]` olan görevlerini `[x]` yapar.
- Tamamlanan görevden sonra Furkan'dan onay alır (yanıt formatı: `ONAY: Furkan ✅ (YYYY-MM-DD)`).
- Kilitli fazların kapsamına geri dönmez; yalnızca aktif faz checklist'lerine odaklanır.

### 6.11 Commit Mesajı Dili (ZORUNLU)

- Tüm commit mesajları **Türkçe** ve anlaşılır olmalıdır.
- Teknik terimler İngilizce kalabilir ancak açıklayıcı cümleler Türkçe olmalıdır.
- Örnek: `feat: aidat listesi filtresi eklendi` ✅ | `feat: add due filter` ❌

### 6.12 Dil ve Çeviri Mantığı (Slang i18n - ZORUNLU)

```
1. Mobil projesinde Ekranda (UI'da) gösterilen veya Toast ile basılan HİÇBİR YAZI (hata mesajları dahil) hardcoded (sabit) string olamaz. Tüm metinler `strings_tr.i18n.json` ve `strings_en.i18n.json` dosyalarına eklenip `context.t` üzerinden okunmalıdır.
2. REPOSITORY ve DATASOURCE katmanlarında ASLA `context.t` veya çeviri (localization) çağrısı yapılamaz. Bu katmanlar, çevrilmemiş saf (raw) veya hata anahtarları (error key) döndürmelidir (örnek: "purchase_failed", "site_load_error").
3. Çeviriler SADECE Presentation (UI / Widget / Provider) katmanında, tercihen `_resolveMessage(context, errorKey)` gibi bir haritalama (mapping) fonksiyonu kullanılarak çevrilir.
4. JSON dosyalarına ekleme yapıldıktan sonra ZORUNLU OLARAK `dart run slang` komutu çalıştırılmalı ve `strings.g.dart` dosyası güncellenmelidir.
5. Parametreli çeviriler için JSON içerisinde `{degisken}` formatı kullanılmalı ve UI tarafında `.replaceAll('{degisken}', deger)` şeklinde kullanılmalıdır.
```

### 6.13 Dokümantasyon Güncelleme Zorunluluğu

Her kod değişikliği oturumunda §0 kuralları uygulanır. AI ajanı oturumu şu kontrolle kapatır:

```
[ ] FAZ_DURUMU.md — aktif faz checklist'i güncel mi?
[ ] AIDATPANEL.md — API/model değiştiyse güncellendi mi?
[ ] AGENTS.md — mimari/stack/faz/feature değiştiyse güncellendi mi?
[ ] .env.example — yeni env anahtarı eklendiyse güncellendi mi?
```

Dokümantasyon güncellenmeden "iş tamamlandı" denmez.
