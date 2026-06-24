# AidatPanel — Backend API Uçları (Tam Kılavuz)

> **Sürüm:** `api/v1` · **Son güncelleme:** 2026-06-23  
> **Hedef kitle:** Flutter / istemci geliştiricileri (Furkan tasarım branch’i dahil)

---

## İçindekiler

1. [Genel kurallar](#1-genel-kurallar)
2. [Ortak şemalar ve enum’lar](#2-ortak-şemalar-ve-enumlar)
3. [Sağlık kontrolü](#3-sağlık-kontrolü)
4. [Kimlik doğrulama — `/api/v1/auth`](#4-kimlik-doğrulama--apiv1auth)
5. [Profil ve oturum — `/api/v1/me`](#5-profil-ve-oturum--apiv1me)
6. [Binalar — `/api/v1/buildings`](#6-binalar--apiv1buildings)
7. [Siteler — `/api/v1/sites`](#7-siteler--apiv1sites)
8. [Site giderleri — `/api/v1/site-expenses`](#8-site-giderleri--apiv1site-expenses)
9. [Daireler — `/api/v1/buildings/:buildingId/apartments`](#9-daireler--apiv1buildingsbuildingidapartments)
10. [Davet kodu — `/api/v1/apartments/:apartmentId/invite-code`](#10-davet-kodu--apiv1apartmentsapartmentidinvite-code)
11. [Bina giderleri — `/api/v1/buildings/:id/expenses` + `/api/v1/expenses`](#11-bina-giderleri)
12. [Aidatlar](#12-aidatlar)
13. [Dekontlar — `/api/v1/dekonts`](#13-dekontlar--apiv1dekonts)
14. [Talepler (ticket)](#14-talepler-ticket)
15. [Bildirimler — `/api/v1/notifications`](#15-bildirimler--apiv1notifications)
16. [Abonelik — `/api/v1/me/subscription` + webhook](#16-abonelik)
17. [Raporlar (PDF)](#17-raporlar-pdf)
18. [WebSocket](#18-websocket)
19. [Statik dosyalar](#19-statik-dosyalar)

---

## 1. Genel kurallar

### Base URL

| Ortam | URL |
|-------|-----|
| Production | `https://api.aidatpanel.com` |
| Yerel backend | `http://localhost:4200` |
| Android emülatör → PC | `http://10.0.2.2:4200` |

Tüm REST uçları `/api/v1/...` prefix’i ile başlar.

### Kimlik doğrulama

Korumalı uçlarda header:

```http
Authorization: Bearer <accessToken>
Content-Type: application/json
```

| Rol | Açıklama |
|-----|----------|
| `MANAGER` | Site/bina yöneticisi |
| `RESIDENT` | Daire sakini |
| `—` | Auth gerekmez |
| `Bearer (webhook)` | RevenueCat webhook secret |

Access token süresi kısadır; `refreshToken` ile `POST /api/v1/auth/refresh` çağrılır.

### Yanıt zarfı (envelope)

**Başarılı JSON:**

```json
{
  "success": true,
  "message": "İsteğe bağlı Türkçe mesaj",
  "data": { }
}
```

Bazı uçlarda yalnızca `success` + `data` döner (`message` opsiyonel).

**Hata:**

```json
{
  "success": false,
  "message": "Sade Türkçe hata metni"
}
```

HTTP durum kodları: `400` doğrulama, `401` oturum, `403` yetki/kota, `404` bulunamadı, `409` çakışma, `503` sağlık hatası.

### Sayfalama (liste uçları)

Query parametreleri (çoğu liste uçunda):

| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `paginated` | `"true"` | Sayfalı mod |
| `cursor` | UUID | Sonraki sayfa (önceki yanıttaki `nextCursor`) |
| `limit` | sayı | Sayfa boyutu (varsayılan 50, üst sınır ~2500) |

**Sayfasız mod** (`paginated` yok, `cursor` yok):

```json
{
  "success": true,
  "data": [ /* tüm satırlar (üst sınıra kadar) */ ]
}
```

**Sayfalı mod:**

```json
{
  "success": true,
  "data": {
    "items": [ /* ... */ ],
    "nextCursor": "uuid-sonraki-sayfa-veya-null"
  }
}
```

Bildirim listesi her zaman `{ items, nextCursor, unreadCount }` döner.

### Para / Decimal alanları

API’de tutarlar çoğunlukla **string** (`"450.00"`) veya JSON number olarak gelir. Prisma `Decimal` alanları serialize edilirken string’e çevrilir.

### Multipart istekler

`Content-Type: multipart/form-data` — alan adları endpoint bölümünde belirtilir.

### PDF yanıtları

`Content-Type: application/pdf` — gövde ikili PDF; JSON değil. `Content-Disposition: attachment; filename="..."`.

---

## 2. Ortak şemalar ve enum’lar

### Kullanıcı (public)

```json
{
  "id": "uuid",
  "email": "yonetici@ornek.com",
  "name": "Ahmet Yılmaz",
  "role": "MANAGER",
  "phone": "5321234567",
  "language": "tr",
  "apartmentId": null,
  "profilePicture": "/uploads/avatars/abc.jpg",
  "createdAt": "2026-01-15T10:00:00.000Z",
  "updatedAt": "2026-06-01T12:00:00.000Z"
}
```

### Auth token çifti

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "user": { /* user public */ }
}
```

### Bina — effective alanlar

Site altı binalarda site varsayılanları + bina override birleşir:

```json
{
  "id": "uuid",
  "name": "A Blok",
  "address": "Merkez Mah. No:1",
  "city": "İstanbul",
  "siteId": "uuid-site",
  "blockLabel": "A Blok",
  "addressExtra": "Kapı 2",
  "siteName": "Güneş Sitesi",
  "effectiveDueAmount": "500.00",
  "effectiveDueDay": 5,
  "effectiveCurrency": "TRY",
  "effectiveCollectionIban": "TR330006100519786457841326",
  "effectiveCollectionAccountTitle": "Site Yönetimi",
  "effectivePaymentReferenceTemplate": "Daire {no}",
  "effectiveCollectionVerifiedAt": "2026-06-01T00:00:00.000Z",
  "isCollectionConfigured": true,
  "effectiveAddress": "Merkez Mah. No:1",
  "effectiveCity": "İstanbul",
  "effectiveDisplayAddress": "Merkez Mah. No:1, Kapı 2, İstanbul",
  "occupiedApartments": 12,
  "totalFloors": 5,
  "apartmentsPerFloor": 4,
  "managerId": "uuid",
  "createdAt": "...",
  "updatedAt": "..."
}
```

Tekil binalarda `siteId: null`, `siteName: null`.

### Aidat breakdown

```json
{
  "baseAmount": "500.00",
  "expenseLines": [
    { "title": "Asansör bakımı", "amount": "25.00", "kind": "EXPENSE" },
    { "title": "Site ortak — Bahçe", "amount": "15.00", "kind": "SITE_EXPENSE" },
    { "title": "Önceki aydan devreden — Elektrik", "amount": "10.00", "kind": "CARRYFORWARD" }
  ],
  "total": "550.00"
}
```

### Enum’lar

| Alan | Değerler |
|------|----------|
| `DueStatus` | `PENDING`, `PAID`, `OVERDUE`, `WAIVED` |
| `ExpenseCategory` | `CLEANING`, `ELEVATOR`, `ELECTRICITY`, `WATER`, `INSURANCE`, `REPAIR`, `GARDEN`, `OTHER` |
| `TicketStatus` | `OPEN`, `IN_PROGRESS`, `RESOLVED`, `CLOSED` |
| `TicketCategory` | `COMPLAINT`, `REQUEST`, `MALFUNCTION`, `OTHER` |
| `DekontStatus` | `RECEIVED`, `EXTRACTING`, `EXTRACT_FAILED`, `PARSED`, `PARSE_LOW_CONFIDENCE`, `MATCHING`, `MATCHED`, `MATCH_AMBIGUOUS`, `UNMATCHED`, `PAYMENT_APPLIED`, `PAYMENT_PARTIAL`, `REJECTED`, `RECIPIENT_MISMATCH`, `NEEDS_MANAGER_REVIEW` |
| `carryForwardPolicy` | `CARRY_TO_NEXT_MONTH`, `WARN_ONLY` |
| `SubscriptionStatus` | `ACTIVE`, `EXPIRED`, `CANCELLED`, `TRIAL` |
| `SubscriptionPlan` | `MONTHLY`, `YEARLY` (ürün eşlemesine bağlı) |

---

## 3. Sağlık kontrolü

### `GET /health`

Auth: **yok**

**Response 200:**

```json
{
  "status": "ok",
  "timestamp": "2026-06-23T14:30:00.000Z"
}
```

**Response 503** (DB erişilemez):

```json
{
  "status": "error",
  "timestamp": "2026-06-23T14:30:00.000Z"
}
```

---

## 4. Kimlik doğrulama — `/api/v1/auth`

Rate limit: auth limiter aktif.

### `POST /api/v1/auth/register`

Rol: herkese açık → oluşturulan kullanıcı `MANAGER`.

**Request:**

```json
{
  "name": "Ahmet Yılmaz",
  "email": "ahmet@ornek.com",
  "phone": "5321234567",
  "password": "sifre123"
}
```

`phone` opsiyonel.

**Response 201:**

```json
{
  "success": true,
  "message": "Hesabınız başarıyla oluşturuldu.",
  "data": {
    "user": "uuid",
    "name": "Ahmet Yılmaz",
    "email": "ahmet@ornek.com",
    "phone": "5321234567",
    "role": "MANAGER",
    "language": "tr",
    "apartmentId": null,
    "createdAt": "2026-06-23T10:00:00.000Z",
    "updatedAt": "2026-06-23T10:00:00.000Z"
  }
}
```

> Not: Kayıt sonrası token dönmez; `login` gerekir.

---

### `POST /api/v1/auth/login`

**Request:**

```json
{
  "identifier": "ahmet@ornek.com",
  "password": "sifre123",
  "deviceLabel": "Pixel 8",
  "platform": "android"
}
```

`identifier`: e-posta veya telefon. `deviceLabel`, `platform` opsiyonel (oturum listesi için).

**Response 200:**

```json
{
  "success": true,
  "message": "Giriş başarılı.",
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "user": {
      "id": "uuid",
      "email": "ahmet@ornek.com",
      "name": "Ahmet Yılmaz",
      "role": "MANAGER",
      "phone": "5321234567",
      "language": "tr",
      "apartmentId": null,
      "createdAt": "...",
      "updatedAt": "..."
    }
  }
}
```

---

### `POST /api/v1/auth/refresh`

**Request:**

```json
{
  "refreshToken": "eyJ...",
  "deviceLabel": "Pixel 8",
  "platform": "android"
}
```

**Response 200:**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJ-yeni...",
    "refreshToken": "eyJ-yeni..."
  }
}
```

---

### `POST /api/v1/auth/join`

Sakin kaydı (davet kodu ile).

**Request:**

```json
{
  "name": "Mehmet Demir",
  "email": "mehmet@ornek.com",
  "phone": "5339876543",
  "password": "sifre123",
  "inviteCode": "AP3-B12-X7K9",
  "deviceLabel": "iPhone 15",
  "platform": "ios"
}
```

**Response 201:**

```json
{
  "success": true,
  "message": "Apartmana başarıyla katıldınız.",
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "user": {
      "id": "uuid",
      "role": "RESIDENT",
      "apartmentId": "uuid-daire",
      "...": "..."
    }
  }
}
```

---

### `POST /api/v1/auth/forgot-password`

**Request:**

```json
{
  "email": "ahmet@ornek.com"
}
```

**Response 200** (e-posta kayıtlı olsun/olmasın aynı mesaj):

```json
{
  "success": true,
  "message": "E-posta adresi sistemde kayıtlıysa şifre sıfırlama talimatları gönderildi."
}
```

---

### `POST /api/v1/auth/reset-password`

**Request:**

```json
{
  "token": "AB3CD9",
  "password": "yeniSifre456"
}
```

`token`: 6 karakterlik e-posta kodu.

**Response 200:**

```json
{
  "success": true,
  "message": "Şifreniz güncellendi. Yeni şifreyle giriş yapabilirsiniz."
}
```

---

### `POST /api/v1/auth/logout`

Auth: **Bearer**

FCM token temizlenir; mevcut oturum kapatılır.

**Request:** gövde yok

**Response 200:**

```json
{
  "success": true,
  "message": "Çıkış başarılı."
}
```

---

### `POST /api/v1/auth/logout-all-devices`

Auth: **Bearer**

**Response 200:**

```json
{
  "success": true,
  "message": "Diğer cihazlardaki oturumlar sonlandırıldı.",
  "data": {
    "revokedCount": 3
  }
}
```

---

## 5. Profil ve oturum — `/api/v1/me`

Auth: **Bearer** · Roller: çoğu uç her iki rol.

### `GET /api/v1/me`

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "ahmet@ornek.com",
    "name": "Ahmet Yılmaz",
    "role": "MANAGER",
    "phone": "5321234567",
    "language": "tr",
    "apartmentId": null,
    "profilePicture": null,
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

---

### `PUT /api/v1/me`

E-posta/telefon değişiminde `currentPassword` zorunlu.

**Request (örnek):**

```json
{
  "name": "Ahmet Y.",
  "email": "yeni@ornek.com",
  "phone": null,
  "language": "en",
  "currentPassword": "sifre123"
}
```

**Response 200:**

```json
{
  "success": true,
  "data": { /* güncel user public */ }
}
```

---

### `DELETE /api/v1/me`

KVKK yumuşak silme.

**Response 200:**

```json
{
  "success": true,
  "message": "Hesabınız kapatıldı."
}
```

---

### `PUT /api/v1/me/password`

**Request:**

```json
{
  "currentPassword": "eskiSifre",
  "newPassword": "yeniSifre456"
}
```

**Response 200:**

```json
{
  "success": true,
  "message": "Şifreniz güncellendi."
}
```

---

### `PUT /api/v1/me/language`

**Request:**

```json
{
  "language": "tr"
}
```

Değerler: `tr`, `en`.

---

### `PUT /api/v1/me/fcm-token`

**Request:**

```json
{
  "fcmToken": "firebase-cloud-messaging-token..."
}
```

**Response 200:**

```json
{
  "success": true,
  "message": "Bildirim token'ı kaydedildi."
}
```

---

### `GET /api/v1/me/sessions`

**Response 200:**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid-session",
      "deviceLabel": "Pixel 8",
      "platform": "android",
      "createdAt": "2026-06-01T08:00:00.000Z",
      "lastSeenAt": "2026-06-23T12:00:00.000Z",
      "isCurrent": true
    }
  ]
}
```

---

### `DELETE /api/v1/me/sessions/:sessionId`

Mevcut oturum silinemez (`400`).

**Response 200:**

```json
{
  "success": true,
  "message": "Oturum sonlandırıldı."
}
```

---

### `POST /api/v1/me/profile-picture`

`multipart/form-data` · alan: `file` (JPEG/PNG/GIF, max 5 MB)

**Response 200:**

```json
{
  "success": true,
  "data": {
    "profilePicture": "/uploads/avatars/uuid.jpg"
  }
}
```

---

### `DELETE /api/v1/me/profile-picture`

**Response 200:**

```json
{
  "success": true,
  "message": "Profil fotoğrafı silindi."
}
```

---

### `GET /api/v1/me/subscription`

Rol: **MANAGER**

**Response 200** (abonelik yok):

```json
{
  "success": true,
  "data": {
    "usage": { "managementUnits": 3 },
    "limits": { "managementUnits": 50 }
  }
}
```

**Response 200** (abonelik var):

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "ACTIVE",
    "plan": "YEARLY",
    "platform": "PLAY_STORE",
    "currentPeriodStart": "2026-01-01T00:00:00.000Z",
    "currentPeriodEnd": "2027-01-01T00:00:00.000Z",
    "usage": { "managementUnits": 3 },
    "limits": { "managementUnits": 50 }
  }
}
```

> **YB (yönetim birimi):** tekil bina (`siteId=null`) + site sayısı. Site içi binalar ek kota tüketmez.

---

### `GET /api/v1/me/payment-collection`

Rol: **RESIDENT** — Havale/dekont ekranı IBAN bilgisi.

**Response 200:**

```json
{
  "success": true,
  "data": {
    "buildingId": "uuid-bina",
    "buildingName": "Güneş Sitesi — A Blok",
    "siteId": "uuid-site",
    "siteName": "Güneş Sitesi",
    "apartmentNumber": "3A",
    "collectionIban": "TR330006100519786457841326",
    "collectionAccountTitle": "Site Yönetimi",
    "paymentReferenceTemplate": "Daire {no}",
    "paymentReference": "Daire 3A",
    "isCollectionConfigured": true
  }
}
```

Site altı dairede bina override IBAN yoksa site varsayılanı kullanılır.

---

### `GET /api/v1/me/dues`

Rol: **RESIDENT** · Query: `month`, `year`, `status`, `paginated`, `cursor`, `limit`

**Response 200** (öğe örneği):

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "apartmentId": "uuid",
      "month": 6,
      "year": 2026,
      "amount": "550.00",
      "status": "PENDING",
      "dueDate": "2026-06-05T20:59:59.999Z",
      "paidAt": null,
      "overdueDays": 0,
      "note": null,
      "breakdown": {
        "baseAmount": "500.00",
        "expenseLines": [],
        "total": "500.00"
      }
    }
  ]
}
```

---

### `GET /api/v1/me/expenses`

Rol: **RESIDENT** · Query: `month`, `year`, `category`, sayfalama

Sakinin dairesinin bağlı olduğu binanın giderleri (okuma).

**Response 200:** bina gider listesi ile aynı `Expense` şekli (aşağıda).

---

### `GET /api/v1/me/tickets`

Rol: **RESIDENT** · Query: `status`, `category`, sayfalama

**Response 200:** ticket listesi (Bölüm 14).

---

### `GET /api/v1/me/dekonts`

Rol: **RESIDENT** · Query: `status`, sayfalama

**Response 200:** dekont listesi (Bölüm 13).

---

## 6. Binalar — `/api/v1/buildings`

Auth: **Bearer** · Rol: **MANAGER**

### `POST /api/v1/buildings`

Tekil bina oluşturur (YB kotası tüketir).

**Request:**

```json
{
  "name": "Yıldız Apartmanı",
  "address": "Atatürk Cad. No:10",
  "city": "Ankara",
  "totalFloors": 5,
  "apartmentsPerFloor": 4,
  "dueAmount": 450,
  "dueDay": 5,
  "currency": "TRY",
  "collectionIban": "TR760006400000123456789012",
  "collectionAccountTitle": "Yıldız Apt. Yönetimi",
  "paymentReferenceTemplate": "Daire {no}"
}
```

`totalFloors` / `apartmentsPerFloor` opsiyonel (varsayılan 1 kat, 2 daire/kat). Daireler `1A`, `1B`, `2A`… oluşturulur. Aidatlar bulunulan aydan yıl sonuna üretilir.

**Response 201:**

```json
{
  "success": true,
  "message": "Bina, daireler ve aidatlar başarıyla oluşturuldu.",
  "data": {
    "id": "uuid",
    "name": "Yıldız Apartmanı",
    "siteId": null,
    "apartments": [
      { "id": "uuid", "number": "1A", "floor": 1, "buildingId": "uuid" }
    ],
    "...": "..."
  }
}
```

---

### `GET /api/v1/buildings`

Query: `standalone=true` (yalnızca tekil binalar), `search`, sayfalama

**Response 200** (öğe — effective alanlarla):

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Yıldız Apartmanı",
      "siteId": null,
      "effectiveDueAmount": "450.00",
      "effectiveCollectionIban": "TR76...",
      "isCollectionConfigured": true,
      "occupiedApartments": 8,
      "_count": { "apartments": 20 }
    }
  ]
}
```

---

### `GET /api/v1/buildings/collection-presets`

Kayıtlı IBAN şablonları (bina + site).

**Response 200:**

```json
{
  "success": true,
  "data": [
    {
      "collectionIban": "TR330006100519786457841326",
      "collectionAccountTitle": "Site Yönetimi",
      "paymentReferenceTemplate": "Daire {no}",
      "lastUsedAt": "2026-06-20T10:00:00.000Z",
      "buildingCount": 2,
      "siteCount": 1
    }
  ]
}
```

---

### `GET /api/v1/buildings/:id`

**Response 200:**

```json
{
  "success": true,
  "data": { /* effective building config + occupiedApartments */ }
}
```

---

### `PUT /api/v1/buildings/:id`

**Request:**

```json
{
  "name": "Yeni Ad",
  "address": "Yeni adres metni",
  "city": "İzmir"
}
```

En az bir alan zorunlu.

**Response 200:**

```json
{
  "success": true,
  "data": { /* güncel bina */ }
}
```

---

### `DELETE /api/v1/buildings/:id`

Cascade: daireler, aidatlar, giderler, dekontlar, talepler vb.

**Response 200:**

```json
{
  "success": true,
  "message": "Bina silindi"
}
```

---

### `PATCH /api/v1/buildings/:id/collection`

**Request:**

```json
{
  "collectionIban": "TR760006400000123456789012",
  "collectionAccountTitle": "Hesap sahibi",
  "paymentReferenceTemplate": "Aidat {no}"
}
```

En az bir alan. IBAN `null` veya `""` → tahsilat sıfırlanır.

**Response 200:**

```json
{
  "success": true,
  "message": "Tahsilat bilgileri güncellendi.",
  "data": { /* bina collection alanları */ }
}
```

---

### `GET /api/v1/buildings/:id/dashboard-summary`

Tek istekte özet KPI.

**Response 200:**

```json
{
  "success": true,
  "data": {
    "apartments": { "total": 20, "occupied": 15 },
    "dues": {
      "PENDING": { "count": 5, "totalAmount": 2750 },
      "PAID": { "count": 10, "totalAmount": 5500 },
      "OVERDUE": { "count": 2, "totalAmount": 1100 }
    },
    "expenses": { "total": 3200, "count": 4 },
    "unreadNotifications": 3,
    "openTickets": 2,
    "pendingDekonts": 1,
    "period": { "month": 6, "year": 2026 }
  }
}
```

---

## 7. Siteler — `/api/v1/sites`

Auth: **Bearer** · Rol: **MANAGER**

### `POST /api/v1/sites`

YB kotası tüketir (1 site = 1 YB).

**Request:**

```json
{
  "name": "Güneş Sitesi",
  "address": "Merkez Mah. Güneş Sok. No:1",
  "city": "İstanbul",
  "dueAmount": 500,
  "dueDay": 5,
  "currency": "TRY",
  "collectionIban": "TR330006100519786457841326",
  "collectionAccountTitle": "Güneş Sitesi Yönetimi",
  "paymentReferenceTemplate": "Daire {no}"
}
```

`dueAmount`, `collectionIban` vb. opsiyonel (site varsayılanları).

**Response 201:**

```json
{
  "success": true,
  "message": "Site başarıyla oluşturuldu.",
  "data": {
    "id": "uuid",
    "name": "Güneş Sitesi",
    "address": "Merkez Mah. Güneş Sok. No:1",
    "city": "İstanbul",
    "managerId": "uuid",
    "dueAmount": "500.00",
    "dueDay": 5,
    "currency": "TRY",
    "collectionIban": "TR330006100519786457841326",
    "collectionAccountTitle": "Güneş Sitesi Yönetimi",
    "paymentReferenceTemplate": "Daire {no}",
    "collectionVerifiedAt": "2026-06-23T10:00:00.000Z",
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

---

### `GET /api/v1/sites`

Query: `search`, `paginated`, `cursor`, `limit`

**Response 200** (öğe):

```json
{
  "id": "uuid",
  "name": "Güneş Sitesi",
  "address": "...",
  "city": "İstanbul",
  "dueAmount": "500.00",
  "dueDay": 5,
  "currency": "TRY",
  "buildingCount": 3,
  "expectedAmount": 15000,
  "collectedAmount": 12000,
  "createdAt": "...",
  "updatedAt": "..."
}
```

`expectedAmount` / `collectedAmount`: cari ay, tüm site daireleri.

---

### `GET /api/v1/sites/:id`

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Güneş Sitesi",
    "buildingCount": 3,
    "expectedAmount": 15000,
    "collectedAmount": 12000,
    "buildings": [
      {
        "id": "uuid-bina",
        "name": "A Blok",
        "siteId": "uuid-site",
        "blockLabel": "A Blok",
        "effectiveDueAmount": "500.00",
        "effectiveCollectionIban": "TR33...",
        "occupiedApartments": 12,
        "_count": { "apartments": 20 }
      }
    ],
    "...": "site alanları"
  }
}
```

---

### `PUT /api/v1/sites/:id`

**Request:**

```json
{
  "name": "Güneş Konutları",
  "address": "Yeni adres",
  "city": "İstanbul",
  "dueAmount": 550,
  "dueDay": 10,
  "currency": "TRY"
}
```

`dueAmount: null` → varsayılan aidat kaldırılır.

**Response 200:**

```json
{
  "success": true,
  "message": "Site güncellendi.",
  "data": { /* güncel site */ }
}
```

---

### `DELETE /api/v1/sites/:id`

Alt binalar cascade silinir (daireler, aidatlar, site giderleri dahil).

**Response 200:**

```json
{
  "success": true,
  "message": "Site ve bağlı binalar silindi."
}
```

---

### `PATCH /api/v1/sites/:id/collection`

Bina `PATCH .../collection` ile aynı gövde.

**Response 200:**

```json
{
  "success": true,
  "message": "Tahsilat bilgileri güncellendi.",
  "data": { /* site collection alanları */ }
}
```

---

### `GET /api/v1/sites/:id/buildings`

**Response 200:**

```json
{
  "success": true,
  "data": [
    { /* effective building config */ }
  ]
}
```

---

### `POST /api/v1/sites/:id/buildings`

Site altı bina — **YB kotası tüketmez**.

**Request:**

```json
{
  "name": "A Blok",
  "blockLabel": "A Blok",
  "addressExtra": "Kapı 1",
  "totalFloors": 4,
  "apartmentsPerFloor": 3,
  "dueAmount": 600,
  "dueDay": 10,
  "collectionIban": null
}
```

Belirtilmeyen alanlar site varsayılanından inherit edilir.

**Response 201:**

```json
{
  "success": true,
  "message": "Site altında bina, daireler ve aidatlar oluşturuldu.",
  "data": { /* effective building config */ }
}
```

---

### `GET /api/v1/sites/:id/expenses`

Query: `month`, `year`, `category`, sayfalama

**Response 200** — `SiteExpense` listesi (Bölüm 8 şeması).

---

### `POST /api/v1/sites/:id/expenses`

Site ortak gideri — tüm site dairelerine eşit pay.

**Request:**

```json
{
  "title": "Bahçe bakımı",
  "amount": 900,
  "category": "GARDEN",
  "date": "2026-06-15T10:00:00.000Z",
  "targetMonth": 6,
  "targetYear": 2026,
  "note": "Haziran ayı",
  "splitMonths": 1,
  "carryForwardPolicy": "WARN_ONLY",
  "confirmPaidImpact": false
}
```

**Preview yanıtı 200** (ödemiş daireler varsa, `confirmPaidImpact: false`):

```json
{
  "success": true,
  "data": {
    "requiresConfirmation": true,
    "paidApartmentCount": 5,
    "perUnitAmount": "30.00",
    "totalUnpaidShare": "150.00",
    "message": "5 daire bu ay aidatını zaten ödedi. Site gideri payı (₺150.00) bir sonraki aya borç olarak eklensin mi?",
    "nextPeriod": { "month": 7, "year": 2026 },
    "pastMonthWarning": false
  }
}
```

Onay için aynı istek `confirmPaidImpact: true` veya `carryForwardPolicy: "CARRY_TO_NEXT_MONTH"`.

**Başarılı oluşturma 201:**

```json
{
  "success": true,
  "message": "Site gideri kaydedildi.",
  "data": {
    "expense": { /* SiteExpense */ },
    "expenses": [ /* split varsa çoklu */ ],
    "warnings": [],
    "pastMonthWarning": false,
    "splitGroupId": null
  }
}
```

---

### `GET /api/v1/sites/:id/expenses/summary`

Query: `month` (1-12), `year` (4 hane) — zorunlu

**Response 200:**

```json
{
  "success": true,
  "data": {
    "month": 6,
    "year": 2026,
    "totalAmount": "900.00",
    "currency": "TRY",
    "byCategory": [
      { "category": "GARDEN", "amount": "900.00", "count": 1 }
    ],
    "apartmentCount": 30
  }
}
```

---

## 8. Site giderleri — `/api/v1/site-expenses`

Auth: **Bearer** · Rol: **MANAGER**

### `PUT /api/v1/site-expenses/:expenseId`

**Request:**

```json
{
  "title": "Güncel başlık",
  "amount": 950,
  "category": "GARDEN",
  "date": "2026-06-16T10:00:00.000Z",
  "targetMonth": 6,
  "targetYear": 2026,
  "note": null
}
```

**Response 200:**

```json
{
  "success": true,
  "message": "Site gideri güncellendi.",
  "data": {
    "id": "uuid",
    "siteId": "uuid-site",
    "title": "Güncel başlık",
    "amount": "950.00",
    "perUnitAmount": "31.67",
    "category": "GARDEN",
    "date": "2026-06-16T10:00:00.000Z",
    "targetMonth": 6,
    "targetYear": 2026,
    "note": null,
    "splitGroupId": null,
    "sourceExpenseId": null,
    "storedPaths": [],
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

---

### `DELETE /api/v1/site-expenses/:expenseId`

Carry-forward temizlenir; ilgili ay aidatları yeniden hesaplanır.

**Response 200:**

```json
{
  "success": true,
  "message": "Site gideri silindi.",
  "data": { "id": "uuid" }
}
```

---

## 9. Daireler — `/api/v1/buildings/:buildingId/apartments`

Auth: **Bearer** · Rol: **MANAGER**

### `GET /api/v1/buildings/:buildingId/apartments`

Query: sayfalama, `search` (daire no)

**Response 200:**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "number": "3A",
      "floor": 3,
      "buildingId": "uuid-bina",
      "resident": null,
      "createdAt": "...",
      "updatedAt": "..."
    },
    {
      "id": "uuid",
      "number": "3B",
      "floor": 3,
      "buildingId": "uuid-bina",
      "resident": {
        "id": "uuid",
        "name": "Mehmet Demir",
        "email": "mehmet@ornek.com",
        "role": "RESIDENT",
        "phone": "5339876543",
        "language": "tr",
        "apartmentId": "uuid",
        "profilePicture": null,
        "createdAt": "...",
        "updatedAt": "..."
      }
    }
  ]
}
```

---

### `POST /api/v1/buildings/:buildingId/apartments`

**Request:**

```json
{
  "number": "6A",
  "floor": 6
}
```

**Response 201:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "number": "6A",
    "floor": 6,
    "buildingId": "uuid-bina"
  }
}
```

---

### `PUT /api/v1/buildings/:buildingId/apartments/:id`

**Request:**

```json
{
  "number": "6B",
  "floor": 6
}
```

**Response 200:**

```json
{
  "success": true,
  "data": { /* güncel daire */ }
}
```

---

### `DELETE /api/v1/buildings/:buildingId/apartments/:id`

**Response 200:**

```json
{
  "success": true,
  "message": "Daire silindi."
}
```

---

### `DELETE /api/v1/buildings/:buildingId/apartments/:id/resident`

Sakini daireden ayırır (hesap silinmez).

**Response 200:**

```json
{
  "success": true,
  "message": "Sakin daireden çıkarıldı."
}
```

---

## 10. Davet kodu — `/api/v1/apartments/:apartmentId/invite-code`

Auth: **Bearer** · Rol: **MANAGER**

### `POST /api/v1/apartments/:apartmentId/invite-code`

**Request:** gövde yok

**Response 201:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "apartmentId": "uuid-daire",
    "code": "AP3-B12-X7K9",
    "expiresAt": "2026-06-30T10:00:00.000Z",
    "usedAt": null
  }
}
```

Geçerlilik: 7 gün.

---

## 11. Bina giderleri

### `GET /api/v1/buildings/:id/expenses`

Query: `month`, `year`, `category`, sayfalama

**Response 200** — `Expense` öğesi:

```json
{
  "id": "uuid",
  "buildingId": "uuid-bina",
  "title": "Asansör bakımı",
  "amount": "450.00",
  "perUnitAmount": "22.50",
  "parsedAmount": null,
  "category": "ELEVATOR",
  "date": "2026-06-10T00:00:00.000Z",
  "targetMonth": 6,
  "targetYear": 2026,
  "note": null,
  "splitGroupId": null,
  "sourceExpenseId": null,
  "storedPaths": ["expenses/uuid/file.pdf"],
  "receiptUrl": "/api/v1/expenses/uuid/file/file.pdf",
  "receiptUrls": ["/api/v1/expenses/uuid/file/file.pdf"],
  "createdAt": "...",
  "updatedAt": "..."
}
```

---

### `POST /api/v1/buildings/:id/expenses`

Site gideri ile aynı gövde yapısı (`buildingId` URL’de).

Preview / create yanıtları site gideri ile paralel (`expense` / `expenses` / `warnings`).

---

### `GET /api/v1/buildings/:id/expenses/summary`

Query: `month`, `year` (zorunlu)

**Response 200:**

```json
{
  "success": true,
  "data": {
    "month": 6,
    "year": 2026,
    "totalAmount": "450.00",
    "currency": "TRY",
    "byCategory": [
      { "category": "ELEVATOR", "amount": "450.00", "count": 1 }
    ]
  }
}
```

---

### `PUT /api/v1/expenses/:expenseId`

**Request:**

```json
{
  "title": "Güncel",
  "amount": 500,
  "category": "ELEVATOR",
  "date": "2026-06-11T00:00:00.000Z",
  "targetMonth": 6,
  "targetYear": 2026,
  "note": "Not",
  "receiptUrl": null
}
```

**Response 200:**

```json
{
  "success": true,
  "message": "Gider güncellendi.",
  "data": { /* Expense */ }
}
```

---

### `DELETE /api/v1/expenses/:expenseId`

**Response 200:**

```json
{
  "success": true,
  "message": "Gider silindi.",
  "data": { "id": "uuid" }
}
```

---

### `POST /api/v1/expenses/:expenseId/proof`

`multipart/form-data` · alanlar: `files` veya `files[]` (max 10, PDF/JPEG/PNG)

**Response 200:**

```json
{
  "success": true,
  "message": "Makbuzlar başarıyla yüklendi.",
  "data": {
    "expense": { /* güncel Expense + OCR parsedAmount */ },
    "ocrSummary": {
      "message": "Toplam tutar okundu: ₺450.00",
      "totalAmount": 450
    }
  }
}
```

---

### `GET /api/v1/expenses/:expenseId/file`

### `GET /api/v1/expenses/:expenseId/file/:filename`

Auth: **MANAGER** veya ilgili **RESIDENT** · Yanıt: dosya stream (`Content-Type` mime)

---

## 12. Aidatlar

### `GET /api/v1/buildings/:id/dues`

Rol: **MANAGER** · Query: `month`, `year`, `status`, sayfalama

**Response 200** (öğe):

```json
{
  "id": "uuid",
  "apartmentId": "uuid",
  "month": 6,
  "year": 2026,
  "amount": "550.00",
  "status": "PENDING",
  "dueDate": "2026-06-05T20:59:59.999Z",
  "paidAt": null,
  "overdueDays": 0,
  "note": null,
  "apartmentNumber": "3A",
  "apartment": { "id": "uuid", "number": "3A", "floor": 3 },
  "resident": { /* user public veya null */ },
  "breakdown": { /* aidat breakdown */ }
}
```

---

### `PATCH /api/v1/buildings/:id/dues/:dueId/status`

**Request:**

```json
{
  "status": "PAID",
  "paidAt": "2026-06-10T14:00:00.000Z",
  "note": "Nakit"
}
```

`paidAt` opsiyonel (`PAID` için varsayılan: şimdi).

**Response 200:**

```json
{
  "success": true,
  "message": "Aidat durumu güncellendi.",
  "data": { /* güncel due + breakdown */ }
}
```

---

### `PATCH /api/v1/buildings/:id/due-amount`

**Request:**

```json
{
  "dueAmount": 500,
  "dueDay": 5,
  "currency": "TRY",
  "affectCurrent": true
}
```

`affectCurrent: true` → açık (ödenmemiş) cari ay aidat tutarları güncellenir.

**Response 200:**

```json
{
  "success": true,
  "message": "Aidat bedeli güncellendi.",
  "data": {
    "building": { /* güncel bina */ },
    "updatedOpenDues": 15
  }
}
```

---

### `POST /api/v1/buildings/:id/dues/remind`

**Request:**

```json
{
  "month": 6,
  "year": 2026,
  "dueIds": ["uuid-1", "uuid-2"]
}
```

`month`+`year` birlikte veya ikisi de boş (tüm PENDING/OVERDUE). `dueIds` opsiyonel filtre.

**Response 200:**

```json
{
  "success": true,
  "message": "12 sakine aidat hatırlatması gönderildi.",
  "data": {
    "reminded": 12,
    "skippedCooldown": 0,
    "skippedNoResident": 1
  }
}
```

---

### `POST /api/v1/buildings/:id/dues/bulk`

Eksik aidatları oluşturur.

**Request** (opsiyonel):

```json
{
  "month": 6,
  "year": 2026
}
```

Boş gövde → bulunulan aydan yıl sonuna.

**Response 200:**

```json
{
  "success": true,
  "message": "40 aidat kaydı oluşturuldu.",
  "data": {
    "created": 40,
    "skipped": 0,
    "message": null
  }
}
```

---

## 13. Dekontlar — `/api/v1/dekonts`

### `POST /api/v1/dekonts/upload`

Auth: **RESIDENT** veya **MANAGER** · `multipart/form-data`

| Alan | Zorunlu | Açıklama |
|------|---------|----------|
| `file` | evet | PDF/JPEG/PNG |
| `dueId` | MANAGER için evet | Hangi aidata bağlı |

**Response 201:**

```json
{
  "success": true,
  "message": "Dekont yüklendi.",
  "data": {
    "id": "uuid",
    "buildingId": "uuid-bina",
    "apartmentId": "uuid-daire",
    "dueId": "uuid-aidat",
    "status": "RECEIVED",
    "source": "RESIDENT_UPLOAD",
    "originalFilename": "dekont.pdf",
    "mimeType": "application/pdf",
    "sizeBytes": 102400,
    "parsedAmount": null,
    "createdAt": "..."
  }
}
```

Arka planda OCR + eşleştirme pipeline çalışır; durum `GET` ile izlenir.

---

### `GET /api/v1/dekonts/:id`

Auth: yükleyen sakin veya ilgili yönetici

Query: `download=1` (opsiyonel, dosya yönlendirmesi için)

**Response 200:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "buildingId": "uuid",
    "apartmentId": "uuid",
    "uploadedById": "uuid",
    "dueId": "uuid",
    "status": "NEEDS_MANAGER_REVIEW",
    "source": "RESIDENT_UPLOAD",
    "originalFilename": "dekont.pdf",
    "mimeType": "application/pdf",
    "sizeBytes": 102400,
    "recipientVerified": true,
    "referenceNumber": "REF123",
    "parsedAmount": "550.00",
    "transactionDate": "2026-06-10",
    "aiConfidence": 0.92,
    "reviewedAt": null,
    "reviewNote": null,
    "rejectionReason": null,
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

---

### `GET /api/v1/dekonts/:id/file`

Yanıt: dosya binary stream.

---

### `PATCH /api/v1/dekonts/:id/review`

Rol: **MANAGER**

**Request:**

```json
{
  "decision": "APPROVE",
  "note": "Uygun",
  "dueId": "uuid-aidat"
}
```

`decision`: `APPROVE` | `REJECT`

**Response 200:**

```json
{
  "success": true,
  "message": "Dekont onaylandı ve ödeme uygulandı.",
  "data": {
    "dekont": { /* güncel dekont */ },
    "due": { /* PAID due */ }
  }
}
```

---

### `GET /api/v1/buildings/:id/dekonts`

Rol: **MANAGER** · Query: `status`, `apartmentId`, sayfalama

**Response 200:** dekont listesi (`formatDekont` şekli).

---

## 14. Talepler (ticket)

### `GET /api/v1/buildings/:id/tickets`

Rol: **MANAGER** · Query: `status`, `category`, sayfalama

**Response 200** (öğe):

```json
{
  "id": "uuid",
  "apartmentId": "uuid",
  "userId": "uuid",
  "title": "Asansör arızası",
  "description": "3. katta duruyor",
  "category": "MALFUNCTION",
  "status": "OPEN",
  "apartmentNumber": "3A",
  "apartment": {
    "id": "uuid",
    "number": "3A",
    "floor": 3,
    "buildingId": "uuid"
  },
  "resident": { /* user public */ },
  "createdBy": { /* user public */ },
  "createdAt": "...",
  "updatedAt": "..."
}
```

---

### `GET /api/v1/tickets/:ticketId`

Sahibi sakin veya ilgili yönetici. `updates` dizisi dahil (detay sorguda).

---

### `POST /api/v1/apartments/:apartmentId/tickets`

Rol: **RESIDENT**

**Request:**

```json
{
  "title": "Su kaçağı",
  "description": "Banyo tavanından damlıyor",
  "category": "MALFUNCTION"
}
```

**Response 201:**

```json
{
  "success": true,
  "data": { /* ticket */ }
}
```

---

### `POST /api/v1/tickets/:ticketId/updates`

Rol: **MANAGER**

**Request:**

```json
{
  "message": "Teknisyen yarın gelecek."
}
```

**Response 201:**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "ticketId": "uuid",
    "message": "Teknisyen yarın gelecek.",
    "fromRole": "MANAGER",
    "createdAt": "..."
  }
}
```

---

### `PATCH /api/v1/tickets/:ticketId/status`

Rol: **MANAGER**

**Request:**

```json
{
  "status": "IN_PROGRESS"
}
```

**Response 200:**

```json
{
  "success": true,
  "message": "Talep durumu güncellendi.",
  "data": { /* güncel ticket */ }
}
```

---

### `POST /api/v1/buildings/:id/announcements`

Rol: **MANAGER** — Binadaki tüm sakinlere bildirim.

**Request:**

```json
{
  "title": "Su kesintisi",
  "body": "Yarın 10:00-14:00 arası su kesilecektir."
}
```

**Response 200:**

```json
{
  "success": true,
  "message": "Duyuru gönderildi.",
  "data": {
    "dbCount": 15,
    "pushSent": 12,
    "pushFailed": 1,
    "pushSkipped": 2
  }
}
```

---

## 15. Bildirimler — `/api/v1/notifications`

Auth: **Bearer** (her iki rol)

### `GET /api/v1/notifications/unread-count`

**Response 200:**

```json
{
  "success": true,
  "data": {
    "unreadCount": 5
  }
}
```

---

### `GET /api/v1/notifications`

Query: `unreadOnly=true`, `limit` (1-50, varsayılan 20), `cursor`

**Response 200:**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "type": "DUE_REMINDER",
        "title": "Aidat hatırlatması",
        "body": "Haziran aidatınız bekliyor.",
        "data": { "dueId": "uuid", "route": "/resident-dashboard" },
        "isRead": false,
        "createdAt": "2026-06-23T08:00:00.000Z"
      }
    ],
    "nextCursor": "uuid-sonraki",
    "unreadCount": 5
  }
}
```

---

### `PATCH /api/v1/notifications/:id/read`

**Response 200:**

```json
{
  "success": true,
  "message": "Bildirim okundu olarak işaretlendi.",
  "data": { /* güncel notification */ }
}
```

---

### `PATCH /api/v1/notifications/read-all`

**Response 200:**

```json
{
  "success": true,
  "message": "Tüm bildirimler okundu.",
  "data": { "updated": 12 }
}
```

---

### `POST /api/v1/notifications/dev/seed` (yalnızca development / E2E)

Test bildirimi oluşturur. Production’da yok.

---

## 16. Abonelik

### `GET /api/v1/me/subscription`

Yukarıda [Bölüm 5](#get-apiv1mesubscription) içinde.

---

### `POST /api/v1/subscription/webhook/revenuecat`

Auth: **RevenueCat Bearer secret** (`revenueCatWebhookAuth` middleware) — JWT değil.

**Request:** RevenueCat webhook JSON gövdesi (ham event).

**Response 200:**

```json
{
  "success": true,
  "data": {
    "handled": true,
    "type": "INITIAL_PURCHASE",
    "userId": "uuid-manager"
  }
}
```

İşlenmeyen event:

```json
{
  "success": true,
  "data": {
    "handled": false,
    "type": "TEST",
    "reason": "test_event"
  }
}
```

---

## 17. Raporlar (PDF)

Auth: **Bearer** · Rol: **MANAGER**

### `GET /api/v1/buildings/:id/reports`

Query:

| Parametre | Zorunlu | Değer |
|-----------|---------|-------|
| `type` | evet | `monthly` \| `annual` |
| `year` | evet | `2026` |
| `month` | aylık için evet | `1`…`12` |

**Response 200:** `application/pdf` binary

Örnek dosya adı: `rapor-Yildiz-Apartmani-2026-06.pdf`

---

### `GET /api/v1/sites/:id/reports`

Aynı query kuralları.

**Response 200:** `application/pdf` — site konsolide rapor (tüm bloklar).

Örnek dosya adı: `site-rapor-Gunes-Sitesi-2026-06.pdf`

Site raporu JSON veri şekli (PDF üretiminde kullanılır; doğrudan endpoint yok):

- `scope: "site"`
- `buildings[]`: blok bazlı tahsilat özeti
- `dues.rows[]`: `buildingName`, `apartmentNumber`, `residentName`
- `expenses`: site + blok giderleri birleşik

---

## 18. WebSocket

### `WSS /api/v1/realtime?token=<accessToken>`

Olay örneği (sunucu → istemci):

```json
{
  "event": "force_logout",
  "sessionId": "uuid-session"
}
```

Başka bir cihazdan oturum kapatıldığında veya `logout-all-devices` sonrası tetiklenir.

Nginx: `Upgrade` + `Connection: upgrade` gerekir.

---

## 19. Statik dosyalar

### `GET /uploads/avatars/<dosya>`

Profil fotoğrafları. Auth yok (public path); URL `profilePicture` alanında döner.

---

## Hızlı endpoint indeksi

| Method | Tam yol | Rol |
|--------|---------|-----|
| GET | `/health` | — |
| POST | `/api/v1/auth/register` | — |
| POST | `/api/v1/auth/login` | — |
| POST | `/api/v1/auth/refresh` | — |
| POST | `/api/v1/auth/join` | — |
| POST | `/api/v1/auth/forgot-password` | — |
| POST | `/api/v1/auth/reset-password` | — |
| POST | `/api/v1/auth/logout` | auth |
| POST | `/api/v1/auth/logout-all-devices` | auth |
| GET | `/api/v1/me` | auth |
| PUT | `/api/v1/me` | auth |
| DELETE | `/api/v1/me` | auth |
| PUT | `/api/v1/me/password` | auth |
| PUT | `/api/v1/me/language` | auth |
| PUT | `/api/v1/me/fcm-token` | auth |
| GET | `/api/v1/me/sessions` | auth |
| DELETE | `/api/v1/me/sessions/:sessionId` | auth |
| GET | `/api/v1/me/subscription` | MANAGER |
| GET | `/api/v1/me/payment-collection` | RESIDENT |
| GET | `/api/v1/me/dues` | RESIDENT |
| GET | `/api/v1/me/expenses` | RESIDENT |
| GET | `/api/v1/me/tickets` | RESIDENT |
| GET | `/api/v1/me/dekonts` | RESIDENT |
| POST | `/api/v1/me/profile-picture` | auth |
| DELETE | `/api/v1/me/profile-picture` | auth |
| POST | `/api/v1/buildings` | MANAGER |
| GET | `/api/v1/buildings` | MANAGER |
| GET | `/api/v1/buildings/collection-presets` | MANAGER |
| GET | `/api/v1/buildings/:id` | MANAGER |
| PUT | `/api/v1/buildings/:id` | MANAGER |
| DELETE | `/api/v1/buildings/:id` | MANAGER |
| PATCH | `/api/v1/buildings/:id/collection` | MANAGER |
| GET | `/api/v1/buildings/:id/dashboard-summary` | MANAGER |
| GET | `/api/v1/buildings/:id/dues` | MANAGER |
| PATCH | `/api/v1/buildings/:id/dues/:dueId/status` | MANAGER |
| PATCH | `/api/v1/buildings/:id/due-amount` | MANAGER |
| POST | `/api/v1/buildings/:id/dues/remind` | MANAGER |
| POST | `/api/v1/buildings/:id/dues/bulk` | MANAGER |
| GET | `/api/v1/buildings/:id/expenses` | MANAGER |
| POST | `/api/v1/buildings/:id/expenses` | MANAGER |
| GET | `/api/v1/buildings/:id/expenses/summary` | MANAGER |
| GET | `/api/v1/buildings/:id/reports` | MANAGER |
| GET | `/api/v1/buildings/:id/tickets` | MANAGER |
| POST | `/api/v1/buildings/:id/announcements` | MANAGER |
| GET | `/api/v1/buildings/:id/dekonts` | MANAGER |
| GET | `/api/v1/buildings/:buildingId/apartments` | MANAGER |
| POST | `/api/v1/buildings/:buildingId/apartments` | MANAGER |
| PUT | `/api/v1/buildings/:buildingId/apartments/:id` | MANAGER |
| DELETE | `/api/v1/buildings/:buildingId/apartments/:id` | MANAGER |
| DELETE | `/api/v1/buildings/:buildingId/apartments/:id/resident` | MANAGER |
| POST | `/api/v1/sites` | MANAGER |
| GET | `/api/v1/sites` | MANAGER |
| GET | `/api/v1/sites/:id` | MANAGER |
| PUT | `/api/v1/sites/:id` | MANAGER |
| DELETE | `/api/v1/sites/:id` | MANAGER |
| PATCH | `/api/v1/sites/:id/collection` | MANAGER |
| GET | `/api/v1/sites/:id/buildings` | MANAGER |
| POST | `/api/v1/sites/:id/buildings` | MANAGER |
| GET | `/api/v1/sites/:id/expenses` | MANAGER |
| POST | `/api/v1/sites/:id/expenses` | MANAGER |
| GET | `/api/v1/sites/:id/expenses/summary` | MANAGER |
| GET | `/api/v1/sites/:id/reports` | MANAGER |
| PUT | `/api/v1/site-expenses/:expenseId` | MANAGER |
| DELETE | `/api/v1/site-expenses/:expenseId` | MANAGER |
| PUT | `/api/v1/expenses/:expenseId` | MANAGER |
| DELETE | `/api/v1/expenses/:expenseId` | MANAGER |
| POST | `/api/v1/expenses/:expenseId/proof` | MANAGER |
| GET | `/api/v1/expenses/:expenseId/file` | auth |
| GET | `/api/v1/expenses/:expenseId/file/:filename` | auth |
| POST | `/api/v1/apartments/:apartmentId/invite-code` | MANAGER |
| POST | `/api/v1/apartments/:apartmentId/tickets` | RESIDENT |
| GET | `/api/v1/tickets/:ticketId` | auth |
| POST | `/api/v1/tickets/:ticketId/updates` | MANAGER |
| PATCH | `/api/v1/tickets/:ticketId/status` | MANAGER |
| POST | `/api/v1/dekonts/upload` | RESIDENT/MANAGER |
| GET | `/api/v1/dekonts/:id` | auth |
| GET | `/api/v1/dekonts/:id/file` | auth |
| PATCH | `/api/v1/dekonts/:id/review` | MANAGER |
| GET | `/api/v1/notifications` | auth |
| GET | `/api/v1/notifications/unread-count` | auth |
| PATCH | `/api/v1/notifications/:id/read` | auth |
| PATCH | `/api/v1/notifications/read-all` | auth |
| POST | `/api/v1/subscription/webhook/revenuecat` | webhook secret |
| WSS | `/api/v1/realtime?token=...` | access JWT |

---

## Notlar (Flutter entegrasyonu)

1. **Liste parse:** `response.data['data']` — dizi mi `{ items, nextCursor }` mi kontrol edin (`paginated` / `cursor` kullanımına bağlı).
2. **Site + bina:** `GET /buildings?standalone=true` → Binalar sekmesi; `GET /sites` → Siteler sekmesi.
3. **Effective IBAN:** Yönetici formlarında bina/site override; sakin ödemede `GET /me/payment-collection`.
4. **Gider preview:** `confirmPaidImpact: false` ile POST; `requiresConfirmation: true` dönerse kullanıcı onayı sonrası `true` ile tekrar gönderin.
5. **PDF indirme:** Dio `responseType: ResponseType.bytes`; `Content-Disposition` dosya adından alınabilir.
6. **Prod API:** `https://api.aidatpanel.com` · Yerel: `http://10.0.2.2:4200` (emülatör).

---

*Bu dosya `backend/index.js` ve `src/routes/*` kaynak koduna göre üretilmiştir. Uçlar canlıda çalışır durumdadır; site yönetimi uçları 2026-06-23 itibarıyla eklendi.*
