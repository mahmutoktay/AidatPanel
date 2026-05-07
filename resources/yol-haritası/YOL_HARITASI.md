# AidatPanel — Geliştirme Yol Haritası

**Güncelleme:** 2026-05-07  
**Versiyon:** v0.1.0+1  
**Branch:** `mobile/app`  
**Geliştirici:** Furkan (tek geliştirici)

---

## Genel Durum Özeti

| Faz | Konu | Durum | Hedef Tarih |
|-----|------|-------|-------------|
| Faz 0 | Foundation (Auth + Buildings + Apartments + Güvenlik + i18n) | TAMAMLANDI | ✅ |
| Faz 1 | Dues (Aidat) + Dashboard | AKTİF | ~2026-05-22 |
| Faz 2 | Notifications + Expenses | Beklemede | ~2026-06-05 |
| Faz 3 | Tickets + Reports | Beklemede | ~2026-06-19 |
| Faz 4 | Subscription + Profile | Beklemede | ~2026-07-03 |
| Faz 5 | Hardening + Testing | Beklemede | ~2026-07-10 |
| Faz 6 | v1.0.0 Lansman | Hedef | ~2026-07-14 |

---

## FAZ 0 — Foundation (TAMAMLANDI) ✅

### Auth (`features/auth/`)
- [x] Login (email + şifre, JWT token alma)
- [x] Register (yönetici kaydı)
- [x] Join (davet koduyla sakin kaydı)
- [x] Token refresh (otomatik, 401'de devreye girer)
- [x] Logout (token temizleme)
- [x] Splash screen (role-based routing: manager / resident)

### Buildings (`features/buildings/`)
- [x] Bina listeleme (yönetici tüm binalarını görür)
- [x] Bina oluşturma (AddBuildingScreen)
- [x] Davet kodu üretme ve görüntüleme (InviteCodeScreen)
- [x] Sakin listesi görüntüleme (BuildingResidentsScreen)
- [x] Manager Dashboard ekranı

### Apartments (`features/apartments/`)
- [x] Daire listeleme
- [x] Daire oluşturma ve silme
- [x] Sakin atama
- [x] Resident Dashboard ekranı

### Güvenlik (Security)
- [x] JWT access + refresh token yönetimi
- [x] `flutter_secure_storage` (Android: EncryptedSharedPreferences, iOS: Keychain)
- [x] HTTPS zorlaması (AndroidManifest + network_security_config.xml)
- [x] `LogInterceptor` yalnızca `kDebugMode`'da aktif
- [x] JWT `exp` claim'inden expiry parsing (hardcoded 15dk yerine)
- [x] Input validation (email, şifre, telefon, isim, tutar)
- [x] Kullanıcıya teknik hata mesajı gösterilmemesi

### i18n
- [x] Slang (TR + EN), 213 anahtar/dil (426 toplam)
- [x] Runtime dil değiştirme
- [x] Dil tercihi SecureStorage'da kalıcı
- [x] Tüm mevcut ekranlar Türkçe + İngilizce

### Core Altyapı
- [x] Clean Architecture (domain / data / presentation)
- [x] Riverpod 2.5 (StateNotifier pattern)
- [x] GoRouter 13 (auth guard, role-based redirect)
- [x] DioClient (JWT interceptor, refresh logic, ayrı `_refreshDio`)
- [x] 76+ API endpoint tanımlı (`api_constants.dart`)
- [x] API Base URL: `https://api.aidatpanel.com/api/v1`

---

## FAZ 1 — Dues (Aidat) + Dashboard (AKTİF)
**Hedef:** ~2026-05-22

### Dues (`features/dues/`) — ÖNCELİK #1
- [ ] `DueEntity` tanımı (`features/dues/domain/entities/due_entity.dart`)
- [ ] `DueModel` (JSON serialization, `features/dues/data/models/`)
- [ ] `DuesRemoteDataSource` — endpoint'ler:
  - `GET /buildings/{id}/dues` — bina aidat listesi
  - `GET /apartments/{id}/dues` — daire aidat listesi
  - `GET /me/dues` — sakin kendi aidatları
  - `PATCH /dues/{id}/status` — ödeme durumu güncelleme
  - `POST /buildings/{id}/dues/bulk` — toplu aidat oluşturma
- [ ] `DuesRepository` + impl
- [ ] `DuesNotifier` (Riverpod StateNotifier)
- [ ] Yönetici: Aidat listesi ekranı (bina bazlı, ödendi/bekliyor filtresi)
- [ ] Yönetici: Manuel ödeme durumu güncelleme
- [ ] Yönetici: Toplu aidat oluşturma formu
- [ ] Sakin: Kendi aidat geçmişi ekranı

### Dashboard (`features/dashboard/`)
- [ ] Manager Dashboard'u tam ekrana taşı (şu an `buildings/presentation` içinde)
- [ ] Resident Dashboard'u tam ekrana taşı (şu an `apartments/presentation` içinde)
- [ ] Dashboard summary card'ları (toplam daire, ödeme oranı, gecikme sayısı)

### Teknik Borç Temizliği
- [ ] `ListView.children` → `ListView.builder` geçişi:
  - `mobile/lib/features/buildings/presentation/screens/invite_code_screen.dart:304`
  - `mobile/lib/features/buildings/presentation/screens/add_building_screen.dart:56`
  - `mobile/lib/features/buildings/presentation/widgets/invite_code_result_view.dart:38`

---

## FAZ 2 — Notifications + Expenses
**Hedef:** ~2026-06-05

### Notifications (`features/notifications/`)
- [ ] `NotificationEntity` tanımı
- [ ] `NotificationsRemoteDataSource` — endpoint'ler:
  - `GET /notifications` — bildirim listesi
  - `PATCH /notifications/{id}/read` — okundu işareti
  - `POST /me/fcm-token` — FCM token kaydetme
- [ ] FCM token kayıt akışı (uygulama açılışında)
- [ ] Bildirim listesi ekranı
- [ ] Push notification handler (foreground + background)

### Expenses (`features/expenses/`)
- [ ] `ExpenseEntity` tanımı
- [ ] `ExpensesRemoteDataSource` — endpoint'ler:
  - `GET /buildings/{id}/expenses` — bina gider listesi
  - `POST /buildings/{id}/expenses` — gider ekle
  - `GET /expenses/{id}` — gider detayı
  - `POST /expenses/{id}/proof` — makbuz yükleme
- [ ] Gider listesi ekranı
- [ ] Gider ekleme formu (kategori seçimi + tutar + açıklama)
- [ ] Makbuz fotoğrafı yükleme

---

## FAZ 3 — Tickets + Reports
**Hedef:** ~2026-06-19

### Tickets (`features/tickets/`)
- [ ] `TicketEntity` + `TicketUpdateEntity` tanımları
- [ ] `TicketsRemoteDataSource` — endpoint'ler:
  - `GET /buildings/{id}/tickets` — bina ticket listesi
  - `POST /buildings/{id}/tickets` — yeni ticket
  - `GET /tickets/{id}` — ticket detayı
  - `POST /tickets/{id}/updates` — ticket güncelleme/yorum
- [ ] Ticket listesi ekranı (yönetici + sakin görünümü)
- [ ] Ticket detay + güncelleme ekranı
- [ ] Ticket oluşturma formu (başlık + açıklama + kategori)

### Reports (`features/reports/`)
- [ ] Raporlar için backend endpoint'leri bağlama:
  - `GET /buildings/{id}/reports` — aylık özet
- [ ] Aylık özet rapor ekranı (gelir/gider tablosu)
- [ ] PDF export (planlama aşamasında — lib belirlenmeli)

---

## FAZ 4 — Subscription + Profile
**Hedef:** ~2026-07-03

### Subscription (`features/subscription/`)
- [ ] RevenueCat SDK entegrasyonu
- [ ] `GET /me/subscription` — abonelik durumu sorgusu
- [ ] Abonelik ekranı (plan seçimi, aktif plan gösterimi)
- [ ] Ücretsiz / Pro / Enterprise plan sınırlamaları

### Profile & Settings
- [ ] `GET /me` — profil bilgileri ekranı
- [ ] `POST /me/password` — şifre değiştirme ekranı
- [ ] `POST /me/language` — dil değiştirme (mevcut locale_provider ile entegrasyon)
- [ ] Çıkış yapma (Logout) ekranı/butonu

---

## FAZ 5 — Hardening + Testing
**Hedef:** ~2026-07-10

### Güvenlik Sertleştirme
- [ ] Certificate pinning aktifleştirme (altyapı hazır, devre dışı)
- [ ] `.env` / build flavors ile ortam bazlı config (dev / staging / prod API URL)
- [ ] Obfuscation (`--obfuscate --split-debug-info`)

### Test Coverage
- [ ] Auth provider unit testleri
- [ ] DioClient interceptor testleri
- [ ] Widget testleri (Login, Register ekranları)
- [ ] Integration test (login → dashboard akışı)
- [ ] Hedef: %30+ test coverage

### Performans
- [ ] Profil fotoğrafı önbellekleme
- [ ] API response önbellekleme (uygun endpoint'ler için)
- [ ] Büyük liste performansı (pagination implemente edilmesi)

---

## FAZ 6 — v1.0.0 Lansman
**Hedef:** ~2026-07-14

- [ ] App Store (iOS) submit
- [ ] Google Play Store submit
- [ ] Landing page güncelleme (aidatpanel.com)
- [ ] Firebase Analytics entegrasyonu
- [ ] Crash reporting (Firebase Crashlytics)
- [ ] v1.0.0 release tag

---

## Teknik Borçlar (Backlog)

| # | Sorun | Dosya | Öncelik |
|---|-------|-------|---------|
| 1 | `ListView.children` → `ListView.builder` | `invite_code_screen.dart:304` | Yüksek |
| 2 | `ListView.children` → `ListView.builder` | `add_building_screen.dart:56` | Yüksek |
| 3 | `ListView.children` → `ListView.builder` | `invite_code_result_view.dart:38` | Yüksek |
| 4 | Certificate pinning aktifleştirme | `dio_client.dart` | Orta |
| 5 | Ortam bazlı config (dev/staging/prod) | `api_constants.dart` | Orta |
| 6 | Test coverage: %0 → %30+ | `test/` | Yüksek |
| 7 | Pagination yok (API hazır, Flutter yok) | Feature ekranları | Orta |

---

## Tasarım Kısıtları (ZORUNLU — 50+ yaş kullanıcılar)

Bu kısıtlar her yeni ekranda kontrol edilmeli:

- **Minimum font boyutu:** 16sp (`AppTypography` değerlerine bak)
- **Minimum dokunma alanı:** 48dp × 48dp (buton, ikon, liste öğesi)
- **Navigasyon:** Bottom Navigation Bar (hamburger menü yasak)
- **Renk kontrastı:** WCAG AA uyumlu (beyaz üzerine koyu metin)
- **Hata mesajları:** Teknik terimden arındırılmış, sade Türkçe
- **Loading state:** Her async işlemde görünür yüklenme göstergesi

---

## Mimari Referans

```
mobile/lib/
├── core/
│   ├── constants/     # AppConstants, ApiConstants (76+ endpoint)
│   ├── network/       # DioClient, ApiException
│   ├── router/        # GoRouter + auth guard
│   ├── storage/       # SecureStorage
│   ├── theme/         # AppColors, AppSizes, AppTypography, AppTheme
│   ├── providers/     # locale_provider
│   └── utils/         # input_validators
├── features/
│   ├── auth/          # ✅ TAM
│   ├── buildings/     # ✅ TAM
│   ├── apartments/    # ✅ TAM
│   ├── dues/          # 🔜 SIRADA (Faz 1)
│   ├── dashboard/     # 🔜 SIRADA (Faz 1)
│   ├── notifications/ # 📋 Faz 2
│   ├── expenses/      # 📋 Faz 2
│   ├── tickets/       # 📋 Faz 3
│   ├── reports/       # 📋 Faz 3
│   └── subscription/  # 📋 Faz 4
├── shared/
│   ├── widgets/       # AltActionButton, PasswordField, ToastOverlay, vb.
│   ├── providers/     # navigation_provider
│   └── utils/         # auth_validators
└── l10n/              # strings_tr.i18n.json, strings_en.i18n.json (213 key/dil)
```
