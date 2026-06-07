# AidatPanel — Yol Haritası ve Faz Durumu

**Tek kaynak:** Tüm fazlar, checklist, onaylar, eksikler ve mimari özeti (Mobil + Backend) bu dosyada.  
**Güncelleme:** 2026-06-07 · **Branch:** `mobile/app` & `backend` · **Sorumlular:** Furkan (Mobil) & Backend Ekibi

**AI asistanlar** her oturumda bu dosyayı okur; yalnızca **AKTİF** fazda kod yazar (`CLAUDE.md` faz kapısı).

---

## MEVCUT DURUM (özet)

| Faz | Konu | Durum | Hedef | ONAY |
|-----|------|-------|-------|------|
| 0 | Foundation | ✅ Tamam | — | ✅ |
| 1 | Aidat + Dashboard + Tur 5 | ✅ Tamam | 2026-05-15 | ✅ 2026-05-10 |
| 2 | Bildirimler + Giderler | ✅ Tamam (Eksik Backend Uçları Var) | 2026-06-05 | ✅ 2026-05-29 |
| 3 | Tickets + Dekont/IBAN (+ Reports ertelendi) | ✅ Tamam | — | ✅ 2026-06-02 |
| 4 | Profil + Abonelik | ▶ **AKTİF** | 2026-07-03 | — |
| 5 | Test + Sertleştirme (Fullstack) | 🔒 Kilitli | 2026-07-10 | — |
| 6 | v1.0.0 Lansman | 🔒 Kilitli | 2026-07-14 | — |

```
▶ AKTİF ÇALIŞMA: FAZ 4 — Profil + Abonelik
▶ FAZ 3: kapalı (ONAY ✅ 2026-06-02) · Reports ertelendi → backlog #12
▶ FAZ 0–3: kapalı
```

**Sıradaki işler (checklist `[ ]`):**
- [ ] **FAZ 4 (Backend)** — RevenueCat webhook (`POST /subscription/webhook/revenuecat`)
- [ ] **FAZ 4 (Backend)** — `logout` endpoint'inde FCM token temizleme eksikliği (Bug Fix)
- [ ] **FAZ 4 (Mobil)** — Canlı E2E + ONAY (profil/dil/abonelik okuma tamam; satın alma webhook sonrası)
- [ ] Gider makbuz **dosya** upload (`POST /expenses/{id}/proof`) — FAZ 2 kalıntısı; backend yok
- [ ] FAZ 5–6 (test, store) — FAZ 4 tamamlanınca

**Ertelenen (unutma — FAZ 3 dışı backlog):**
- [ ] **Reports** — yönetici aylık özet PDF (`GET /buildings/{id}/reports`); backend yok · aşağı § Reports (ertelendi)

**Referanslar:** API → `origin/backend/yedek` · `API/FLUTTER-BACKEND.md` §12 · Dekont rehberi → `API/FLUTTER-DEKONT-IMPLEMENTATION.md` · Dev → `flutter run -t lib/main_dev.dart`

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
- [x] Logout (token temizleme) — *Backend'de FCM token temizliği eksik (Faz 4'te düzeltilecek)*
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

| Uç | Durum |
|----|--------|
| `PUT /me/fcm-token` | ✅ canlı |
| `GET /notifications`, `PATCH read`, `read-all` | ✅ canlı E2E |
| Gider CRUD + `receiptUrl` (HTTPS) | ✅ canlı E2E |
| `POST /expenses/{id}/proof` (dosya) | ⏳ **Backend YOK** — mobil 404’te uyarı; receiptUrl kullanılıyor |

### Notifications (`features/notifications/`)
- [x] NotificationEntity, listesi, detay sheet
- [x] FCM + `notification_payload` deep-link
- [x] **Backend API** — `GET/PATCH /notifications` + push servisi

### Expenses (`features/expenses/`)
- [x] ExpenseEntity, gider listesi + form (kategori, tutar, tarih, not)
- [x] **Makbuz `receiptUrl`** — HTTPS URL ile create/update
- [x] **Makbuz fotoğrafı upload altyapısı** — API hazır değil, canlıda 404 → kullanıcıya bilgi toast’ı

---

## ✅ FAZ 3 — Tickets + Dekont/IBAN (TAMAMLANDI)

**Durum:** TAMAMLANDI ✅ (2026-06-02)  
**ONAY: Furkan ✅** (2026-06-02)

> **Reports:** **ertelendi** (2026-06-02 ürün kararı) — FAZ 3 kapsamı dışı; backlog #12. Backend `GET /buildings/:id/reports` + PDF yok.

### Tickets (features/tickets/)
- [x] Tüm Ticket uçları (`backend/yedek` + canlı E2E)
- [x] Ticket listesi, detay, oluşturma formu

### Dekont + tahsilat IBAN
- **Backend Pipeline**: Dosya yükleme → Hash duplicate koruması → Validation → Tesseract OCR → Business Rules → Auto-apply (veya Needs Review). Çok iyi entegre edilmiş, sağlam altyapı.
- [x] **M3** Tahsilat / IBAN tanımlama (Yönetici)
- [x] **M4** Ödeme yap + dekont yükle (Sakin) — `file_picker`, multipart POST
- [x] **M5** Dekontlarım (Sakin) — durum detayları (`MATCHED`, `REJECTED`, vs.)
- [x] **M6** Dekont inceleme (Yönetici) — `PATCH /dekonts/:id/review` `APPROVE` / `REJECT`
- [x] **FCM** push bildirimleri (dekont durumları)

---

## ▶ FAZ 4 — Subscription + Profile

**Durum:** **AKTİF** — FAZ 3 kapandı (2026-06-02); Reports FAZ 3 dışı ertelendi  
**Hedef:** ~2026-07-03

> **ÖNEMLİ:** Backend ekibi profil ve şifre sıfırlama uçlarını **canlıya aldı**. Fakat **RevenueCat webhook henüz yok** ve **`logout` endpoint FCM token temizliği eksik**.

### Profil (features/profile/)
- [x] Profil bilgileri ekranı (`GET /me`, `PUT /me` name/phone)
- [x] `PUT /me/language` (Dil seçimi sunucu senkronu)
- [x] "Diğer cihazlardan çıkış" (`POST /auth/logout-all-devices` + WebSocket `force_logout`)
- [ ] **Backend Bug Fix**: `POST /auth/logout` FCM token'ını silecek şekilde güncellenecek
- [ ] Canlı E2E — profil güncelleme + dil senkronu

### Subscription (features/subscription/)
- [ ] **Backend Görevi**: RevenueCat webhook (`POST /subscription/webhook/revenuecat`)
- [ ] **Mobil Görevi**: RevenueCat SDK + satın alma (webhook hazırlandıktan sonra)
- [x] Abonelik okuma ekranı (`GET /me/subscription`); satın alma butonu devre dışı

---

## 🔒 FAZ 5 — Hardening + Testing (Fullstack)

**Durum:** KİLİTLİ — Faz 4 tamamlanmadan açılamaz  
**Hedef:** ~2026-07-10

### Mobil Görevleri
- [ ] Certificate pinning aktifleştirme
- [ ] Build flavors (dev / staging / prod) & Obfuscation
- [ ] Unit testleri (Auth provider, DioClient interceptor, vb.)
- [ ] Widget testleri & Integration test (login → dashboard)
- [ ] `StateNotifier` → `Notifier` migration planı (Riverpod 3.x hazırlığı)
- [ ] Upload işlemleri için ayrı Dio instance (Timeout yarış koşulu riskine karşı)
- [ ] Pagination implementasyonu

### Backend Görevleri
- [ ] `validate.js`'in (727 satır) feature bazlı modüllere bölünmesi
- [ ] `authControllers.js` (register/login) içindeki inline Prisma çağrılarının service katmanına taşınması
- [ ] `Expense` Prisma modeline `updatedAt` alanının eklenmesi
- [ ] Rate limit (`authLimiter`) IP key'inin review edilmesi
- [ ] Senkron OCR Darboğazı: Tesseract işlemlerinin `worker_threads` veya mikroservis mimarisine alınması (Ölçekleme hazırlığı)

---

## 🔒 FAZ 6 — v1.0.0 Lansman

**Durum:** KİLİTLİ — Faz 5 tamamlanmadan açılamaz  
**Hedef:** ~2026-07-14

- [ ] App Store (iOS) & Google Play Store submit
- [ ] Landing page güncelleme
- [ ] Firebase Analytics & Crashlytics entegrasyonu
- [ ] v1.0.0 release tag

---

## Teknik borç ve bilinen eksikler (Fullstack Backlog)

| # | Konu | Platform | Durum | Not |
|---|------|----------|-------|-----|
| 1 | `ListView.children` → `builder` | Mobil | ✅ | FAZ 1 |
| 2 | Certificate pinning | Mobil | ⏳ | FAZ 5 |
| 3 | Test coverage %30+ | Mobil | ⏳ | FAZ 5 |
| 4 | Pagination (büyük listeler) | Mobil | ⏳ | FAZ 5 |
| 5 | Bina kartı dolu daire `0/N` | Backend | ⏳ | API’de `occupiedApartments` yok |
| 6 | Profil / Dil / Şifre uçları | Fullstack | ✅ | FAZ 4 |
| 7 | RevenueCat satın alma + webhook | Fullstack | 🔴 Blok | FAZ 4 — okuma ekranı var; webhook bekliyor |
| 8 | Gider makbuz dosya `/proof` | Backend | ⏳ | FAZ 2 Kalıntısı; backend yok (`receiptUrl` kullanılıyor) |
| 9 | **Reports** (aylık özet PDF) | Backend | ⏳ Ertelendi | FAZ 3 dışı backlog (#12); `GET /buildings/{id}/reports` yok |
| 10 | `logout` FCM token temizliği | Backend | 🔴 Hata | FAZ 4 — Push token'ı silinmiyor |
| 11 | Upload için ayrı Dio instance | Mobil | ⏳ | FAZ 5 — Race condition riskini önlemek için |
| 12 | `validate.js` & `meService.js` Refactor | Backend | ⏳ | FAZ 5 — Monolitik dosyaların bölünmesi |
| 13 | OCR performans iyileştirmesi | Backend | ⏳ | FAZ 5 — `setImmediate` darboğazını giderme |

---

## Tasarım kısıtları (ZORUNLU — 50+ yaş)

- Minimum font: **16sp** (`AppTypography`)
- Minimum dokunma: **48×48dp**
- **Bottom Navigation** (hamburger yasak)
- Hata mesajları: sade Türkçe, teknik terim yok
- Loading: her async işte görünür gösterge
- Animasyon: max **200ms**, `Curves.easeInOut`

Detay: `resources/tasarım/TASARIM_KILAVUZU.md`

---

## Nasıl Kullanılır

1. **AI asistan** her oturumda bu dosyayı okur; **MEVCUT DURUM** tablosuna ve **sıradaki işler** listesine bakar.
2. **Sadece izin verilen / aktif** fazın görevlerini yapar; **kilitli** fazlara dokunmaz (`CLAUDE.md`).
3. Bir fazın tüm checklist `[x]` olunca onay: `ONAY: Furkan ✅` (tarih ile).
4. Görev bitince bu dosyada ilgili `[ ]` → `[x]` güncelle; üst tabloyu senkron tut.
5. API sözleşmesi: `origin/backend/yedek` → `API/FLUTTER-BACKEND.md` (backend kaynağı).
