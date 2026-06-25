# Uçtan Uca Proje Analiz Raporu

**Proje:** AidatPanel — Flutter + Node.js / Prisma / PostgreSQL
**Tarih:** 2026-06-25
**Kapsam:** Backend (Express.js) + Flutter (Riverpod, Clean Architecture)

---

## 🔴 Kritik Bulgular

### 1. `asyncHandler` Tanımlı Ama Hiçbir Controller Kullanmıyor

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`backend/src/utils/asyncHandler.js`](backend/src/utils/asyncHandler.js:27) | 27 | `asyncHandler` utility mevcut — Express 4 uyumlu, `Promise.resolve().catch(next)` |
| [`authControllers.js`](backend/src/controllers/authControllers.js:15) | 15-23 | Kendi `handleHttp()` fonksiyonunu yazmış. Aynı pattern altı controller'da kopyalanmış |
| [`expenseController.js`](backend/src/controllers/expenseController.js:15) | 15-23 | Aynı `handleHttp()` kopyası |
| [`meController.js`](backend/src/controllers/meController.js:15) | 15-23 | Aynı `handleHttp()` kopyası |
| [`dueController.js`](backend/src/controllers/dueController.js:96) | 151-156 | `postBulkGenerateBuildingDues` içinde manuel `HttpError` kontrolü + direkt `next(error)` |
| [`dekontController.js`](backend/src/controllers/dekontController.js:16) | 16-29 | Yine kendi `handleHttp()` kopyası |

**Sorun:** Altı farklı controller dosyasında aynı `handleHttp()` fonksiyonu kopyalanmış. Bazı controller'lar (dueController) direkt `next(error)` çağırırken, bazıları (auth/expense) `handleHttp` üzerinden geçiyor. Tutarsız yaklaşım — hata yönetiminde tek bir noktadan sapma.

**Önerilen düzeltme:**
```js
// Tüm controller'larda:
export const getDuesByBuilding = asyncHandler(async (req, res) => {
  const data = await getDuesByBuildingService(...);
  res.json({ success: true, data });
});
// try-catch + handleHttp kaldırılır — asyncHandler + errorHandler yeterlidir.
```

**Öncelik:** 🔴 Kritik

---

### 2. `authMiddleware` Session/Account Validity Kontrolü Yapmıyor

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`authMiddleware.js`](backend/src/middlewares/authMiddleware.js:19) | 19-21 | JWT `verify` sonrası sadece `id`, `role`, `sid` alınıyor |

**Sorun:** JWT çözüldükten sonra:
- Kullanıcının `deletedAt` dolu mu (hesap kapatılmış mı) kontrol edilmiyor
- Session'ın `revokedAt` dolu mu (oturum iptal edilmiş mi) kontrol edilmiyor
- Bu kontroller yalnızca refresh token akışında yapılıyor, access token ile yapılan her istekte atlanıyor

**Önerilen düzeltme:**
```js
// authMiddleware.js içinde decoded sonrası:
const user = await prisma.user.findFirst({
  where: { id: decoded.id, deletedAt: null },
  select: { id: true, role: true },
});
if (!user) {
  return res.status(401).json({ success: false, message: "Hesap bulunamadı." });
}
```

**Öncelik:** 🔴 Kritik

---

### 3. `dueController` Tutarsız Hata Yönetimi

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`dueController.js`](backend/src/controllers/dueController.js:34) | 34 | `getDuesByBuilding`: `catch (error) { next(error); }` — direkt passtrough |
| [`dueController.js`](backend/src/controllers/dueController.js:61) | 61 | `updateDueStatus`: aynı — direkt `next(error)` |
| [`dueController.js`](backend/src/controllers/dueController.js:151) | 151-156 | `postBulkGenerateBuildingDues`: manuel `HttpError` kontrolü **+** `next(error)` |
| [`dueController.js`](backend/src/controllers/dueController.js:184) | 184 | `updateBuildingDueAmount`: direkt `next(error)` |

**Sorun:** Aynı controller dosyasında üç farklı hata yönetimi pattern'i var. `postBulkGenerateBuildingDues` içinde manuel HttpError kontrolü varken diğerleri direkt passtrough yapıyor.

**Öncelik:** 🔴 Kritik

---

### 4. Flutter: `authController` logout/forgotPassword HttpError Kontrolü Eksik

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`authControllers.js`](backend/src/controllers/authControllers.js:84) | 84 | `logout`: `catch (err) { next(err); }` — HttpError değilse direkt geçer |
| [`authControllers.js`](backend/src/controllers/authControllers.js:110) | 110 | `forgotPassword`: aynı — direkt `next(err)` |

**Sorun:** Diğer auth handler'ları `handleHttp()` ile HttpError kontrolü yaparken, `logout` ve `forgotPassword` direkt `next(err)` çağırıyor. Bu, hata mesajlarının errorHandler'a ham olarak gitmesine ve production'da "Bir hata oluştu" şeklinde maskelenmesine yol açar.

**Öncelik:** 🔴 Kritik

---

### 5. `logoutService` Çoklu Cihaz FCM Token'ını Siliyor

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`authService.js`](backend/src/services/authService.js:296-299) | 296-299 | `logoutService` içinde `await prisma.user.update({ data: { fcmToken: null } })` |

**Sorun:** Kullanıcı tek bir cihazdan çıkış yaptığında (logout), tüm cihazlardaki FCM token'ı siliniyor. Kullanıcının başka cihazları varsa push bildirim alamaz hale geliyor.

Not: Schema'da `User.fcmToken` tek bir string alanı — çoklu cihaz desteği için `UserFcmToken` ayrı tablo olmalı.

**Önerilen düzeltme:**
```js
// logoutService: session bazında FCM token temizliği
const session = await prisma.userSession.findUnique({
  where: { id: sessionId },
  select: { platform: true, deviceLabel: true },
});
// İleride: UserFcmToken tablosu eklenerek cihaz bazlı FCM yönetimi
```

**Öncelik:** 🔴 Kritik

---

## 🟡 Orta Öncelikli Bulgular

### 6. `roleMiddleware.js` — `authMiddleware` Sonrası Session Validity Kontrolü Eksik

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`roleMiddleware.js`](backend/src/middlewares/roleMiddleware.js:8) | 8-23 | Sadece `req.user.role` kontrolü yapıyor, session geçerliliğini kontrol etmiyor |

**Sorun:** `authMiddleware` + `roleMiddleware` zinciri session geçerliliğini **(revokedAt, deletedAt)** kontrol etmez. Token geçerliyse, hesap kapatılmış olsa bile yetkilendirme geçer.

**Öncelik:** 🟡 Orta

---

### 7. Flutter: Global `onSessionExpired` Değişkeni

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`auth_provider.dart`](mobile/lib/features/auth/presentation/providers/auth_provider.dart:20) | 20 | `SessionExpiredCallback? onSessionExpired;` global değişken |

**Sorun:** Riverpod'un test edilebilirlik avantajını ortadan kaldırıyor. DI (Dependency Injection) yerine global mutable state kullanımı.

**Önerilen düzeltme:** Callback'i Provider üzerinden geçirin veya event bus pattern kullanın.

**Öncelik:** 🟡 Orta

---

### 8. Due Controller'ların Çoğu asyncHandler Kullanmıyor

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`dueController.js`](backend/src/controllers/dueController.js:14-186) | Tümü | 6 handler'ın hiçbiri `asyncHandler` kullanmıyor |

Aynı durum [`siteController.js`](backend/src/controllers/siteController.js), [`siteExpenseController.js`](backend/src/controllers/siteExpenseController.js), [`ticketController.js`](backend/src/controllers/ticketController.js) için de geçerli.

**Öncelik:** 🟡 Orta

---

### 9. `req.id` Fallback Kullanılıyor Ama `express-request-id` Middleware'i Eksik

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`logger.js`](backend/src/config/logger.js:88) | 88 | `req.id || \`${Date.now()}-${Math.random()}...\`` fallback var |
| [`index.js`](backend/index.js:43-60) | 43-60 | express-request-id middleware mount edilmemiş |

**Sorun:** Proje kuralı RULE-07'ye göre `req.id` kullanımı middleware gerektiriyor. Fallback çalışır ama her request'te `express-request-id` tarafından atanan unique ID daha güvenilirdir.

**Öncelik:** 🟡 Orta

---

### 10. Expense Modellerde Decimal → String Dönüşümü

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`expenseService.js`](backend/src/services/expenseService.js:46-53) | 46-53 | `amount.toString()` ile Decimal → string dönüşümü |

**Sorun:** Backend `Prisma Decimal` tipini JSON'da **number** olarak döner. Flutter tarafında bu direkt `double` parse edilir. `toString()` ile string'e çevrilmesi Flutter model'de tip uyuşmazlığına yol açabilir.

**Öncelik:** 🟡 Orta

---

### 11. Validator Dosyalarında İsimlendirme Tutarsızlığı

| Dosya | Pattern |
|-------|---------|
| [`authSchemas.js`](backend/src/validators/authSchemas.js) | `authSchemas` |
| [`expenseSchemas.js`](backend/src/validators/expenseSchemas.js) | `expenseSchemas` |
| [`authValidator.js`](backend/src/validators/authValidator.js) | `authValidator` |
| [`notificationValidator.js`](backend/src/validators/notificationValidator.js) | `notificationValidator` |

**Öncelik:** 🟡 Orta

---

### 12. `dueService.updateDueStatusService` — `paidAt` Parse Riski

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`dueService.js`](backend/src/services/dueService.js:195) | 195 | `paidAt ? new Date(paidAt) : new Date()` |

**Sorun:** Geçersiz string gelirse `Invalid Date` oluşur. Zod schemas bunu kontrol etmeli — `paidAt` alanı Zod şemasında validation'dan geçmiyor.

**Öncelik:** 🟡 Orta

---

### 13. Flutter Token Refresh Service'de Gereksiz Catch Bloğu

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`token_refresh_service.dart`](mobile/lib/core/network/token_refresh_service.dart:107-109) | 107-109 | `catch (e) { rethrow; }` — hiçbir iş yapmıyor |

**Öncelik:** 🟢 Düşük

---

## 🟢 Düşük Öncelikli Bulgular

### 14. Flutter GET Cache 30s TTL — `beginSessionMutation`/`endSessionMutation` Kullanımı

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`dio_client.dart`](mobile/lib/core/network/dio_client.dart:224-248) | 224-248 | 30 saniyelik in-memory GET cache, token değişiminde temizleniyor |

İyi tasarlanmış. Öneri: Cache süresi environment variable'dan okunabilir.

**Öncelik:** 🟢 Düşük

---

### 15. Flutter TicketModel.fromJson — `createdBy`/`resident` Fallback Mantığı Karmaşık

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`ticket_model.dart`](mobile/lib/features/tickets/data/models/ticket_model.dart:61-82) | 61-82 | `resident` ve `createdBy` alanlarından hangisi doluysa ondan okuma |

**Sorun:** Backend'de ticket entity'si `user` ilişkisi üzerinden sakin bilgisini döner. İki farklı alandan fallback yapmak yerine tek bir kaynaktan okumak daha temiz olur.

**Öncelik:** 🟢 Düşük

---

### 16. KVKK: `reqLogger` Her İstekte `userId` ve `ip` Logluyor

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| [`logger.js`](backend/src/config/logger.js:88-93) | 88-93 | `reqLogger` içinde `userId` ve `ip` alanları loglanıyor |

KVKK kapsamında not: Kişisel veri (IP adresi) loglanıyor. Bu kabul edilebilir bir loglama seviyesi, ancak log retention policy dokümante edilmeli.

**Öncelik:** 🟢 Düşük

---

## Özet İstatistik

| Öncelik | Sayı |
|---------|------|
| 🔴 Kritik | 5 |
| 🟡 Orta | 8 |
| 🟢 Düşük | 3 |
| **Toplam** | **16** |

## Önerilen Aksiyon Sırası

1. **Tüm controller'larda `asyncHandler` kullanımına geçiş** — en yüksek etki, en düşük risk
2. **`authMiddleware`'e session/account validity kontrolü ekleme**
3. **`logoutService` FCM token çoklu cihaz davranışının düzeltilmesi**
4. **`dueController` hata yönetiminin standartlaştırılması**
5. **`authController` logout/forgotPassword HttpError kontrolü eklenmesi**
6. **Global `onSessionExpired` değişkeninin Riverpod Provider'a taşınması**
7. **Validator isimlendirme standardizasyonu**
