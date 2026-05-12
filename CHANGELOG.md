# AidatPanel — Değişiklik günlüğü

## Hotfix — 2026-05-12 09:52:18

| Alan | Değer |
|------|--------|
| **Tarih / saat** | 2026-05-12 09:52:18 (yerel) |
| **Git etiketi (tag)** | `hotfix-2026-05-12-0952` |

### Yapılan değişiklikler

- **`GET /buildings`:** `_count.apartments` (Prisma); `FLUTTER-BACKEND.md` §2.3 / §5 / §8.
- **Davet kodu:** Üretim `APX-XXX-XXXX` (3+3+4); `join` + `validateInviteCode` normalizasyonu; `test.py` format doğrulaması.
- **Belgeler:** `resources/MOBILE-TO-BACKEND.md` güncellemeleri.
- **Cursor:** `push et` + hotfix CHANGELOG kuralı (`.cursor/rules/changelog-ve-push.mdc`).

## [aidatpanel-20260510-164734] — 2026-05-10 16:47:34 +03

| Alan | Değer |
|------|--------|
| **Tarih / saat** | 2026-05-10 16:47:34 +03 |
| **Git etiketi (tag)** | `aidatpanel-20260510-164734` |
| **Commit (ana özellik seti)** | `8cc21526dafb2037a2a0a6f05a255104889082a3` |
| **Etiketin hedefi** | `aidatpanel-20260510-164734` etiketi, CHANGELOG dahil **son push edilen** `backend/yedek` commit’ine basılır; tam hash: `git rev-parse refs/tags/aidatpanel-20260510-164734^{commit}` |

### Yapılan değişiklikler

- **Backend P0 — Sakin ayırma:** `DELETE /api/v1/buildings/:buildingId/apartments/:id/resident` (yönetici); `User.apartmentId` kaldırılır, aidat geçmişi korunur.
- **Backend P0 — Güvenli `resident`:** `GET .../apartments` ve aidat listesinde `resident` için `userPublicSelect` (`meService` export); `passwordHash` / `refreshTokenVersion` vb. yok.
- **CORS:** `PATCH` metodu `backend/index.js` içinde izin listesine eklendi (aidat uçları, Flutter web).
- **Docker:** `backend/Dockerfile`, genişletilmiş `docker-compose.yml` (Postgres healthcheck + `api` servisi, `e2e-data` volume, `AIDATPANEL_E2E_RESET_LOG`), `backend/.dockerignore`, `backend/scripts/docker-test.sh`.
- **test.py:** CORS preflight (`OPTIONS` + `PATCH`), `resident` hassas alan kontrolü, join sonrası daire/due doğrulaması, `DELETE .../resident` + ikinci çağrıda 404, dairesiz sakin `GET /me` ve boş `GET /me/dues`.
- **dueService:** Bina aidat listesinde iç içe `resident` alanı `userPublicSelect` ile hizalandı.
- **Belgeler:** `FLUTTER-BACKEND.md` — Faz 1 backend⟷mobil özet, P0 tamam işaretleri, Docker/geçmiş notları; `resources/MOBILE-TO-BACKEND.md` (mobil talep raporu, çapraz linkler); `backend/.env.example` (Docker E2E, `ALLOWED_ORIGINS` notu); `backend/.gitignore` (`e2e-data/`).
- **Cursor:** `.cursor/rules/changelog-ve-push.mdc` — “raporla ve push et” iş akışı kuralı.
- **Dışlanan:** `backend/Arşiv.zip` depoya eklenmedi (yerel yedek).
