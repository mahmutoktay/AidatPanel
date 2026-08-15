# AidatPanel Admin Panel

## 1. Amaç ve Kapsam

AidatPanel geliştirici/operasyon ekibi için iç yönetim paneli. `admin.aidatpanel.com` üzerinden deploy edilir.

- Cross-tenant veri erişimi (tüm yöneticiler/sakinler)
- Her hassas işlem `AdminAuditLog` tablosuna yazılır
- Mobil `User` RBAC (`MANAGER`/`RESIDENT`) ile karışmaz — ayrı `AdminUser` tablosu

## 2. Mimari

```
adminpanel/ (EJS + HTMX + Alpine.js, port 4300, PM2: aidatpanel-admin)
    ↓ HttpOnly cookie + admin JWT
backend /api/v1/admin/* (Express + Prisma)
    ↓
PostgreSQL (AdminUser, AdminAuditLog, PromoGrant, UserActivityDaily, DbBackup, …)
```

## 3. Tasarım Sistemi ve Responsive Gereksinimler

- **Mobile-first CSS:** `adminpanel/public/css/` (`tokens.css`, `layout.css`, `components.css`)
- **Breakpoint'ler:** xs &lt;480 · sm 480–767 · md 768–1023 · lg 1024–1279 · xl ≥1280
- **Sidebar:** mobil drawer · md ikon-only · lg+ tam panel
- **Tablolar:** lg+ tablo · &lt;lg kart görünümü
- **Dokunma alanı:** min 44×44px
- **Onay kapısı:** Login, dashboard, liste, detay — 5 viewport'ta doğrulama (`adminpanel/tests/responsive/`)

## 4. Rol ve Yetki Matrisi

| İşlem | SUPPORT | SUPER_ADMIN |
| --- | --- | --- |
| Dashboard / listeleme | ✅ | ✅ |
| Şifre sıfırlama tetikleme | ✅ | ✅ |
| Promo / abonelik grant | ✅ | ✅ |
| KVKK hesap kapatma | ❌ | ✅ |
| DB yedek alma/indirme | ❌ | ✅ |

## 5. Modül Spesifikasyonları

| Modül | API | UI |
| --- | --- | --- |
| Kimlik | `POST /admin/auth/login` | `/auth/login` |
| Üyeler | `GET /admin/users`, `GET /admin/users/:id` | `/users` |
| Abonelik | `GET /admin/subscriptions`, `POST .../grant` | `/subscriptions` |
| Dekont | `GET /admin/dekonts/summary` | `/reports/dekonts` |
| Sakin | `GET /admin/residents`, payment-habits | `/reports/residents` |
| Analitik | `GET /admin/analytics/active-users` | `/analytics` |
| Bildirim | `GET/POST /admin/notifications/*` | topbar + `/analytics` |
| Yedek | `POST /admin/backups/create` | `/backups` (SUPER_ADMIN) |

## 6. Güvenlik ve KVKK

- Ayrı `ADMIN_JWT_SECRET`, rate limit (5 deneme/15dk), opsiyonel IP allowlist
- Listelerde PII maskeleme; detay görüntüleme audit'e yazılır
- Admin-initiated soft delete (`forceManager` override ile)
- Web panelinden DB **geri yükleme yok** — SSH: `backend/scripts/restore-db.sh`

## 7. Performans

- Tüm listeler pagination (default 25)
- DAU/MAU: `UserActivityDaily` + gece aggregation job
- Dashboard KPI cache (5dk, v1 in-memory)

## 8. Deploy

- **API:** `bash backend/scripts/deploy.sh` (admin route'ları dahil; PM2 `aidapanel-api`)
- **UI:** `bash adminpanel/scripts/deploy.sh` → `/home/aidatpanel-admin/htdocs/admin.aidatpanel.com`
  - PM2 süreç: `aidat-admin` (kullanıcı `aidatpanel-admin`, port 4300)
  - Config: `adminpanel/scripts/deploy.config.example.json` → `deploy.local.json`
  - `.env` üzerine yazılmaz; log: `bash adminpanel/scripts/deploy.sh --logs`
- **Env:** `ADMIN_JWT_SECRET`, `ADMIN_API_BASE`, `ADMIN_BACKUP_DIR`, `ADMIN_PORT`
- AI kuralı: `AGENTS.md` §6.2 — `adminpanel/` değişince deploy zorunlu

## 9. Kapsam Dışı (v1)

- Web'den DB restore
- Telegram bot
- RevenueCat REST sync (opsiyonel, sonraki sürüm)

## 10. Faz Checklist (FAZ 0–F)

- [x] FAZ 0: Responsive tasarım sistemi
- [x] FAZ A: AdminUser, auth, dashboard shell
- [x] FAZ B: Üye yönetimi, KVKK
- [x] FAZ C: Abonelik, promo, district
- [x] FAZ D: Dekont/sakin raporları
- [x] FAZ E: DAU/MAU, admin bildirimleri
- [x] FAZ F: Yedekleme, Jest/Playwright, dokümantasyon
