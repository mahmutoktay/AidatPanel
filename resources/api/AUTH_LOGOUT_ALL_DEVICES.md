# POST /api/v1/auth/logout-all-devices

**Amaç:** Kullanıcının diğer telefon/tablet oturumlarını sonlandırır; isteği atan cihazda oturum devam eder (yeni token çifti döner).

## İstek

| Alan | Değer |
|------|--------|
| Method | `POST` |
| Path | `/api/v1/auth/logout-all-devices` |
| Auth | `Authorization: Bearer <accessToken>` |
| Body | Yok |

## Başarı (200)

```json
{
  "success": true,
  "message": "Diğer cihazlardaki oturumlar sonlandırıldı.",
  "data": {
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

**Sunucu davranışı:**
1. `refreshTokenVersion` +1 (eski `rv` içeren refresh JWT'ler geçersiz).
2. Güncel kullanıcı ile yeni access + refresh üretilir.
3. `fcmToken` **silinmez** (bu cihaz push almaya devam eder).

## `POST /auth/logout` farkı

| | `logout` | `logout-all-devices` |
|---|----------|----------------------|
| Bu cihaz | Mobil `clearAuth()` ile çıkar | Yeni token kaydedilir, kalır |
| Diğer cihazlar | Eski refresh geçersiz | Eski refresh geçersiz |
| FCM | `fcmToken: null` | Değişmez |

## Manuel test

1. Aynı hesapla iki cihazda giriş.
2. Cihaz A → Ayarlar → Diğer cihazlardan çıkış → onayla.
3. Cihaz A → API çağrıları çalışmalı.
4. Cihaz B → refresh veya korumalı istek → 401 → login.

## Mobil

- `ApiConstants.logoutAllDevices`
- `AuthRemoteDataSource.logoutAllDevices()`
- Ayarlar: `settings_tab.dart` → `_LogoutAllDevicesTile`

**Kaynak branch:** Backend güncel kodu `origin/mobile/dekont` içindeki `backend/` klasöründen alınır.
