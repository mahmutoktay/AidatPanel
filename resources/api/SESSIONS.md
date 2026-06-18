# Cihaz Oturumları API

## GET /api/v1/me/sessions

Aktif oturumları listeler. Mevcut cihaz `isCurrent: true` ile işaretlenir.

**Auth:** Bearer access token (JWT içinde `sid` claim)

**Yanıt (200):**

```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "deviceLabel": "Samsung Galaxy A54",
      "platform": "android",
      "createdAt": "2026-06-01T10:30:00.000Z",
      "lastSeenAt": "2026-06-18T08:15:00.000Z",
      "isCurrent": true
    }
  ]
}
```

## DELETE /api/v1/me/sessions/:sessionId

Tek bir oturumu sonlandırır. **Mevcut cihaz oturumu silinemez** (400).

Hedef cihaza WebSocket `force_logout` + `sessionId` gönderilir.

## POST /api/v1/auth/logout-all-devices

Diğer tüm oturumları sonlandırır; isteği atan cihazda oturum devam eder.

Bkz. [`AUTH_LOGOUT_ALL_DEVICES.md`](./AUTH_LOGOUT_ALL_DEVICES.md)

## Login / Join / Refresh — cihaz meta

Opsiyonel body alanları:

| Alan | Açıklama |
|------|----------|
| `deviceLabel` | Cihaz adı (max 120) |
| `platform` | `android`, `ios` veya `unknown` |

Login/join'de yeni `UserSession` oluşturulur; JWT'ye `sid` eklenir.

Eski refresh token'larda `sid` yoksa ilk refresh'te yeni session oluşturulur.
