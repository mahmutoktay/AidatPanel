# AidatPanel — Claude Code Master Reference

> **Güncelleme:** 2026-07-14 · Canonical şema: `backend/prisma/schema.prisma` · Faz durumu: `resources/yol-haritası/FAZ_DURUMU.md`  
> Bu dosya API sözleşmesi, veri modeli ve deployment özetidir. Drift olursa kod / Prisma kaynak kabul edilir.

## 📌 Proje Özeti

**AidatPanel**, Türk apartman ve site yöneticileri için geliştirilmiş bir mobil aidat yönetim platformudur. Yöneticiler site + tekil bina hiyerarşisini tek hesaptan yönetir; sakinler kendi aidat, gider, dekont ve ticket süreçlerini kullanır.

- **Domain:** aidatpanel.com (Cloudflare)
- **Platform:** iOS + Android (Flutter) — sürüm `0.6.10+2000000013`
- **Backend:** Node.js + Express (Contabo VPS, PM2: `aidapanel-api`)
- **Veritabanı:** PostgreSQL (Prisma 7)
- **Web:** Statik landing (`web/`); admin panel API: `/api/v1/admin`
- **Dil:** TR + EN (Slang i18n)
- **Abonelik:** RevenueCat (`aidatpanel_monthly` / `aidatpanel_annual`) — kota: **toplam bina sayısı**

---

## 📁 Klasör Yapısı

```
aidatpanel/
├── web/                  # Landing page (statik)
├── mobile/               # Flutter uygulaması
│   ├── lib/
│   │   ├── core/         # theme, router, network, notifications
│   │   ├── features/     # auth, dashboard, sites, buildings, …
│   │   ├── l10n/         # Slang TR/EN
│   │   └── shared/
│   └── pubspec.yaml
└── backend/
    ├── src/
    │   ├── routes/       # Express route mount'ları
    │   ├── controllers/
    │   ├── services/     # iş kuralları (SRP)
    │   ├── middlewares/
    │   ├── validators/   # Zod
    │   ├── realtime/     # WebSocket hub
    │   ├── jobs/         # OVERDUE / auto-generate
    │   └── utils/
    ├── prisma/
    │   └── schema.prisma
    ├── scripts/          # deploy.sh / deploy.ps1
    ├── .env.example
    └── index.js
```

---

## 🖥️ Backend

### Stack
- **Runtime:** Node.js 20+ (ES Modules)
- **Framework:** Express.js 5
- **ORM:** Prisma 7 (`@prisma/adapter-pg` / Neon adapter)
- **Auth:** JWT — access ~15dk (`JWT_SECRET`), refresh ~30gün (`REFRESH_TOKEN_SECRET`) + `refreshTokenVersion` / `UserSession` SHA-256 replay koruması
- **Email:** Resend (şifre sıfırlama)
- **Push:** Firebase Admin SDK (FCM)
- **Sakin telefon doğrulama:** Firebase Auth Phone + reCAPTCHA Enterprise (`recaptcha_enterprise_flutter` 18.9.1; mobil SMS → `idToken` → `POST /auth/firebase-phone`). Identity Platform: `useSmsTollFraudProtection=true`, `phoneEnforcementState=AUDIT`, `smsRegionConfig` TR allowlist (Vodafone Error 39 / toll-fraud rota bloğunu önler). USB/`flutter run` sideload’da Play Integrity çalışmaz → tarayıcı reCAPTCHA açılır; `MainActivity`’de `android:taskAffinity=""` olmamalı (aksi halde `about:blank`, SMS gitmez — flutterfire#17737). İstemci Error 39 → `firebase_phone_carrier_blocked`.
- **SMS (şifre sıfırlama / yönetici e-posta dışı):** Twilio Verify / Twilio SMS / NetGsm (`SMS_PROVIDER`) — sakin OTP için kullanılmaz
- **Abonelik:** RevenueCat webhook + mobil SDK
- **Realtime:** `ws` — `WSS /api/v1/realtime?token=ACCESS_JWT`
- **Deploy:** PM2 · `api.aidatpanel.com` (CloudPanel reverse proxy, port 4200)

### Ortam Değişkenleri (özet — tam liste: `backend/.env.example`)

```env
PORT=4200
NODE_ENV=development|production
DATABASE_URL=postgresql://...

JWT_SECRET=...                         # min 32 karakter
REFRESH_TOKEN_SECRET=...               # eski ad JWT_REFRESH_SECRET DEĞİL
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=30d

# Opsiyonel
ALLOWED_ORIGINS=https://admin.aidatpanel.com,...
RESEND_API_KEY=...
RESEND_FROM_EMAIL=...
FIREBASE_SERVICE_ACCOUNT_JSON=...      # veya FIREBASE_SERVICE_ACCOUNT_PATH
FIREBASE_PROJECT_ID=aidatpanel
REALTIME_WS_ENABLED=true

# SMS — şifre sıfırlama ve (legacy) yönetici telefon OTP
# Sakin telefon doğrulama Firebase Auth Phone ile yapılır; bu env'ler sakin OTP için zorunlu değil.
SMS_PROVIDER=auto|twilio|netgsm
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_FROM=...
TWILIO_VERIFY_SERVICE_SID=...          # doluysa legacy OTP Verify ile gider
NETGSM_USER=...
NETGSM_PASS=...
NETGSM_HEADER=AIDATPANEL

# Dekont / OCR / listeler
DEKONT_MAX_BYTES=10485760
DEKONT_UPLOAD_DIR=./uploads/dekonts
DEKONT_AMOUNT_TOLERANCE=0.05
DEKONT_AI_AUTO_THRESHOLD=0.85
DEKONT_AUTO_APPLY_PAYMENT=false
DEKONT_OCR_MIN_CONFIDENCE=0.6
DEKONT_PIPELINE_MAX_RETRIES=1
# DEKONT_PIPELINE_CONCURRENCY=1
# DEKONT_OCR_IN_WORKER=true

REVENUECAT_API_KEY=...
REVENUECAT_WEBHOOK_SECRET=...

# Admin panel (mobil JWT ile paylaşılmaz)
ADMIN_JWT_SECRET=...
# ADMIN_JWT_EXPIRES_IN=15m
# ADMIN_REFRESH_EXPIRES_IN=8h
# ADMIN_ALLOWED_IPS=...
```

**Sağlık:** `GET /health` → DB `SELECT 1` (API prefix dışı).

---

## 🗄️ Veritabanı Şeması (Prisma — 2026-07-14)

Aşağıdaki özet canlı `schema.prisma` ile hizalıdır. Index / relation detayı için kaynak dosyaya bakın.

```prisma
model User {
  id                  String    @id @default(uuid())
  email               String?   @unique          // sakinlerde opsiyonel
  passwordHash        String
  name                String
  phone               String?
  firebaseUid         String?   @unique         // Firebase Auth Phone uid
  role                UserRole  @default(RESIDENT)
  fcmToken            String?
  language            String    @default("tr")
  refreshTokenVersion Int       @default(0)     // logout / logout-all
  deletedAt           DateTime?                 // KVKK soft-delete
  profilePicture      String?
  apartmentId         String?   @unique         // RESIDENT one-to-one
  managedBuildings    Building[] @relation("BuildingManager")
  managedSites        Site[]     @relation("SiteManager")
  sessions            UserSession[]
  uploadedDekonts     Dekont[]
  reviewedDekonts     Dekont[]   @relation("DekontReviewer")
  // ... notifications, tickets, subscription, promoGrants, passwordResetTokens
  @@unique([phone, role])
}

model UserSession {
  id            String    @id @default(uuid())
  userId        String
  deviceLabel   String
  platform      String
  lastTokenHash String?   // refresh SHA-256 — replay tespiti
  createdAt     DateTime  @default(now())
  lastSeenAt    DateTime  @default(now())
  revokedAt     DateTime?
}

model PasswordResetToken {
  id        String    @id @default(uuid())
  userId    String
  tokenHash String    @unique
  expiresAt DateTime
  usedAt    DateTime?
  createdAt DateTime  @default(now())
}

model PhoneOtpToken {
  id        String    @id @default(uuid())
  phone     String?
  email     String?
  purpose   String    // resident_login | resident_join | resident_phone_change | manager_*
  tokenHash String    @unique
  payload   Json?
  expiresAt DateTime
  usedAt    DateTime?
  attempts  Int       @default(0)
  createdAt DateTime  @default(now())
}

enum UserRole { MANAGER RESIDENT }

model Subscription {
  id                 String             @id @default(uuid())
  userId             String             @unique
  status             SubscriptionStatus
  plan               String             // "monthly" | "annual"
  platform           String             // "ios" | "android"
  revenuecatId       String?
  currentPeriodStart DateTime
  currentPeriodEnd   DateTime
  createdAt          DateTime           @default(now())
  updatedAt          DateTime           @updatedAt
}

enum SubscriptionStatus { ACTIVE EXPIRED CANCELLED TRIAL }

model Site {
  id                       String   @id @default(uuid())
  name                     String
  address                  String
  city                     String
  district                 String?
  managerId                String
  dueAmount                Decimal? @db.Decimal(10, 2)
  dueDay                   Int      @default(1)
  currency                 String   @default("TRY")
  collectionIban           String?
  collectionAccountTitle   String?
  collectionIbanLabel      String?  // yönetici takma adı (ör. "Ziraat IBAN'ım")
  paymentReferenceTemplate String?
  collectionVerifiedAt     DateTime?
  buildings                Building[]
  siteExpenses             SiteExpense[]
  createdAt                DateTime @default(now())
  updatedAt                DateTime @updatedAt
}

model Building {
  id                 String   @id @default(uuid())
  name               String
  address            String
  city               String
  district           String?
  totalFloors        Int?
  apartmentsPerFloor Int?
  managerId          String
  siteId             String?  // null = tekil bina; dolu → site altı blok
  blockLabel         String?  // site altı için zorunlu (API)
  addressExtra       String?
  dueAmount          Decimal? @db.Decimal(10, 2)
  dueDay             Int      @default(1)
  currency           String   @default("TRY")
  collectionIban           String?
  collectionAccountTitle   String?
  collectionIbanLabel      String?
  paymentReferenceTemplate String?
  collectionVerifiedAt     DateTime?
  apartments         Apartment[]
  expenses           Expense[]
  dekonts            Dekont[]
  createdAt          DateTime @default(now())
  updatedAt          DateTime @updatedAt
}

model SiteExpense {
  id              String          @id @default(uuid())
  siteId          String
  title           String
  amount          Decimal?        @db.Decimal(10, 2)
  category        ExpenseCategory
  date            DateTime
  targetMonth     Int
  targetYear      Int
  perUnitAmount   Decimal?        @db.Decimal(10, 2)
  splitGroupId    String?
  sourceExpenseId String?
  note            String?
  receiptUrl      String?
  storedPaths     Json?           @default("[]")
  // OCR alanları (Expense ile uyumlu)
  rawText         String?
  parsedJson      Json?
  parsedAmount    Decimal?        @db.Decimal(12, 2)
  transactionDate DateTime?
  aiConfidence    Float?
  ocrReceiptsJson Json?
  carryforwards   DueExpenseCarryforward[]
  createdAt       DateTime        @default(now())
  updatedAt       DateTime        @updatedAt
}

model Apartment {
  id          String @id @default(uuid())
  number      String
  floor       Int?
  buildingId  String
  resident    User?          // one-to-one
  dues        Due[]
  inviteCodes InviteCode[]
  tickets     Ticket[]
  dekonts     Dekont[]
  expenseCarryforwards DueExpenseCarryforward[]
  createdAt   DateTime @default(now())
}

model InviteCode {
  id          String    @id @default(uuid())
  code        String    @unique
  apartmentId String
  usedAt      DateTime?
  usedBy      String?
  expiresAt   DateTime
  createdAt   DateTime  @default(now())
}

model Due {
  id                   String    @id @default(uuid())
  apartmentId          String
  amount               Decimal   @db.Decimal(10, 2)
  currency             String    @default("TRY")
  month                Int
  year                 Int
  dueDate              DateTime
  status               DueStatus @default(PENDING)
  paidAt               DateTime?
  overdueDays          Int?      @default(0)
  residentNameSnapshot String?
  note                 String?
  payments             DuePayment[]
  dekontAllocations    DekontDueAllocation[]
  createdAt            DateTime  @default(now())
  updatedAt            DateTime  @updatedAt
}

enum DueStatus { PENDING PAID OVERDUE WAIVED }

model DuePayment {
  id        String   @id @default(uuid())
  dueId     String
  dekontId  String?  // null = manuel "ödendi"
  amount    Decimal  @db.Decimal(12, 2)
  paidAt    DateTime
  currency  String   @default("TRY")
  note      String?
  createdAt DateTime @default(now())
}

model Expense {
  id              String          @id @default(uuid())
  buildingId      String
  title           String
  amount          Decimal?        @db.Decimal(10, 2)
  category        ExpenseCategory
  date            DateTime
  targetMonth     Int
  targetYear      Int
  perUnitAmount   Decimal?        @db.Decimal(10, 2)
  splitGroupId    String?
  sourceExpenseId String?
  note            String?
  receiptUrl      String?         // @deprecated → storedPaths
  storedPaths     Json?           @default("[]")
  rawText         String?
  parsedJson      Json?
  parsedAmount    Decimal?        @db.Decimal(12, 2)
  transactionDate DateTime?
  aiConfidence    Float?
  ocrReceiptsJson Json?
  carryforwards   DueExpenseCarryforward[]
  createdAt       DateTime        @default(now())
  updatedAt       DateTime        @updatedAt
}

model DueExpenseCarryforward {
  id            String  @id @default(uuid())
  expenseId     String?
  siteExpenseId String?
  apartmentId   String
  fromMonth     Int
  fromYear      Int
  toMonth       Int
  toYear        Int
  amount        Decimal @db.Decimal(10, 2)
  createdAt     DateTime @default(now())
  @@unique([expenseId, apartmentId])
  @@unique([siteExpenseId, apartmentId])
}

enum ExpenseCategory {
  CLEANING ELEVATOR ELECTRICITY WATER INSURANCE REPAIR GARDEN OTHER
}

model Ticket {
  id             String         @id @default(uuid())
  apartmentId    String
  userId         String
  title          String
  description    String
  category       TicketCategory
  status         TicketStatus   @default(OPEN)
  attachmentPath String?        // → yanıtta attachmentUrl
  updates        TicketUpdate[]
  createdAt      DateTime       @default(now())
  updatedAt      DateTime       @updatedAt
}

enum TicketCategory { COMPLAINT REQUEST MALFUNCTION OTHER }
enum TicketStatus { OPEN IN_PROGRESS RESOLVED CLOSED }

model TicketUpdate {
  id        String   @id @default(uuid())
  ticketId  String
  message   String
  fromRole  UserRole
  createdAt DateTime @default(now())
}

model Notification {
  id        String           @id @default(uuid())
  userId    String
  code      String           // i18n anahtarı
  params    Json?
  title     String
  body      String
  type      NotificationType
  isRead    Boolean          @default(false)
  data      Json?
  createdAt DateTime         @default(now())
}

enum NotificationType {
  DUE_REMINDER DUE_PAID TICKET_CREATED TICKET_UPDATE
  ANNOUNCEMENT SYSTEM
  DEKONT_RECEIVED DEKONT_MATCHED DEKONT_PAYMENT_APPLIED DEKONT_NEEDS_REVIEW
  EXPENSE_ADDED
}

enum DekontStatus {
  RECEIVED EXTRACTING EXTRACT_FAILED PARSED PARSE_LOW_CONFIDENCE
  MATCHING MATCHED MATCH_AMBIGUOUS UNMATCHED
  PAYMENT_APPLIED PAYMENT_PARTIAL REJECTED RECIPIENT_MISMATCH NEEDS_MANAGER_REVIEW
}

enum DekontSource { RESIDENT_UPLOAD MANAGER_UPLOAD }

model Dekont {
  id                String       @id @default(uuid())
  buildingId        String
  apartmentId       String?
  uploadedById      String
  dueId             String?
  status            DekontStatus @default(RECEIVED)
  source            DekontSource
  storedPath        String
  originalFilename  String
  mimeType          String
  sizeBytes         Int
  rawText           String?
  parsedJson        Json?
  parserProfile     String?
  parseError        String?
  recipientVerified Boolean?
  verificationJson  Json?
  fileHash          String?
  referenceNumber   String?
  senderIban        String?
  receiverIban      String?
  parsedAmount      Decimal?     @db.Decimal(12, 2)
  transactionDate   DateTime?
  aiConfidence      Float?
  reviewedById      String?
  reviewedAt        DateTime?
  reviewNote        String?
  rejectionReason   String?
  payments          DuePayment[]
  dueAllocations    DekontDueAllocation[]
  createdAt         DateTime     @default(now())
  updatedAt         DateTime     @updatedAt
  @@unique([buildingId, referenceNumber])
  @@unique([buildingId, fileHash])
}

model DekontDueAllocation {
  id              String   @id @default(uuid())
  dekontId        String
  dueId           String
  allocatedAmount Decimal? @db.Decimal(12, 2)
  createdAt       DateTime @default(now())
  @@unique([dekontId, dueId])
}

// --- Admin paneli (mobil User tablosundan ayrı) ---
enum AdminRole { SUPER_ADMIN SUPPORT }

model AdminUser {
  id           String    @id @default(uuid())
  email        String    @unique
  passwordHash String
  name         String
  role         AdminRole @default(SUPPORT)
  isActive     Boolean   @default(true)
  fcmToken     String?
  lastLoginAt  DateTime?
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
}

model AdminAuditLog {
  id         String   @id @default(uuid())
  adminId    String
  action     String
  targetType String?
  targetId   String?
  metadata   Json?
  ipAddress  String?
  createdAt  DateTime @default(now())
}

enum PromoType { FREE_PERIOD DISCOUNT_PERCENT }

model PromoGrant {
  id              String    @id @default(uuid())
  userId          String
  grantedById     String
  type            PromoType
  plan            String?
  durationDays    Int?
  discountPercent Int?
  reason          String
  expiresAt       DateTime?
  createdAt       DateTime  @default(now())
}

model UserActivityDaily {
  id          String   @id @default(uuid())
  date        DateTime @db.Date
  role        UserRole
  activeUsers Int
  createdAt   DateTime @default(now())
  @@unique([date, role])
}

model AdminNotification {
  id        String   @id @default(uuid())
  adminId   String?
  title     String
  body      String
  type      String   @default("SYSTEM")
  isRead    Boolean  @default(false)
  metadata  Json?
  createdAt DateTime @default(now())
}

model DbBackup {
  id                     String    @id @default(uuid())
  filename               String
  sizeBytes              BigInt?
  status                 String    @default("PENDING")
  createdById            String
  errorMessage           String?
  downloadTokenHash      String?
  downloadTokenExpiresAt DateTime?
  createdAt              DateTime  @default(now())
  completedAt            DateTime?
}
```

### Effective config (Site → Building)
Site altı binalarda aidat / IBAN / adres boşsa site varsayılanına düşer (`resolveEffectiveBuildingConfig`). Dekont doğrulama ve sakin `payment-collection` **effective IBAN** kullanır.

### IBAN takma adı (`collectionIbanLabel`)
- Yönetici Site/Bina collection alanlarında opsiyonel takma ad (max 40 karakter).
- `GET /buildings/collection-presets` yanıtında döner (kayıtlı IBAN listesi / matcher).
- Preset yanıtı: `buildingCount` (bu seti kullanan bina sayısı) + `siteCount` (bu seti kullanan site sayısı; binası olmasa da site varsayılan IBAN sayılır).
- Dekont alıcı IBAN eşleşince etiketi boş olan aynı manager + aynı IBAN kayıtlarına TR banka kodundan otomatik isim yazılır: `"{banka} IBAN'ım"` (`collectionIbanLabelService` + `trIbanBank.js`). Dolu etiketlere dokunulmaz.

---

## 🔌 API Endpoint'leri

Yanıt sözleşmesi: `{ "success": true|false, "message": "...", "data": ... }`

### Sistem
```
GET    /health                              # DB connectivity (prefix dışı)
WSS    /api/v1/realtime?token=ACCESS_JWT
```

### Auth (`/api/v1/auth`)
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login             # body: identifier (email veya telefon) + password
POST   /api/v1/auth/check-identifier  # purpose: manager_identifier | manager_register | manager_login | resident_phone
                                      # Rate: authLimiter (hesap/telefon key; başarılı istek sayılmaz). strictLimiter YOK.
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout            # FCM token temizler
POST   /api/v1/auth/logout-all-devices
POST   /api/v1/auth/join              # Legacy: email+şifre + davet kodu
POST   /api/v1/auth/invite/validate   # Public: { inviteCode } → { valid, label }
POST   /api/v1/auth/otp/send          # e-posta OTP (manager_*); sakin telefon → 410 (Firebase kullanın)
POST   /api/v1/auth/otp/verify        # e-posta OTP; sakin telefon → 410
POST   /api/v1/auth/firebase-phone    # sakin: idToken + purpose (resident_login|resident_join|resident_phone_change)
POST   /api/v1/auth/otp/complete-resident-join  # phone + name + inviteCode (Firebase doğrulama sonrası)
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
```

**Sakin Firebase Phone (`POST /auth/firebase-phone`):**
- Body: `{ idToken, purpose: "resident_login"|"resident_join"|"resident_phone_change", name?, inviteCode?, deviceLabel?, platform? }`
- Mobil Firebase Auth Phone ile SMS doğrular → `idToken` alır → backend `admin.auth().verifyIdToken` → AidatPanel JWT
- Console (Identity Platform `projects/*/config` → `recaptchaConfig`): `useSmsTollFraudProtection=true`, `phoneEnforcementState=AUDIT`, `tollFraudManagedRules` (ör. `startScore=0.8`); `smsRegionConfig.allowlistOnly.allowedRegions=["TR"]`
- Play Store E2E (2026-08-05): Turkcell / Türk Telekom / Vodafone SMS OK
- `resident_login` → `{ accessToken, refreshToken, user }`
- `resident_join` (isim yok) → `{ requireName: true }` (pending `PhoneOtpToken`)
- `resident_phone_change` → `{ verified: true }` (pending; `PUT /me` telefon ile tüketir)
- `User.firebaseUid` ilk başarılı doğrulamada bağlanır

**Şifre sıfırlama (`POST /auth/forgot-password`):**
- Body: `{ email? }` **veya** `{ phone? }` (en az biri); opsiyonel `channel: "email" | "sms"`
- Kanal kuralı (SMS kotası tasarrufu):
  1. Hesapta e-posta varsa → varsayılan **e-posta** (Resend)
  2. Yalnızca telefon varsa → **SMS**
  3. E-posta gönderildikten sonra kod alamıyorsa → `channel: "sms"` opt-in (hesapta telefon şart)
- Yanıt `data`: `{ deliveredVia: "email"|"sms"|null, smsFallbackAvailable: boolean }`
- `POST /auth/reset-password`: `{ token, password }`

**Yönetici identifier-öncelikli akış (mobil):**
1. `POST /auth/check-identifier` `{ identifier, purpose: "manager_identifier" }` → `{ exists, name? }`
2. Kayıtlıysa → `POST /auth/login`; yeniyse isim+şifre → `register` + `login`
3. Telefon eşleşmesi kanonik 10 hane + legacy yazılışlar; aynı telefonda MANAGER+RESIDENT varsa şifre eşleşen hesap seçilir

**Sakin telefon-öncelikli akış (mobil):**
1. `check-identifier` (`resident_phone`) → `{ exists, name? }` → Firebase Phone Auth SMS
2. SMS kodu → Firebase `idToken` → `POST /auth/firebase-phone` (login JWT veya join `requireName`)
3. Yeni sakin: isim + davet kodu → `otp/complete-resident-join`
4. Deep link: `https://aidatpanel.com/join?code=...` / `aidatpanel://join?code=...`

### Buildings (Yönetici)
```
GET    /api/v1/buildings                    # ?standalone=true → site altı olmayan binalar
POST   /api/v1/buildings
GET    /api/v1/buildings/:id
PUT    /api/v1/buildings/:id
DELETE /api/v1/buildings/:id
PATCH  /api/v1/buildings/:id/collection     # collectionIban?, collectionAccountTitle?, collectionIbanLabel?, paymentReferenceTemplate?
GET    /api/v1/buildings/collection-presets # bina + site IBAN önerileri (+ label, buildingCount, siteCount)
GET    /api/v1/buildings/:id/dashboard-summary
POST   /api/v1/buildings/dashboard-summary/batch
GET    /api/v1/buildings/:id/dekonts
POST   /api/v1/buildings/:id/announcements  # body: { body } — başlık sistemde "Duyuru"
```

### Sites (Yönetici — FAZ 8)
```
GET    /api/v1/sites
POST   /api/v1/sites
GET    /api/v1/sites/:id
PUT    /api/v1/sites/:id
DELETE /api/v1/sites/:id                    # alt binalar cascade
PATCH  /api/v1/sites/:id/collection         # collectionIban?, collectionAccountTitle?, collectionIbanLabel?, paymentReferenceTemplate?
GET    /api/v1/sites/:id/buildings
POST   /api/v1/sites/:id/buildings          # blockLabel zorunlu; name opsiyonel
GET    /api/v1/sites/:id/expenses
POST   /api/v1/sites/:id/expenses
PUT    /api/v1/sites/:id/expenses/:expenseId
DELETE /api/v1/sites/:id/expenses/:expenseId
GET    /api/v1/sites/:id/reports            # PDF type=monthly|annual
```

**Kota:** `GET /me/subscription` → `usage.buildings` / `limits.buildings` (toplam bina; site başlığı sayılmaz).

### Apartments (Yönetici)
```
GET    /api/v1/buildings/:buildingId/apartments
POST   /api/v1/buildings/:buildingId/apartments
PUT    /api/v1/buildings/:buildingId/apartments/:id
DELETE /api/v1/buildings/:buildingId/apartments/:id
DELETE /api/v1/buildings/:buildingId/apartments/:id/resident
POST   /api/v1/apartments/:apartmentId/invite-code
```

**Davet kodu formatı:** `AP` + 1 hex + `-` + 3 hex + `-` + 4 hex (örn. `APB-794-11FF`). Backend `crypto.randomBytes(4).toString("hex")` üretir; sabit önekteki `P` hex değildir. Mobil `InviteCodeInputRow` girişte `0-9A-FP` kabul eder (`G–Z` reddedilir). Deep link `aidatpanel://join?code=` / `https://aidatpanel.com/join?code=` kodu doğrudan state’e yazar.

### Dues (Aidat)
```
GET    /api/v1/buildings/:id/dues
GET    /api/v1/buildings/:id/dues/transactions
POST   /api/v1/buildings/:id/dues/bulk
POST   /api/v1/buildings/:id/dues/remind
PATCH  /api/v1/buildings/:id/dues/:dueId/status
PATCH  /api/v1/buildings/:id/due-amount
GET    /api/v1/me/dues
```

Computed: `paidAmount` (DuePayment toplamı), `remainingAmount`. Kısmi ödemede `PENDING`/`OVERDUE` kalır; tolerans içinde `PAID`. Manuel `PAID` → `DuePayment` (dekontId=null).

### Expenses (Gider)
```
GET    /api/v1/buildings/:id/expenses
POST   /api/v1/buildings/:id/expenses
GET    /api/v1/buildings/:id/expenses/summary
GET    /api/v1/buildings/:id/reports        # PDF type=monthly|annual
PUT    /api/v1/expenses/:id
DELETE /api/v1/expenses/:id
POST   /api/v1/expenses/:id/proof           # makbuz upload (multipart)
GET    /api/v1/expenses/:id/file
GET    /api/v1/expenses/:id/file/:filename
GET    /api/v1/me/expenses
```

Gider → aidat: `targetMonth/Year`, `perUnitAmount`, `DueExpenseCarryforward` (site gideri için `siteExpenseId`).

### Tickets
```
GET    /api/v1/buildings/:id/tickets
GET    /api/v1/tickets/:id
POST   /api/v1/apartments/:apartmentId/tickets
POST   /api/v1/tickets/:id/attachment       # JPG/PNG, max 5MB — sakin, OPEN
POST   /api/v1/tickets/:id/updates
PATCH  /api/v1/tickets/:id/status
GET    /api/v1/me/tickets
```

**TicketStatus geçişleri** (yalnızca MANAGER):

| Mevcut | İzin verilen | UI |
|--------|--------------|-----|
| `OPEN` | `IN_PROGRESS`, `CLOSED` | Açık → Onaylandı / Reddedildi |
| `IN_PROGRESS` | `RESOLVED`, `OPEN` | Onaylandı → Yapıldı / Geri Al |
| `RESOLVED` | `IN_PROGRESS` | Yapıldı → Geri Al |
| `CLOSED` | `OPEN` | Reddedildi → Geri Al |

### Dekont
```
POST   /api/v1/dekonts/upload
GET    /api/v1/dekonts/:id
GET    /api/v1/dekonts/:id/file
PATCH  /api/v1/dekonts/:id/review
GET    /api/v1/me/dekonts
GET    /api/v1/me/payment-collection
```

- `GET /dekonts/:id` → `buildingName` (site altı: `Site · Blok`)
- Upload: `file` + `dueId` ve/veya `dueIds` → `DekontDueAllocation`
- Onay (`APPROVE`): OCR tutarı FIFO → her dilim `DuePayment`; hepsi kapanırsa `PAYMENT_APPLIED`, aksi `PAYMENT_PARTIAL`
- Review body: `{ decision, note?, dueId?, dueIds?, amount? }`
- Pipeline: storage → OCR → verification (IBAN) → business rules → payment → FCM; eşleşmede boş `collectionIbanLabel` otomatik doldurulabilir

### Notifications
```
GET    /api/v1/notifications
GET    /api/v1/notifications/unread-count
PATCH  /api/v1/notifications/:id/read
PATCH  /api/v1/notifications/read-all
```

### Profile (`/api/v1/me`)
```
GET    /api/v1/me
PUT    /api/v1/me                 # name, email?, phone?, language; yönetici email/phone → currentPassword; sakin phone → otpCode
PUT    /api/v1/me/password
PUT    /api/v1/me/language
DELETE /api/v1/me                 # KVKK hesap kapatma (deletedAt)
PUT    /api/v1/me/fcm-token
GET    /api/v1/me/sessions
DELETE /api/v1/me/sessions/:sessionId
POST   /api/v1/me/profile-picture          # multipart
DELETE /api/v1/me/profile-picture
GET    /api/v1/me/profile-picture-file
GET    /api/v1/me/subscription             # MANAGER — usage.buildings + limits
GET    /api/v1/me/payment-collection       # RESIDENT
GET    /api/v1/me/dues | /expenses | /tickets | /dekonts
```

### Subscription
```
GET    /api/v1/me/subscription
POST   /api/v1/subscription/webhook/revenuecat   # Bearer REVENUECAT_WEBHOOK_SECRET
```

### Admin (`/api/v1/admin` — ayrı `AdminUser` JWT)
```
POST   /api/v1/admin/auth/login
POST   /api/v1/admin/auth/refresh
POST   /api/v1/admin/auth/logout
GET    /api/v1/admin/auth/me

GET    /api/v1/admin/dashboard/kpis|alerts|insights|segments
GET    /api/v1/admin/hierarchy/managers
GET    /api/v1/admin/hierarchy/managers/:id
GET    /api/v1/admin/hierarchy/buildings/:id
GET    /api/v1/admin/hierarchy/apartments/:id

GET    /api/v1/admin/users
GET    /api/v1/admin/users/:id
POST   /api/v1/admin/users/:id/reset-password
POST   /api/v1/admin/users/:id/close-account      # SUPER_ADMIN

GET    /api/v1/admin/subscriptions
POST   /api/v1/admin/subscriptions/grant
POST   /api/v1/admin/subscriptions/:userId/grant
GET    /api/v1/admin/promos
POST   /api/v1/admin/promos

GET    /api/v1/admin/dekonts/summary
GET    /api/v1/admin/dekonts
GET    /api/v1/admin/residents
GET    /api/v1/admin/residents/:id/payment-habits
GET    /api/v1/admin/analytics/active-users

GET    /api/v1/admin/notifications
PATCH  /api/v1/admin/notifications/:id/read
POST   /api/v1/admin/notifications/broadcast
POST   /api/v1/admin/notifications/preview
GET    /api/v1/admin/audit-logs

POST   /api/v1/admin/backups/create               # SUPER_ADMIN
GET    /api/v1/admin/backups
POST   /api/v1/admin/backups/:id/download-token
GET    /api/v1/admin/backups/:id/download
```

---

## 📱 Flutter Uygulaması

### Sürüm / paketler (`pubspec.yaml` — 0.6.10+2000000013)

```yaml
environment:
  sdk: ^3.11.5

dependencies:
  flutter_riverpod: ^3.3.1          # Notifier / NotifierProvider (CodeGen yok)
  go_router: ^17.3.0
  dio: ^5.4.0
  flutter_secure_storage: ^10.3.1
  web_socket_channel: ^3.0.2
  slang: ^4.15.0
  slang_flutter: ^4.15.0
  firebase_core: ^4.10.0
  firebase_auth: ^6.5.6
  recaptcha_enterprise_flutter: 18.9.1  # Phone Auth SMS defense (Identity Platform)
  firebase_messaging: ^16.3.0
  firebase_analytics: ^12.0.0
  firebase_crashlytics: ^5.0.0
  flutter_local_notifications: ^22.0.1
  permission_handler: ^12.0.3
  purchases_flutter: ^10.2.3
  google_fonts: ^8.1.0
  fl_chart: ^1.2.0
  pdfx: ^2.9.2
  # + equatable, image_picker, file_picker, share_plus, app_links, gal, …
```

### Klasör yapısı

```
mobile/lib/
├── main.dart / main_dev.dart       # flavor: prod / dev
├── core/                           # constants, theme, router, network, storage, notifications
├── l10n/                           # strings_tr / strings_en (Slang)
├── features/
│   ├── auth/
│   ├── dashboard/                  # ManagerPropertiesTab: Siteler | Binalar
│   ├── sites/                      # FAZ 8
│   ├── buildings/
│   ├── apartments/
│   ├── dues/
│   ├── expenses/
│   ├── tickets/
│   ├── notifications/
│   ├── profile/
│   ├── reports/
│   ├── dekont/
│   └── subscription/
└── shared/widgets/
```

**Katman:** `domain` (entity/repo interface) → `data` (model/datasource/repo impl) → `presentation` (Riverpod Notifier). Datasource → `response.data['data']`.

**GoRouter (özet):** `/login`, `/sign-up`, `/manager-dashboard`, `/resident-dashboard`; site/bina CRUD; dekont; `/notifications`; ticket create/detail. Deep link: `aidatpanel://join?code=`.

**Flavors:** `flutter run -t lib/main_dev.dart --flavor dev` · prod: `-t lib/main.dart --flavor prod --dart-define=REVENUECAT_ANDROID_KEY=...`

---

## 👥 Kullanıcı Rolleri ve Yetkiler

### MANAGER
- Site + bina (blok) CRUD; kota: toplam bina
- Daire / davet kodu; aidat bulk + durum; gider + site ortak gideri
- Collection IBAN (+ takma ad); dekont inceleme / onay
- PDF rapor (bina + site); duyuru; ticket yönetimi
- Abonelik yoksa / kota dolunca: yeni bina ekleme vb. kilitlenir (mevcut veriler okunur)

### RESIDENT
- Kendi aidat / ledger breakdown; gider listesi (okuma)
- Dekont yükleme; payment-collection (IBAN + açıklama)
- Ticket oluşturma + ek; bildirimler; dil; profil (telefon OTP ile değişir)

---

## 🔑 Sakin Onboarding Akışı

```
1. Yönetici → daire → davet kodu (tek kullanımlık, süreli)
2. Paylaşım: https://aidatpanel.com/join?code=... (deep link ile app açılır)
3. Sakin → telefon → OTP (resident_join | resident_login)
4. Yeni sakin → isim + davet kodu (linkten geldiyse kod sorulmaz)
5. complete-resident-join → JWT → sakin dashboard
```

---

## 🔔 Bildirim Sistemi

Uygulama **açıkken** WebSocket; **kapalıyken** FCM; **yedek** HTTP poll.

```text
Olay → notificationService (DB)
     → notificationDeliveryService
           ├─ realtimeHub → WebSocket
           └─ FCM (pushService.js)

Mobil → NotificationDeliveryCoordinator
           ├─ WebSocketNotificationRealtimeSource
           ├─ FcmNotificationRealtimeSource
           └─ PollingNotificationRealtimeSource
```

| Backend | Rol |
|---------|-----|
| `src/realtime/realtimeHub.js` + `wsGateway.js` | Hub + JWT WS |
| `src/services/notificationDeliveryService.js` | Hub + FCM |
| `GET /notifications/unread-count` | Rozet |

**Env:** `REALTIME_WS_ENABLED=true`, Firebase credential  
**WS:** `wss://api.aidatpanel.com/api/v1/realtime?token=ACCESS_JWT`  
Nginx: `Upgrade` / `Connection "upgrade"`. Deploy: `backend/scripts/deploy.sh` / `deploy.ps1` · PM2: `aidapanel-api`.

---

## 💳 Abonelik Sistemi (RevenueCat)

| Plan | Product ID | Fiyat (önerilen) |
|------|------------|------------------|
| Aylık | `aidatpanel_monthly` | ₺99/ay |
| Yıllık | `aidatpanel_annual` | ₺799/yıl |

Webhook: `POST /api/v1/subscription/webhook/revenuecat` — `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, `EXPIRATION`, `BILLING_ISSUE`.  
Mobil: `purchases_flutter` + `--dart-define=REVENUECAT_ANDROID_KEY=...`.  
Yönetici kota: `GET /me/subscription` → `usage.buildings` / `limits.buildings`.

---

## 🌐 Web (Landing Page)

Statik HTML/CSS/JS — uygulama indirme, SSS, KVKK. Domain: `aidatpanel.com`. Admin UI ayrı origin olabilir (`admin.aidatpanel.com` → `/api/v1/admin`).

---

## 🚀 Deployment

| Öğe | Değer |
|-----|-------|
| API | `api.aidatpanel.com` → port 4200 |
| Sunucu yolu | `/home/aidatpanel-api/htdocs/api.aidatpanel.com` |
| PM2 | `aidapanel-api` |
| Script | `backend/scripts/deploy.sh` / `deploy.ps1` |
| Config | `deploy.config.example.json` → `deploy.local.json` (gitignore) |

```bash
# Yerel deploy (zorunlu kural: backend değişince)
bash backend/scripts/deploy.sh
# Sunucuda: npm ci --omit=dev && npx prisma migrate deploy && pm2 restart aidapanel-api
```

`.env`, `uploads/dekonts/`, Firebase JSON **üzerine yazılmaz**.

| Subdomain | Hedef |
|-----------|-------|
| `aidatpanel.com` | Landing |
| `api.aidatpanel.com` | API + WS |

---

## 🗺️ Roadmap

**Tek kaynak:** `resources/yol-haritası/FAZ_DURUMU.md`

| Faz | Konu | Durum |
|-----|------|-------|
| 0–6 | Foundation → Subscription | ✅ Onaylı |
| 7 | v1.0.0 lansman | ▶ Aktif |
| 8 | Site yönetimi | ▶ Aktif (E2E + Furkan onayı bekliyor) |
| 9+ | Online ödeme, multi-manager, trend grafikleri | Planlı |

---

## ⚙️ Teknik Kararlar

| Karar | Seçim | Gerekçe |
|-------|-------|---------|
| State | Riverpod 3 Notifier | CodeGen yok; referans: auth/dues |
| Navigation | GoRouter | Deep link |
| ORM | Prisma | Migration + type-safe |
| i18n | Slang (TR/EN JSON) | Type-safe; UI'da hardcoded string yasak |
| Abonelik | RevenueCat | iOS+Android |
| Push | FCM + WS | Tray + anlık |
| Sakin telefon OTP | Firebase Auth Phone | SMS + idToken; Identity Platform SMS toll fraud (`AUDIT`) + TR region; Error 39 → `firebase_phone_carrier_blocked` |
| SMS (şifre sıfırlama) | Twilio / NetGsm | Yönetici şifre reset |

---

## 🎨 Tasarım Sistemi

### Hedef Kitle ve Tasarım Felsefesi

AidatPanel kullanıcılarının önemli bir kısmı **50+ yaş** grubundadır (apartman yöneticileri çoğunlukla emekli veya orta-üst yaş erkekler, sakinlerin büyük kısmı da bu yaş grubundadır). Tasarımın her kararı bu gerçeği gözetmelidir.

**Temel ilke:** Sade, güvenilir, net. Şova gerek yok — işlevsellik ön planda.

---

### Renk Paleti

Kaynak: logo lacivert (`#082860`) + turuncu (`#F86000`) — logo biraz daha önde;
slate nötrler harmanlanır. Token’lar:
`mobile/lib/core/theme/app_color_palette.dart` → `AppColors`.

**Kural:** `ink` / gövde metni asla dolgu değildir. CTA dolgusu = `action`.

```dart
// Sabit marka
brandNavy     = Color(0xFF082860); // Logo lacivert
brandNavyLift = Color(0xFF0B2F6B); // UI lacivert
brandOrange   = Color(0xFFF86000); // Logo turuncu

// Semantik — açık
brand / primary = brandNavyLift;     // ikon, link, outline
ink / textPrimary = Color(0xFF0F172A);
action          = brandNavyLift;     // CTA / FAB
onAction        = Color(0xFFFFFFFF);
accent          = brandOrange;

// Semantik — koyu
brand / primary = Color(0xFF8BA3C7); // lacivert tint (marka hissi)
ink / textPrimary = Color(0xFFE8EEF8);
action          = brandOrange;       // CTA / FAB
onAction        = Color(0xFFFFFFFF);
accent          = brandOrange;

// Semantik durum (tema bağımsız)
success = Color(0xFF16A34A);
error   = Color(0xFFDC2626);
warning = Color(0xFFF59E0B); // amber; accent’ten ayrı
info    = Color(0xFF2563EB);

// Nötrler — açık
background = #F8FAFC · surface = #FFFFFF · fill = #EEF2F7
dashboardBackground = #F3F5F9 · border = #E2E8F0

// Nötrler — koyu (lacivert-siyah)
dashboardBackground #0A101C · surface #121A2A · fill #1A2438 · border #2A3548
```

---

### Tipografi

```dart
// core/theme/app_typography.dart
// Kullanılan font: "Nunito" (Google Fonts)
// Seçim gerekçesi: Yuvarlak hatları sayesinde sıcak ve okunabilir,
// yaşlı kullanıcılar için Inter/Roboto'dan daha az yorucu.

class AppTypography {
  static const fontFamily = 'Nunito';

  // Başlıklar
  static const h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.3);
  static const h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3);
  static const h3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);

  // Gövde metni — MİNİMUM 16sp, asla altına inme
  static const body1 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6);
  static const body2 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.6);

  // Etiket ve küçük metinler — 14sp alt sınır
  static const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);
  static const caption = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4);

  // Buton metni
  static const button = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.2);
}
```

**Kritik kural:** `textScaleFactor` hiçbir yerde kısıtlanmamalı. Kullanıcı sistem fontunu büyüttüyse uygulama buna saygı göstermeli.

---

### Dokunma Alanları ve Boyutlar

```dart
// Minimum dokunma alanı: 48x48dp (Google Material standardı)
// Yaşlı kullanıcılar için ideal: 56x56dp+

class AppSizes {
  // Buton yükseklikleri
  static const buttonHeightPrimary   = 56.0; // Ana aksiyon butonu
  static const buttonHeightSecondary = 48.0; // İkincil buton

  // İkon + dokunma alanı
  static const iconTouchTarget = 48.0; // İkon etrafında minimum alan
  static const iconSize        = 24.0; // İkon boyutu

  // Boşluklar
  static const spacingXS  = 4.0;
  static const spacingS   = 8.0;
  static const spacingM   = 16.0;
  static const spacingL   = 24.0;
  static const spacingXL  = 32.0;
  static const spacingXXL = 48.0;

  // Kart ve köşe
  static const cardRadius   = 12.0;
  static const buttonRadius = 10.0;
  static const inputRadius  = 10.0;

  // Liste öğesi yüksekliği (kolay tıklanabilir)
  static const listItemHeight = 72.0;
}
```

---

### Buton Stilleri

```dart
// Birincil buton — tam genişlik, belirgin
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: AppTypography.button,
    elevation: 0,
  ),
)

// Aksiyon butonu (Ödendi işaretle, Davet kodu üret vb.)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 56),
    ...
  ),
)
```

---

### Navigasyon

**Her zaman BottomNavigationBar kullan — hamburger menü yasak.**

```dart
// Yönetici tab'ları
// 1. Ana Sayfa (Apartments overview)
// 2. Aidat
// 3. Giderler
// 4. Bildirimler
// 5. Profil

// Sakin tab'ları
// 1. Aidatlarım
// 2. Taleplerim
// 3. Bildirimler
// 4. Profil

// Her tab: ikon + yazı birlikte gösterilmeli, sadece ikon yok
BottomNavigationBarItem(
  icon: Icon(Icons.home_outlined),
  activeIcon: Icon(Icons.home),
  label: 'Ana Sayfa', // Yazı her zaman görünür
)
```

---

### Dil Kuralları (UI Metinleri)

```
✅ DOĞRU                         ❌ YANLIŞ
"Aidat Ekle"                     "Add Due"
"Ödendi İşaretle"                "Mark as Paid"
"Geri Dön"                       "Navigate Back"
"Telefon numarası hatalı"        "Error 422: Validation failed"
"Bu işlemi geri alamazsınız"     "This action is irreversible"
"Emin misiniz?"                  "Confirm action?"
"Yükleniyor..."                  "Loading..."  ← bu kabul edilebilir
```

**Kural:** Dashboard, sync, toggle, payload, cache gibi teknik terimler UI'da asla görünmemeli.

---

### Geri Dönülemez İşlemler — Onay Dialog'u

Her silme, ödendi işaretleme ve toplu işlem için zorunlu:

```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Emin misiniz?', style: AppTypography.h3),
    content: const Text(
      'Bu daireyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
      style: AppTypography.body1,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('İptal', style: TextStyle(fontSize: 16)),
      ),
      ElevatedButton(
        onPressed: () { /* işlemi yap */ },
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
        child: const Text('Sil', style: TextStyle(fontSize: 16)),
      ),
    ],
  ),
);
```

---

### Durum Göstergeleri (Aidat Durumu)

```dart
// Aidat durumu badge'leri — renk + yazı birlikte, sadece renk yok
Widget _buildStatusBadge(DueStatus status) {
  final config = {
    DueStatus.paid:    ('Ödendi',    AppColors.success,   AppColors.successBg),
    DueStatus.pending: ('Bekliyor',  AppColors.warning,   AppColors.warningBg),
    DueStatus.overdue: ('Gecikmiş',  AppColors.error,     AppColors.errorBg),
    DueStatus.waived:  ('Muaf',      AppColors.textSecondary, AppColors.border),
  }[status]!;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: config.$3,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(config.$1,
      style: AppTypography.label.copyWith(color: config.$2)),
  );
}
```

---

### Animasyon Kuralları

```dart
// Geçiş süresi: hızlı ve sade
const Duration kAnimDuration = Duration(milliseconds: 200);
const Curve kAnimCurve = Curves.easeInOut;

// PageTransition: slide — sola/sağa, yukarı/aşağı yok
// Loading state: CircularProgressIndicator (primary renkte)
// Skeleton loading: shimmer paketi ile (kart placeholder)

// YASAK:
// - Lottie animasyonları (gereksiz karmaşıklık)
// - Hero animasyonları (göz yanıltıcı)
// - Bounce/elastic eğriler
// - 300ms+ süren geçişler

// İZİN / NOT:
// - Statik CustomPaint illüstrasyonlarda ui.Gradient (linear/radial) serbest.
// - İlk kurulum: splash sonrası `/welcome` (5 sayfalık PageView); tamamlanınca
//   SecureStorage `onboarding_completed` = true → `/login` (rol seçimi).
//   Gradyan sabitleri: `core/theme/illustration_gradients.dart`.
```

---

### Erişilebilirlik Kontrol Listesi

Her ekran tamamlanmadan önce şunlar kontrol edilmeli:

- [ ] Tüm metinler minimum 16sp
- [ ] Kontrast oranı 4.5:1+ (WCAG AA) — koyu arka plan üzerine açık metin veya tersi
- [ ] Tüm butonlar minimum 48dp yükseklik
- [ ] Her buton/ikonun `Semantics` label'ı var
- [ ] `textScaleFactor` hiçbir yerde kısıtlanmıyor
- [ ] Hata mesajları Türkçe ve anlaşılır
- [ ] Geri dönülemez işlemler onay dialog'u içeriyor
- [ ] Her tab'da ikon + yazı birlikte görünüyor

---

## 📝 Geliştirici Notları

- OkulOptik ile **aynı PostgreSQL instance** kullanılabilir ama **ayrı veritabanı** (`aidatpanel` adıyla) oluşturulmalı
- Port çakışması olmaması için OkulOptik portunu kontrol et, 4200 müsait değilse 4201 kullan
- Tüm API route'ları `/api/v1/` prefix'i ile başlamalı (ileride versiyonlama için)
- KVKK uyumu için kullanıcı verisi silme endpoint'i (`DELETE /api/me`) faz 1'de yazılmalı
- Apple App Store'da "Kids Category" seçilmemeli, subscription için "Finance" kategorisi uygundur
