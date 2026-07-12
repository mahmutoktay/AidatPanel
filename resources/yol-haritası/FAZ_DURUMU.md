# AidatPanel — Yol Haritası ve Faz Durumu

**Tek kaynak:** Fazlar, checklist, onaylar ve eksikler (Mobil + Backend).  
**Güncelleme:** 2026-06-22 · **Branch:** `mobile/app` · **Sorumlular:** Furkan (Mobil) & Backend Ekibi

**AI asistanlar** her oturumda bu dosyayı okur; yalnızca **AKTİF** fazda kod yazar (`CLAUDE.md` faz kapısı).

**Referanslar:** API + bildirim → `resources/AIDATPANEL.md` · Backend → `backend/README.md` · Dev → `flutter run -t lib/main_dev.dart`

---

## Faz özeti

| Faz | Konu | Durum | Hedef | ONAY |
| --- | --- | --- | --- | --- |
| 0 | Foundation | ✅ | — | ✅ |
| 1 | Aidat + Dashboard + Tur 5 | ✅ | 2026-05-15 | ✅ 2026-05-10 |
| 2 | Bildirimler + Giderler | ✅ | 2026-06-05 | ✅ 2026-05-29 |
| 3 | Tickets + Dekont/IBAN | ✅ | — | ✅ 2026-06-02 |
| 4 | Profil + Reports (PDF) | ✅ | 2026-07-03 | ✅ 2026-06-13 |
| 5 | Test + Sertleştirme | ✅ | 2026-07-10 | ✅ 2026-06-14 |
| 6 | Subscription | ✅ | 2026-07-12 | ✅ 2026-06-18 |
| **7** | **v1.0.0 Lansman** | **▶ AKTİF** | 2026-07-14 | — |
| **8** | **Site Yönetimi** | **▶ AKTİF** | 2026-08 | — |

```
▶ ŞU AN: FAZ 7 — v1.0.0 Lansman
▶ SIRADAKİ: FAZ 8 — Site Yönetimi (aktif)
▶ FAZ 0–6: kapalı (onaylı)
```

---

## ✅ FAZ 5 — Hardening + Testing (TAMAMLANDI)

**ONAY: Furkan ✅** (2026-06-14)

### Sıradaki işler

| # | Görev | Platform | Durum |
| --- | --- | --- | --- |
| 1 | Upload ayrı Dio (`_uploadDio`, 3 dk timeout) | Mobil | [x] |
| 2 | Pagination (dues, tickets, expenses, dekonts) | Fullstack | [x] |
| 3 | Mobil testler (auth, Dio, widget, integration iskelet) | Mobil | [x] |
| 4 | Certificate pinning (`api.aidatpanel.com` SHA-256) | Mobil | [x] |
| 5 | Build flavors (`dev` / `prod`) + obfuscation notu | Mobil | [x] |

### Mobil

- [x] Certificate pinning (`certificate_pinning.dart` + DioClient)
- [x] Build flavors (`dev` / `prod`) — `--flavor dev` · release: `--obfuscate --split-debug-info`
- [x] Unit testleri (Auth provider, DioClient)
- [x] Widget test (LoginScreen smoke)
- [x] Integration test iskeleti (`integration_test/login_dashboard_test.dart`)
- [x] `StateNotifier` → `Notifier` migration (Riverpod 3.x — FAZ 6 öncesi plan)
- [x] Upload ayrı Dio instance
- [x] Pagination (dues, tickets, expenses, dekonts + notifications)

### Backend (tamamlandı)

- [x] `validate.js` feature bazlı modüllere bölündü (`src/validators/`)
- [x] `authControllers.js` → `authService.js` taşındı
- [x] Rate limit (`authLimiter`) hesap bazlı key
- [x] Backend Jest unit test altyapısı (`npm test` — 24 test)
- [x] Aidat yaşam döngüsü: yeni daire aidatı, `POST /dues/bulk`, otomatik OVERDUE job
- [x] `meService.js` refactor (236 satır → `services/me/` modülleri)
- [x] `Expense.updatedAt` — migration (`20260613120000_expense_updated_at`)
- [x] OCR ölçekleme — gider makbuz OCR dekont pipeline kuyruğuna alındı (`expenseOcrService.js`)
- [x] Jest kapsamı genişletildi (`meProfileHelpers`, `expenseOcrService`, `reportAggregation` vb.)
- [x] VPS deploy scriptleri (`backend/scripts/deploy.ps1`)

---

## FAZ 4 — Profil + Reports (PDF) ✅

**ONAY: Furkan ✅** (2026-06-13)

### Profil

- [x] Profil bilgileri ekranı (`GET /me`, `PUT /me` name/email/phone)
- [x] `PUT /me/language` (Dil seçimi sunucu senkronu)
- [x] "Diğer cihazlardan çıkış" (`POST /auth/logout-all-devices` + WebSocket `force_logout`)
- [x] `POST /auth/logout` FCM token temizliği
- [x] Gider makbuz dosya upload (`POST /expenses/{id}/proof`)
- [x] Canlı E2E — profil güncelleme + dil senkronu

### Reports (`features/reports/` + backend)

**API:**

```
GET /api/v1/buildings/:id/reports?type=monthly&month=6&year=2026
GET /api/v1/buildings/:id/reports?type=annual&year=2026
→ Content-Type: application/pdf
```

| Öncelik | Görev | Platform | Durum |
| --- | --- | --- | --- |
| P1 | `reportDataService.js` — aidat/gider/doluluk özeti | Backend | [x] |
| P2 | `reportPdfService.js` — aylık PDF (50+ yaş TR) | Backend | [x] |
| P2 | Route + controller + Zod; yönetici bina sahipliği | Backend | [x] |
| P3 | `features/reports/` — indirme + paylaşma | Mobil | [x] |
| P3 | Bina menüsünden «Rapor indir» (ay seçici) | Mobil | [x] |
| P4 | Yıllık PDF — 12 aylık tablo | Backend | [x] |
| P5 | Operasyonel ek (ticket, dekont, duyuru sayıları) | Backend | [x] |
| P5 | Jest: `reportAggregation` testleri | Backend | [x] |
| P5 | Canlı E2E — aylık + yıllık PDF önizleme + paylaş | Fullstack | [x] |

**Bilinen sınırlar (v1):** Net = tahsil − gider (kasa yok) · Manuel «ödendi» → `DuePayment` oluşmaz · OCR bitmemiş gider raporda «henüz hesaplanmadı»

> Reports FAZ 3'te ertelenmişti → FAZ 4'e taşındı (2026-06-13).

---

## FAZ 3 — Tickets + Dekont/IBAN ✅

**ONAY: Furkan ✅** (2026-06-02)

### Tickets (`features/tickets/`)

- [x] Tüm Ticket uçları (canlı E2E)
- [x] Ticket listesi, detay, oluşturma formu

### Dekont + tahsilat IBAN

- [x] **M3** Tahsilat / IBAN tanımlama (Yönetici)
- [x] **M4** Ödeme yap + dekont yükle (Sakin) — multipart POST
- [x] **M5** Dekontlarım (Sakin) — `MATCHED`, `REJECTED` vb.
- [x] **M6** Dekont inceleme (Yönetici) — `PATCH /dekonts/:id/review`
- [x] **FCM** push bildirimleri (dekont durumları)
- Pipeline: upload → hash duplicate → validation → Tesseract OCR → business rules → auto-apply / needs review

---

## FAZ 2 — Notifications + Expenses ✅

**ONAY: Furkan ✅** (2026-05-29) · **Hedef:** ~2026-06-05

### Backend uçları

| Uç | Durum |
| --- | --- |
| `PUT /me/fcm-token` | ✅ |
| `GET /notifications`, `PATCH read`, `read-all` | ✅ |
| Gider CRUD + `receiptUrl` | ✅ |
| `POST /expenses/{id}/proof` (dosya) | ✅ |

### Mobil

**Notifications (`features/notifications/`):**

- [x] NotificationEntity, listesi, detay sheet
- [x] FCM + `notification_payload` deep-link
- [x] Backend API — `GET/PATCH /notifications` + push servisi

**Expenses (`features/expenses/`):**

- [x] ExpenseEntity, gider listesi + form (kategori, tutar, tarih, not)
- [x] Makbuz `receiptUrl` — HTTPS URL ile create/update
- [x] Makbuz dosya upload — `POST /expenses/{id}/proof` (multipart, OCR)

---

## FAZ 1 — Dues + Dashboard ✅

**ONAY: Furkan ✅** (2026-05-10) — Tur 1–5 dahil

### Dues (`features/dues/`)

- [x] DueEntity, DueModel, DuesRemoteDataSource, Repository, DuesNotifier
- [x] Yönetici & Sakin ekranları (filtreleme, manuel durum, geçmiş)
- [x] Dashboard summary card'ları

### Tur notları (Faz 2 öncesi düzeltmeler)

- [x] Oturum kalıcılığı (cold start restoreSession)
- [x] Geri tuşu uygulamayı kapatmaz (Android moveTaskToBack)
- [x] Tur 1: `PATCH /buildings/{buildingId}/dues/{dueId}/status`
- [x] Tur 2: `ApartmentModel` resident parse (isOccupied)
- [x] Tur 3: Bina/daire CRUD UI (EditBuilding, EditApartment, DeleteDialog)
- [x] Tur 4: Submit Guard (rapid-tap koruması)
- [x] Tur 5: Sakin çıkarma, bina formu uyumu, server-side dues filter, şifre/KVKK UI, şifremi unuttum

---

## FAZ 0 — Foundation ✅

**ONAY: Furkan ✅**

### Auth

- [x] Login, SignUp (yönetici + sakin davet), Register/Join birleşik
- [x] Şifremi unuttum + sıfırlama
- [x] Token refresh (401'de otomatik)
- [x] Logout (token + FCM sıfırlama)
- [x] Splash (role-based routing: manager / resident)

### Buildings & Apartments

- [x] Bina CRUD, davet kodu, sakin listesi
- [x] Daire CRUD, sakin atama
- [x] Manager / Resident Dashboard

### Güvenlik & altyapı

- [x] JWT access + refresh (`refreshTokenVersion`)
- [x] flutter_secure_storage
- [x] KVKK Soft Delete (`deletedAt`)
- [x] HTTPS, LogInterceptor (kDebugMode), Zod + Flutter validators
- [x] Rate Limiting (4 katmanlı)
- [x] Slang TR/EN, Clean Architecture, Riverpod, GoRouter
- [x] Prisma Schema (15 model, PostgreSQL/Neon)

---

## ✅ FAZ 6 — Subscription (TAMAMLANDI)

**Hedef:** ~2026-07-12 · **ONAY: Furkan ✅** (2026-06-18)

- [x] RevenueCat webhook (`POST /subscription/webhook/revenuecat`)
- [x] RevenueCat SDK + satın alma (Mobil)
- [x] Abonelik okuma ekranı (`GET /me/subscription`); satın alma butonu devre dışı
- [x] Canlı E2E — Abonelik akışı

### 📌 Devam noktası (2026-06-15 — Furkan)

**Buradan devam:** RevenueCat **webhook** + internal test satın alma.

**Tamamlanan:**
- [x] RevenueCat projesi (AidatPanel) + entitlement (AidatPanel Pro)
- [x] Play Store app RevenueCat’e bağlandı (`com.aidatpanel.app`, service account JSON)
- [x] RevenueCat ↔ Play Store bağlantısı onaylandı (hatasız)
- [x] Google Play **satıcı hesabı** açıldı / onaylandı
- [x] Play Console **abonelikler** ayarlandı (`aidatpanel_monthly`, `aidatpanel_annual`)
- [x] RevenueCat **default offering** → doğru Play ürünleri bağlandı
- [x] RevenueCat **webhook** kuruldu + VPS `REVENUECAT_WEBHOOK_SECRET` deploy
- [x] Android SDK API key alındı (`goog_...`)
- [x] Backend webhook + `GET /me/subscription` deploy edildi
- [x] Mobil `purchases_flutter` + abonelik ekranı satın alma butonları
- [x] Fiziksel cihazda giriş + prod AAB (`0.1.7+1778674180`)
- [x] TLS cert pin, RevenueCat `logIn` giriş engeli, JitPack repo düzeltmeleri

**Bekleyen (sırayla):**
1. [x] Internal test track'e AAB yükle → lisans test kullanıcısı ekle → sandbox satın alma testi
2. [x] Canlı E2E (satın alma → webhook → `GET /me/subscription`) → Furkan onayı

### 🔧 Kod Kalitesi İyileştirmeleri (ANALIZ_RAPORU_FAZ6.md)

**Gerçek Durum (mevcut kod analiz edildi):**

| # | Madde | Severity | Platform | Durum | Açıklama |
|---|-------|----------|----------|-------|----------|
| 1 | pdf-parse → pdfjs-dist (OCR) | 🟡 MEDIUM | Backend | [x] | `pdfjs-dist` entegre edildi (`extractPdfTextWithPdfjs`) |
| 2 | file_picker beta → stable | 🟡 MEDIUM | Mobil | [x] | `12.0.0-beta.5` → `11.1.1` |
| 3 | asyncHandler.js (try-catch wrapper) | 🟢 CODE QUALITY | Backend | [x] | `src/utils/asyncHandler.js` oluşturuldu |
| 4 | logger.js (Pino structured logging) | 🟢 CODE QUALITY | Backend | [x] | `src/config/logger.js` oluşturuldu (Pino) |
| 5 | limiterConstants.js (rate limit config) | 🟢 CODE QUALITY | Backend | [x] | `src/constants/limiterConstants.js` oluşturuldu, `rateLimitMiddleware.js` güncellendi |

**✅ Zaten mevcut olanlar (rapor hatalı):**
- Token Refresh Race Condition → `_inFlight` pattern zaten var (`token_refresh_service.dart:28`)
- CORS wildcard → Env'den `allowedOrigins` whitelist kullanılıyor (`index.js:35-37`)
- WebSocket Auto-Reconnect → `_scheduleReconnect()` zaten var (`websocket_notification_realtime_source.dart:123`)
- CSRF Protection → Web UI olmadığı için henüz gerekli değil
- Multer Cleanup → Kontrol edilecek

**Çalıştırma / AAB (prod — RevenueCat anahtarı zorunlu):**
```bash
cd mobile
flutter run --flavor prod -t lib/main.dart --dart-define=REVENUECAT_ANDROID_KEY=goog_...
flutter build appbundle --release --flavor prod -t lib/main.dart --dart-define=REVENUECAT_ANDROID_KEY=goog_...
```

---

## Gider–Aidat Hesaplama (FAZ 7 öncesi özellik)

**Hedef:** Aylık gider → aidat dağıtımı + sakin ödeme breakdown

- [x] Expense `targetMonth/Year`, `perUnitAmount`, carryforward tablosu (migration)
- [x] `dueExpenseRecalcService` — recalc, breakdown, carry-forward
- [x] Gider CRUD preview/confirm + aidat API breakdown
- [x] Mobil: gider formu (tutar, ay, split) + ödeme breakdown UI
- [x] i18n, testler, backend deploy

---

## ▶ FAZ 7 — v1.0.0 Lansman (AKTİF)

**Hedef:** ~2026-07-14

- [ ] App Store & Google Play submit
- [ ] Landing page güncelleme
- [x] Firebase Analytics & Crashlytics
- [ ] v1.0.0 release tag

### Lansman öncesi UX / akış temizliği (2026-07-11)

- [x] Aidat breakdown UI bağlandı (`DueDetailSheet`, `MakePaymentScreen`, sakin ledger detay)
- [x] Sakin gider listesi (`ResidentExpensesScreen` + `/resident-dashboard/expenses` + quick actions)
- [x] Giderler / Dekontlar: «Tüm Binalar» kaldırıldı (tickets normalize pattern + deep-link resolve)
- [x] Çapraz role route guard (`/manager-dashboard` ↔ `/resident-dashboard`)
- [x] Yönetici nav etiketi: «Mülkler» (Siteler | Binalar)
- [x] Kritik tipografi (ledger, bildirim chip, ticket timeline → min 16sp)
- [x] Gider listesi 500: `Expense.rawText` vb. OCR kolonları migration eksikti → `20260711220000_expense_ocr_fields` deploy
- [x] Sakin Hızlı İşlemler: 2×2 ayrık renkli kartlar (Aidat / Talepler / Giderler / Duyurular) + `ResidentAnnouncementsScreen`
- [x] Dekont detay: OCR polling (7sn) + tek durum kartı (çelişkili notice kutuları kaldırıldı)
- [x] Yönetici auth: deneyim adımı kaldırıldı; e-posta/telefon → `manager_identifier` exists dallanması (giriş veya isim+şifre kayıt)
- [x] Profil/talep: Kamera|Galeri seçici; talep `attachmentPath` + `POST /tickets/:id/attachment`
- [x] Bildirim: liste gövdesi kısaltılmıyor; tıklamada önce sheet (başlık+metin); ilgili kayıt sheet butonuyla
- [x] Sakin profil: e-posta gizli; telefon değişiminde SMS OTP (`resident_phone_change` + `otpCode`)
- [x] Para birimi gösterimi ₺ (`currencyDisplay` / `AppCurrencyFormat.displaySymbol`); hatırlatmada kalan borç
- [x] Sakin «Ödeme Yap» butonu yüksekliği 48dp (`buttonHeightSmall`)

---

## ▶ FAZ 8 — Site Yönetimi (AKTİF)

**Hedef:** ~2026-08 · **Önkoşul:** FAZ 7 `ONAY: Furkan ✅`

Site → bina hiyerarşisi; tekil binalar korunur. Site silinince alt binalar cascade silinir. Abonelik kotası **toplam bina sayısı** (site içi bloklar dahil). Site ortak giderleri tüm site dairelerine paylaştırılır; site + bina PDF raporları ayrı üretilir.

### Kararlar (2026-06-22, kota güncelleme 2026-06-25)

| Konu | Karar |
| --- | --- |
| Site silme | `onDelete: Cascade` — alt binalar + tüm bağlı veriler silinir |
| Site altı bina | `blockLabel` **zorunlu**, `name` **opsiyonel** (boşsa `blockLabel` kullanılır) |
| Mevcut "Sitesi A Blok" binalar | Taşıma / dönüştürme aracı **yok**; `siteId = null` tekil kalır |
| Abonelik kotası | **Toplam bina sayısı** (tekil + site altı tüm bloklar); site başlığı kotaya dahil değil |
| Site ortak gideri | `SiteExpense` + tüm site dairelerine eşit pay (`perUnitAmount`) |
| Raporlar | `GET /sites/:id/reports` (aylık/yıllık PDF) + mevcut bina raporları korunur |
| Mobil FAB | Tek FAB → genişleyerek **Yeni Site** / **Yeni Bina** |

### Backend — veri modeli

- [x] `Site` modeli (adres, varsayılan aidat, varsayılan IBAN)
- [x] `Building.siteId?`, `Building.blockLabel?`, `Building.addressExtra?`
- [x] `SiteExpense` modeli (site ortak gider; `Expense` alanlarıyla uyumlu)
- [x] `DueExpenseCarryforward.siteExpenseId?` (site gider payı daire aidatına yansıma)
- [x] Migration; mevcut binalar `siteId = null`

### Backend — API & servis

- [x] `GET/POST /api/v1/sites`, `GET/PUT/DELETE /api/v1/sites/:id`
- [x] `PATCH /api/v1/sites/:id/collection`
- [x] `GET/POST /api/v1/sites/:id/buildings` (site altı bina; inherit + override)
- [x] `GET /api/v1/buildings?standalone=true` (Binalar sekmesi)
- [x] `resolveEffectiveBuildingConfig` (aidat / IBAN / adres site varsayılanına düşer)
- [x] Dekont + sakin ödeme: effective IBAN
- [x] `siteExpenseService` + `siteExpenseAllocationService` (tüm site dairelerine pay)
- [x] `siteAggregationService` — site ve bina `collectedAmount` / `expectedAmount` (cari ay)
- [x] `GET /api/v1/sites/:id/reports?type=monthly\|annual` (PDF)
- [x] `reportDataService` / `reportPdfService` site konsolidasyonu
- [x] `buildingQuotaService` — toplam bina sayımı; `POST /buildings` ve site altı bina öncesi kontrol
- [x] `GET /me/subscription` yanıtına `usage.buildings` + `limits.buildings` ekleme
- [x] Jest: site config, kota, quota (temel suite)

### Mobil — `features/sites/`

- [x] Clean Architecture katmanları (`SiteEntity`, repository, datasource)
- [x] `sitesStoreProvider` + `siteBuildingsProvider`
- [x] `AddSiteScreen` (adres + varsayılan aidat + IBAN; kat/daire yok)
- [x] `SiteDetailScreen` (blok listesi + site toplanan tutar)
- [x] `AddSiteBuildingScreen` (blok zorunlu, bina adı opsiyonel, aidat/IBAN override switch)
- [x] `ManagerPropertiesTab` → **Siteler \| Binalar** sekmeleri (Siteler solda)
- [x] Genişleyen FAB: **Yeni Site** / **Yeni Bina**
- [x] Site ortak gider formu + listesi (`features/sites/`)
- [x] Site rapor indirme (`SiteReportScreen` + `report` datasource genişlemesi)
- [x] i18n (TR + EN) + `slang`

### Mobil — mevcut modül güncellemeleri

- [x] `BuildingEntity` / model: `siteId`, `blockLabel`, `addressExtra`, effective alanlar
- [x] `InviteCodeScreen`: site → bina → daire akışı (site’li binalar için)
- [x] Davet paylaşım metni: site adı + bina/blok
- [x] Saved IBAN matcher: site varsayılan IBAN dahil (backend collection presets)
- [x] Abonelik ekranı: bina kullanım özeti (`usage.buildings`)

### E2E & dokümantasyon

- [ ] Canlı E2E: site oluştur → blok ekle → ortak gider → aidat breakdown → site PDF
- [x] `resources/AIDATPANEL.md` API + şema güncellemesi (özet)
- [ ] Furkan onayı → `ONAY: Furkan ✅`

---

## Teknik borç ve bilinen eksikler

| # | Konu | Platform | Durum | Not |
| --- | --- | --- | --- | --- |
| 1 | `ListView.children` → `builder` | Mobil | ✅ | FAZ 1 |
| 2 | Certificate pinning | Mobil | ✅ | FAZ 5 |
| 3 | Test coverage %30+ | Mobil | ⏳ | Auth/Dio/widget eklendi; genişletilecek |
| 4 | Pagination | Fullstack | ✅ | 4 liste + notifications |
| 5 | Bina kartı dolu daire `0/N` | Backend | ✅ | `occupiedApartments` |
| 6 | Profil / Dil / Şifre uçları | Fullstack | ✅ | FAZ 4 |
| 7 | RevenueCat satın alma + webhook | Fullstack | 🟡 | FAZ 6 — webhook + SDK; E2E bekliyor |
| 8 | Gider makbuz `/proof` | Backend | ✅ | FAZ 2 kalıntısı |
| 9 | Reports (aylık/yıllık PDF) | Fullstack | ✅ | E2E onaylandı |
| 10 | `logout` FCM token temizliği | Backend | ✅ | FAZ 4 |
| 11 | Upload ayrı Dio instance | Mobil | ✅ | `_uploadDio` |
| 12 | `validate.js` modülerleştirme | Backend | ✅ | `src/validators/*.js` |
| 13 | OCR performans iyileştirmesi | Backend | ⏳ | Worker thread kısmen; kuyruk var |
| 14 | Aidat yaşam döngüsü | Backend | ✅ | bulk + OVERDUE job |
| 15 | `authService` refactor | Backend | ✅ | FAZ 5 |
| 16 | Backend unit test (Jest) | Backend | ✅ | 53 test (13 suite) |
| 17 | VPS deploy scriptleri | Backend | ✅ | `deploy.ps1` / `deploy.sh` |
| 18 | console.* → Pino structured logging | Backend | ✅ | Tüm runtime dosyaları |
| 19 | Health check endpoint (`GET /health`) | Backend | ✅ | DB connectivity check |
| 20 | Prisma P2014 handler (409) | Backend | ✅ | Relation violation |
| 21 | Notification partial index | Backend | ✅ | `userId + createdAt WHERE isRead=false` |
| 22 | Annual report batch optimizasyonu | Backend | ✅ | 24→2 sorgu |
| 23 | Firebase Analytics + Crashlytics | Mobil | ✅ | FAZ 7 |
| 24 | Site yönetimi (hiyerarşi + ortak gider + rapor) | Fullstack | ✅ | FAZ 8 |

---

## Tasarım kısıtları (50+ yaş — ZORUNLU)

- Minimum font: **16sp** (`AppTypography`)
- Minimum dokunma: **48×48dp**
- **Bottom Navigation** (hamburger yasak)
- Hata mesajları: sade Türkçe
- Loading: her async işte görünür gösterge
- Animasyon: max **200ms**, `Curves.easeInOut`

---

## Nasıl kullanılır

1. **Faz özeti** tablosuna ve **FAZ 5 sıradaki işler**e bak.
2. Yalnızca **aktif** fazda kod yaz; kilitli fazlara dokunma (`CLAUDE.md`).
3. Görev bitince ilgili `[ ]` → `[x]`; onay: `ONAY: Furkan ✅` (tarih ile).
4. API sözleşmesi: `resources/AIDATPANEL.md` + `backend/README.md`.
