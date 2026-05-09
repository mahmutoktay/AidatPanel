# Faz 1 — Çekirdek (MVP) İlerleme Raporu

> **Son güncelleme:** 9 Mayıs 2026  
> **Kapsam:** Backend analizi (AIDATPANEL.md Faz 1 gereksinimleri vs. mevcut kod)

---

## 📊 Genel Durum Özeti

| Durum | Sayı |
|---|---|
| ✅ Tamamlanan | 2 |
| 🟡 Kısmen tamamlanan | 3 |
| 🔴 Başlanmayan | 3 |

**Faz 1 genel tamamlanma: ~%35**

---

## 🔍 Faz 1 Maddeleri — Detaylı Analiz

### 1. Auth (register, login, JWT, davet kodu ile katılım) — 🟡 %70

**Tamamlanan:**
- ✅ `POST /api/v1/auth/register` — Yönetici kaydı (MANAGER rolü atanıyor)
- ✅ `POST /api/v1/auth/login` — Email veya telefon ile giriş
- ✅ `POST /api/v1/auth/refresh` — Access token yenileme
- ✅ `POST /api/v1/auth/logout` — Çıkış
- ✅ `POST /api/v1/auth/join` — Davet koduyla sakin kaydı (transaction ile)
- ✅ JWT access token (15dk) + refresh token (30 gün)
- ✅ Zod validation tüm auth endpoint'lerinde
- ✅ Auth rate limiting (brute-force koruması)

**Eksikler:**
- ❌ `POST /api/auth/forgot-password` — Şifre sıfırlama maili gönderme
- ❌ `POST /api/auth/reset-password` — Yeni şifre belirleme
- ❌ `POST /api/auth/join` endpoint'inde `phone` alanı validation'da zorunlu değil ama AIDATPANEL.md'de sakin phone alanı opsiyonel — uyumlu
- ⚠️ Register endpoint JWT token döndürmüyor — kullanıcı kayıt sonrası ayrıca login yapmak zorunda

**Hatalar:**
- ⚠️ `authLimiter` tüm auth route'larına uygulanıyor (5 istek/15dk, `skipSuccessfulRequests: true`) — `/register` ve `/join` için bu limit çok agresif, normal kullanıcılar bile kısa sürede bloklanabilir

---

### 2. Bina ve daire CRUD — ✅ %90

**Tamamlanan:**
- ✅ `GET /api/v1/buildings` — Yöneticinin tüm binaları
- ✅ `POST /api/v1/buildings` — Bina oluştur (transaction: bina + daireler + aidatlar)
- ✅ `GET /api/v1/buildings/:id` — Bina detayı
- ✅ `PUT /api/v1/buildings/:id` — Bina güncelle
- ✅ `DELETE /api/v1/buildings/:id` — Bina sil
- ✅ `GET /api/v1/buildings/:buildingId/apartments` — Daire listesi (resident bilgisiyle)
- ✅ `POST /api/v1/buildings/:buildingId/apartments` — Daire ekle
- ✅ `PUT /api/v1/buildings/:buildingId/apartments/:id` — Daire güncelle
- ✅ `DELETE /api/v1/buildings/:buildingId/apartments/:id` — Daire sil
- ✅ Manager ownership validation (service katmanında)
- ✅ Zod validation tüm endpoint'lerde

**Eksikler:**
- ⚠️ `getBuildingByIdService` apartments bilgisini include etmiyor — detaylı bina bilgisi eksik
- ❌ Sayfalama (pagination) yok — büyük veri setlerinde performans sorunu

**Güvenlik Hatası:**
- 🔴 `updateBuildingService` gelen `req.body`'yi direkt `prisma.building.update`'e gönderiyor — `managerId` değiştirilebilir! Güvenlik açığı.

---

### 3. Davet kodu sistemi — 🟡 %70

**Tamamlanan:**
- ✅ `POST /api/v1/apartments/:apartmentId/invite-code` — Davet kodu üretme
- ✅ 7 gün geçerlilik süresi
- ✅ Tek kullanımlık (usedAt takibi)
- ✅ Benzersiz kod üretimi (collision retry mekanizması)
- ✅ Manager ownership validation
- ✅ `validateInviteCode` fonksiyonu (join akışında kullanılıyor)

**Eksikler:**
- ❌ Davet kodu doğrulama endpoint'i yok — Sakin uygulamada kodu girdiğinde hangi bina/daireye ait olduğunu göstermek için `GET /api/invite-codes/:code/validate` gerekli
- ❌ Davet kodu listeleme endpoint'i yok — Yöneticinin bir dairenin aktif davet kodlarını görmesi için

**Kod Hatası:**
- 🔴 `validateInviteCode` fonksiyonu **iki yerde** tanımlı:
  - `src/controllers/inviteCodeController.js:76-95`
  - `src/services/authService.js:43-62`
  - `authControllers.js` service'den import ediyor ama controller'daki versiyon kullanılmıyor — duplicate ve tutarsızlık riski

---

### 4. Aylık aidat oluşturma (toplu) ve durum güncelleme — 🔴 %40

**Tamamlanan:**
- ✅ `getDuesByBuildingService` — Binadaki aidatları listeleme (filtreleme: month, year, status)
- ✅ `updateDueStatusService` — Aidat durumu güncelleme (PAID, OVERDUE, WAIVED, PENDING)
- ✅ `getMyDuesService` — Sakinin kendi aidatlarını listeleme
- ✅ `updateBuildingDueAmountService` — Bina aidat bedelini güncelleme (mevcut PENDING'leri de güncelleyebilir)
- ✅ Bina oluşturulurken otomatik aidat oluşturma (bulunulan aydan yıl sonuna)

**Kritik Hata:**
- 🔴🔴🔴 **`dueRoutes` index.js'te import edilmemiş!** — Tüm aidat endpoint'leri hiç çalışmıyor. Bu en kritik bug.
  - `index.js`'te `dueRoutes` import ve `app.use()` satırı yok

**Eksikler:**
- ❌ `POST /api/buildings/:id/dues/bulk` — Toplu aidat oluşturma endpoint'i yok. Mevcut implementasyon sadece bina oluşturulurken aidat üretiyor. Yeni ay için aidat oluşturma mekanizması yok.
- ❌ Route yapısı AIDATPANEL.md spec'inden sapma:
  - Spec: `GET /api/buildings/:id/dues` → Mevcut: `GET /api/v1/dues/buildings/:buildingId`
  - Spec: `PATCH /api/dues/:id/status` → Mevcut: `PATCH /api/v1/dues/:dueId/status`
  - Spec: `GET /api/me/dues` → Mevcut: `GET /api/v1/dues/me`

**Performans Hatası:**
- ⚠️ `getDuesByBuildingService` N+1 query sorunu — Her due için ayrı bir `prisma.apartment.findUnique` sorgusu yapılıyor. Tek sorguda `include` ile çözülebilir.

---

### 5. Sakin: kendi aidat durumunu görme — ✅ %90

**Tamamlanan:**
- ✅ `GET /api/v1/dues/me` — Sakinin kendi aidatlarını listeleme (status ve year filtresi)
- ✅ Building bilgisi response'a ekleniyor

**Eksikler:**
- ⚠️ dueRoutes bağlı olmadığı için şu an çalışmıyor (Kritik Hata #1'e bağlı)
- ⚠️ Aidat özeti/istatistik yok (toplam borç, ödenen, bekleyen sayısı)

---

### 6. FCM push notification altyapısı — ⚪ %0

**Hiç başlanmadı.** Tümüyle eksik:

- ❌ `firebase-admin` paketi `package.json`'da yok
- ❌ Notification service yok
- ❌ FCM token yönetimi:
  - `PUT /api/me/fcm-token` — FCM token güncelleme
- ❌ Bildirim endpoint'leri:
  - `GET /api/notifications` — Bildirimlerim
  - `PATCH /api/notifications/:id/read` — Okundu işaretle
  - `PATCH /api/notifications/read-all` — Tümünü oku
- ❌ Push notification gönderme servisi
- ❌ Notification model Prisma şemasında var ama controller/route yok

---

### 7. RevenueCat abonelik entegrasyonu (iOS + Android) — ⚪ %0

**Hiç başlanmadı.** Tümüyle eksik:

- ❌ RevenueCat webhook endpoint: `POST /api/subscription/webhook/revenuecat`
- ❌ Abonelik durumu sorgulama: `GET /api/me/subscription`
- ❌ Abonelik kontrol middleware'i (aktif abonelik kontrolü)
- ❌ Subscription model Prisma şemasında var ama controller/route yok
- ❌ Webhook signature doğrulama

---

### 8. Landing page (web) — ⚪ %0

**Hiç başlanmadı.** Backend analizi kapsamı dışında, ancak not edilmesi gerekir:
- ❌ `web/` klasörü mevcut değil
- ❌ Statik HTML/CSS/JS landing page yok

---

## 🐛 Kritik Hatalar (Öncelik Sırasına Göre)

### P0 — Derhal Düzeltilmeli (Uygulama çalışmıyor)

| # | Hata | Dosya | Açıklama |
|---|---|---|---|
| 1 | **dueRoutes bağlı değil** | `index.js` | Aidat endpoint'leri hiç çalışmıyor. `import` ve `app.use()` satırı eksik |
| 2 | **CORS PATCH metodunu içermiyor** | `index.js:35` | `methods` dizisinde PATCH yok. Due status güncelleme (PATCH) CORS hatası alır |

### P1 — Güvenlik Açıkları

| # | Hata | Dosya | Açıklama |
|---|---|---|---|
| 3 | **Building update managerId değiştirilebilir** | `buildingService.js:119` | `req.body` direkt `prisma.update`'e gönderiliyor. `managerId`, `createdAt` gibi alanlar değiştirilebilir |
| 4 | **.env.example'de gerçek DB URL** | `.env.example:3` | Neon veritabanı bağlantı URL'si (credentials dahil) commit'lenmiş |

### P2 — Kod Kalitesi / Performans

| # | Hata | Dosya | Açıklama |
|---|---|---|---|
| 5 | **validateInviteCode duplicate** | `inviteCodeController.js` + `authService.js` | Aynı fonksiyon iki yerde. Controller'daki versiyon kullanılmıyor |
| 6 | **N+1 query** | `dueService.js:37-52` | Her due için ayrı apartment+resident sorgusu. `include` ile tek sorguda çözülebilir |
| 7 | **Auth rate limit çok agresif** | `rateLimitMiddleware.js:24-35` | 5 istek/15dk + `skipSuccessfulRequests: true` — register/join için uygun değil |
| 8 | **Register token döndürmüyor** | `authControllers.js:39-51` | Login ve join token döndürüyor ama register döndürmüyor |

---

## 📋 Eksik Özellikler (Öncelik Sırasına Göre)

### P0 — Faz 1'i tamamlamak için zorunlu

| # | Eksik Özellik | Açıklama |
|---|---|---|
| 1 | **Toplu aidat oluşturma endpoint'i** | `POST /api/buildings/:id/dues/bulk` — Yeni ayın aidatlarını tüm daireler için oluşturma |
| 2 | **Şifre sıfırlama** | `POST /api/auth/forgot-password` + `POST /api/auth/reset-password` — Resend email servisi gerekli |
| 3 | **Profil endpoint'leri** | `GET /api/me`, `PUT /api/me`, `PUT /api/me/password`, `PUT /api/me/language` |
| 4 | **KVKK: Kullanıcı verisi silme** | `DELETE /api/me` — AIDATPANEL.md notu: "faz 1'de yazılmalı" |
| 5 | **FCM push notification altyapısı** | Firebase Admin SDK, notification service, token yönetimi, bildirim endpoint'leri |
| 6 | **Davet kodu doğrulama endpoint'i** | `GET /api/invite-codes/:code/validate` — Sakin kayıt öncesi bina/daire bilgisini göstermek için |

### P1 — Faz 1'i güçlendirmek için gerekli

| # | Eksik Özellik | Açıklama |
|---|---|---|
| 7 | **RevenueCat abonelik entegrasyonu** | Webhook, abonelik kontrol middleware'i, abonelik durumu endpoint'i |
| 8 | **Role-based middleware** | `requireManager` middleware — MANAGER-only endpoint'ler için merkezi kontrol |
| 9 | **Sayfalama (pagination)** | Tüm list endpoint'leri için (buildings, apartments, dues, notifications) |

### P2 — İyileştirme

| # | Eksik Özellik | Açıklama |
|---|---|---|
| 10 | **Landing page (web)** | Statik HTML/CSS/JS — Backend kapsamı dışında |
| 11 | **Route yapısı düzeltme** | Due route'larını AIDATPANEL.md spec'ine uygun hale getirme |
| 12 | **getBuildingById apartments include** | Bina detayında daireler listesi de dönmeli |

---

## ✅ Önerilen Düzeltme Sırası

Aşağıdaki sırayla ilerlenmesi önerilir:

### Adım 1: Kritik Hataları Düzelt (P0)
1. `index.js`'e dueRoutes import ve app.use() ekle
2. CORS methods dizisine PATCH ekle

### Adım 2: Güvenlik Düzeltmeleri (P1)
3. `updateBuildingService`'de whitelist ile güncellenebilir alanları sınırla
4. `.env.example`'den gerçek DB URL'sini kaldır

### Adım 3: Kod Kalitesi Düzeltmeleri (P2)
5. `validateInviteCode` duplicate'ini kaldır (sadece service'de kalsın)
6. `getDuesByBuildingService` N+1 query'yi düzelt
7. Auth rate limiter'ı ayır (login için agresif, register/join için normal)
8. Register endpoint'ine token ekle

### Adım 4: Eksik Faz 1 Özellikleri (P0)
9. Toplu aidat oluşturma endpoint'i
10. Şifre sıfırlama endpoint'leri (Resend entegrasyonu)
11. Profil endpoint'leri (GET/PUT /api/me)
12. KVKK kullanıcı silme (DELETE /api/me)
13. FCM push notification altyapısı
14. Davet kodu doğrulama endpoint'i

### Adım 5: Faz 1 Tamamlayıcı Özellikler (P1)
15. RevenueCat abonelik entegrasyonu
16. Role-based middleware (requireManager)
17. Sayfalama

---

## 📁 Mevcut Dosya Yapısı

```
backend/
├── index.js                          ← dueRoutes BAĞLI DEĞİL!
├── package.json
├── .env.example                      ← Gerçek DB URL'si var!
├── prisma/
│   └── schema.prisma                 ← Notification, Subscription model var ama kullanılmıyor
├── src/
│   ├── config/
│   │   └── db.js
│   ├── controllers/
│   │   ├── authControllers.js        ← validateInviteCode authService'den import ediyor
│   │   ├── buildingController.js
│   │   ├── apartmentController.js
│   │   ├── inviteCodeController.js   ← validateInviteCode duplicate var!
│   │   └── dueController.js          ← Çalışmıyor (route bağlı değil)
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── buildingRoutes.js
│   │   ├── apartmentRoutes.js
│   │   ├── inviteCodeRoutes.js
│   │   └── dueRoutes.js             ← index.js'te kullanılmıyor!
│   ├── services/
│   │   ├── authService.js            ← validateInviteCode burada da var
│   │   ├── buildingService.js        ← Güvenlik: update whitelist eksik
│   │   ├── apartmentService.js
│   │   └── dueService.js             ← N+1 query sorunu
│   ├── middlewares/
│   │   ├── authMiddleware.js         ← Role kontrolü yok
│   │   ├── errorHandler.js
│   │   ├── rateLimitMiddleware.js    ← Auth limiter çok agresif
│   │   └── validate.js
│   ├── utils/
│   │   └── generateTokens.js
│   └── validators/
│       └── authValidator.js
```

---

## 📌 Notlar

- Prisma şemasında `Notification` ve `Subscription` modelleri tanımlı ama hiçbir controller/route/service yok
- `Apartment` modelinde `resident` ilişkisi var ama `residents` (çoğul) AIDATPANEL.md'de — mevcut şema one-to-one, spec one-to-many öneriyor. Mevcut yapı (tek sakin) daha mantıklı.
- `Ticket` ve `Expense` modelleri şemada var ama bunlar Faz 2 özellikleri
- `test.py` dosyası backend klasöründe gereksiz duruyor
