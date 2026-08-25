# AidatPanel Backend API

Türk apartman ve site yöneticileri için aidat yönetim platformunun Node.js API'si (Express 5, Prisma 7, PostgreSQL).

## Hızlı başlangıç

### Gereksinimler

- Node.js 20+
- PostgreSQL (yerel Docker veya Neon)
- Opsiyonel (dekont OCR): `tesseract` (`tur+eng`), `poppler-utils` (`pdftoppm`)

### Kurulum

```bash
cd backend
npm install
cp .env.example .env
# DATABASE_URL ve JWT_* değerlerini düzenleyin
npx prisma migrate deploy
npx prisma generate
npm run dev
```

API: `http://127.0.0.1:4200/api/v1`

```bash
npm test   # unit testler (dueGeneration, trDueDate, authRateLimitKey)
```

### Tanıtım / Play Store demo verisi

Canlı (veya tünellenmiş) DB’de yönetici hesabına site/blok/gider/talep doldurur. Varsayılan tünel portu `5433`.

```bash
# SSH tüneli: uzak 5432 → yerel 5433 açık olmalı
DEMO_MANAGER_EMAIL=abdullahaslan061212@gmail.com npm run seed:showcase
# Sıfırdan: DEMO_FORCE=1 npm run seed:showcase
```

### Müşteri demo (tek bina)

Sıfır DB’de `abdullah@demo.com` + 10 dairelik Çamlık Apartmanı (aidat %75, elden/havale, giderler, talepler, duyurular).

```bash
# SSH tüneli: uzak 5432 → yerel 5433
npm run seed:customer-demo
# Yerel DB: DEMO_DB_PORT=5432 npm run seed:customer-demo
```

---

## Proje yapısı (özet)

```
backend/
├── index.js
├── prisma/schema.prisma
├── src/
│   ├── routes/              # auth, buildings, dekonts, me, notifications, …
│   ├── controllers/         # ince HTTP katmanı
│   ├── services/            # iş mantığı
│   ├── validators/          # Zod şemaları (feature bazlı)
│   ├── middlewares/         # auth, validate, rateLimit
│   ├── jobs/                # dueAutoGenerateJob (aidat bakımı)
│   └── realtime/            # WebSocket gateway
├── __tests__/               # Jest unit testler
└── uploads/dekonts/
```

---

## API özeti

Tüm route'lar `/api/v1` altında. Yanıt: `{ "success": true|false, "message"?, "data"?, "errors"? }`.

| Alan | Route dosyası | Not |
|------|---------------|-----|
| Auth | `authRoutes` | register, login, refresh, join, logout, logout-all-devices, forgot/reset |
| Me | `meRoutes` | profil, şifre, dil, fcm-token, KVKK delete |
| Buildings | `buildingRoutes` | CRUD, dues, expenses, tickets, announcements, collection, dekont |
| Apartments | `apartmentRoutes` | CRUD, resident çıkarma, invite-code |
| Notifications | `notificationRoutes` | liste, unread-count, okundu |
| Realtime | `realtime/wsGateway.js` | `wss://…/api/v1/realtime?token=` |
| Tickets | `ticketRoutes` | talep + güncelleme |
| Expenses | `expenseRoutes` | CRUD, proof upload, dosya indirme |
| Dekonts | `dekontRoutes` | upload, review, OCR pipeline |

### Aidat bakımı (otomatik)

`DUE_AUTO_GENERATE_ENABLED=true` ile günlük job:
- Eksik aidat üretimi (`bulunulan ay → yıl sonu`)
- `PENDING` → `OVERDUE` geçişi

Manuel: `POST /buildings/:id/dues/bulk` (yönetici)

---

## Dekont

- **Endpoint'ler:** `POST /dekonts/upload`, `GET /dekonts/:id/file`, `PATCH /dekonts/:id/review`, `GET /me/dekonts`, `GET /buildings/:id/dekonts`, `PATCH /buildings/:id/collection`
- **OCR:** Tesseract (worker thread destekli), `pdf-parse`
- **Env:** `backend/.env.example` (`DEKONT_*`, `TESSERACT_CMD`)

---

## Ortam değişkenleri (temel)

| Değişken | Açıklama |
|----------|----------|
| `DATABASE_URL` | PostgreSQL |
| `JWT_SECRET`, `REFRESH_TOKEN_SECRET` | Token imzalama |
| `ALLOWED_ORIGINS` | CORS |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Push |
| `REALTIME_WS_ENABLED` | WebSocket |
| `DUE_AUTO_GENERATE_ENABLED` | Aidat bakım job'u |

Tam liste: `.env.example`

---

## Dokümantasyon

| Dosya | İçerik |
|-------|--------|
| [`../resources/AIDATPANEL.md`](../resources/AIDATPANEL.md) | Master referans (API + bildirim mimarisi) |
| [`../resources/yol-haritası/FAZ_DURUMU.md`](../resources/yol-haritası/FAZ_DURUMU.md) | Faz durumu |
| [`../resources/api/DEKONT_FILE_404_TROUBLESHOOTING.md`](../resources/api/DEKONT_FILE_404_TROUBLESHOOTING.md) | Dekont 404/502 |
| [`../resources/api/AUTH_LOGOUT_ALL_DEVICES.md`](../resources/api/AUTH_LOGOUT_ALL_DEVICES.md) | logout-all-devices sözleşmesi |
