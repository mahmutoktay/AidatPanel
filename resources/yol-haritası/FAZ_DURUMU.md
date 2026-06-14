# AidatPanel — Yol Haritası ve Faz Durumu

**Tek kaynak:** Tüm fazlar, checklist, onaylar, eksikler ve mimari özeti (Mobil + Backend) bu dosyada.  
**Güncelleme:** 2026-06-13 (Reports → FAZ 4) · **Branch:** `mobile/app` & `backend` · **Sorumlular:** Furkan (Mobil) & Backend Ekibi

**AI asistanlar** her oturumda bu dosyayı okur; yalnızca **AKTİF** fazda kod yazar (`CLAUDE.md` faz kapısı).

---

## MEVCUT DURUM (özet)

| Faz | Konu                            | Durum       | Hedef      | ONAY          |
| --- | ------------------------------- | ----------- | ---------- | ------------- |
| 0   | Foundation                      | ✅ Tamam    | —          | ✅            |
| 1   | Aidat + Dashboard + Tur 5       | ✅ Tamam    | 2026-05-15 | ✅ 2026-05-10 |
| 2   | Bildirimler + Giderler          | ✅ Tamam    | 2026-06-05 | ✅ 2026-05-29 |
| 3   | Tickets + Dekont/IBAN           | ✅ Tamam    | —          | ✅ 2026-06-02 |
| 4   | Profil + Reports (PDF)          | ✅ Tamam    | 2026-07-03 | ✅ 2026-06-13 |
| 5   | Test + Sertleştirme (Fullstack) | ▶ **AKTİF** | 2026-07-10 | —             |
| 6   | Subscription (Lansman Öncesi)   | 🔒 Kilitli  | 2026-07-12 | —             |
| 7   | v1.0.0 Lansman                  | 🔒 Kilitli  | 2026-07-14 | —             |

```
▶ AKTİF ÇALIŞMA: FAZ 5 — Test + Sertleştirme (upload Dio ✅ sıradaki: pagination / testler)
▶ FAZ 4: kapalı (ONAY ✅ 2026-06-13)
▶ FAZ 0–4: kapalı
```

**Sıradaki işler (FAZ 5):**

- [x] Upload için ayrı Dio instance (`_uploadDio`, 3 dk timeout)
- [ ] Pagination (büyük listeler)
- [ ] Mobil unit/widget testleri
- [ ] Certificate pinning

**Tamamlanan (FAZ 4):**

- [x] Gider makbuz **dosya** upload (`POST /expenses/{id}/proof`) — FAZ 2 kalıntısı
- [x] **FAZ 4 (Backend)** — `logout` endpoint'inde FCM token temizleme
- [x] **FAZ 4 (Mobil)** — Canlı E2E + ONAY (profil/dil/abonelik okuma)

- [ ] FAZ 5–7 (test, abonelik, store) — FAZ 4 tamamlanınca

**Referanslar:** API + bildirim → `resources/AIDATPANEL.md` · Backend → `backend/README.md` · Dev → `flutter run -t lib/main_dev.dart`

---

## FAZ 0 — Foundation

**Durum:** TAMAMLANDI ✅  
**ONAY: Furkan ✅**

### Auth (Mobil + Backend)

- [x] Login (email + şifre, JWT token alma)
- [x] SignUp — birleşik kayıt (`sign_up_screen.dart`: yönetici + sakin davet kodu; `/sign-up`, `/register`, `/join`)
- [x] Register (yönetici kaydı) — SignUp ile birleşik
- [x] Join (davet koduyla sakin kaydı) — SignUp ile birleşik
- [x] Şifremi unuttum + sıfırlama (`forgot_password_screen`, `reset_password_screen`)
- [x] Token refresh (otomatik, 401'de devreye girer)
- [x] Logout (token temizleme + FCM token sıfırlama)
- [x] Splash screen (role-based routing: manager / resident)

### Buildings & Apartments

- [x] Bina listeleme, oluşturma (AddBuildingScreen)
- [x] Davet kodu üretme ve görüntüleme (InviteCodeScreen)
- [x] Sakin listesi görüntüleme (BuildingResidentsScreen)
- [x] Daire listeleme, oluşturma ve silme, sakin atama
- [x] Manager / Resident Dashboard ekranları

### Güvenlik (Mobil + Backend)

- [x] JWT access + refresh token yönetimi (`refreshTokenVersion` tabanlı)
- [x] flutter_secure_storage (Android: EncryptedSharedPreferences, iOS: Keychain)
- [x] KVKK Soft Delete (DB `deletedAt` alanı)
- [x] HTTPS zorlaması & LogInterceptor (kDebugMode)
- [x] Input validation (Zod backend, Flutter validatorler)
- [x] Rate Limiting (4 katmanlı API koruması)

### i18n & Core Altyapı

- [x] Slang (TR + EN), Runtime dil değiştirme, SecureStorage kalıcılığı
- [x] Clean Architecture (domain / data / presentation) (Mobil)
- [x] Service-Controller ayrımı (Backend)
- [x] Riverpod 2.5 (StateNotifier pattern)
- [x] GoRouter 13 (auth guard, role-based redirect)
- [x] Prisma Schema (15 model, 17+ index, PostgreSQL/Neon)

---

## FAZ 1 — Dues (Aidat) + Dashboard ✅ TAMAMLANDI

**Durum:** TAMAMLANDI ✅
**Tamamlanma:** 2026-05-10
**ONAY: Furkan ✅** (Tur 1 + Tur 2 + Tur 3 + Tur 4 dahil)

### Dues (features/dues/)

- [x] DueEntity tanımı, DueModel (JSON serialization)
- [x] DuesRemoteDataSource (GET bina aidat listesi, GET sakin kendi aidatları, PATCH ödeme durumu, PATCH aidat tutarı güncelleme)
- [x] DuesRepository + impl, DuesNotifier (Riverpod StateNotifier)
- [x] Yönetici & Sakin ekranları (filtreleme, manuel durum güncelleme, geçmiş)
- [x] Dashboard summary card'ları tam ekran taşıması

### Faz 2 Öncesi Kritik Düzeltmeler & Tur Notları

- [x] Oturum kalıcılığı (cold start restoreSession)
- [x] Geri tuşu uygulamayı kapatmaz (Android moveTaskToBack)
- [x] Tur 1: `PATCH /buildings/{buildingId}/dues/{dueId}/status` migrasyonu
- [x] Tur 2: `ApartmentModel` resident alanının parse edilmesi (isOccupied)
- [x] Tur 3: Bina ve daire CRUD UI tamamlanması (EditBuilding, EditApartment, DeleteDialog)
- [x] Tur 4: Submit Guard (rapid-tap koruması)
- [x] Tur 5 (Backend Uyum): Sakin çıkarma UI, Bina formu uyumu, Server-side dues filter, Şifre değiştir UI, Hesabı kapat UI (KVKK), Şifremi unuttum akışı.

---

## ✅ FAZ 2 — Notifications + Expenses (TAMAMLANDI)

**Durum:** TAMAMLANDI ✅ — bildirimler + gider CRUD + özet + `receiptUrl` (E2E 2026-05-29)  
**Tamamlanma:** 2026-05-29  
**Hedef:** ~2026-06-05

### Backend bağımlılık

| Uç                                             | Durum        |
| ---------------------------------------------- | ------------ |
| `PUT /me/fcm-token`                            | ✅ canlı     |
| `GET /notifications`, `PATCH read`, `read-all` | ✅ canlı E2E |
| Gider CRUD + `receiptUrl` (HTTPS)              | ✅ canlı E2E |
| `POST /expenses/{id}/proof` (dosya)            | ✅ canlı E2E |

### Notifications (`features/notifications/`)

- [x] NotificationEntity, listesi, detay sheet
- [x] FCM + `notification_payload` deep-link
- [x] **Backend API** — `GET/PATCH /notifications` + push servisi

### Expenses (`features/expenses/`)

- [x] ExpenseEntity, gider listesi + form (kategori, tutar, tarih, not)
- [x] **Makbuz `receiptUrl`** — HTTPS URL ile create/update
- [x] **Makbuz dosya upload** — `POST /expenses/{id}/proof` (multipart, OCR)

---

## ✅ FAZ 3 — Tickets + Dekont/IBAN (TAMAMLANDI)

**Durum:** TAMAMLANDI ✅ (2026-06-02)  
**ONAY: Furkan ✅** (2026-06-02)

> **Reports:** FAZ 3'te ertelendi (2026-06-02) → **FAZ 4'e taşındı** (2026-06-13).

### Tickets (features/tickets/)

- [x] Tüm Ticket uçları (canlı E2E)
- [x] Ticket listesi, detay, oluşturma formu

### Dekont + tahsilat IBAN

- **Backend Pipeline**: Dosya yükleme → Hash duplicate koruması → Validation → Tesseract OCR → Business Rules → Auto-apply (veya Needs Review). Çok iyi entegre edilmiş, sağlam altyapı.
- [x] **M3** Tahsilat / IBAN tanımlama (Yönetici)
- [x] **M4** Ödeme yap + dekont yükle (Sakin) — `file_picker`, multipart POST
- [x] **M5** Dekontlarım (Sakin) — durum detayları (`MATCHED`, `REJECTED`, vs.)
- [x] **M6** Dekont inceleme (Yönetici) — `PATCH /dekonts/:id/review` `APPROVE` / `REJECT`
- [x] **FCM** push bildirimleri (dekont durumları)

---

## ▶ FAZ 4 — Profil + Reports (PDF) ✅ TAMAMLANDI

**Durum:** TAMAMLANDI ✅  
**Tamamlanma:** 2026-06-13  
**ONAY: Furkan ✅** (2026-06-13)

### Profil & Diğer Eksikler ✅

- [x] Profil bilgileri ekranı (`GET /me`, `PUT /me` name/email/phone)
- [x] `PUT /me/language` (Dil seçimi sunucu senkronu)
- [x] "Diğer cihazlardan çıkış" (`POST /auth/logout-all-devices` + WebSocket `force_logout`)
- [x] **Backend Bug Fix**: `POST /auth/logout` FCM token'ını silecek şekilde güncellendi
- [x] Gider makbuz **dosya** upload (`POST /expenses/{id}/proof`) — Tamamlandı
- [x] Canlı E2E — profil güncelleme + dil senkronu

### Reports (`features/reports/` + backend) — öncelik sırası

**API sözleşmesi:**

```
GET /api/v1/buildings/:id/reports?type=monthly&month=6&year=2026
GET /api/v1/buildings/:id/reports?type=annual&year=2026
→ Content-Type: application/pdf
```

**Veri kaynakları:** `Building`, `Apartment`, `User`, `Due`, `Expense` (+ mevcut `expenses/summary`), `Ticket`, `Dekont`, `Notification`(ANNOUNCEMENT sayısı).

| Öncelik | Görev                                                                                                                                             | Platform  | Durum |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ----- |
| **P1**  | `reportDataService.js` — dönem aidat özeti (beklenen/tahsil/geciken/muaf), daire satır listesi, gider özeti (`expenses/summary` mantığı), doluluk | Backend   | [x]   |
| **P2**  | `reportPdfService.js` — aylık PDF şablonu (kapak özeti + aidat tablosu + gider dökümü); 50+ yaş: büyük punto, sade TR                             | Backend   | [x]   |
| **P2**  | Route + controller + Zod (`type`, `month`, `year`); yönetici bina sahipliği kontrolü                                                              | Backend   | [x]   |
| **P3**  | `features/reports/` — datasource/repository/provider; PDF binary indirme + paylaşma                                                               | Mobil     | [x]   |
| **P3**  | Giriş noktası: bina detayı veya gider ekranından «Aylık rapor indir» (ay seçici)                                                                  | Mobil     | [x]   |
| **P4**  | Yıllık PDF — 12 aylık tahsil/gider/net tablosu + yıllık kategori özeti                                                                            | Backend   | [x]   |
| **P5**  | Operasyonel ek: ticket sayıları, dekont özeti, duyuru sayısı (kısa tablo)                                                                         | Backend   | [x]   |
| **P5**  | Jest: `reportDataService` aggregasyon testleri                                                                                                    | Backend   | [x]   |
| **P5**  | Canlı E2E — aylık + yıllık PDF önizleme + paylaş                                                                                                  | Fullstack | [x]   |

**Ürün onayı (2026-06-13):** Furkan rapor akışını onayladı (önizleme + paylaş).

**ONAY: Furkan ✅** (2026-06-13)

**MVP kapsamı (P1–P3):** Aylık PDF — özet kutusu, aidat detay tablosu, kategori gider özeti.  
**v1.1 (P4–P5):** Yıllık tablo + operasyonel ekler.

**Bilinen sınırlar (dokümante et, bug değil):**

- Bina kasası / banka bakiyesi yok → «net» = tahsil − gider (dönem içi akış).
- Manuel «ödendi» işareti `DuePayment` oluşturmaz → v1 tahsilat kaynağı `Due` tablosu.
- OCR bitmemiş gider (`amount = null`) özette «henüz hesaplanmadı» olarak işaretlenir.

---

## ▶ FAZ 5 — Hardening + Testing (Fullstack)

**Durum:** **AKTİF** — FAZ 4 kapandı (2026-06-13)  
**Hedef:** ~2026-07-10

### Mobil Görevleri

- [ ] Certificate pinning aktifleştirme
- [ ] Build flavors (dev / staging / prod) & Obfuscation
- [ ] Unit testleri (Auth provider, DioClient interceptor, vb.)
- [ ] Widget testleri & Integration test (login → dashboard)
- [ ] `StateNotifier` → `Notifier` migration planı (Riverpod 3.x hazırlığı)
- [x] Upload işlemleri için ayrı Dio instance (Timeout yarış koşulu riskine karşı)
- [ ] Pagination implementasyonu

### Backend Görevleri

- [x] `validate.js` feature bazlı modüllere bölündü (`src/validators/`)
- [x] `authControllers.js` → `authService.js` taşındı
- [x] Rate limit (`authLimiter`) hesap bazlı key
- [x] Backend Jest unit test altyapısı (`npm test`)
- [x] Aidat yaşam döngüsü: yeni daire aidatı, `POST /dues/bulk`, otomatik OVERDUE job
- [x] `meService.js` refactor (236 satır → `services/me/` modülleri)
- [x] `Expense.updatedAt` — migration eklendi (`20260613120000_expense_updated_at`)
- [x] OCR ölçekleme — gider makbuz OCR dekont pipeline kuyruğuna alındı (`expenseOcrService.js`)
- [x] Jest kapsamı genişletildi (`meProfileHelpers`, `expenseOcrService`, `reportFormat` — 24 test)

---

## 🔒 FAZ 6 — Subscription (Lansman Öncesi)

**Durum:** KİLİTLİ — Faz 5 tamamlanmadan açılamaz  
**Hedef:** ~2026-07-12

### Subscription (features/subscription/)

- [ ] **Backend Görevi**: RevenueCat webhook (`POST /subscription/webhook/revenuecat`)
- [ ] **Mobil Görevi**: RevenueCat SDK + satın alma
- [x] Abonelik okuma ekranı (`GET /me/subscription`); satın alma butonu devre dışı
- [ ] Canlı E2E — Abonelik akışı testleri

---

## 🔒 FAZ 7 — v1.0.0 Lansman

**Durum:** KİLİTLİ — Faz 6 tamamlanmadan açılamaz  
**Hedef:** ~2026-07-14

- [ ] App Store (iOS) & Google Play Store submit
- [ ] Landing page güncelleme
- [ ] Firebase Analytics & Crashlytics entegrasyonu
- [ ] v1.0.0 release tag

---

## Teknik borç ve bilinen eksikler (Fullstack Backlog)

| #   | Konu                                     | Platform  | Durum        | Not                                         |
| --- | ---------------------------------------- | --------- | ------------ | ------------------------------------------- |
| 1   | `ListView.children` → `builder`          | Mobil     | ✅           | FAZ 1                                       |
| 2   | Certificate pinning                      | Mobil     | ⏳           | FAZ 5                                       |
| 3   | Test coverage %30+                       | Mobil     | ⏳           | FAZ 5                                       |
| 4   | Pagination (büyük listeler)              | Mobil     | ⏳           | FAZ 5                                       |
| 5   | Bina kartı dolu daire `0/N`              | Backend   | ✅           | API’de `occupiedApartments` eklendi         |
| 6   | Profil / Dil / Şifre uçları              | Fullstack | ✅           | FAZ 4                                       |
| 7   | RevenueCat satın alma + webhook          | Fullstack | 🔴 Ertelendi | FAZ 6 — okuma ekranı var; webhook bekliyor  |
| 8   | Gider makbuz dosya `/proof`              | Backend   | ✅           | FAZ 2 Kalıntısı tamamlandı                  |
| 9   | **Reports** (aylık/yıllık PDF)           | Fullstack | ✅           | E2E onaylandı; VPS deploy bekliyor          |
| 10  | `logout` FCM token temizliği             | Backend   | ✅           | FAZ 4 — Çıkışta fcmToken sıfırlandı         |
| 11  | Upload için ayrı Dio instance            | Mobil     | ✅           | FAZ 5 — `_uploadDio` + gider proof migrate  |
| 12  | `validate.js` modülerleştirme            | Backend   | ✅           | `src/validators/*.js`                       |
| 13  | OCR performans iyileştirmesi             | Backend   | ⏳           | Worker thread kısmen; kuyruk var            |
| 14  | Aidat yaşam döngüsü (daire/bulk/OVERDUE) | Backend   | ✅           | `dueBulkService`, `dueOverdueService`, job  |
| 15  | `authService` refactor                   | Backend   | ✅           | FAZ 5 öncesi tamamlandı                     |
| 16  | Backend unit test (Jest)                 | Backend   | ⏳           | 14 test; kapsam genişletilecek              |

---

## Tasarım kısıtları (ZORUNLU — 50+ yaş)

- Minimum font: **16sp** (`AppTypography`)
- Minimum dokunma: **48×48dp**
- **Bottom Navigation** (hamburger yasak)
- Hata mesajları: sade Türkçe, teknik terim yok
- Loading: her async işte görünür gösterge
- Animasyon: max **200ms**, `Curves.easeInOut`

---

## Nasıl Kullanılır

1. **AI asistan** her oturumda bu dosyayı okur; **MEVCUT DURUM** tablosuna ve **sıradaki işler** listesine bakar.
2. **Sadece izin verilen / aktif** fazın görevlerini yapar; **kilitli** fazlara dokunmaz (`CLAUDE.md`).
3. Bir fazın tüm checklist `[x]` olunca onay: `ONAY: Furkan ✅` (tarih ile).
4. Görev bitince bu dosyada ilgili `[ ]` → `[x]` güncelle; üst tabloyu senkron tut.
5. API sözleşmesi: `resources/AIDATPANEL.md` + `backend/README.md`.
