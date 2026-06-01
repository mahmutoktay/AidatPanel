# Bildirim sistemi — tek seferde deploy

Backend + mobil birlikte yüklenince: **açık uygulama → WebSocket anında**, **kapalı → FCM tray**, **yedek → poll**.

---

## 1. Backend (VPS)

```bash
cd /path/to/AidatPanel/backend
git pull   # veya dosyaları kopyala
npm install
npx prisma migrate deploy
```

### `.env` (canlıda mutlaka)

```env
REALTIME_WS_ENABLED=true
FIREBASE_SERVICE_ACCOUNT_JSON=...   # veya PATH
JWT_SECRET=...
DATABASE_URL=...
```

### PM2

```bash
pm2 restart aidatpanel-api
pm2 logs aidatpanel-api --lines 50
```

Başarı logları:

- `[realtime] WebSocket dinleniyor: /api/v1/realtime`
- Talep güncellemesi sonrası: `[notification] iletim özeti: ... pushSent=1`

### Nginx (CloudPanel / reverse proxy)

WebSocket upgrade şart:

```nginx
location /api/v1/realtime {
    proxy_pass http://127.0.0.1:4200;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_read_timeout 86400;
}
```

---

## 2. Mobil

```bash
cd mobile
flutter pub get
flutter run   # veya release / AAB
```

- `main.dart` kullanın (`main_dev` mock — WebSocket yok).
- Logcat: `[realtime] WebSocket bağlandı`
- Logcat: `[FCM] PUT /me/fcm-token başarılı`

`NotificationDeliveryConfig.webSocketEnabled = true` (kaynakta açık).

---

## 3. Test (2 cihaz)

| Cihaz | Hesap |
|-------|--------|
| Telefon | Yönetici |
| Emülatör / 2. telefon | Sakin (farklı hesap) |

1. Sakin giriş → FCM token + WebSocket bağlantısı logları OK.
2. **Uygulama açık (sakin):** Yönetici talep notu → **hemen** toast/rozet (WebSocket).
3. Uygulamayı son uygulamalardan kapat (zorla durdurma değil).
4. Yönetici tekrar güncelle → **tray** bildirimi (FCM).

---

## 4. Sorun giderme

| Belirti | Kontrol |
|---------|---------|
| WS bağlanmıyor | Nginx upgrade, `REALTIME_WS_ENABLED`, JWT süresi |
| Tray yok | `fcmToken` DB’de dolu mu, Firebase JSON |
| Açıkken gecikme | WS log; yoksa poll 50–90 sn yedek |
| Liste var tray yok | FCM / izin / token |

SQL: [`FCM_E2E_CHECKLIST.md`](FCM_E2E_CHECKLIST.md)

Mimari: [`REALTIME_NOTIFICATIONS.md`](REALTIME_NOTIFICATIONS.md)
