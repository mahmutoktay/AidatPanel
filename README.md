# AidatPanel

Türk apartman ve site yönetimi için tam yığın monorepo: **mobil (Flutter)**, **backend (Node.js)**, **web** (landing).

## Klasörler

| Klasör | Açıklama |
|--------|----------|
| [`mobile/`](mobile/) | Flutter uygulaması (iOS + Android) |
| [`backend/`](backend/) | Express 5 + Prisma + PostgreSQL API |
| [`resources/`](resources/) | Yol haritası, API notları, tasarım |
| [`web/`](web/) | Tanıtım sitesi (varsa) |

## Hızlı başlangıç

### Backend (yerel)

```bash
cd backend
npm install
cp .env.example .env
# DATABASE_URL, JWT_* düzenleyin
npx prisma migrate deploy
npm run dev
```

API: `http://127.0.0.1:4200/api/v1` — ayrıntı: [`backend/README.md`](backend/README.md)

### Mobil

```bash
cd mobile
flutter pub get
flutter run
```

Canlı API + push: `main.dart`. Mock: `flutter run -t lib/main_dev.dart`

## Bildirimler (FCM + canlı mimari)

- Push: backend `pushService.js` → Firebase FCM; mobil token `PUT /me/fcm-token`
- Rozet: `GET /api/v1/notifications/unread-count` (hafif poll)
- Genişletilebilir katman (Instagram-benzeri): [`resources/bildirim/REALTIME_NOTIFICATIONS.md`](resources/bildirim/REALTIME_NOTIFICATIONS.md)
- **Tek seferde deploy:** [`resources/bildirim/DEPLOY_TEK_SEFER.md`](resources/bildirim/DEPLOY_TEK_SEFER.md)
- E2E: [`resources/bildirim/FCM_E2E_CHECKLIST.md`](resources/bildirim/FCM_E2E_CHECKLIST.md)

## Belgeler

- Faz / görevler: [`resources/yol-haritası/FAZ_DURUMU.md`](resources/yol-haritası/FAZ_DURUMU.md)
- AI kuralları: [`CLAUDE.md`](CLAUDE.md)
- Mimari özet: [`resources/AIDATPANEL.md`](resources/AIDATPANEL.md)
