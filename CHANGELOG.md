# Changelog

Tüm önemli değişiklikler bu dosyada belgelenir.  
Format [Keep a Changelog](https://keepachangelog.com/tr/1.1.0/) esas alınır.

## [Unreleased] — 2026-06-13

Bu oturumda tamamlanan işler: **FAZ 4 (Reports + ONAY)**, **FAZ 5 backend sertleştirme** ve ilgili mobil/dokümantasyon güncellemeleri.

### Added

#### Backend — PDF Raporlar (FAZ 4)

- `GET /api/v1/buildings/:id/reports?type=monthly|annual` — aylık ve yıllık PDF çıktısı (`pdfkit`)
- `reportDataService.js` — aidat, gider ve operasyonel veri toplama
- `reportPdfService.js` — 50+ yaş dostu PDF şablonları (TR)
- `reportController.js`, `reportSchemas.js`, `reportPeriod.js`, `reportAggregation.js`, `reportLabels.js`
- Jest: `reportAggregation.test.js` (aidat/gider aggregasyon)

#### Backend — FAZ 5 sertleştirme

- `services/me/` — `meService.js` modüler refactor (profil, şifre, dil, ödeme bilgisi, KVKK, FCM)
- `expenseOcrService.js` — gider makbuz OCR'ı dekont pipeline kuyruğuna alındı (async, `ocrPending`)
- `dueBulkService.js`, `dueOverdueService.js`, `dueGeneration.js` — aidat toplu üretim ve OVERDUE job
- `authService.js` — auth iş mantığı controller'dan servise taşındı
- `validators/` — Zod şemaları feature bazlı modüllere bölündü
- `authRateLimitKey.js` — hesap bazlı rate limit anahtarı
- Prisma migration: `20260613120000_expense_updated_at` (`Expense.updatedAt` kolonu)
- Jest altyapısı (`npm test`) — 24 unit test:
  - `meProfileHelpers.test.js`
  - `expenseOcrService.test.js`
  - `reportAggregation.test.js`
  - `dueGeneration.test.js`
  - `trDueDate.test.js`
  - `authRateLimitKey.test.js`
- Dev HTTP istek log middleware (`backend/index.js`)

#### Mobil — Reports (FAZ 4)

- `features/reports/` — Clean Architecture (datasource, repository, provider, sheet, preview)
- Bina ⋮ menüsünden «Rapor indir» → ay/yıl seçimi → **Raporu göster** → tam ekran PDF önizleme → **Raporu paylaş**
- i18n: `features.reports` (TR/EN)

#### Mobil — FAZ 5

- `DioClient` — upload işlemleri için ayrı `_uploadDio` instance (3 dk timeout; global timeout yarışı riski giderildi)
- Gider ve dekont upload datasource'ları `postMultipart` kullanacak şekilde güncellendi

#### Yerel geliştirme

- `API_BASE_URL` — `String.fromEnvironment` ile dart-define desteği (`api_constants.dart`)
- Android `network_security_config.xml` — localhost / `10.0.2.2` cleartext (yerel backend)
- `mobile/README.md`, `backend/README.md` — yerel çalıştırma komutları

### Changed

- `expenseService.js` — makbuz yükleme yanıtı: dosyalar hemen kaydedilir, OCR arka planda (`ocrPending: true`)
- `reportDataService.js` — `formatMoney` `reportFormat.js` util'ine taşındı
- `meService.js` — barrel export; geriye dönük uyumluluk korundu
- `FAZ_DURUMU.md` — FAZ 4 ✅ ONAY (2026-06-13); FAZ 5 backend checklist tamamlandı
- `resources/AIDATPANEL.md` — reports endpoint dokümantasyonu

### Removed

- `mobile/docs/DEPENDENCY_UPGRADE.md`
- `resources/PERF_GUVENLIK_ODAK.md`
- `resources/bildirim/DEPLOY_TEK_SEFER.md`
- `resources/bildirim/FCM_E2E_CHECKLIST.md`

### Fixed

- Yerel `npm run dev` backend'e istek gitmeme sorunu — production URL varsayılanı yerine `API_BASE_URL` dart-define
- `main_dev.dart` mock bina ID (`b1`) ile rapor testi yapılamaması — dokümante edildi (`main.dart` + gerçek giriş gerekir)

### Bilinen sınırlar (rapor v1)

- Net = tahsil − gider (kasa bakiyesi yok)
- Manuel «ödendi» → `DuePayment` oluşmaz; v1 tahsilat kaynağı `Due` tablosu
- OCR bitmemiş gider (`amount = null`) raporda «hesaplanmadı» olarak işaretlenir

---

## Faz durumu (özet)

| Faz | Durum |
|-----|-------|
| 0–4 | ✅ Kapalı (FAZ 4 ONAY: 2026-06-13) |
| 5   | ▶ Aktif — mobil: pagination, testler, certificate pinning |
| 6–7 | 🔒 Kilitli |
