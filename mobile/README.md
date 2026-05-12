# AidatPanel Mobile

Apartman ve site yönetiminde en çok zamanı yiyen işlerden biri aidat takibi: kim ödedi, kim gecikti, hangi daire boş? **AidatPanel**, yöneticilere ve sakinlere aynı uygulama içinde net bir tablo sunar — telefonla daire dağıtmak, davet koduyla sakin eklemek, aidat durumunu güncellemek ve pano özetine bakmak tek akışta toplanır.

Bu klasör, Flutter ile yazılmış resmi mobil istemcidir. Mimari **Clean Architecture** (domain → data → presentation), durum yönetimi **Riverpod**, yönlendirme **GoRouter**; ağ katmanı **Dio** ve JWT ile çalışır. Metinler **Slang** ile Türkçe ve İngilizce sunulur.

## Hızlı başlangıç

```bash
cd mobile
flutter pub get
flutter run
```

Sunucu olmadan arayüz denemek için (mock veri, ekranda **DEV** rozeti):

```bash
flutter run -t lib/main_dev.dart
```

## Çeviri ve görevler

Çeviri anahtarları `lib/l10n/` altındaki JSON dosyalarında; üretilen kod `strings.g.dart`. Üst klasördeki VS Code / Cursor görevleri: Slang watch/generate, i18n tarama (`dart run tool/i18n_scan.dart`, `dart run tool/check_translations.dart`). Toplu çeviri için DeepL API anahtarı `tool/.deepl_key` dosyasına konur (dosya `.gitignore`’dadır, repoya girmez). Tek anahtar eklemek: `dart run tool/add_translation.dart <anahtar> "Türkçe" ["English"]`.

## Proje belgeleri

API sözleşmesi, fazlar ve mobil–backend eşlemesi repoda `resources/` altında (ör. `AIDATPANEL.md`, `FAZ_DURUMU.md`, `MOBILE-TO-BACKEND.md`). Bu README yalnızca mobil pakete giriş içindir; ayrıntılı kurallar ve checklist orada güncellenir.

---

*AidatPanel — aidat ve site işlerini telefonda toparlayan yardımcınız.*
