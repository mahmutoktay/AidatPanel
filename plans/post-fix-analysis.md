# Post-Fix Analiz Raporu

**Tarih:** 2026-06-25
**Durum:** 12 düzeltme uygulandıktan sonra kalan/güncel sorunlar

---

## 1. ✅ Düzeltilmiş Bulgular (Önceki Rapor)

| # | Bulgu | Durum |
|---|-------|-------|
| 1 | `asyncHandler` kullanılmayan controller'lar | ✅ **Düzeltildi** — 6 controller asyncHandler'a geçti |
| 2 | `authMiddleware` session/account validity | ✅ **Düzeltildi** — deletedAt + DB fallback eklendi |
| 3 | `dueController` tutarsız hata yönetimi | ✅ **Düzeltildi** — asyncHandler standardize edildi |
| 4 | `authController` logout/forgotPassword HttpError | ✅ **Düzeltildi** — asyncHandler ile çözüldü |
| 5 | `logoutService` FCM token çoklu cihaz | ✅ **Düzeltildi** — session bazlı sonlandırma |
| 6 | Global `onSessionExpired` değişkeni | ✅ **Düzeltildi** — `onSessionExpiredProvider` |
| 7 | Validator isimlendirme | ✅ **Düzeltildi** — authValidator.js silindi |
| 8 | `express-request-id` middleware | ✅ **Düzeltildi** — mount edildi |
| 9 | Decimal→String dönüşümü | ✅ **Düzeltildi** — Number() kullanılıyor |
| 10 | `paidAt` parse riski | ✅ **Düzeltildi** — isNaN kontrolü eklendi |
| 11 | Gereksiz catch bloğu | ✅ **Düzeltildi** — kaldırıldı |
| 12 | TicketModel createdBy fallback | ✅ **Düzeltildi** — sadeleştirildi |

---

## 2. 🔴 Hala Kritik Bulgular

### 2.1. 4 Controller'da Hala `handleHttp` Kopyası Var

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`announcementController.js`](backend/src/controllers/announcementController.js:4-12) | 4-12 | `handleHttp` kopyası |
| [`notificationController.js`](backend/src/controllers/notificationController.js:14-22) | 14-22 | `handleHttp` kopyası |
| [`sessionController.js`](backend/src/controllers/sessionController.js:7-15) | 7-15 | `handleHttp` kopyası |
| [`subscriptionController.js`](backend/src/controllers/subscriptionController.js:8-16) | 8-16 | `handleHttp` kopyası (tahmini) |

**Öneri:** Bu 4 controller'ı da `asyncHandler` kullanacak şekilde dönüştürün.

**Öncelik:** 🔴 Kritik

### 2.2. 3 Controller'da `asyncHandler` Yok, `handleHttp` da Yok

| Dosya | Satır | Pattern |
|-------|-------|---------|
| [`buildingController.js`](backend/src/controllers/buildingController.js) | 11-143 | Tüm handler'lar `catch (error) { next(error); }` |
| [`apartmentController.js`](backend/src/controllers/apartmentController.js) | 11-117 | Aynı |
| [`buildingCollectionController.js`](backend/src/controllers/buildingCollectionController.js) | — | (tahmini) aynı |
| [`siteCollectionController.js`](backend/src/controllers/siteCollectionController.js) | — | (tahmini) aynı |
| [`inviteCodeController.js`](backend/src/controllers/inviteCodeController.js) | — | (tahmini) aynı |

**Öneri:** Tümü `asyncHandler` kullanacak şekilde dönüştürün.

**Öncelik:** 🔴 Kritik

---

## 3. 🟡 Orta Bulgular

### 3.1. `setState` ile Yönetilen State'ler Riverpod'a Taşınmalı

Tarama: **221 `setState` kullanımı** tespit edildi. Çoğu UI widget'larında local form state için kabul edilebilir olsa da, şu pattern'ler sorunlu:

| Dosya | Satır | Sorun |
|-------|-------|-------|
| [`manager_dues_tab.dart`](mobile/lib/features/dues/presentation/screens/manager_dues_tab.dart:81) | 81 | `_selectedBuildingId` setState ile yönetiliyor — Riverpod buildingId state'i üzerinden gitmeli |
| [`manager_expenses_screen.dart`](mobile/lib/features/expenses/presentation/screens/manager_expenses_screen.dart:191) | 191 | Aynı pattern |
| [`manager_tickets_screen.dart`](mobile/lib/features/tickets/presentation/screens/manager_tickets_screen.dart:143) | 143 | Aynı pattern |
| [`manager_dekonts_screen.dart`](mobile/lib/features/dekont/presentation/screens/manager_dekonts_screen.dart:137) | 137 | Aynı pattern |

Bu 4 dosyada `_selectedBuildingId`/`_buildingId` setState ile yönetiliyor. Building seçimi Riverpod Notifier/StateProvider ile merkezi yönetilmeli.

**Öncelik:** 🟡 Orta

### 3.2. `authMiddleware` Session (revokedAt) Kontrolü Eksik

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`authMiddleware.js`](backend/src/middlewares/authMiddleware.js:22-33) | 22-33 | `deletedAt` kontrolü eklendi ama `revokedAt` ve session geçerliliği kontrol edilmiyor |

JWT `sid` alanından session ID okunuyor ama bu session'ın `revokedAt` dolu olup olmadığı kontrol edilmiyor. Refresh token akışında bu kontrol var ama access token ile yapılan isteklerde yok.

**Öncelik:** 🟡 Orta

### 3.3. `authBackHandler` / `dashboardBackHandler` — Global State Kullanımı

Bu dosyaları henüz okumadım ama isimlerinden Flutter back navigation handler'lar olduğu anlaşılıyor. Global state içerebilir.

**Öncelik:** 🟡 Orta (doğrulama gerekli)

### 3.4. Flutter Provider'larında Doğrudan DataSource Referansı

| Dosya | Pattern |
|-------|---------|
| [`dekont_provider.dart`](mobile/lib/features/dekont/presentation/providers/dekont_provider.dart:19-27) | Provider → DataSource → Repository → Provider |
| [`expenses_provider.dart`](mobile/lib/features/expenses/presentation/providers/expenses_provider.dart:11-19) | Aynı |

Clean Architecture'a göre presentation katmanı sadece Repository'e bağımlı olmalı. Provider'lar DataSource'a doğrudan bağımlı değil (Repository üzerinden gidiyor) — bu iyi. Ancak bazı provider'lar (`dekont_provider.dart:19`) ayrıca `DekontRemoteDataSource` provider'ı da tanımlıyor. Bu gereksiz bir abstraction katmanı.

**Öncelik:** 🟢 Düşük

---

## 4. Doğrulanmış İyi Tasarımlar

| Alan | Dosya | Açıklama |
|------|-------|----------|
| N+1 önleme | [`dashboardController.js`](backend/src/controllers/dashboardController.js:38-92) | 7 paralel sorgu `Promise.all` ile |
| Batch breakdown | [`dueService.js`](backend/src/services/dueService.js:58-81) | `attachBreakdownToDuesBatch` N+1'i önler |
| Token replay detection | [`authService.js`](backend/src/services/authService.js:186-199) | Refresh token hash mismatch → tüm oturumları iptal |
| Transaction atomicity | [`authService.js`](backend/src/services/authService.js:124-133) | Token üretimi + hash kaydı atomik transaction |
| Row-level locking | [`authService.js`](backend/src/services/authService.js:176-179) | `FOR UPDATE` ile TOCTOU race önleme |
| Soft delete (KVKK) | [`schema.prisma`](backend/prisma/schema.prisma:26-27) | `deletedAt` ile hesap kapatma, PII maskelenir |

---

## 5. Özet

| Kategori | Önceki | Yeni | Kalan |
|----------|--------|------|-------|
| 🔴 Kritik | 5 | 0 | **2** (4+5 controller asyncHandler'sız) |
| 🟡 Orta | 8 | 4 | **4** (setState, revokedAt, back handler, authBackHandler doğrulama) |
| 🟢 Düşük | 3 | 1 | **2** |

## 6. Önerilen Aksiyon Sırası

1. **Kalan controller'ları `asyncHandler`'a geçir** (`announcementController`, `notificationController`, `sessionController`, `subscriptionController`, `buildingController`, `apartmentController`, `buildingCollectionController`, `siteCollectionController`, `inviteCodeController`)
2. **`authMiddleware`'e `revokedAt` session kontrolü ekle**
3. **Flutter'da `setState` ile yönetilen building seçimlerini Riverpod Provider'a taşı**
