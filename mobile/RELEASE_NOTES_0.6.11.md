# AidatPanel 0.6.11 (2000000014) — Sürüm Notları

**Tarih:** 2026-07-22  
**Paket:** `app-prod-release.aab`  
**Yol:** `mobile/build/app/outputs/bundle/prodRelease/app-prod-release.aab`

## Play Console (kısa)

### Türkçe
- Alt menüde «Mülkler» etiketi «Binalar» olarak güncellendi.
- Yeni bina/site ekleme, silme ve düzenleme sonrası listeler otomatik yenileniyor; sayfayı aşağı çekerek yenilemeye gerek kalmıyor.
- Gider, site gideri, dekont inceleme, talep durumu, daire/sakin değişiklikleri ve Ana Sayfa özetleri de aynı şekilde güncel tutuluyor.
- Abonelik kotası ve bildirim rozeti, ilgili işlemlerden sonra yenileniyor.

### English
- Bottom nav label renamed from “Properties” to “Buildings”.
- Lists refresh automatically after adding, editing, or deleting buildings/sites—no pull-to-refresh needed.
- Expenses, site expenses, dekont review, ticket status, apartment/resident changes, and Home summary cards stay in sync.
- Subscription quota and notification badge update after related actions.

## Teknik özet (dahili)

- Nav i18n: `features.dashboard.properties` → TR «Binalar» / EN «Buildings»
- Otomatik liste senkronu: `list_cache_refresh`, `manager_home_caches`, `buildings_cache_refresh`
- Binalar sekmesi `buildingsStoreProvider` kaynağına bağlandı; dual-store mutasyon mirror’ı eklendi
- Detay ekranından dönüş ve silme sonrası dashboard’a yönlendirme

## Doğrulama checklist

- [ ] Soğuk açılış / giriş
- [ ] Alt nav «Binalar» etiketi
- [ ] Yeni bina ekle → Binalar listesinde anında görünür
- [ ] Yeni site ekle → Siteler segmentinde anında görünür
- [ ] Gider / dekont / talep sonrası Ana Sayfa sayaçları
- [ ] Pull-to-refresh hâlâ çalışıyor (yedek)
