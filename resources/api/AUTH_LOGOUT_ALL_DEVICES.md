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
1. `refreshTokenVersion` +1 (eski `rv` içeren access ve refresh JWT'ler geçersiz).
2. Güncel kullanıcı ile yeni access + refresh üretilir.
3. `fcmToken` **silinmez** (bu cihaz push almaya devam eder).

## `POST /auth/logout` farkı

| | `logout` | `logout-all-devices` |
|---|----------|----------------------|
| Bu cihaz | Mobil `clearAuth()` ile çıkar | Yeni token kaydedilir, kalır |
| Diğer cihazlar | **Etkilenmez** (sunucu `refreshTokenVersion` artırmaz) | Eski `rv` ile tüm oturumlar düşer |
| Sunucu DB | No-op (yalnızca 200 JSON) | `refreshTokenVersion++` |
| FCM | Değişmez | Değişmez |

**Ürün notu:** Tüm cihazlardan zorunlu çıkış için `logout-all-devices` veya şifre değişimi (`PUT /me/password` → `refreshTokenVersion++`) kullanılır. Tek cihaz seçimi için ileride `UserDevice` tablosu planlanır.

## Manuel test

1. Aynı hesapla iki cihazda giriş.
2. Cihaz A → Ayarlar → Diğer cihazlardan çıkış → onayla.
3. Cihaz A → API çağrıları çalışmalı.
4. Cihaz B → refresh veya korumalı istek → 401 → login.

## Mobil

- `ApiConstants.logoutAllDevices`
- `AuthRemoteDataSource.logoutAllDevices()`
- `DioClient.beginSessionMutation()` / `endSessionMutation()` — paralel 401 yarışını önler
- Profil: `LogoutAllDevicesTile` (`profile_details_screen.dart`)

**Kaynak branch:** Backend güncel kodu `origin/mobile/dekont` içindeki `backend/` klasöründen alınır.
