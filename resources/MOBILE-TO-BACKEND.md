# MOBILE → BACKEND — Sözleşme Uyum + Talep Raporu

> **Sürüm:** 2026-05-10 (FAZ 1 tamamlandı, FAZ 2 backend bekliyor)
> **Hedef:** backend ekibinin `FLUTTER-BACKEND.md` dosyasının ters yönü.
> Mobil tarafın **mevcut implementasyon durumunu**, **sözleşmeden saptığı varsayımları**, **eksik gördüğü uçları** ve **E2E test edilemediği senaryoları** tek dosyada raporlar.
> **Kullanım:** backend ekibi bu dosyayı okur, bizden gelen talepleri görür; sonraki sprint'te hangi uçları açacaklarını planlar.

**Çapraz referans — teknik sözleşme:** HTTP path’leri, istek/yanıt gövdeleri ve backend’in sıradaki iş özeti repo kökünde [`FLUTTER-BACKEND.md`](../FLUTTER-BACKEND.md) dosyasında (§1–§10) tekleştirilir. Bu belge **mobil perspektiften** talep ve E2E raporudur; uç tanımı veya davranış çelişkisinde **repo kodu + `FLUTTER-BACKEND.md`** esas alınır.

---

## 0. Yönetici Özeti (TL;DR)

| Konu | Durum | Eylem |
|---|---|---|
| Mobile FAZ 1 (Auth + Buildings + Apartments + Dues + Dashboard) | ✅ kod tamam, dev preview'de manuel test edildi | Sunucu staging'e alınmalı, E2E doğrulama yapılmalı |
| Sözleşmeye tam uyum ([`FLUTTER-BACKEND.md`](../FLUTTER-BACKEND.md) §1–§8) | ✅ uyduğumuzu iddia ediyoruz | Backend integration testleri ile karşılıklı doğrulama |
| Mobile'ın istediği yeni uçlar | 🔴 7 uç açılmalı (öncelik tablosu §3) | Backend sprint planına alınmalı |
| Sunucu çalışmadığı için E2E doğrulanmayan akışlar | ⚠️ §6'da liste var | Staging deploy + test hesabı ile çözülür |
| Sakin atama kaldırma ucu | 🔴 yok, mobile UI gizli | Açılana kadar mobile'da gösterilmiyor |

**Kritik talep:** Backend FAZ 2 modüllerinden **en az bir tanesi** (notifications **veya** expenses) staging'e alınana kadar mobile FAZ 2 başlatamıyor. Mobile şu an dev preview'de mock'larla çalışıyor; gerçek API olmadan UI iyileştirmeleri ve teknik borç dışında ilerleyemiyoruz.

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

### 1.2 Tamamlanmayan Modüller (Backend'i bekliyor)

| Modül | Eksik | Yapılamayan |
|---|---|---|
| **Notifications** | `GET /notifications`, `PATCH /notifications/:id/read` yok | Bildirim listesi ekranı |
| **Expenses** | Tüm uçlar yok | Gider yönetimi |
| **Tickets** | Tüm uçlar yok | Talep oluşturma + takip |
| **Reports** | `GET /buildings/:id/reports` yok | Aylık özet rapor + PDF export |
| **Subscription** | RevenueCat webhook yok | Abonelik akışı (mobile SDK eklenebilir ama webhook olmadan sunucuda durum yok) |
| **Resident management** | Sakin çıkarma ucu yok (§3.1) | Manager dairedeki sakini çıkaramıyor |

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

### 🔴 P0 — KRİTİK (FAZ 1 tamamlandığı için ilk açılması gereken)

#### 3.1 Sakin Atama Kaldırma

**Sorun:** Manager bir daireden sakini çıkaramıyor.

**Belge'de durum:** Yok. `PUT /buildings/:bId/apartments/:id` body sadece `number`, `floor` kabul ediyor; `resident` veya `residentId` parametresi yok.

**Önerilen uç (iki seçenek):**

```http
DELETE /buildings/:bId/apartments/:apartmentId/resident
Authorization: Bearer <manager_token>
```

veya:

```http
PATCH /buildings/:bId/apartments/:apartmentId
Authorization: Bearer <manager_token>
Content-Type: application/json

{ "residentId": null }
```

**Yetkilendirme:** Sadece binanın manager'ı çağırabilir.

**Yan etki tartışması:** Sakinin geçmiş aidat kayıtları silinmemeli (history korunmalı), sadece `apartments.residentId = null` ve `users.apartmentId = null` set edilmeli. Sakin hesabı **silinmez**, sadece bağlantı kopar — tekrar başka davet kodu ile başka daireye katılabilir.

**Mobile durumu:** UI'da hiç gösterilmiyor (sakin çıkarma butonu yok). Açıldığında BuildingResidentsScreen daire kart menüsüne 3. seçenek olarak eklenecek. Tahmini geliştirme: 1 saat.

---

### 🟠 P1 — YÜKSEK (FAZ 2 başlatılabilmesi için)

#### 3.2 Notifications

**Mobile FAZ 2 plan:** Bildirim listesi + okundu işaretleme.

| Uç | Method + Path | Önerilen body / response |
|---|---|---|
| Liste | `GET /notifications?unreadOnly=false` | `[{ id, title, body, type, data?, isRead, createdAt }]` |
| Okundu işaretle | `PATCH /notifications/:id/read` | 200, `{ id, isRead: true, readAt }` |
| Hepsini okundu | `PATCH /notifications/read-all` | 200, `{ updatedCount }` |
| FCM token kayıt | `PUT /me/fcm-token` body `{ token }` | ✅ canlı (Belge §4) — sadece doğrula |

**Notification type enum önerisi:** `DUE_REMINDER`, `DUE_OVERDUE`, `EXPENSE_ADDED`, `TICKET_REPLY`, `INVITE_USED`, `SYSTEM`.

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

## 4. Mobile Tarafın Yaptığı Varsayımlar (Backend Onaylasın)

### 4.1 createBuilding sonrası daire seed'i

**Şu anki davranış:** `AddBuildingScreen._seedApartmentsIfNeeded` — bina yaratıldıktan sonra `GET /buildings/:id/apartments` çağırıp boş gelirse mobile manuel olarak `totalFloors × apartmentsPerFloor` daire açıyor (`POST /buildings/:bId/apartments` döngüsü).

**Soru:** Backend `POST /buildings` sırasında `totalFloors` ve `apartmentsPerFloor` parametrelerini kullanarak daireleri otomatik seed ediyor mu? Eğer **evet**, mobile fallback loop'u gereksiz yere tekrar yaratmaya çalışıyor (mock testte sorun yok ama gerçek API'de duplicate olursa hata alabilir).

**Talep:**
- Backend bu davranışı `FLUTTER-BACKEND.md §5.2`'ye netleştirmeli (otomatik seed var mı?)
- Eğer otomatik seed varsa mobile fallback loop'u silinmeli
- Eğer yoksa backend'e taşınmalı (atomik transaction içinde) — şu an mobile'da iki ayrı network round-trip var, ortada koparsa bina var, daireler eksik

### 4.2 Logout sırasında sunucu hatası tolere ediliyor

**Davranış:** `AuthRepositoryImpl.logout()` önce `POST /auth/logout` çağırıyor; hata olsa bile `try/catch (_)` ile yutuluyor, sonra local `SecureStorage.clearAuth()` her durumda yapılıyor.

**Gerekçe:** Sunucu down iken kullanıcı yine "çıkmış" görünmeli; refresh token sunucuda invalidate edilemese bile local token siliniyor.

**Soru:** Backend bu davranışı kabul ediyor mu? Yoksa mobile sunucu yanıtını bekleyip retry mi yapsın? (Mobile'ın görüşü: kullanıcı deneyimi açısından mevcut davranış doğru; refresh token expiry zamanı zaten kısa, kalan süre boyunca kötü kullanım riski sınırlı.)

### 4.3 PATCH `/buildings/:id/dues/:dueId/status` yanıtında `apartmentNumber`

**Davranış:** Mobile `DueModel.fromJson` PATCH yanıtında düz `apartmentNumber` alanı yoksa `apartment.number` nested fallback'ine düşüyor.

**Soru:** Backend PATCH yanıtında her zaman `apartmentNumber` döndürebilir mi (GET ile tutarlı)? Şu an mobile defansif kod ile her iki şekli de kaldırıyor ama tutarlılık daha iyi.

### 4.4 `DELETE /me` (KVKK soft delete) sakin hesabı

**Mobile'ın varsayımı:** Sakin `DELETE /me` çağırınca:
1. `users.deletedAt` set edilir (soft delete)
2. `apartments.residentId = null` (daire boşalır)
3. Geçmiş `dues` kayıtları silinmez (audit için kalır)

**Soru:** Backend bu davranışı yapıyor mu? Manager hesabı `DELETE /me` çağırırsa ne oluyor (binaları varsa 409 mı dönüyor)?

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

## 7. Backend Ekibinden İstenen Aksiyonlar

Teknik öncelik kodu ve kısa iş listesi için bkz. [`FLUTTER-BACKEND.md`](../FLUTTER-BACKEND.md) **§9 Backend — yapılacaklar planı** (B1–B11). Aşağıdaki maddeler operasyon ve iletişim odaklıdır.

### Kısa vade (1 hafta)
1. **Staging ortamı kur** ve mobile'a `.env` dosyası ile API base URL paylaş
2. **Test kullanıcı hesapları** oluştur:
   - 1 manager hesabı (en az 2 binası, her birinde 4-6 daire)
   - 2-3 sakin hesabı (farklı dairelerde)
   - Davet kodu örneği
3. **Postman collection** veya **OpenAPI/Swagger spec** paylaş — mobile karşı taraftan otomatik doğrulama yapabilsin
4. **§4.1 sorusu** — createBuilding otomatik seed yapıyor mu, [`FLUTTER-BACKEND.md`](../FLUTTER-BACKEND.md) §5 `POST /buildings` notlarına netleştir

### Orta vade (2-3 hafta — FAZ 2 başlamadan önce)
5. **Sakin çıkarma ucu** (§3.1) açılmalı — UI hazır, sadece backend bekliyor
6. **Notifications uçları** (§3.2) MVP — minimum `GET /notifications` ve `PATCH /notifications/:id/read`
7. **FCM push payload formatı** netleştir (data alanları, deep-link parametreleri)

### Uzun vade (FAZ 3-4 için, daha sonra)
8. **Expenses** (§3.3), **Tickets** (§3.4), **Reports** (§3.5)
9. **RevenueCat webhook** (§3.6) — sözleşme + güvenlik (HMAC imza)

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
| **Backend (Node + Express + Prisma)** | **Abdullah** | `backend/yedek` | [`FLUTTER-BACKEND.md`](../FLUTTER-BACKEND.md) — API sözleşmesi + backend iş planı (§9) |
| **Faz takibi (her iki taraf)** | Furkan koordinasyon | `mobile/app` | `resources/FAZ_DURUMU.md` |

**Senkronizasyon kuralı:** Bu dosya ve `FLUTTER-BACKEND.md` her sprint başında **karşılıklı** güncellenmeli; iki tarafın da onayı olmadan üretime alınma yapılmaz.

**İletişim önceliği:**
- Acil P0 (sakin çıkarma ucu, §3.1): Furkan → Abdullah doğrudan, GitHub issue veya direkt mesaj
- P1-P2 talepler (§3.2-§3.5): sprint planlamasında karşılıklı görüşülür
- §4'teki varsayım soruları: Abdullah `FLUTTER-BACKEND.md`'ye yorum/güncelleme olarak cevap verir, Furkan PR ile karşılıklı doğrulama yapar

---

> **Bir sonraki güncelleme:** Backend §3.1 (sakin çıkarma) ucu açıldıktan veya §6'daki E2E test sonuçları geldikten sonra bu dosyaya "Karşılıklı Test Sonuçları" §10 bölümü eklenecek.
