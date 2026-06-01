# AidatPanel Backend API

Türk apartman ve site yöneticileri için aidat yönetim platformunun Node.js API’si (Express 5, Prisma 7, PostgreSQL).

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

Smoke test: `python3 test.py` (sunucu çalışırken)

---

## Proje yapısı (özet)

```
backend/
├── index.js                 # Express giriş, /api/v1 mount
├── prisma/schema.prisma
├── prisma/migrations/
├── src/
│   ├── config/              # db, firebase, dekont
│   ├── routes/              # auth, buildings, dekonts, notifications, …
│   ├── controllers/
│   ├── services/
│   ├── middlewares/         # authMiddleware, validate (Zod), rateLimit
│   ├── constants/
│   └── utils/
├── uploads/dekonts/         # Yerel dekont depolama (gitignore)
├── test.py                  # E2E smoke (Faz 1 + 2A + dekont)
└── tools/parseDekontSamples.js
```

---

## API özeti

Tüm route’lar `/api/v1` altında. Yanıt gövdesi: `{ "success": true|false, "message"?, "data"?, "errors"? }`.

| Alan | Route dosyası | Not |
|------|---------------|-----|
| Auth | `authRoutes` | register, login (`identifier`), refresh, logout, forgot/reset |
| Buildings | `buildingRoutes` | CRUD, dues, expenses, tickets, announcements, collection, dekont listesi |
| Apartments | `apartmentRoutes` | CRUD, resident, invite-code |
| Me | `meRoutes` | profil, dues, tickets, dekonts, fcm-token, KVKK delete |
| Notifications | `notificationRoutes` | liste, `GET /unread-count`, okundu, duyuru |
| Realtime | `realtime/wsGateway.js` | WebSocket `/api/v1/realtime` (`REALTIME_WS_ENABLED`) |
| Tickets | `ticketRoutes`, `apartmentTicketRoutes` | talep + güncelleme |
| Expenses | `expenseRoutes` | gider CRUD + özet |
| Dekonts | `dekontRoutes` | upload, review, file stream |

Detaylı sözleşme: [`../API/FLUTTER-BACKEND.md`](../API/FLUTTER-BACKEND.md)

---

## Dekont

- **Endpoint’ler:** `POST /dekonts/upload`, `GET /dekonts/:id`, `GET /dekonts/:id/file`, `PATCH /dekonts/:id/review`, `GET /me/dekonts`, `GET /buildings/:id/dekonts`, `PATCH /buildings/:id/collection`
- **OCR:** `pdf-parse`, Tesseract CLI — Vision API yok
- **Env:** `backend/.env.example` (`DEKONT_*`, `TESSERACT_CMD`)

```bash
# Arch örnek
sudo pacman -S tesseract tesseract-data-tur poppler
cd backend && python3 test.py
```

---

## Ortam değişkenleri (temel)

| Değişken | Açıklama |
|----------|----------|
| `DATABASE_URL` | PostgreSQL |
| `JWT_SECRET`, `REFRESH_TOKEN_SECRET` | Token imzalama |
| `ALLOWED_ORIGINS` | CORS (Flutter web) |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Push (production’da gerekli) |
| `DEKONT_UPLOAD_DIR` | Varsayılan `./uploads/dekonts/` |

Tam liste: `.env.example`

---

## Dokümantasyon

| Dosya | İçerik |
|-------|--------|
| [`../AIDATPANEL.md`](../AIDATPANEL.md) | Master referans |
| [`../API/README.md`](../API/README.md) | API dokümantasyon indeksi |
| [`../API/FLUTTER-BACKEND.md`](../API/FLUTTER-BACKEND.md) | Mobil entegrasyon sözleşmesi |
| [`FURKAN_ICIN_DOKUMANTASYON.md`](FURKAN_ICIN_DOKUMANTASYON.md) | Flutter JWT rehberi |
| [`GOREVDAGILIMI.md`](GOREVDAGILIMI.md) | Fazlar ve görev dağılımı |
| [`../planning/DEKONT_VERIFICATION_PLAN.md`](../planning/DEKONT_VERIFICATION_PLAN.md) | Dekont implementasyon planı |
| [`../API/YUSUF_YAPILANLAR_BİLDİRİM.md`](../API/YUSUF_YAPILANLAR_BİLDİRİM.md) | Bildirim modülü notları |

---

## Geliştirme notları

- Şema değişikliği: `npx prisma migrate dev` (geliştirme) / `migrate deploy` (CI/prod)
- Prisma Studio: `npx prisma studio`
- Dekont regex örnekleri: `npm run test:dekont-regex`
- Bildirim demo: `npm run demo:notifications`
- `.env` dosyasını commit etmeyin
