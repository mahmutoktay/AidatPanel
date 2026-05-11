# MOBILE ↔ BACKEND — Sözleşme Uyum + Talep Raporu

> **Sürüm:** 2026-05-11 — Mobile Tur 5 tamamlandı, **production APK canlı backend ile çalışıyor ✅**
> **Hedef:** Mobile ↔ Backend (Furkan ↔ Abdullah) için **tek karşılıklı** sözleşme dosyası.
> Mobil tarafın **mevcut durumunu**, **varsayımlarını**, **istediği uçları**, **E2E test edilemediği senaryoları** ve **backend'in karşılayıp karşılamadığını** tek dosyada raporlar.
> **Kural:** Bu dosya **evergreen** — yeni rapor üretilmez, ✅/⏳ işaretleri bu dosya üzerinde güncellenir.

---

## 0. Yönetici Özeti (TL;DR)

| Konu | Durum | Eylem |
|---|---|---|
| Mobile FAZ 1 kodu (Auth + Buildings + Apartments + Dues + Dashboard) | ✅ tamam | — |
| Sözleşmeye tam uyum (`FLUTTER-BACKEND.md` §1-§6) | ✅ uyumlu | — |
| Backend'den istenen uçlar (P0-P2) | ✅ **7/7 açıldı** (sakin çıkar + profil + şifre değiştir + KVKK + şifre sıfırlama + sakin aidat + FCM) | — |
| Eksik uçlar | ⏳ Notifications listesi (P1), Expenses (P1), Tickets (P2), Reports (P2), RevenueCat (P3) — FAZ 2+ | Sprint planına |
| Production APK | ✅ **Canlı backend ile çalışıyor** (2026-05-11) | Furkan FAZ 1 onayı verecek |
| **Mobile Tur 5 (backend uyum)** | ✅ Tamamlandı — sakin çıkarma + bina formu + server-side filter + şifre değiştir + hesap kapat + şifremi unuttum | bkz. §10 |
| **Mobile sıradaki iş** | ⏸ FAZ 2 backend bekliyor (Notifications + Expenses uçları açılınca başlar) | bkz. §0.1 |

**Karar:** Mobile FAZ 1 kodu **production'da canlı**. FAZ 2'ye geçiş için sadece backend Notifications + Expenses uçlarını açmayı bekliyor.

---

## 0.1 🔔 Abdullah'tan açık talepler — şu an aktif

> Furkan, Tur 5 sonrası ve production deploy çalıştıktan sonra **bu blok güncel** —
> tamamlanan/eskimiş talepler `§7` altına çekildi; aşağıda **sadece açık olanlar**.

### 🟠 Hemen (dakikalar / saatler)

| # | İş | Detay | Etki |
|---|----|-------|------|
| 1 | **`GET /buildings` yanıtına `_count.apartments` ekle** (§3.8) | Prisma `include: { _count: { select: { apartments: true } } }` — 1-2 satır | Mobile dashboard kartlarında doğru daire sayısı (şu an placeholder) |
| 2 | **`FLUTTER-BACKEND.md`'yi güncelle** | Tur 2'de açtığın uçların imzaları henüz yok: `DELETE /buildings/:bId/apartments/:id/resident`, `GET/PUT/DELETE /me`, `PUT /me/password`, `PUT /me/language`, `PUT /me/fcm-token`, `POST /auth/forgot-password`, `POST /auth/reset-password` | Sözleşme dosyası mobile ile senkron olur |
| 3 | **Test hesapları + örnek davet kodu paylaş** (opsiyonel) | 1 manager (2 bina, her birinde 4-6 daire, karışık aidat statüleri) + 2-3 sakin + 1 davet kodu | Demo / regresyon testi için faydalı, bloklayıcı değil |

### 🟡 FAZ 2 başlamadan önce (orta vade — mobile bunu bekliyor)

| # | İş | Detay |
|---|----|-------|
| 4 | **Notifications MVP uçları** | `GET /notifications?unreadOnly=` + `PATCH /notifications/:id/read` + `PATCH /notifications/read-all`. Prisma şeması **zaten hazır**, sadece controller + route lazım. (§3.2) |
| 5 | **Expenses MVP uçları** | `GET/POST /buildings/:id/expenses` + `DELETE /buildings/:id/expenses/:expenseId` + makbuz fotoğrafı upload/download. Prisma şeması **zaten hazır**. (§3.3) |
| 6 | **FCM push payload formatı netleşsin** | `data` alanları + deep-link parametreleri (örn. `{type:"DUE_REMINDER", apartmentId:"..."}` → mobile hangi ekrana açar) |

### 🟢 Sonraki fazlar (uzun vade)

| # | İş | Faz |
|---|----|-----|
| 7 | Tickets (§3.4) — arıza/şikayet talepleri | FAZ 3 |
| 8 | Reports (§3.5) — aylık özet + PDF export | FAZ 3 |
| 9 | RevenueCat webhook (§3.6) — abonelik | FAZ 4 |

### ❓ E2E doğrulama soruları (Tur 5 sonrası açık)

Aşağıdakileri kod okuyup ya da bana mesajla teyit edersen `§6` E2E listesini bitirebilirim:

1. `DELETE /buildings/:id` FK ihlali geldiğinde **gerçek hata mesajı ne?** Mobile şu an `foreign|p2003|still|apartment|resident|due` kelimelerini tarayıp insanlaştırıyor — özel Türkçe mesaj döndürürsen regex'imiz kaçırabilir.
2. `PUT /buildings/:bId/apartments/:id` yanıtında `resident` alanı **dönüyor mu**? (Mobile şu an defansif olarak eski resident'i merge ediyor — backend her zaman döndürüyorsa merge kaldırılabilir)
3. `overdueDays` **server-side mi hesaplanıyor** yoksa mobile mı `today - dueDate` yapsın?
4. `dueDate` **UTC mi local mi**? (Timezone netleşmesi)
5. `PUT /me/language` — sunucuda dil tercihi **kalıcı mı** (relogin'de doğru dil geliyor mu)?

---

## 1. Mobile Tarafın Mevcut Durumu

### 1.1 Tamamlanan Modüller (FAZ 0 + FAZ 1)

| Modül | Mobile Durumu | Backend Sözleşmesi |
|---|---|---|
| **Auth** — login (email/phone), register, join (invite code), logout, JWT refresh, restoreSession | ✅ tamam | `POST /auth/login` (`identifier`), `/register`, `/join`, `/logout`, `/refresh` |
| **Buildings** — list, create, edit (name/address/city), delete (FK kontrolü), invite code | ✅ tamam (Tur 3'te edit/delete UI eklendi) | `GET/POST /buildings`, `PUT/DELETE /buildings/:id`, `POST /buildings/:id/invite-codes` |
| **Apartments** — list, create, edit (number/floor), delete | ✅ tamam (Tur 3'te edit/delete UI eklendi) | `GET/POST /buildings/:bId/apartments`, `PUT/DELETE /buildings/:bId/apartments/:id` |
| **Dues** — yönetici listesi, sakin geçmişi, durum güncelleme, aidat tutarı güncelleme | ✅ tamam | `GET /buildings/:id/dues`, `GET /me/dues`, `PATCH /buildings/:bId/dues/:dueId/status`, `PATCH /buildings/:id/due-amount` |
| **Dashboard** — manager + resident özet kartları | ✅ tamam | (özet hesaplamaları client-side) |
| **i18n** — Türkçe + İngilizce, runtime dil değiştirme | ✅ tamam (239 anahtar/dil) | (sunucu tarafı `language` alanı User'da var) |

### 1.2 Backend hazır — mobile UI sırada

| Modül | Backend | Mobile UI |
|---|---|---|
| **Resident remove** (§3.1 P0) | ✅ `DELETE /buildings/:bId/apartments/:id/resident` (commit `8cc2152`) | ✅ UI tamam (Tur 5 §10/1) |
| **Şifre değiştir** (§3.3 P1) | ✅ `PUT /me/password` — `refreshTokenVersion++` | ✅ UI tamam — Settings → Şifre Değiştir bottom sheet (Tur 5 §10/4) |
| **KVKK soft delete** (§3.4 P2) | ✅ `DELETE /me` — yöneticide bina varsa 409 | ✅ UI tamam — Settings → Tehlikeli Bölge → Hesabımı Kapat (Tur 5 §10/5) |
| **Şifre sıfırlama** (§3.2 P1) | ✅ `POST /auth/forgot-password`, `POST /auth/reset-password` | ✅ UI tamam — Login → Şifremi Unuttum + 2 ekran (Tur 5 §10/6) |
| **Profile + Language + FCM** (§3.3 P1) | ✅ `GET/PUT /me`, `PUT /me/language`, `PUT /me/fcm-token` | ⏳ FAZ 2'ye (FCM bildirim bağlandığında) |
| **Sakin aidat listesi** (§3.5 P2) | ✅ `GET /me/dues?status=&year=&month=` | ✅ Çağrılıyor; ek filtre UI'ı eklenecek |

### 1.3 Backend'i hâlâ bekleyen modüller (FAZ 2+)

| Modül | Eksik | Mobile etkisi |
|---|---|---|
| **Notifications** | `GET /notifications`, `PATCH /notifications/:id/read`, `PATCH /notifications/read-all` yok | Bildirim listesi ekranı yok |
| **Expenses** | Tüm uçlar yok | Gider yönetimi yok |
| **Tickets** | Tüm uçlar yok (FAZ 3) | Talep oluşturma yok |
| **Reports** | `GET /buildings/:id/reports/monthly` yok (FAZ 3) | Aylık özet + PDF yok |
| **Subscription** | RevenueCat webhook yok (FAZ 4) | Abonelik akışı yok |

---

## 2. Sözleşmeye Uyum Beyanı

Aşağıdaki tablo, FLUTTER-BACKEND.md §1-§6'da belirtilen sözleşmeye **mobile'ın uyduğu iddiasını** içerir. Backend integration testleri ile karşılıklı doğrulanmalı.

### 2.1 Auth (Belge §3, §4)

| Sözleşme | Mobile'da nasıl |
|---|---|
| `POST /auth/login` body: `{ identifier, password }` (email **veya** phone) | `LoginRequest.identifier` (eski `email` field'ı yeniden adlandırıldı) |
| `POST /auth/logout` Bearer token, refresh token sunucuda invalid edilir | `AuthRepositoryImpl.logout()` önce sunucuya, sonra `SecureStorage.clearAuth()`; sunucu hatası yutuluyor (kullanıcı yine "çıkmış" sayılır) |
| `POST /auth/refresh` 401'de otomatik | `DioClient` interceptor hallediyor; başarısızsa logout |
| JWT exp claim parse | `_parseJwtExpiry` base64Url decode ile alıyor |
| `User.apartmentId` sakin için var, manager için null | `UserEntity.apartmentId` String? |

### 2.2 Buildings (Belge §5)

| Sözleşme | Mobile'da nasıl |
|---|---|
| `GET /buildings` → manager'ın yönettiği binalar | `BuildingsNotifier.loadBuildings` |
| `POST /buildings` body: `name`, `address`, `city`, `totalFloors?`, `apartmentsPerFloor?`, `dueAmount?`, `dueDay?`, `currency?` | `AddBuildingScreen` tüm alanları gönderiyor; submit guard ile rapid-tap engellendi |
| `PUT /buildings/:id` body: `name?`, `address?`, `city?` (kısmi update) | `EditBuildingBottomSheet` sadece değişen alanları body'e koyuyor |
| `DELETE /buildings/:id` → FK varsa 400 | `DeleteBuildingDialog` 400'ü "Bu binayı silemezsiniz: hâlâ daire/sakin/aidat var. Önce daireleri/aidatları temizleyin." mesajına çeviriyor |
| `dueAmount` Decimal — JSON'da string olarak dönebilir | `BuildingModel._toDouble` `num`/`String`/`null` üçünü de kaldırır |

### 2.3 Apartments (Belge §6)

| Sözleşme | Mobile'da nasıl |
|---|---|
| `GET /buildings/:bId/apartments` her dairede `resident: User \| null` nested | `ApartmentModel.resident` → `ResidentModel` parse, entity'ye `ResidentInfo` olarak geçiyor; `apt.isOccupied` getter `resident != null` |
| `POST /buildings/:bId/apartments` body: `number`, `floor?` | `AddBuildingScreen` "fallback seed" loop'u (eğer createBuilding daireleri otomatik açmazsa mobile manuel seed ediyor — bkz. §4.1) |
| `PUT /buildings/:bId/apartments/:id` body: `number?`, `floor?` | `EditApartmentBottomSheet` floor için -5..200 client-side doğrulama |
| `DELETE /buildings/:bId/apartments/:id` → FK varsa 400 | `DeleteApartmentDialog` "Önce sakin hesabını kapatmalı..." mesajına çeviriyor |
| `PUT` yanıtında `resident` dönmüyor | Mobile mevcut sakini merge ediyor (`copyWith(resident: existing.resident)`) — backend her response'ta `resident` döndürürse merge gereksiz olur |

### 2.4 Dues (Belge §7)

| Sözleşme | Mobile'da nasıl |
|---|---|
| `GET /buildings/:id/dues` | `DuesRemoteDataSource.getBuildingDues` |
| `GET /me/dues` (sakin) | `getMyDues` |
| `PATCH /buildings/:bId/dues/:dueId/status` body: `{ status: 'PAID'\|'PENDING'\|'OVERDUE' }` | `manager_dues_tab.dart` `_updateStatus` çağrısı |
| `PATCH /buildings/:id/due-amount` body: `{ dueAmount, dueDay?, currency?, affectCurrent }` | "Aidat tutarı güncelle" formu, `affectCurrent=true` iken liste otomatik tazelenir |
| `Due` response: `id`, `apartmentId`, `apartmentNumber`/`apartment.number`, `month`, `year`, `amount`, `status`, `dueDate?`, `overdueDays` | `DueModel` her ikisini de kaldırıyor (PATCH yanıtında düz `apartmentNumber` gelmiyor, nested `apartment.number` kullanılıyor) |
| `PATCH /me/fcm-token` (FCM token kayıt) | ⏳ FAZ 2'de, henüz çağırmıyoruz |

---

## 3. Backend'den İstenen Yeni Uçlar (Öncelik Sırasıyla)

### ✅ P0 — TAMAMLANDI (Backend hazır, mobile UI sırada)

#### 3.1 Sakin Atama Kaldırma — ✅ TAMAM (commit `8cc2152`)

**Backend açtı:**
```http
DELETE /api/v1/buildings/:buildingId/apartments/:id/resident
Authorization: Bearer <manager_token>
```

**Davranış (kod doğrulandı — `apartmentService.removeResidentFromApartmentService`):**
- `User.apartmentId = null` set edilir; **hesap silinmez**
- Aidat geçmişi (`Due` kayıtları) korunur
- Yetki: sadece binanın yöneticisi
- 403 (yetki yok) / 404 (daire / sakin yok) / 200 (başarı + güncel apartment) yanıtları net

**Mobile durumu:** ✅ UI tamam — `RemoveResidentDialog` widget'ı + `ApartmentsNotifier.removeResidentFromApartment`. `BuildingResidentsScreen` daire kart menüsünde dolu daireler için "Sakini Çıkar" seçeneği görünür; 403/404 mesajları insanlaştırıldı; dev mock da senaryoyu simüle ediyor.

---

### ⏳ P1 — BEKLEMEDE (FAZ 2 başlamak için lazım)

#### 3.2 Notifications

**Mobile FAZ 2 plan:** Bildirim listesi + okundu işaretleme.

| Uç | Method + Path | Önerilen body / response | Durum |
|---|---|---|---|
| Liste | `GET /notifications?unreadOnly=false` | `[{ id, title, body, type, data?, isRead, createdAt }]` | ⏳ yok |
| Okundu işaretle | `PATCH /notifications/:id/read` | 200, `{ id, isRead: true, readAt }` | ⏳ yok |
| Hepsini okundu | `PATCH /notifications/read-all` | 200, `{ updatedCount }` | ⏳ yok |
| FCM token kayıt | `PUT /me/fcm-token` body `{ fcmToken }` | ✅ **AÇILDI** (commit `8cc2152`) — Mobile FAZ 2'de çağıracak | ✅ |

**Backend not:** `Notification` modeli Prisma şemasında **hazır** (DUE_REMINDER, DUE_PAID, TICKET_UPDATE, ANNOUNCEMENT, SYSTEM enum'ları); sadece controller/route eklenmesi gerekiyor.

**Mobile öneri (type enum):** `DUE_REMINDER`, `DUE_OVERDUE`, `EXPENSE_ADDED`, `TICKET_REPLY`, `INVITE_USED`, `SYSTEM` — backend'in mevcut enum'ı ile uyumlu, `DUE_OVERDUE` ve `EXPENSE_ADDED` eklenebilir.

#### 3.3 Expenses

| Uç | Method + Path | Notlar |
|---|---|---|
| Liste | `GET /buildings/:id/expenses` | Yıl/ay filtresi opsiyonel `?year=2026&month=5` |
| Oluştur | `POST /buildings/:id/expenses` body `{ category, amount, description, date }` | category enum: `MAINTENANCE`, `UTILITIES`, `CLEANING`, `STAFF`, `OTHER` |
| Sil | `DELETE /buildings/:id/expenses/:expenseId` | manager only |
| Makbuz fotoğrafı yükle | `POST /expenses/:id/proof` multipart `file` | image/jpeg, image/png; max 5MB |
| Makbuz indir | `GET /expenses/:id/proof` | binary |

---

### 🟡 P2 — ORTA (FAZ 3 için)

#### 3.4 Tickets

| Uç | Method + Path | Notlar |
|---|---|---|
| Liste (manager) | `GET /buildings/:id/tickets?status=OPEN` | filter: status, apartmentId |
| Liste (resident) | `GET /me/tickets` | sakinin kendi talepleri |
| Detay | `GET /tickets/:id` | response: ticket + updates[] |
| Oluştur | `POST /buildings/:id/tickets` body `{ category, title, description, priority? }` | category: `PLUMBING`, `ELECTRIC`, `ELEVATOR`, `COMMON_AREA`, `OTHER` |
| Güncelleme/yanıt ekle | `POST /tickets/:id/updates` body `{ message, statusChange? }` | her iki taraf yazabilir |
| Kapatma | `PATCH /tickets/:id/status` body `{ status: 'CLOSED' }` | manager only |

#### 3.5 Reports

| Uç | Method + Path | Notlar |
|---|---|---|
| Aylık özet | `GET /buildings/:id/reports/monthly?year=2026&month=5` | response: `{ totalDuesExpected, totalCollected, collectionRate, totalExpenses, byCategory[] }` |
| PDF export | `GET /buildings/:id/reports/monthly.pdf?year=2026&month=5` | binary, `application/pdf` |

---

### 🟢 P3 — DÜŞÜK (FAZ 4 için)

#### 3.6 RevenueCat Webhook + Abonelik Durumu

| Uç | Method + Path | Notlar |
|---|---|---|
| Webhook (RevenueCat → backend) | `POST /webhooks/revenuecat` | imza doğrulama |
| Mobile'a abonelik durumu | `GET /me/subscription` | response: `{ planId, status, expiresAt, isTrial }` |

---

### ✅ Backend'in mobile talebi olmadan tamamladığı uçlar (Tur 2'de açıldı)

#### 3.7 Profil + KVKK + Şifre sıfırlama

| Uç | Method + Path | Durum | Mobile UI |
|---|---|---|---|
| Profil görüntüle | `GET /api/v1/me` | ✅ | mevcut (auth provider kullanıyor) |
| Profil güncelle | `PUT /api/v1/me` body `{ name?, phone?, language? }` (en az 1) | ✅ | ⏳ Tur 5 §10/4 |
| Şifre değiştir | `PUT /api/v1/me/password` body `{ currentPassword, newPassword }` → `refreshTokenVersion++` (oturum biter) | ✅ | ⏳ Tur 5 §10/4 |
| Dil değiştir | `PUT /api/v1/me/language` body `{ language: "tr"\|"en" }` | ✅ | ⏳ mevcut local i18n yeterli, sunucuya yazma opsiyonel |
| FCM token kayıt | `PUT /api/v1/me/fcm-token` body `{ fcmToken }` (10–4096 char) | ✅ | ⏳ FAZ 2'de Firebase entegrasyonu sonrası |
| KVKK soft delete | `DELETE /api/v1/me` → PII maskelenir; **yöneticide bina varsa 409** | ✅ | ⏳ Tur 5 §10/5 (409 mesajı insanlaştırılacak) |
| Şifremi unuttum | `POST /api/v1/auth/forgot-password` body `{ email }` (her zaman 200, leak yok) | ✅ | ⏳ Tur 5 §10/6 |
| Şifre sıfırla | `POST /api/v1/auth/reset-password` body `{ token (6 char), password }` | ✅ | ⏳ Tur 5 §10/6 |

#### 3.8 Backend'in talep tablosuna eklemesi istenen küçük iyileştirme (mobile P3)

| Uç | İstek | Gerekçe |
|---|---|---|
| `GET /api/v1/buildings` | Yanıta `_count: { apartments }` (ve mümkünse `_count: { occupiedApartments }`) ekle | Mobile dashboard'da bina kartında doğru daire sayısını göstermek için. Şu an mobile `totalFloors × apartmentsPerFloor` ile placeholder hesaplıyor; sonradan daire eklenince/silinince sapma olur. |

---

## 4. Mobile Varsayımları — Backend kod doğrulaması

> Tur 2'de Abdullah'ın `backend/yedek` branch'inden kod okunarak doğrulandı (commit `5a24c37`).

### 4.1 createBuilding sonrası daire seed'i — ✅ DOĞRULANDI

**Backend davranışı (`buildingService.createBuildingService`):**
- `POST /api/v1/buildings` body'sinde `totalFloors` + `apartmentsPerFloor` (default: 1, 2) verilirse, **tek transaction** içinde `kat × daire/kat` adet daire (1A, 1B, 2A, 2B…) oluşturulur
- `dueAmount` da verilmişse, bulunulan aydan **yıl sonuna kadar** her daire için `PENDING` due üretilir (Europe/Istanbul tabanlı `dueDate`)
- Transaction `maxWait: 10s, timeout: 60s`

**Mobile aksiyon:** ✅ Tur 5 §10/2'de tamamlandı. `_seedApartmentsIfNeeded` fallback loop'u kaldırıldı; form `totalFloors`+`apartmentsPerFloor` artık zorunlu (1-200 / 1-50 range validator); `MockBuildingRepository.createBuilding` backend davranışını birebir simüle ediyor (tek "transaction"da apartments seed).

### 4.2 Logout sırasında sunucu hatası tolere ediliyor — ✅ KABUL EDİLDİ

**Backend davranışı (`authControllers.logout`):** `refreshTokenVersion++` + 200. Sunucu hatası olursa mobile yine yerel temizliği yapar; refresh token sunucuda da kısa süre sonra `rv` mismatch ile geçersizleşir. Kabul edilen trade-off.

### 4.3 PATCH dues status yanıtında `apartmentNumber` — ✅ DOĞRULANDI

**Backend (`dueService.updateDueStatusService`):** Yanıt root'unda `apartmentNumber` döner (`apartment.number` üzerinden alınıp düzleştirilir). Mobile defansif `apartment.number` fallback'i artık gereksiz ama bırakılabilir (regresyon yok).

### 4.4 `DELETE /me` (KVKK soft delete) — ✅ DOĞRULANDI + 409 koşulu

**Backend (`meService.softDeleteAccountService`):**
- `User.deletedAt = now`, `email → ghost`, `phone → null`, `name → "Silinmiş kullanıcı"`, `passwordHash` rastgele, `apartmentId = null`, `fcmToken = null`, `refreshTokenVersion++`
- `PasswordResetToken` kayıtları silinir (cascade)
- **409 koşulu:** Kullanıcının yönettiği bina varsa: *"Yönettiğiniz bina kayıtları varken hesap kapatılamaz. Önce binaları silin veya başka yöneticiye devredin."*
- Aidat geçmişi (`Due` kayıtları) silinmez ✅

**Mobile aksiyon:** Tur 5 §10/5'te Ayarlar → "Hesabı Kapat" UI'ı bu mesajı insanlaştırılmış olarak gösterecek.

### 4.5 `affectCurrent=true` davranışı — ✅ DOĞRULANDI

**Backend (`dueService.updateBuildingDueAmountService`):** `affectCurrent=true` iken sadece `status: "PENDING"` due'lar `updateMany` ile güncellenir; PAID/OVERDUE/WAIVED dokunulmaz. Mobile `dev_mocks` davranışı zaten birebir bunu simüle ediyor.

**Tur 5 §10/3 ek davranış:** `affectCurrent=true` sonrası mobile listeyi tazelerken **kullanıcının aktif filtre setini koruyor** (`_lastMonth/_lastYear/_lastStatus`); filtre seçimi update sırasında kaybolmuyor.

### 4.6 Bina yanıtında apartment count — ⚠️ EKSİK

**Backend (`buildingService.getBuildingsService`):** Sadece Building model alanları döner; `_count.apartments` veya benzeri yok.

**Mobile aksiyon:** §3.8'de küçük P3 talep olarak Abdullah'a iletildi. O eklenene kadar mobile `totalFloors × apartmentsPerFloor` placeholder'ı kalır.

---

## 5. Backend'den Saptığımız Noktalar (NONE)

Mobile FAZ 1 sözleşmeye **tamamen uydu** — sapma yok. Eski sürümde 3 kritik mismatch vardı, hepsi düzeltildi:

| Eski yanlış | Düzeltme |
|---|---|
| `PATCH /dues/:id/status` (yanlış path) | `PATCH /buildings/:bId/dues/:dueId/status` |
| `GET /apartments/:id/dues` (yok) | Kaldırıldı; sakin için `GET /me/dues`, manager için `GET /buildings/:id/dues` |
| `POST /buildings/:id/dues/bulk` (yok) | Kaldırıldı; yerine `PATCH /buildings/:id/due-amount` ile `affectCurrent` flag |
| `LoginRequest.email` (yanlış field adı) | `identifier` (email **veya** phone) |
| `Apartment.resident` parse edilmiyordu | `ResidentInfo` value object + `ResidentModel` parse |
| `BuildingModel.toEntity` city'yi address'e concat ediyordu | `BuildingEntity.city` ayrı alan + `displayAddress` getter |

---

## 6. E2E Test Edilemeyen Senaryolar (Sunucu Lazım)

Aşağıdaki akışlar mobile dev preview'inde mock'larla çalışıyor; gerçek backend ile karşılıklı doğrulama yapılmalı.

### 6.1 Auth akışları
- [ ] Login (email + phone iki yol)
- [ ] Register → email doğrulama (varsa)
- [ ] Join (invite code) — sakin daireye doğru bağlanıyor mu?
- [ ] JWT refresh — interceptor 401'i yakalıyor, transparently yeniliyor
- [ ] restoreSession (cold start) — token süresi dolmuş ise refresh deniyor
- [ ] Logout — sunucu hatası simülasyonu (network drop)

### 6.2 Buildings + Apartments
- [ ] `POST /buildings` sonrası daireler otomatik seed mi (§4.1 sorusu)?
- [ ] `DELETE /buildings/:id` FK senaryosu — gerçek Prisma hata mesajı `humanize()` regex'imize takılıyor mu? (Mobile şu an `foreign|p2003|still|apartment|resident|due` kelimeleri içeren mesajı insanlaştırıyor; backend gerçek mesajı paylaşmalı)
- [ ] `DELETE /buildings/:bId/apartments/:id` FK senaryosu (sakinli daire)
- [ ] `PUT /buildings/:bId/apartments/:id` yanıtında `resident` dönüyor mu (§2.3 satır 5 sorusu)?

### 6.3 Dues
- [ ] `GET /buildings/:id/dues` ay/yıl bazında doğru filtreleme
- [ ] `PATCH .../dues/:dueId/status` üç durum geçişi (PAID/PENDING/OVERDUE)
- [ ] `PATCH /buildings/:id/due-amount` `affectCurrent=true` iken **sadece** PENDING aidatlar mı güncelleniyor (PAID olanlar dokunulmamalı)?
- [ ] `overdueDays` server-side hesaplanıyor mu yoksa mobile tarafında `today - dueDate` yapılması mı gerek?
- [ ] `dueDate` UTC mi local mi, timezone netleşmeli

### 6.4 Invite Code
- [ ] Davet kodu oluşturma → kullanım → expire (varsa)
- [ ] Aynı koda 2 sakin denerse ne oluyor (race condition)?
- [ ] Manager invite code'u tekrar üretebiliyor mu (eski kod invalid mı oluyor)?

### 6.5 i18n
- [ ] `PUT /me/language` — sunucuda dil tercihi kalıcı mı (relogin'de doğru dil)?
- [ ] Notification mesajları sunucudan kullanıcının diline göre mi geliyor (FAZ 2 başladığında)?

---

## 7. Backend Ekibinden İstenen Aksiyonlar — Tarihsel kayıt

> **Güncel açık talepler için bkz. §0.1.** Bu bölüm tarihsel — Tur 1-5 boyunca
> backend'den istenen maddelerin tamamlanma durumunu izlemek için tutuluyor.

### Tur 1-2 (mobile FAZ 1 öncesi/sırasında istenenler)
1. ✅ ~~**Staging URL paylaş**~~ — production deploy edildi (2026-05-11), gerek kalmadı
2. ✅ ~~**`ALLOWED_ORIGINS`** mobile production / staging için güncellensin~~ — production APK çalıştığına göre tamam
3. ⏳ **Test kullanıcı hesapları** (§0.1 / madde 3'e taşındı)
4. ⏳ **`GET /buildings` yanıtına `_count.apartments`** ekle (§3.8 — §0.1 / madde 1'e taşındı)
5. ⏳ **`FLUTTER-BACKEND.md` güncelleme** — eklenen P0/P1/P2 uçlarının imzaları (§0.1 / madde 2'ye taşındı)

### Tur 2 sonrası backend'in mobile talebi olmadan açtığı uçlar
✅ Resident remove, profil, şifre değiştir, KVKK, şifre sıfırlama, FCM token, sakin aidat
(Detay: §3.7 + §1.2)

### FAZ 2 öncesi orta vade
6. ⏳ **Notifications uçları** (§3.2) — §0.1 / madde 4
7. ⏳ **Expenses uçları** (§3.3) — §0.1 / madde 5
8. ⏳ **FCM push payload formatı** netleştir — §0.1 / madde 6

### Uzun vade (FAZ 3-4 için, daha sonra)
9. **Tickets** (§3.4), **Reports** (§3.5) — §0.1 / madde 7-8
10. **RevenueCat webhook** (§3.6) — sözleşme + güvenlik (HMAC imza) — §0.1 / madde 9
11. Plan §11–13: otomatik test suite (Vitest + supertest), `AIDATPANEL.md` doc senkronu, deploy checklist

---

## 8. Mobile'ın Şu Anki Çalıştırma Modları

| Mod | Komut | Davranış |
|---|---|---|
| Production | `flutter run` | Gerçek backend'e bağlanır (`api_constants.dart` base URL) |
| Dev preview (offline) | `flutter run -t lib/main_dev.dart` | In-memory mock repository'ler, otomatik manager girişi, sağ üstte `DEV` rozeti |

Dev preview ile UI değişiklikleri staging beklenmeden test edilebilir. Backend ekibi staging'e deploy edince mobile production mod ile E2E test'e geçer.

---

## 9. İletişim

| Taraf | Sorumlu | Branch | Sözleşme dosyası |
|---|---|---|---|
| **Mobile (Flutter)** | **Furkan** | `mobile/app` | `resources/MOBILE-TO-BACKEND.md` (bu dosya) — talepler + uyum beyanı |
| **Backend (Node + Express + Prisma)** | **Abdullah** | `backend/yedek` | `FLUTTER-BACKEND.md` — API sözleşmesi |
| **Faz takibi (her iki taraf)** | Furkan koordinasyon | `mobile/app` | `resources/FAZ_DURUMU.md` |

**Senkronizasyon kuralı:** Bu dosya ve `FLUTTER-BACKEND.md` her sprint başında **karşılıklı** güncellenmeli; iki tarafın da onayı olmadan üretime alınma yapılmaz.

**İletişim önceliği:**
- Mobile UI için backend hazır olan tüm uçlar — Furkan §10 sırasıyla tek tek bağlar; Abdullah'ı bloklamaz
- Backend'den istenen küçük iyileştirme (§3.8 `_count.apartments`): GitHub issue veya direkt mesaj
- §6'daki E2E koşumu staging URL alındıktan sonra; sonuçlar bu dosyada §11 olarak işaretlenir

---

## 10. Mobile aksiyon listesi (Tur 5 — Backend uyum)

> Backend §3 P0–P2 hazır. Mobile sırayla şu UI'ları bağlayacak. Liste evergreen — tamamlananlar `[x]` işaretlenir.

| # | İş | Backend ucu | Tahmini süre | Durum |
|---|-----|-------------|--------------|-------|
| 1 | **Sakin çıkarma UI** — `BuildingResidentsScreen` daire kart menüsüne "Sakini Çıkar", AlertDialog onayı, `apartmentsStoreProvider` invalidate | `DELETE /apartments/:id/resident` ✅ | 1.5 saat | [x] |
| 2 | **Bina formu uyumu** — `AddBuildingScreen`'de `totalFloors` + `apartmentsPerFloor` zorunlu, validation 1-200 / 1-50; `_seedApartmentsIfNeeded` fallback loop'u kaldır (backend zaten seed ediyor) | `POST /buildings` ✅ | 2 saat | [x] |
| 3 | **Server-side dues filter** — `manager_dues_tab.dart` ay/yıl filtresi değişince repo'ya `month`/`year` query gönder; client-side filtreleme kalksın (büyük listede performans) | `GET /buildings/:id/dues?month=&year=` ✅ | 1.5 saat | [x] |
| 4 | **Ayarlar tab** — Şifre değiştir formu (`PUT /me/password` → `refreshTokenVersion++` olduğu için otomatik logout) | `PUT /me/password` ✅ | 2 saat | [x] |
| 5 | **Hesabı kapat UI** — Ayarlar tab'da tip-to-confirm; **409 yöneticide bina var** mesajını insanlaştır ("Önce binaları sil/devret") | `DELETE /me` ✅ | 1 saat | [x] |
| 6 | **Şifremi unuttum** — Login ekranında link + 2 ekran (email gir → 6 karakter kod + yeni şifre) | `POST /auth/forgot-password` + `POST /auth/reset-password` ✅ | 3 saat | [x] |

**Toplam tahmin:** ~11 saat — sıra tamamlandığında mobile FAZ 1'in **tüm backend ucu** karşılanmış olur. FAZ 2 (Notifications + Expenses) backend kalanını bekleyecek.

---

> **Bir sonraki güncelleme:** Backend §0.1'deki maddeler tamamlandıkça oradan kaldırılır, §1.2'ye geçer ve §10'a karşılık gelen mobile UI satırı eklenir. FAZ 2 başlama tetikçisi: §0.1 / madde 4 (Notifications) **veya** madde 5 (Expenses) açılması.
