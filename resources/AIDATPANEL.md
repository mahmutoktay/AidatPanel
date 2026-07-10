# AidatPanel — Claude Code Master Reference

## 📌 Proje Özeti

**AidatPanel**, Türk apartman ve site yöneticileri için geliştirilmiş bir mobil aidat yönetim platformudur. Yöneticiler birden fazla apartmanı tek hesaptan yönetebilir. Sakinler kendi aidat durumlarını görüntüleyebilir ve arıza/talep bildirimi yapabilir.

- **Domain:** aidatpanel.com (Cloudflare üzerinde)
- **Platform:** iOS + Android (Flutter)
- **Backend:** Node.js, aynı Contabo VPS (OkulOptik ile ortak sunucu)
- **Veritabanı:** PostgreSQL
- **Web:** Sadece tanıtım/landing sayfası (mobil uygulama indirme yönlendirmeli)
- **Dil:** Türkçe + İngilizce (i18n hazır)

---

## 📁 Klasör Yapısı

```
aidatpanel/
├── web/                  # Landing page (statik HTML/CSS/JS)
│   ├── index.html
│   ├── assets/
│   └── ...
├── mobile/               # Flutter uygulaması
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── pubspec.yaml
│   └── ...
└── backend/              # Node.js API
    ├── src/
    │   ├── routes/
    │   ├── controllers/
    │   ├── models/
    │   ├── middleware/
    │   ├── services/
    │   └── utils/
    ├── prisma/
    │   └── schema.prisma
    ├── .env.example
    ├── package.json
    └── index.js
```

---

## 🖥️ Backend

### Stack
- **Runtime:** Node.js 20+
- **Framework:** Express.js
- **ORM:** Prisma
- **Veritabanı:** PostgreSQL
- **Auth:** JWT (access token 15dk, refresh token 30 gün)
- **Email:** Resend (noreply@aidatpanel.com)
- **Push Notification:** Firebase Admin SDK (FCM)
- **SMS/WhatsApp:** Twilio (veya Netgsm Türkiye alternatifi)
- **Abonelik Doğrulama:** RevenueCat REST API (App Store + Google Play receipt validation)
- **Deployment:** PM2, aynı Contabo VPS
- **Subdomain:** api.aidatpanel.com (CloudPanel üzerinde reverse proxy)

### Ortam Değişkenleri (.env)

```env
PORT=4200
DATABASE_URL=postgresql://aidatpanel:PASSWORD@localhost:5432/aidatpanel
JWT_SECRET=...
JWT_REFRESH_SECRET=...
RESEND_API_KEY=...
FIREBASE_SERVICE_ACCOUNT_JSON=...
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_WHATSAPP_FROM=whatsapp:+14155238886
TWILIO_SMS_FROM=+1...
REVENUECAT_API_KEY=...
REVENUECAT_WEBHOOK_SECRET=...
```

---

## 🗄️ Veritabanı Şeması (Prisma)

```prisma
model User {
  id            String        @id @default(uuid())
  email         String        @unique
  passwordHash  String
  name          String
  phone         String?
  role          UserRole      @default(RESIDENT)
  fcmToken      String?
  language      String        @default("tr")
  createdAt     DateTime      @default(now())
  updatedAt     DateTime      @updatedAt

  // Yönetici ilişkileri
  managedBuildings  Building[]     @relation("BuildingManager")

  // Sakin ilişkileri
  apartment     Apartment?    @relation(fields: [apartmentId], references: [id])
  apartmentId   String?

  // Ortak
  notifications Notification[]
  tickets       Ticket[]
  subscription  Subscription?
}

enum UserRole {
  MANAGER
  RESIDENT
}

model Subscription {
  id                  String    @id @default(uuid())
  userId              String    @unique
  user                User      @relation(fields: [userId], references: [id])
  status              SubscriptionStatus
  plan                String    // "monthly" | "annual"
  platform            String    // "ios" | "android"
  revenuecatId        String?
  currentPeriodStart  DateTime
  currentPeriodEnd    DateTime
  createdAt           DateTime  @default(now())
  updatedAt           DateTime  @updatedAt
}

enum SubscriptionStatus {
  ACTIVE
  EXPIRED
  CANCELLED
  TRIAL
}

model Site {
  id                        String        @id @default(uuid())
  name                      String
  address                   String
  city                      String
  managerId                 String
  manager                   User          @relation("SiteManager", fields: [managerId], references: [id])
  dueAmount                 Decimal?      @db.Decimal(12, 2)
  dueDay                    Int?
  currency                  String        @default("TRY")
  collectionIban            String?
  collectionAccountTitle    String?
  paymentReferenceTemplate  String?
  buildings                 Building[]
  expenses                  SiteExpense[]
  createdAt                 DateTime      @default(now())
  updatedAt                 DateTime      @updatedAt
}

model SiteExpense {
  id          String   @id @default(uuid())
  siteId      String
  site        Site     @relation(fields: [siteId], references: [id], onDelete: Cascade)
  title       String
  amount      Decimal  @db.Decimal(12, 2)
  expenseDate DateTime
  category    String?
  note        String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}

model Building {
  id          String      @id @default(uuid())
  name        String
  address     String
  city        String
  managerId   String
  manager     User        @relation("BuildingManager", fields: [managerId], references: [id])
  siteId      String?
  site        Site?       @relation(fields: [siteId], references: [id], onDelete: Cascade)
  blockLabel  String?
  addressExtra String?
  apartments  Apartment[]
  expenses    Expense[]
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
}

model Apartment {
  id           String    @id @default(uuid())
  number       String    // "B-12", "3A" vb.
  floor        Int?
  buildingId   String
  building     Building  @relation(fields: [buildingId], references: [id])
  residents    User[]
  dues         Due[]
  inviteCodes  InviteCode[]
  tickets      Ticket[]
  createdAt    DateTime  @default(now())
}

model InviteCode {
  id          String    @id @default(uuid())
  code        String    @unique  // Örn: "AP3-B12-X7K9"
  apartmentId String
  apartment   Apartment @relation(fields: [apartmentId], references: [id])
  usedAt      DateTime?
  usedBy      String?
  expiresAt   DateTime
  createdAt   DateTime  @default(now())
}

model Due {
  id          String    @id @default(uuid())
  apartmentId String
  apartment   Apartment @relation(fields: [apartmentId], references: [id])
  amount      Decimal   @db.Decimal(10, 2)
  currency    String    @default("TRY")
  month       Int       // 1-12
  year        Int
  status      DueStatus @default(PENDING)
  paidAt      DateTime?
  note        String?
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
}

enum DueStatus {
  PENDING
  PAID
  OVERDUE
  WAIVED
}

model Expense {
  id          String    @id @default(uuid())
  buildingId  String
  building    Building  @relation(fields: [buildingId], references: [id])
  title       String
  amount      Decimal   @db.Decimal(10, 2)
  category    ExpenseCategory
  date        DateTime
  note        String?
  receiptUrl  String?
  createdAt   DateTime  @default(now())
}

enum ExpenseCategory {
  CLEANING
  ELEVATOR
  ELECTRICITY
  WATER
  INSURANCE
  REPAIR
  GARDEN
  OTHER
}

model Ticket {
  id          String      @id @default(uuid())
  apartmentId String
  apartment   Apartment   @relation(fields: [apartmentId], references: [id])
  userId      String
  user        User        @relation(fields: [userId], references: [id])
  title       String
  description String
  category    TicketCategory
  status      TicketStatus @default(OPEN)
  updates     TicketUpdate[]
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
}

enum TicketCategory {
  COMPLAINT
  REQUEST
  MALFUNCTION
  OTHER
}

enum TicketStatus {
  OPEN
  IN_PROGRESS
  RESOLVED
  CLOSED
}

model TicketUpdate {
  id        String  @id @default(uuid())
  ticketId  String
  ticket    Ticket  @relation(fields: [ticketId], references: [id])
  message   String
  fromRole  UserRole
  createdAt DateTime @default(now())
}

model Notification {
  id        String    @id @default(uuid())
  userId    String
  user      User      @relation(fields: [userId], references: [id])
  title     String
  body      String
  type      NotificationType
  isRead    Boolean   @default(false)
  data      Json?
  createdAt DateTime  @default(now())
}

enum NotificationType {
  DUE_REMINDER
  DUE_PAID
  TICKET_UPDATE
  ANNOUNCEMENT
  SYSTEM
}
```

---

## 🔌 API Endpoint'leri

### Auth (`/api/v1/auth`)
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login             # body: identifier (email veya telefon) + password
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout            # FCM token temizler
POST   /api/v1/auth/logout-all-devices
POST   /api/v1/auth/join
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
```

### Buildings (Yönetici)
```
GET    /api/v1/buildings                    # ?standalone=true → site altı olmayan binalar
POST   /api/v1/buildings
GET    /api/v1/buildings/:id
PUT    /api/v1/buildings/:id
DELETE /api/v1/buildings/:id
PATCH  /api/v1/buildings/:id/collection    # Tahsilat IBAN
GET    /api/v1/buildings/collection-presets  # Bina + site IBAN önerileri
GET    /api/v1/buildings/:id/dekonts
POST   /api/v1/buildings/:id/announcements   # body: { body } — başlık sistemde "Duyuru" olarak üretilir
```

### Sites (Yönetici — FAZ 8)
```
GET    /api/v1/sites
POST   /api/v1/sites
GET    /api/v1/sites/:id
PUT    /api/v1/sites/:id
DELETE /api/v1/sites/:id                     # Alt binalar cascade silinir
PATCH  /api/v1/sites/:id/collection
GET    /api/v1/sites/:id/buildings
POST   /api/v1/sites/:id/buildings         # blockLabel zorunlu; name opsiyonel
GET    /api/v1/sites/:id/expenses
POST   /api/v1/sites/:id/expenses
PUT    /api/v1/sites/:id/expenses/:expenseId
DELETE /api/v1/sites/:id/expenses/:expenseId
GET    /api/v1/sites/:id/reports           # PDF (type=monthly|annual)
```

**Kota:** Abonelik `usage.buildings` / `limits.buildings` — toplam bina sayısı (site içi bloklar dahil; site başlığı kotaya dahil değil).

### Apartments (Yönetici)
```
GET    /api/v1/buildings/:buildingId/apartments
POST   /api/v1/buildings/:buildingId/apartments
PUT    /api/v1/buildings/:buildingId/apartments/:id
DELETE /api/v1/buildings/:buildingId/apartments/:id
DELETE /api/v1/buildings/:buildingId/apartments/:id/resident
POST   /api/v1/apartments/:apartmentId/invite-code
```

### Dues (Aidat)
```
GET    /api/v1/buildings/:id/dues
POST   /api/v1/buildings/:id/dues/bulk      # Eksik aidatları oluştur
POST   /api/v1/buildings/:id/dues/remind
PATCH  /api/v1/buildings/:id/dues/:dueId/status
PATCH  /api/v1/buildings/:id/due-amount
GET    /api/v1/me/dues                      # Sakin
```

### Expenses (Gider)
```
GET    /api/v1/buildings/:id/expenses
POST   /api/v1/buildings/:id/expenses
GET    /api/v1/buildings/:id/expenses/summary
GET    /api/v1/buildings/:id/reports          # PDF (type=monthly|annual)
PUT    /api/v1/expenses/:id
DELETE /api/v1/expenses/:id
POST   /api/v1/expenses/:id/proof           # Makbuz upload (multipart)
GET    /api/v1/expenses/:id/file
GET    /api/v1/me/expenses                  # Sakin (okuma)
```

### Tickets
```
GET    /api/v1/buildings/:id/tickets
GET    /api/v1/tickets/:id
POST   /api/v1/apartments/:apartmentId/tickets
POST   /api/v1/tickets/:id/updates
PATCH  /api/v1/tickets/:id/status
GET    /api/v1/me/tickets
```

**TicketStatus geçişleri** (`PATCH .../status`, yalnızca MANAGER):

| Mevcut | İzin verilen sonraki | UI anlamı |
|--------|----------------------|-----------|
| `OPEN` | `IN_PROGRESS`, `CLOSED` | Açık → Onaylandı / Reddedildi |
| `IN_PROGRESS` | `RESOLVED`, `OPEN` | Onaylandı → Yapıldı / Geri Al |
| `RESOLVED` | `IN_PROGRESS` | Yapıldı → Geri Al |
| `CLOSED` | `OPEN` | Reddedildi → Geri Al |

Enum değerleri değişmez; mobil etiketler: Açık / Onaylandı / Yapıldı / Reddedildi.

### Dekont
```
POST   /api/v1/dekonts/upload
GET    /api/v1/dekonts/:id
GET    /api/v1/dekonts/:id/file
PATCH  /api/v1/dekonts/:id/review
GET    /api/v1/me/dekonts
GET    /api/v1/me/payment-collection
```

### Notifications
```
GET    /api/v1/notifications
GET    /api/v1/notifications/unread-count
PATCH  /api/v1/notifications/:id/read
PATCH  /api/v1/notifications/read-all
PUT    /api/v1/me/fcm-token
```

### Profile (`/api/v1/me`)
```
GET    /api/v1/me
PUT    /api/v1/me               # name, email, phone, language (email/phone değişimi → currentPassword)
PUT    /api/v1/me/password
PUT    /api/v1/me/language
DELETE /api/v1/me               # KVKK hesap kapatma
```

### Realtime
```
WSS    /api/v1/realtime?token=ACCESS_JWT
```

### Ertelenen / yok
```
GET    /api/v1/me/subscription                # FAZ 6
POST   /api/v1/subscription/webhook/revenuecat # FAZ 6
```

---

## 📱 Flutter Uygulaması

### pubspec.yaml — Temel Paketler

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # Navigation
  go_router: ^13.0.0
  
  # Network
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  
  # i18n
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  
  # Firebase
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0
  
  # In-App Purchase (RevenueCat)
  purchases_flutter: ^7.0.0
  
  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  
  # Utils
  equatable: ^2.0.5
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.0

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
```

### Flutter Klasör Yapısı

```
mobile/lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # Base URL, endpoint'ler
│   │   └── app_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   ├── router/
│   │   └── app_router.dart         # GoRouter tanımları
│   ├── network/
│   │   ├── dio_client.dart         # Interceptor'lar, token refresh
│   │   └── api_exception.dart
│   ├── storage/
│   │   └── secure_storage.dart     # JWT token saklama
│   └── utils/
│       ├── date_utils.dart
│       └── currency_utils.dart
├── l10n/
│   ├── strings_tr.i18n.json        # Türkçe (Slang)
│   └── strings_en.i18n.json        # İngilizce
├── features/
│   ├── auth/                       # Referans Clean Architecture implementasyonu
│   │   ├── data/ | domain/ | presentation/
│   │   └── presentation/screens/
│   │       ├── login_screen.dart
│   │       ├── sign_up_screen.dart # Birleşik kayıt (sakin davet kodu + yönetici)
│   │       ├── splash_screen.dart
│   │       ├── forgot_password_screen.dart
│   │       └── reset_password_screen.dart
│   ├── dashboard/
│   │   └── presentation/screens/
│   │       ├── manager_dashboard_screen.dart
│   │       └── resident_dashboard_screen.dart
│   ├── buildings/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── apartments/
│   ├── dues/
│   ├── expenses/
│   ├── tickets/
│   ├── notifications/
│   ├── reports/
│   └── subscription/
│       └── presentation/
│           └── paywall_screen.dart  # RevenueCat paywall
└── shared/
    └── widgets/
        ├── password_field.dart
        ├── empty_state_widget.dart
        ├── friendly_error_screen.dart
        ├── tint_dashboard_tile.dart
        ├── toast_overlay.dart
        └── settings_tab.dart
```

**GoRouter (özet):** `/login`, `/sign-up`, `/register` ve `/join` → `SignUpScreen` (alias); `/manager-dashboard`, `/resident-dashboard`; `/notifications`; `/manager/tickets`, `/manager/expenses`; `/tickets/create`, `/tickets/:id`. Gider ve duyuru formları **bottom sheet** (`ExpenseFormSheet`, `AnnouncementFormSheet`) — ayrı tam ekran route yok.

---

## 👥 Kullanıcı Rolleri ve Yetkiler

### MANAGER (Yönetici)

**Abonelik aktifken:**
- Birden fazla apartman oluşturma ve yönetme
- Daire ekleme/düzenleme/silme
- Her daire için davet kodu üretme (tek kullanımlık, 7 gün geçerli)
- Aylık aidat oluşturma (toplu — tüm dairelere otomatik)
- Aidat ödendi/ödenmedi işaretleme
- Gider kaydı (kategorili)
- Aylık PDF rapor alma
- Arıza/talep takibi ve güncelleme
- FCM push bildirimi gönderme (tüm sakinlere duyuru)

**Abonelik dolduğunda (kilitlenen özellikler):**
- Yeni apartman/daire ekleme
- Yeni aidat oluşturma
- PDF rapor alma
- Toplu bildirim gönderme

*(Mevcut veriler okunabilir, sakinler etkilenmez)*

### RESIDENT (Sakin)

**Her zaman erişebilir (abonelikten bağımsız):**
- Kendi aylık aidat durumu (PENDING/PAID/OVERDUE)
- Aidat geçmişi (tüm aylar)
- Arıza/talep oluşturma ve takip etme
- Bildirimlerini görme
- Uygulama dilini değiştirme

---

## 🔑 Sakin Onboarding Akışı

```
1. Yönetici → Daire detayından "Davet Kodu Üret" butonuna basar
2. Backend → Benzersiz 12 karakterlik kod üretir (Örn: "APB3-K7X9-M2")
   - Koda daire ID'si bağlıdır
   - 7 gün geçerlilik süresi
   - Tek kullanımlık (kullanıldıktan sonra geçersiz)
3. Yönetici kodu sakine iletir (WhatsApp/kağıt/sözlü)
4. Sakin uygulamayı indirir → "Davet Koduyla Katıl" ekranını seçer
5. Kodu girer → Backend kodu doğrular, hangi daire/bina olduğunu döner
6. Sakin adını, emailini ve şifresini belirler → Kayıt tamamlanır
7. Kullanıcı direkt olarak sakin dashboard'una yönlendirilir
```

---

## 🔔 Bildirim Sistemi

Uygulama **açıkken** WebSocket ile anlık rozet/toast; **kapalıyken** FCM tray; **yedek** olarak seyrek HTTP poll.

### Katmanlar

```text
Olay → notificationService (DB)
     → notificationDeliveryService
           ├─ realtimeHub → WebSocket aboneleri
           └─ FCM push (pushService.js)

Mobil → NotificationDeliveryCoordinator
           ├─ WebSocketNotificationRealtimeSource  (açık app)
           ├─ FcmNotificationRealtimeSource         (tray + ön plan)
           └─ PollingNotificationRealtimeSource     (yedek)
```

### Backend

| Dosya | Rol |
|-------|-----|
| `src/constants/realtimeEvents.js` | Olay adları + payload |
| `src/realtime/realtimeHub.js` | publish/subscribe |
| `src/realtime/wsGateway.js` | `ws` + JWT `?token=` |
| `src/utils/verifyAccessToken.js` | WS auth |
| `src/services/notificationDeliveryService.js` | Hub + FCM |
| `src/services/pushService.js` | Firebase Admin SDK |
| `GET /notifications/unread-count` | Hafif rozet |

**Env:** `REALTIME_WS_ENABLED=true`, `FIREBASE_SERVICE_ACCOUNT_JSON`

**WebSocket:** `wss://api.aidatpanel.com/api/v1/realtime?token=ACCESS_JWT`

Sunucu → istemci örnek payload:

```json
{
  "event": "notification.created",
  "notificationId": "uuid",
  "type": "TICKET_UPDATE",
  "title": "...",
  "body": "...",
  "data": { "ticketId": "...", "route": "/resident-dashboard" }
}
```

### Mobil

| Dosya | Rol |
|-------|-----|
| `core/notifications/realtime/notification_delivery_config.dart` | `webSocketEnabled` |
| `core/notifications/realtime/websocket_notification_realtime_source.dart` | `web_socket_channel` |
| `core/notifications/realtime/notification_delivery_coordinator.dart` | Orchestrator |
| `core/constants/api_constants.dart` | `realtimeWebSocketUri()` |

### FCM test (canlı)

- `main.dart` kullanın (`main_dev.dart` mock — push çalışmaz)
- Logcat: `[FCM] PUT /me/fcm-token başarılı`, `[realtime] WebSocket bağlandı`
- Yönetici + sakin testinde **farklı hesap** kullanın
- Android 13+: bildirim izni; Play Store imzalı build veya debug + gerçek cihaz

### Canlı deploy notları

1. Backend: `REALTIME_WS_ENABLED=true`, Firebase JSON, `npx prisma migrate deploy`, `pm2 restart aidapanel-api`
2. Nginx: `/api/v1/realtime` için WebSocket upgrade (`Upgrade`, `Connection "upgrade"`)
3. Deploy otomasyonu: `backend/scripts/deploy.ps1` (bkz. Deployment bölümü)

---

## 💳 Abonelik Sistemi (RevenueCat)

### Neden RevenueCat?
- App Store (iOS) ve Google Play (Android) aboneliklerini tek API'dan yönetir
- Receipt validation backend'i üstlenir
- Webhook ile anlık abonelik olayları alınır

### Abonelik Planları (App Store Connect + Play Console'da tanımlanacak)

| Plan | ID | Fiyat (önerilen) |
|------|-------|---------|
| Aylık | `aidatpanel_monthly` | ₺99/ay |
| Yıllık | `aidatpanel_annual` | ₺799/yıl |

### Webhook Olayları (RevenueCat → Backend)

```javascript
// POST /api/subscription/webhook/revenuecat
const events = {
  'INITIAL_PURCHASE': () => activateSubscription(),
  'RENEWAL': () => extendSubscription(),
  'CANCELLATION': () => markCancelled(),
  'EXPIRATION': () => expireSubscription(),
  'BILLING_ISSUE': () => notifyBillingIssue(),
};
```

### Flutter'da RevenueCat Entegrasyonu

```dart
// main.dart içinde
await Purchases.setLogLevel(LogLevel.debug);
PurchasesConfiguration configuration;
if (Platform.isAndroid) {
  configuration = PurchasesConfiguration(androidApiKey);
} else {
  configuration = PurchasesConfiguration(iosApiKey);
}
await Purchases.configure(configuration);
```

---

## 🌐 Web (Landing Page)

**Amaç:** Sadece tanıtım. Uygulama indirmeye yönlendirme.

**İçerik:**
- Hero: Uygulama adı, tagline, App Store + Google Play butonları
- Özellikler bölümü (3-4 madde)
- Ekran görüntüleri (mockup)
- Fiyatlandırma (aylık/yıllık)
- SSS
- İletişim / Destek emaili
- Gizlilik politikası ve KVKK metni (yasal zorunluluk)

**Teknoloji:** Saf HTML + CSS + minimal JS (framework yok)

**Deployment:** CloudPanel üzerinden aidatpanel.com domain'ine bağlı statik site

---

## 🚀 Deployment

### Backend (VPS — CloudPanel)

| Öğe | Değer |
|-----|-------|
| Domain | `api.aidatpanel.com` |
| Sunucu yolu | `/home/aidatpanel-api/htdocs/api.aidatpanel.com` |
| PM2 süreç adı | `aidapanel-api` (t harfi yok) |
| Deploy script | `backend/scripts/deploy.ps1` |

**Yerel makineden deploy:**

```powershell
powershell -ExecutionPolicy Bypass -File backend/scripts/deploy.ps1
```

İlk kurulum: `backend/scripts/deploy.config.example.json` → `deploy.local.json` (gitignore).

**Sunucuda manuel restart:**

```bash
source ~/.nvm/nvm.sh
cd /home/aidatpanel-api/htdocs/api.aidatpanel.com
git pull   # veya deploy.ps1 ile sync
npm ci --omit=dev
npx prisma migrate deploy
pm2 restart aidapanel-api
```

### Subdomain Yapısı

| Subdomain | Hedef |
|-----------|-------|
| `aidatpanel.com` | Web landing page |
| `api.aidatpanel.com` | Node.js backend (port 4200) |

### Veritabanı

```bash
# PostgreSQL kullanıcı ve veritabanı oluşturma
createuser aidatpanel --pwprompt
createdb aidatpanel --owner=aidatpanel

# Prisma migration
npx prisma migrate deploy
```

---

## 🏗️ MVP Geliştirme Önceliği

### Faz 1 — Çekirdek (MVP)
- [ ] Auth (register, login, JWT, davet kodu ile katılım)
- [ ] Bina ve daire CRUD
- [ ] Davet kodu sistemi
- [ ] Aylık aidat oluşturma (toplu) ve durum güncelleme
- [ ] Sakin: kendi aidat durumunu görme
- [ ] FCM push notification altyapısı
- [ ] RevenueCat abonelik entegrasyonu (iOS + Android)
- [ ] Landing page (web)

### Faz 2 — Tamamlama
- [ ] Gider kaydı ve kategorileme
- [ ] Arıza/talep sistemi (Ticket)
- [ ] Yönetici → Sakin bildirim gönderme
- [ ] WhatsApp aidat hatırlatma
- [ ] PDF rapor (aylık özet)
- [ ] i18n (TR/EN)

### Faz 3 — Büyüme
- [ ] Online ödeme entegrasyonu (İyzico/PayTR)
- [ ] Çoklu yönetici (personel atama)
- [ ] Aidat geçmişi grafiği / istatistik dashboard
- [ ] Belge paylaşımı (yönetim kararları, toplantı tutanakları)

---

## ⚙️ Teknik Kararlar ve Gerekçeleri

| Karar | Seçim | Gerekçe |
|-------|-------|---------|
| State management | Riverpod | OkulOptik'te zaten biliniyor |
| Navigation | GoRouter | Flutter best practice, deep link desteği |
| ORM | Prisma | Type-safe, migration yönetimi kolay |
| Abonelik | RevenueCat | iOS + Android tek entegrasyon |
| Push | Firebase FCM | Cross-platform standart |
| WhatsApp | Twilio | Sandbox ile hızlı test, Türkiye desteği var |
| i18n | Flutter ARB | Flutter native çözüm |

---

## 🎨 Tasarım Sistemi

### Hedef Kitle ve Tasarım Felsefesi

AidatPanel kullanıcılarının önemli bir kısmı **50+ yaş** grubundadır (apartman yöneticileri çoğunlukla emekli veya orta-üst yaş erkekler, sakinlerin büyük kısmı da bu yaş grubundadır). Tasarımın her kararı bu gerçeği gözetmelidir.

**Temel ilke:** Sade, güvenilir, net. Şova gerek yok — işlevsellik ön planda.

---

### Renk Paleti

```dart
// core/theme/app_colors.dart

class AppColors {
  // Ana renkler
  static const primary       = Color(0xFF1B3A6B); // Koyu lacivert — güven, resmiyet
  static const primaryLight  = Color(0xFF2D5FA8); // Hover/pressed state
  static const accent        = Color(0xFFF59E0B); // Amber — aksiyon butonları, vurgu

  // Durum renkleri
  static const success       = Color(0xFF16A34A); // Ödendi, tamamlandı
  static const error         = Color(0xFFDC2626); // Gecikmiş aidat, hata
  static const warning       = Color(0xFFF59E0B); // Beklemede, uyarı
  static const info          = Color(0xFF2563EB); // Bilgi mesajları

  // Nötr renkler
  static const background    = Color(0xFFF8FAFC); // Ana arka plan (saf beyaz değil)
  static const surface       = Color(0xFFFFFFFF); // Kart, modal yüzeyi
  static const border        = Color(0xFFE2E8F0); // Ayırıcı çizgiler
  static const textPrimary   = Color(0xFF0F172A); // Ana metin
  static const textSecondary = Color(0xFF475569); // İkincil metin
  static const textDisabled  = Color(0xFF94A3B8); // Devre dışı metin

  // Durum badge arka planları (açık ton)
  static const successBg     = Color(0xFFDCFCE7);
  static const errorBg       = Color(0xFFFEE2E2);
  static const warningBg     = Color(0xFFFEF3C7);
}
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
