# 📋 İmplementasyon Planı — Abonelik Sisteminin Bina Bazlı Yeniden Tasarlanması
_Oluşturulma: 2026-06-27_

---

## 🎯 Hedef
Abonelik sistemini bina sayısına dayalı paketler (1-5, 5-20, 20-50, 50+) şeklinde yeniden yapılandırmak. Mevcut `aidatpanel_monthly` ve `aidatpanel_annual` paketleri 1-5 bina paketi olarak kullanılacak. Diğer paketler UI'da "Yakında" (Coming Soon) olarak gösterilecek ve UI sıfırdan modern bir şekilde tasarlanacak (profil bilgileri korunarak).

---

## 🗂️ Etkilenen Dosyalar

| Dosya | İşlem |
|-------|-------|
| `backend/src/constants/subscriptionConstants.js` | Yeni paket sabitlerini ve bina limitlerini ekle |
| `backend/src/services/buildingQuotaService.js` | `resolveBuildingLimit` fonksiyonunu paketlere göre limit döndürecek şekilde güncelle |
| `backend/src/utils/revenueCatWebhook.js` | `mapProductIdToPlan` fonksiyonunu yeni paketleri destekleyecek şekilde genişlet |
| `mobile/lib/features/subscription/presentation/screens/subscription_screen.dart` | UI'ı tamamen yenile, yeni paket kartlarını ekle |
| `mobile/lib/l10n/strings_tr.i18n.json` | Yeni UI metinlerini ekle |
| `mobile/lib/l10n/strings_en.i18n.json` | Yeni UI metinlerini ekle |

---

## 🧩 Adımlar

### Adım 1 — Backend: Sabitlerin ve Limitlerin Güncellenmesi
- [ ] `backend/src/constants/subscriptionConstants.js` dosyasına yeni plan adlarını ekle (`monthly_5_20`, `annual_5_20`, vb.).
- [ ] `backend/src/services/buildingQuotaService.js` dosyasındaki `resolveBuildingLimit` fonksiyonunu güncelle. Aktif aboneliği olmayanlar için limit 1, `monthly`/`annual` için 5, diğerleri için ilgili limitleri (20, 50, null) döndür.
- [ ] `backend/src/utils/revenueCatWebhook.js` dosyasındaki `mapProductIdToPlan` fonksiyonunu yeni olası ID'leri de (ilerisi için) parse edebilecek şekilde güncelle.

### Adım 2 — Flutter: i18n Metinlerinin Eklenmesi
- [ ] `strings_tr.i18n.json` ve `strings_en.i18n.json` dosyalarına yeni paket isimleri, "Yakında" etiketi ve "İletişime Geçin" metinlerini ekle.

### Adım 3 — Flutter: UI Yeniden Tasarımı
- [ ] `SubscriptionScreen` dosyasını aç ve `build` metodunu baştan tasarla.
- [ ] Mevcut profil satırını (`_ProfileRow`) koru ve modernleştir.
- [ ] Profilin altına bina kullanımını gösteren ilerleme çubuğu (progress bar) ekle (Kullanılan / Limit).
- [ ] Ekranın üst kısmına "Aylık" ve "Yıllık" seçenekleri için bir toggle (tab) ekle. Seçili olan tab siyah arka planlı olacak.
- [ ] Abonelik yoksa `_StatusStrip`'te "Temel Paket" yazacak ve 1-5 Bina paketinde "Mevcut Planınız" rozeti gizlenecek.
- [ ] Abonelik yoksa en üste "Temel Paket" özelliklerini gösteren yeni bir kart eklenecek (1 Bina, PDF Raporu vb.).
- [ ] 1-5 Bina paketi için ana bir kart oluştur. Seçilen tab'a göre sadece ilgili fiyat ve satın alma butonu gösterilecek.
- [ ] Fiyat bilgisi RevenueCat'ten gelmiyorsa fallback olarak "99 ₺" ve "999 ₺" gösterilecek.
- [ ] "En avantajlı" rozeti ve tasarruf konsepti kaldırılacak.
- [ ] 5-20 Bina ve 20-50 Bina paketleri için pasif (disabled) kartlar oluştur ve üzerlerine "Yakında" (Coming Soon) rozeti ekle.
- [ ] 50+ Bina paketi için "Özel Fiyat" kartı oluştur ve "İletişime Geçin" yönlendirmesi ekle.

---

## 🌐 i18n Anahtarları

| Anahtar | Türkçe | İngilizce |
|---------|--------|-----------|
| `plan_1_5_buildings` | 1-5 Bina Paketi | 1-5 Buildings Plan |
| `plan_5_20_buildings` | 5-20 Bina Paketi | 5-20 Buildings Plan |
| `plan_20_50_buildings` | 20-50 Bina Paketi | 20-50 Buildings Plan |
| `plan_50_plus_buildings` | 50+ Bina (Özel) | 50+ Buildings (Custom) |
| `coming_soon` | Yakında | Coming Soon |
| `contact_us` | İletişime Geçin | Contact Us |
| `contact_us_desc` | Özel fiyatlandırma için bizimle iletişime geçin. | Contact us for custom pricing. |
| `building_limit_reached` | Bina kotanız doldu. Yeni bina eklemek için aboneliğinizi yükseltin. | Building limit reached. Upgrade your subscription to add more. |
| `feature_1_5_buildings` | 1-5 Bina Yönetimi | Manage 1-5 Buildings |
| `feature_5_20_buildings` | 5-20 Bina Yönetimi | Manage 5-20 Buildings |
| `feature_20_50_buildings` | 20-50 Bina Yönetimi | Manage 20-50 Buildings |
| `feature_50_plus_buildings` | Sınırsız Bina Yönetimi | Unlimited Building Management |
| `feature_custom_support` | Özel Müşteri Temsilcisi | Dedicated Account Manager |
| `toggle_monthly` | Aylık | Monthly |
| `toggle_annual` | Yıllık | Annual |
| `current_plan_badge` | Mevcut Planınız | Your Current Plan |
| `plan_basic` | Temel Paket | Basic Plan |
| `feature_basic_buildings` | 1 Bina Yönetimi | Manage 1 Building |
| `feature_basic_reports` | Temel Raporlar | Basic Reports |
| `status_unlimited` | Süresiz | Lifetime |

### Adım 4 — Hata Yönetimi ve Tasarım Düzeltmeleri
- [ ] `SubscriptionNotifier.load` metodunda `RevenueCatService.fetchStorePrices()` hata fırlatırsa, backend'den gelen abonelik bilgisini kaybetmemek için `Future.wait` yerine ayrı ayrı `try-catch` blokları kullanılacak.
- [ ] `SubscriptionScreen`'de Aylık ve Yıllık kartları arasındaki tasarım farkı (mavi kısım) giderilecek. `_PlanOption` içindeki `isYearly`'ye bağlı renk/tasarım farklılıkları kaldırılacak.
- [ ] Abonelik yoksa progress bar'ın 1/1 dolu görünmesi sağlanacak.

---

## 🚀 Deploy Gerekli mi?
[x] Evet — `bash backend/scripts/deploy.sh` (Backend mantığı değiştiği için)
[ ] Hayır

---

## ⚙️ Code Generation Gerekli mi?
[x] `dart run slang` (i18n değişiklikleri için)
[ ] `flutter pub run build_runner build --delete-conflicting-outputs`
[ ] Gerekmez
