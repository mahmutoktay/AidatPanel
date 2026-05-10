# AidatPanel — Flutter ↔ Backend (Faz 1) API rehberi

Bu belge **yalnızca** canlı backend sözleşmesini tanımlar: `AidatPanel/backend`, Express 5, Prisma, önek **`/api/v1`**. Flutter ekibi (ör. Furkan) ve yapay zekâ asistanı için **istek gövdesi**, **query**, **başarılı JSON yanıtı** ve **ortak veri modelleri** burada netleştirilir.

> **Tek kaynak:** Davranış her zaman **repo kodu**dur (`backend/src/...`). `AIDATPANEL.md` veya eski mobil sabitler bu belgeyle çelişirse **bu belge + kod** esas alınır.

---

## 1) Genel kurallar

| Konu | Değer |
|------|--------|
| Kök URL | `{BASE}/api/v1` — örn. `https://api.aidatpanel.com/api/v1` |
| `baseUrl` (Flutter) | Host + `/api/v1` birleştirilir; path’te **çift** `/api/v1` oluşmaz |
| Header | `Content-Type: application/json` |
| Yetki | Korumalı uçlar: `Authorization: Bearer <accessToken>` |
| Başarı | `{ "success": true, "data": ... }` ve/veya `"message"` |
| Hata | `{ "success": false, "message": "..." }`; validasyonda `"errors": [{ "field", "message" }]` (HTTP **400**) |
| Sayı (JSON) | Bina oluşturma / aidat bedeli gibi gövdelerde **number** gönderilir (tırnaklı string değil) |
| `Decimal` (Prisma) | Yanıtta çoğu alan **string** (örn. `"600.00"`); Flutter’da güvenli parse |
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
- Çıkışta: **`POST /auth/logout`** zorunlu; ardından yerel token sil.

### Rate limit

- `/api/v1` genel: ~15 dk / 100 istek (IP).
- `/api/v1/auth/*`: ek limit; çoklu **başarısız** deneme **429** verebilir.

---

## 2) Ortak veri modelleri (yanıt şekilleri)

### 2.1 `User` (login / join / `GET|PUT /me` `data`)

Alanlar: `id` (uuid), `email`, `name`, `role` (`MANAGER` \| `RESIDENT`), `phone` (null olabilir), `language` (`tr` \| `en`), `apartmentId` (null veya uuid), `createdAt`, `updatedAt`.

### 2.2 `RegisterData` (`POST /auth/register` → `data`)

`user`: **string** (kullanıcı uuid’si; Flutter’da genelde `id` alanına map edilir). Diğer alanlar `User` ile aynı (`token` yok).

### 2.3 `Building` (Prisma)

Örnek alanlar: `id`, `name`, `address`, `city`, `totalFloors`, `apartmentsPerFloor`, `managerId`, `dueAmount` (string \| null), `dueDay`, `currency`, `createdAt`, `updatedAt`. Liste/tekil cevaplarda `apartments` sadece **POST /buildings** sonrası include ile gelir.

### 2.4 `Apartment`

`id`, `buildingId`, `number`, `floor` (int \| null), `createdAt`. Liste (`GET .../apartments`): **`resident`** = ilişkili `User` kaydı veya **null** (daire boşsa). İstemci yalnızca `id`, `name`, `email`, `phone`, `role`, `language` vb. kullanmalı; **`passwordHash` veya `refreshTokenVersion` gibi alanlar kullanılmamalı** (idealde backend yanıtta `select` ile budanır).

### 2.5 `InviteCode` (`POST .../invite-code` → `data`)

`id`, `apartmentId`, `code`, `expiresAt`, `usedAt` (null veya ISO).

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
| **Body** | `name`, `email`, `password` (register ile aynı kurallar); `inviteCode` string 1–20; `phone` opsiyonel |
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

| **200 `data`** | `Building[]` |

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

---

## 9) Flutter — dosya eşlemesi (tipik)

| Konu | Örnek konum |
|------|-------------|
| Path sabitleri | `core/constants/api_constants.dart` |
| Dio + 401/refresh | `core/network/dio_client.dart` |
| Auth + forgot/reset | `features/auth/data/...` |
| Profil / me | `features/auth` veya `features/profile/...` |
| Bina / daire / davet / aidat | ilgili `features/*/data/...` |

---

## 10) Yapay zekâ / geliştirici kontrol listesi

1. Tüm path’ler **Bölüm 3–7** ile aynı mı? Eski path’ler kaldırıldı mı?
2. `login` gövdesi `identifier` + `password` mı?
3. Register yanıtında `user` string → uygulama içi `id` map’i yapıldı mı?
4. Logout sunucuya `POST /auth/logout` gidiyor mu?
5. Aidat durum güncellemede `buildingId` route parametresi kullanılıyor mu?
6. `Due` modellerinde `apartmentNumber` ve (`/me/dues` için) `building` parse ediliyor mu?

---

## 11) Backend kaynak dosyalar (güncelleme için)

`backend/index.js`, `src/routes/*.js`, `src/controllers/*.js`, `src/middlewares/validate.js`, `src/services/dueService.js`, `passwordResetService.js`.

---

## 12) Faz 1 dışı (backend’de uç yok)

RevenueCat webhook, gider, ticket, bildirim listesi, PDF rapor, `GET /health` — mobilde sabit varsa Faz 2’ye ertelenmeli veya kaldırılmalı.

---

## 13) Geçmiş

| Tarih | Not |
|-------|-----|
| 2026-05-10 | Faz 1 uçları tamam; profil, forgot/reset, soft delete, 6 haneli reset kodu. |
| 2026-05-10 | Belge: tüm endpoint istek/yanıt modelleri netleştirildi. |
