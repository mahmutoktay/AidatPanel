# Changelog

Format [Keep a Changelog](https://keepachangelog.com/tr/1.1.0/) esas alınır.  
Faz durumu için: [`resources/yol-haritası/FAZ_DURUMU.md`](resources/yol-haritası/FAZ_DURUMU.md)

## [Unreleased]

### Added

- `backend/scripts/deploy.ps1` — SSH + tar ile VPS deploy (Mutagen yerine)
- `backend/scripts/deploy.sh` — WSL/Linux alternatifi
- `backend/scripts/deploy.config.example.json` — sunucu ayar şablonu

### Changed

- Bildirim mimarisi tek kaynakta: `resources/AIDATPANEL.md` (§ Bildirim Sistemi)
- `resources/bildirim/` klasörü kaldırıldı; tüm referanslar güncellendi

---

## [0.1.0] — 2026-06-13

FAZ 4 (Reports PDF) tamamlandı; FAZ 5 backend sertleştirmesi başlandı.

### Added

- **Backend:** PDF raporlar (`GET /buildings/:id/reports?type=monthly|annual`), `reportDataService`, `reportPdfService`
- **Backend:** `services/me/` modüler refactor, expense OCR kuyruğu, aidat bulk/overdue job, Jest altyapısı (24 test)
- **Mobil:** `features/reports/` — PDF önizleme ve paylaşım
- **Mobil:** Upload için ayrı `_uploadDio` (3 dk timeout)
- **Dev:** `API_BASE_URL` dart-define, Android cleartext localhost

### Changed

- `meService.js` barrel export; Zod validators feature modüllerine bölündü
- `FAZ_DURUMU.md` — FAZ 4 ONAY (2026-06-13)

### Fixed

- Yerel backend testi: production URL varsayılanı yerine `API_BASE_URL` dart-define

---

## Faz durumu (özet)

| Faz | Durum |
|-----|-------|
| 0–4 | Kapalı (FAZ 4 ONAY: 2026-06-13) |
| 5   | Aktif — pagination, testler, certificate pinning |
| 6–7 | Kilitli |

[Unreleased]: https://github.com/mahmutoktay/AidatPanel/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/mahmutoktay/AidatPanel/releases/tag/v0.1.0
