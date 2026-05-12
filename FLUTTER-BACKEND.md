# AidatPanel — API sözleşmesi, backend planı ve mobil yol haritası

Bu belge **`AidatPanel/backend`** (Express, Prisma) için **`/api/v1`** altındaki **canlı sözleşmeyi** tanımlar; ayrıca backend ekibinin sıradaki işlerini ve **henüz mobilde bağlanmamış / backend’i bekleyen** adımları listeler.

> **Tek kaynak (davranış):** `backend/src/...` ve bu dosyadaki tablolar. Eski `AIDATPANEL.md` veya sabitler çelişirse **kod + bu belge** esas alınır.

> **Mobil (`mobile/app`):** Faz 1 kapsamındaki istemci uygulaması bu sözleşmeyle uyumlu kabul edilir; bu belgede **Faz 1 için Flutter dosya eşlemesi ve tamamlanmış kontrol listesi tutulmaz** — aşağıda yalnızca **kalan** mobil adımlar özetlenir.

**Çapraz referans — mobil talep raporu:** [`resources/MOBILE-TO-BACKEND.md`](resources/MOBILE-TO-BACKEND.md) — mobil taraftan backend’e uyum beyanı, varsayımlar, eksik uç talepleri ve E2E kontrol listesi. Bu belgedeki **§9 Backend planı** öncelikleri o raporla hizalanır.

---

## 1) Genel kurallar

| Konu | Değer |
|------|--------|
| Kök URL | `{BASE}/api/v1` — örn. `https://api.aidatpanel.com/api/v1` |
| İstemci `baseUrl` | Host + `/api/v1` birleştirilir; path’te **çift** `/api/v1` oluşmaz |
| Header | `Content-Type: application/json` |
| Yetki | Korumalı uçlar: `Authorization: Bearer <accessToken>` |
| Başarı | `{ "success": true, "data": ... }` ve/veya `"message"` |
| Hata | `{ "success": false, "message": "..." }`; validasyonda `"errors": [{ "field", "message" }]` (HTTP **400**) |
| Sayı (JSON) | Bina oluşturma / aidat bedeli gibi gövdelerde **number** gönderilir (tırnaklı string değil) |
| `Decimal` (Prisma) | Yanıtta çoğu alan **string** (örn. `"600.00"`); istemci güvenli parse etmeli |
| Tarih | ISO 8601 string |

### Roller

| Rol | Uçlar |
|-----|--------|
| **MANAGER** | `/buildings/**`, `/buildings/:buildingId/apartments/**`, `POST /apartments/:apartmentId/invite-code`, `/me` **hariç** `GET /me/dues` |
| **RESIDENT** | `GET /me/dues` + tüm `/me` (profil, şifre, dil, FCM, hesap kapatma) |

### Oturum

- **Access JWT:** `id`, `role` — süre `JWT_EXPIRES_IN` (örn. `15m`).
- **Refresh JWT:** `id`, `role`, `rv` (`refreshTokenVersion`).
- **`POST /auth/logout`** (Bearer access): `refreshTokenVersion` artar; aynı refresh ile **`POST /auth/refresh`** → **401**.
- Çıkışta: **`POST /auth/logout`** zorunlu; ardından istemci yerel oturumu siler.

### Rate limit

- `/api/v1` genel: ~15 dk / 100 istek (IP).
- `/api/v1/auth/*`: ek limit; çoklu **başarısız** deneme **429** verebilir.

---

## 2) Ortak veri modelleri (yanıt şekilleri)

### 2.1 `User` (login / join / `GET|PUT /me` `data`)

Alanlar: `id` (uuid), `email`, `name`, `role` (`MANAGER` \| `RESIDENT`), `phone` (null olabilir), `language` (`tr` \| `en`), `apartmentId` (null veya uuid), `createdAt`, `updatedAt`.

### 2.2 `RegisterData` (`POST /auth/register` → `data`)

`user`: **string** (kullanıcı uuid’si). Diğer alanlar `User` ile aynı (`token` yok).

### 2.3 `Building` (Prisma)

Örnek alanlar: `id`, `name`, `address`, `city`, `totalFloors`, `apartmentsPerFloor`, `managerId`, `dueAmount` (string \| null), `dueDay`, `currency`, `createdAt`, `updatedAt`. **`GET /buildings`** yanıtında her kayıt için **`_count`**: `{ apartments: number }` (Prisma relation count). **`apartments`** dizisi yalnızca **POST /buildings** sonrası include ile gelir; liste uçlarında tam daire listesi dönmez.

### 2.4 `Apartment`

`id`, `buildingId`, `number`, `floor` (int \| null), `createdAt`. Liste (`GET .../apartments`): **`resident`** = ilişkili `User` kaydı veya **null** (daire boşsa). İstemci yalnızca `id`, `name`, `email`, `phone`, `role`, `language` vb. kullanmalı; **`passwordHash` veya `refreshTokenVersion` gibi alanlar yanıtta dönmemeli** — backend bu liste (ve `DELETE .../resident` yanıtı) için `resident` alanında güvenli `select` kullanır.

### 2.5 `InviteCode` (`POST .../invite-code` → `data`)

`id`, `apartmentId`, **`code`** (`AP` + 1 hex + `-` + 3 hex + `-` + 4 hex, örn. `AP3-B12-A9F0` — toplam **14** karakter; eski üretim `AP99-C1F6-48` biçimi kullanımdan kalktı), `expiresAt`, `usedAt` (null veya ISO). **`POST /auth/join`** istemcisi `inviteCode` değerini boşluklu / küçük harfli gönderirse sunucu trim + büyük harf + iç boşluk silerek eşleştirir.

### 2.6 `Due` — yönetici (`GET /buildings/:id/dues` vs. `PATCH .../dues/:dueId/status`)

Prisma `Due` alanları artı düz alanlar:

- `id`, `apartmentId`, `amount` (string), `currency`, `month`, `year`, `dueDate`, `status` (`PENDING` \| `PAID` \| `OVERDUE` \| `WAIVED`), `paidAt`, `overdueDays`, `note`, `createdAt`, `updatedAt`
- **`apartmentNumber`**: string (daire no)
- **`GET .../dues`**: **`apartment`**: `{ id, number, floor }`; **`resident`**: `User` \| **null**
- **`PATCH .../status` yanıtı**: **`apartment`**: `{ id, number }` (floor yok); **`resident`** yok

### 2.7 `Due` — sakin (`GET /me/dues`)

Yukarıdaki due alanları +:

- `apartmentNumber`, `apartment`: `{ id, number }`
- **`building`**: `{ id, name, address }`
- **`resident`** alanı bu listede yok (sakin kendi kaydıdır).

---

## 3) Auth (`/api/v1/auth`)

Tüm auth uçları **Bearer gerektirmez** (logout hariç aşağıda).

### `POST /auth/register`

| | |
|--|--|
| **Body** | `name` string 2–50; `email` geçerli email; `password` string 6–100; `phone` opsiyonel string 10–15 veya atlanır / `""` → yok sayılır |
| **201 `data`** | `RegisterData` (bkz. §2.2) |
| **409** | Email veya telefon zaten kullanılıyor |

### `POST /auth/login`

| | |
|--|--|
| **Body** | `identifier` string (email **veya** telefon); `password` string |
| **200 `data`** | `{ accessToken, refreshToken, user: User }` |
| **401** | Kimlik bilgisi hatalı veya hesap kapatılmış |

### `POST /auth/refresh`

| | |
|--|--|
| **Body** | `{ refreshToken: string }` |
| **200 `data`** | `{ accessToken: string }` — **yeni refresh dönmez** |
| **401** | Geçersiz refresh veya logout sonrası sürüm uyuşmazlığı |

### `POST /auth/logout`

| | |
|--|--|
| **Header** | `Authorization: Bearer <access>` |
| **Body** | Yok |
| **200** | `{ success, message }` — refresh iptali |

### `POST /auth/join`

| | |
|--|--|
| **Body** | `name`, `email`, `password` (register ile aynı kurallar); **`inviteCode`** — sunucunun ürettiği `APX-XXX-XXXX` (14 karakter); istemci trim/büyük harf farkı tolere edilir; `phone` opsiyonel |
| **201 `data`** | `{ accessToken, refreshToken, user: User }` — `user.role` = `RESIDENT`, `apartmentId` dolu |
| **400** | Geçersiz / süresi dolmuş davet vb. |

### `POST /auth/forgot-password`

| | |
|--|--|
| **Body** | `{ email: string }` |
| **200** | Her zaman benzer `{ success, message }` (email enumeration yok) |
| **Not** | E-posta **Resend** ile gider (`RESEND_API_KEY`). Kod **6 karakter** (harf+rakam; `0,O,1,I,L` yok). |

### `POST /auth/reset-password`

| | |
|--|--|
| **Body** | `token` string **6** karakter (alfabe: `23456789ABCDEFGHJKLMNPQRSTUVWXYZ`; sunucu trim + büyük harf); `password` 6–100 |
| **200** | `{ success, message }` |
| **400** | Geçersiz veya süresi dolmuş kod |

---

## 4) Profil — `/api/v1/me`

**Bearer zorunlu.** `GET /me/dues` yalnızca **RESIDENT**; diğerleri **MANAGER veya RESIDENT**.

### `GET /me`

| **200 `data`** | `User` |

### `PUT /me`

| | |
|--|--|
| **Body** | `name?` 2–50; `phone?` (opsiyonel telefon kuralları register ile aynı); `language?` `"tr"` \| `"en"` — **en az biri** zorunlu |
| **200 `data`** | Güncel `User` |

### `DELETE /me`

| | |
|--|--|
| **Body** | Yok |
| **200** | KVKK soft delete; mesaj döner |
| **409** | Yöneticinin yönettiği bina varken hesap kapatılamaz |

### `PUT /me/password`

| | |
|--|--|
| **Body** | `currentPassword` string; `newPassword` string 6–100 |
| **200** | `{ success, message }` — `refreshTokenVersion` artar |

### `PUT /me/language`

| | |
|--|--|
| **Body** | `{ language: "tr" \| "en" }` |
| **200 `data`** | Güncel `User` |

### `PUT /me/fcm-token`

| | |
|--|--|
| **Body** | `{ fcmToken: string }` uzunluk 10–4096 |
| **200** | `{ success, message }` |

### `GET /me/dues` — **yalnızca RESIDENT**

| | |
|--|--|
| **Query** | `month`?, `year`? (string veya sayı; sunucu parse eder), `status`? = `PENDING` \| `PAID` \| `OVERDUE` \| `WAIVED` |
| **200 `data`** | `Due[]` (§2.7) |
| **403** | MANAGER token |

---

## 5) Binalar — `/api/v1/buildings`

**Bearer + MANAGER.**

### `POST /buildings`

| | |
|--|--|
| **Body** | `name` 2–100; `address` 5–200; `city` 2–50; `totalFloors?` int 1–200; `apartmentsPerFloor?` int 1–50; `dueAmount?` number > 0; `dueDay?` int 1–28; `currency?` tam 3 harf (örn. `TRY`) |
| **201 `data`** | `Building` + **`apartments`** dizisi; `dueAmount` verildiyse ilgili **Due** kayıtları oluşturulur |
| **Not** | Daire adları `1A`, `1B`, …; aidatlar İstanbul takvimine göre üretilir |

### `GET /buildings`

| **200 `data`** | `Building[]` — her öğede §2.3 alanları + **`_count.apartments`** (sayı); `apartments` dizisi yok |

### `GET /buildings/:id`

| | |
|--|--|
| **Param** | `id` uuid |
| **200 `data`** | `Building` |
| **404** | Yetkisiz veya yok |

### `GET /buildings/:id/dues`

| | |
|--|--|
| **Param** | `id` uuid (bina) |
| **Query** | `month?`, `year?`, `status?` (enum string) |
| **200 `data`** | `Due[]` (§2.6) |
| **404** | Bina yok veya yetki yok |

### `PATCH /buildings/:id/due-amount`

| | |
|--|--|
| **Param** | `id` uuid |
| **Body** | `dueAmount` number > 0; `dueDay?` 1–28; `currency?` 3 harf; `affectCurrent?` boolean — `true` ise mevcut **PENDING** aidat tutarları güncellenir |
| **200 `data`** | Güncel `Building` |

### `PATCH /buildings/:id/dues/:dueId/status`

| | |
|--|--|
| **Param** | `id`, `dueId` uuid |
| **Body** | `status` enum; `paidAt?` ISO datetime string (opsiyonel; `PAID` için varsayılan şimdi); `note?` max 500 |
| **200 `data`** | Güncel `Due` (§2.6, `apartmentNumber` dahil) |
| **403 / 404** | Yetki / kayıt yok |

### `PUT /buildings/:id`

| | |
|--|--|
| **Body** | `name?`, `address?`, `city?` — hepsi Zod’da opsiyonel; pratikte en az bir alan gönderilir |
| **200 `data`** | Güncel `Building` |

### `DELETE /buildings/:id`

| **200** | `{ success, message }` |
| **Not** | Sakin / FK bağlı kayıtlar varsa silme **başarısız** olabilir (Prisma hatası → **400** vb.) |

---

## 6) Daireler — `/api/v1/buildings/:buildingId/apartments`

**Bearer + MANAGER.** Parametreler **uuid**.

### `GET ...`

| **200 `data`** | `Apartment[]` (§2.4) |

### `POST ...`

| | |
|--|--|
| **Body** | `number` string 1–10; `floor?` int −5…200 |
| **201 `data`** | Oluşturulan `Apartment` |

### `PUT .../:id`

| | |
|--|--|
| **Body** | `number?`, `floor?` |
| **200 `data`** | Güncel `Apartment` |

### `DELETE .../:id/resident`

| | |
|--|--|
| **Body** | Yok |
| **200 `data`** | Güncel `Apartment` — `resident` **null** (sakin hesabı silinmez; yalnızca `User.apartmentId` kaldırılır; geçmiş aidat kayıtları kalır) |
| **403** | Bina bu yöneticiye ait değil |
| **404** | Daire yok **veya** dairede atanmış sakin yok |

### `DELETE .../:id`

| **200** | `{ success, message }` |

---

## 7) Davet kodu — `POST /api/v1/apartments/:apartmentId/invite-code`

**Bearer + MANAGER.** Body yok.

| **201 `data`** | `InviteCode` (§2.5) |
| **403** | Daire bu yöneticiye ait değil |

---

## 8) Bu API’de olmayan (eski / yanlış path’ler)

| Kullanma | Doğrusu |
|----------|---------|
| `PATCH /api/v1/dues/:id/status` | `PATCH /buildings/:buildingId/dues/:dueId/status` |
| `GET /api/v1/apartments/:id/dues` | Yok |
| `POST /buildings/:id/dues/bulk` | Yok |
| `POST /buildings/:id/invite-code` | `POST /apartments/:apartmentId/invite-code` |

### Faz 1 — Backend ⟷ mobil (`mobile/app`) uyum özeti

Bu tablo, **§1–§7** kapsamındaki uçların `mobile/app` dalındaki `ApiConstants` + ilgili `RemoteDataSource` çağrılarıyla **bire bir** eşleştiğini doğrulamak içindir. Davranışın tek kaynağı yine `backend/src/...` kodudur.

| Alan | Durum |
|------|--------|
| Auth: `identifier` login, register `user` string, join, refresh, logout; **`POST /auth/forgot-password`**, **`POST /auth/reset-password`** (§3) | Eşleşir |
| `/me`: **GET/PUT/DELETE**, **`PUT /me/password`**, **`PUT /me/language`**, **`PUT /me/fcm-token`** (§4; `fcm-token` Faz 1 mobilde çoğu senaryoda çağrılmıyor; uç mevcut) | Eşleşir |
| Binalar: CRUD, **`GET /buildings`** (`_count.apartments`), `GET/ PATCH .../dues`, `PATCH .../due-amount` | Eşleşir |
| Daireler: CRUD, **`DELETE .../apartments/:id/resident`**, `GET` içinde `resident` güvenli alanlar | Eşleşir (P0 sonrası backend) |
| Davet: `POST /apartments/:apartmentId/invite-code` | Eşleşir |
| Sakin aidat: `GET /me/dues` | Eşleşir |

**Backend yapılandırması**

- **`ALLOWED_ORIGINS`:** Flutter web veya başka bir ön uçtan `fetch` ile test edeceksen, `backend/.env` içinde bu origin’leri virgülle ekleyin (`backend/index.js` CORS).
- **CORS `PATCH`:** Aidat uçları için gerekli; yerel backend güncel `index.js` ile `PATCH` içerir.

**Mobil davranış (bilinçli fark)**

- `DioClient`, access token yerelde “süresi dolmuş” sayılırsa isteği **sunucuya göndermeden** reddedebilir; otomatik yenileme ise çoğunlukla sunucunun **401** dönmesiyle tetiklenir. Native istemcide clock/JWT uyumu ve oturum süresi test edilirken buna dikkat edin.

**Tam güvence için:** Staging API + gerçek cihaz veya emülatör ile Auth → Bina → Daire → Davet → Aidat akışının uçtan uca denenmesi önerilir ([`resources/MOBILE-TO-BACKEND.md`](resources/MOBILE-TO-BACKEND.md) §6).

---

## 9) Backend — yapılacaklar planı

Aşağıdaki sıra, [`resources/MOBILE-TO-BACKEND.md`](resources/MOBILE-TO-BACKEND.md) (§3–§7) ile uyumlu öncelik önerisidir. Ayrıntılı gerekçe ve mobil test notları için o dosyaya bakın. Her madde için: route + controller + service + `validate.js` şeması + Prisma işlemi; gerekirse migration.

### P0 — Operasyonel / sözleşme boşluğu

| # | İş | Durum |
|---|-----|--------|
| B1 | **Sakini daireden ayırma** — `DELETE /buildings/:buildingId/apartments/:id/resident` | ✅ (2026-05-10) |
| B2 | **`GET .../apartments` içinde `resident` budama** (`userPublicSelect`) | ✅ (2026-05-10) |

### P1 — Faz 2 (mobil bildirim / gider öncesi)

| # | İş | Notlar |
|---|-----|--------|
| B3 | **Bildirimler** | MVP: `GET /notifications` (query: `unreadOnly`), `PATCH /notifications/:id/read`, isteğe bağlı `PATCH /notifications/read-all`. Şema `Notification` ile hizala. |
| B4 | **`PUT /me/fcm-token` doğrulama** | Uç var; push entegrasyonunda rate limit ve token uzunluğu gözden geçirilir. |
| B5 | **Giderler (Expenses)** | `GET/POST /buildings/:id/expenses`, `DELETE .../expenses/:expenseId`; makbuz: `POST /expenses/:id/proof` (multipart), `GET .../proof`. Kategori enum’unu Prisma `ExpenseCategory` ile tekilleştir. |

### P2 — Faz 3

| # | İş | Notlar |
|---|-----|--------|
| B6 | **Talepler (Tickets)** | Yönetici: `GET /buildings/:id/tickets`; sakin: `GET /me/tickets`; `GET /tickets/:id`, `POST /buildings/:id/tickets`, `POST /tickets/:id/updates`, `PATCH /tickets/:id/status`. |
| B7 | **Raporlar** | `GET /buildings/:id/reports/monthly?year=&month=`; PDF: `GET .../reports/monthly.pdf` veya ayrı export ucu — MIME ve yetki netleştirilir. |

### P3 — Abonelik

| # | İş | Notlar |
|---|-----|--------|
| B8 | **RevenueCat** | Webhook path’i tek kaynakta sabitle (örn. `/api/v1/webhooks/revenuecat` **veya** `/api/v1/subscription/webhook/revenuecat`); istemci sabitleriyle aynı hizada tutulur. `GET /me/subscription` yanıt şekli buraya eklenir. |
| B9 | **`GET /health` (opsiyonel)** | LB / uptime için; auth gerektirmez. |

### Ortam ve kalite

| # | İş |
|---|-----|
| B10 | Staging + örnek manager/sakin hesapları; mobil E2E için base URL. |
| B11 | OpenAPI 3.0 veya Postman collection — sözleşmenin makine tarafından doğrulanması. |

---

## 10) Mobil (`mobile/app`) — kalan adımlar (referans)

Flutter kaynak kodu bu repoda bu görev kapsamında **değiştirilmez**; aşağıdakiler entegrasyon sırası için check-list’tir. Uzun checklist ve sprint notları için [`resources/MOBILE-TO-BACKEND.md`](resources/MOBILE-TO-BACKEND.md) §1–§8 kullanılabilir.

### Faz 2

- **FCM:** Uygulama içi token alındığında **`PUT /api/v1/me/fcm-token`** çağrısı (`{ "fcmToken": "..." }`).
- **Bildirim UI:** Backend B3 tamamlandıktan sonra liste + okundu; sabit path’ler backend ile eşlenir.
- **Gider UI:** Backend B5 tamamlandıktan sonra liste/ekle/sil + makbuz akışı.

### Faz 3–4

- **Ticket ekranları** (B6), **rapor / PDF** (B7).
- **Abonelik** (B8): SDK + sunucu webhook sonrası `GET /me/subscription` ile durum gösterme.

### Backend P0 sonrası

- **Sakin çıkarma UI:** B1 ucu canlıya alındığında daire kartı menüsüne bağlanır (mobil tarafta ayrı PR).

### İsteğe bağlı iyileştirme

- **`POST /buildings` sonrası daire seed:** Backend zaten transaction içinde daire üretir (bkz. `buildingService.js`). İstemci tarafında “liste boşsa toplu `POST .../apartments`” yedek mantığı varsa, staging doğrulamasından sonra **kaldırılabilir** (tekrarlayan daire riskine karşı).

---

## 11) Backend kaynak dosyalar (güncelleme için)

`backend/index.js`, `src/routes/*.js`, `src/controllers/*.js`, `src/middlewares/validate.js`, `src/services/dueService.js`, `passwordResetService.js`.

---

## 12) Geçmiş

| Tarih | Not |
|-------|-----|
| 2026-05-10 | Faz 1 uçları tamam; profil, forgot/reset, soft delete, 6 haneli reset kodu. |
| 2026-05-10 | Belge: tüm endpoint istek/yanıt modelleri netleştirildi. |
| 2026-05-10 | Belge: Faz 1 mobil tamam varsayımıyla §9–§10 kaldırıldı; backend planı (§9) ve kalan mobil adımlar (§10) eklendi; API sözleşmesi §1–§8 korundu. |
| 2026-05-10 | `resources/MOBILE-TO-BACKEND.md` ile çapraz referans (giriş, §9, §10, geçmiş). |
| 2026-05-10 | P0: `DELETE .../apartments/:id/resident`; daire listesinde `resident` alanı güvenli `select`. |
| 2026-05-10 | Faz 1 uyum: CORS’a `PATCH` eklendi; §8 altında backend⟷mobil özet tablosu. |
| 2026-05-10 | Docker: `backend/docker-compose.yml` (db+api), `backend/scripts/docker-test.sh`, `test.py` genişletildi (P0 resident, CORS preflight, resident güvenlik). |
| 2026-05-12 | **`GET /buildings`**: Prisma `_count.apartments`; §2.3 / §5 / §8 sözleşme metni güncellendi (mobil dashboard daire sayısı). |
| 2026-05-12 | Davet kodu üretimi **3+3+4** (`AP3-B12-A9F0`) ile mobil doğrulama hizalandı; `join` + `validateInviteCode` için kod **normalize** (trim, uppercase, boşluk silme). |
