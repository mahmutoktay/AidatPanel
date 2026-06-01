# FCM push — E2E kontrol listesi

Uygulama **kapalıyken** sistem bildirimi (tray) için: backend kayıt + FCM + cihaz `fcmToken` + bildirim izni gerekir. In-app liste dolu, tray boşsa sorun genelde FCM katmanındadır.

## Emülatör (sakin test cihazı)

1. Android Studio → Device Manager → **Play Store** simgeli AVD (Google Play Services şart).
2. `cd mobile` → `flutter run` (`lib/main.dart`, `main_dev` değil).
3. **Sakin** hesabıyla giriş.
4. Logcat filtre `FCM`:
   - `[FCM] Cihaz token alındı`
   - `[FCM] PUT /me/fcm-token başarılı`
5. Ayarlar → Aidat Paneli → **Bildirimler açık** (Android 13+).
6. Uygulamayı **son uygulamalardan kaydır** (Ayarlar → Zorla durdur **değil**).
7. Fiziksel telefonda **yönetici** ile talep güncelle / duyuru gönder.
8. Emülatör tray’de bildirim beklenir.

Kapalıyken mesaj geldi mi: `adb logcat | findstr FCM` → `[FCM background]` satırı.

## Telefon (yönetici)

- **Farklı hesap** kullanın (sakin emülatördeyken yönetici telefonda).
- Aynı sakin hesabını telefonda açmayın; son cihazın token’ı backend’de kalır.

## Backend doğrulama (canlı / VPS)

### Sakin `fcmToken` dolu mu?

```sql
SELECT id, email, role, LEFT("fcmToken", 20) AS token_prefix, LENGTH("fcmToken") AS token_len
FROM "User"
WHERE email = 'test1@test.com' AND "deletedAt" IS NULL;
```

`token_len` null veya 0 ise push atlanır; sunucu logu: `[notification] push atlandı — fcmToken yok`.

### Talep güncellemesi sonrası log

`pm2 logs aidatpanel-api` (veya eşdeğeri) içinde:

- Başarı: push özeti `sent=1`
- Token yok: `[notification] push atlandı — fcmToken yok`
- Firebase hata: `[push] Gönderim hatası:` veya `Geçersiz token temizlendi`

### Deploy

Backend (`backend/` bu repoda):

- `pushService.js` — FCM `channelId`, title/body data
- `notificationService.js` — push logları
- `GET /notifications/unread-count` — mobil rozet (liste poll azaltır)

VPS: deploy + `pm2 restart aidatpanel-api` (veya eşdeğeri).

## Başarı kriterleri

1. Sakin girişinde `PUT /me/fcm-token` 200, DB’de token dolu.
2. Yönetici `TICKET_UPDATE` → emülatör kapalı → tray bildirimi.
3. Bildirime dokununca `/tickets/:id` açılır.
