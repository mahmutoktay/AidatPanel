# AidatPanel Mobile

Apartman ve site yönetiminde en çok zamanı yiyen işlerden biri aidat takibi: kim ödedi, kim gecikti, hangi daire boş? **AidatPanel**, yöneticilere ve sakinlere aynı uygulama içinde net bir tablo sunar — telefonla daire dağıtmak, davet koduyla sakin eklemek, aidat durumunu güncellemek ve pano özetine bakmak tek akışta toplanır.

Bu klasör, Flutter ile yazılmış resmi mobil istemcidir. Mimari **Clean Architecture** (domain → data → presentation), durum yönetimi **Riverpod**, yönlendirme **GoRouter**; ağ katmanı **Dio** ve JWT ile çalışır. Metinler **Slang** ile Türkçe ve İngilizce sunulur.

## Hızlı başlangıç

```bash
cd mobile
flutter pub get
flutter run
```

**Yerel backend ile test** (VPS DB tüneli + `backend` içinde `npm run dev`):

```bash
# Linux masaüstü / iOS simülatör
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4200

# Android emülatör (localhost = 10.0.2.2)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4200

# Fiziksel telefon (aynı Wi‑Fi; PC IP'nizi yazın)
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:4200
```

`main.dart` ile gerçek giriş yapın; `main_dev.dart` mock bina ID kullanır — rapor indirme çalışmaz.

Sunucu olmadan arayüz denemek için (mock veri, ekranda **DEV** rozeti):

```bash
flutter run -t lib/main_dev.dart
```

## Çeviri ve görevler

Çeviri anahtarları `lib/l10n/` altındaki JSON dosyalarında; üretilen kod `strings.g.dart`. Üst klasördeki VS Code / Cursor görevleri: Slang watch/generate, i18n tarama (`dart run tool/i18n_scan.dart`, `dart run tool/check_translations.dart`). Toplu çeviri için DeepL API anahtarı `tool/.deepl_key` dosyasına konur (dosya `.gitignore`’dadır, repoya girmez). Tek anahtar eklemek: `dart run tool/add_translation.dart <anahtar> "Türkçe" ["English"]`.

## Google Play (release imzası)

1. `android/upload-keystore.jks` dosyan `android/` klasöründe olsun (veya `key.properties` içindeki `storeFile` yolunu ona göre düzenle).
2. `android/key.properties.example` dosyasını `android/key.properties` olarak kopyala; şifreleri ve `storeFile` yolunu doldur. Bu dosya `.gitignore`’dadır.
3. `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab` → Play Console’a yükle. **Her AAB öncesi** `pubspec.yaml` içinde `+` sonrası sürüm kodunu 1 artır (Play reddeder aksi halde).

`key.properties` yoksa release derlemesi geçici olarak debug anahtarıyla imzalanır; mağazaya **yalnızca** `key.properties` + keystore ile üretilen AAB gönder.

## Push bildirimi (FCM) test

Kapalı uygulamada tray push için Play Store’lu emülatör, `main.dart`, bildirim izni ve sakin hesabında `[FCM] PUT /me/fcm-token başarılı` logu gerekir. Yönetici telefon + sakin emülatör **farklı hesap** olmalı. Mimari: [`resources/AIDATPANEL.md`](../resources/AIDATPANEL.md) (Bildirim Sistemi).

## Android notları

- Dekont PDF önizleme (`pdfx`): [`docs/DEKONT_ANDROID_REBUILD.md`](docs/DEKONT_ANDROID_REBUILD.md) — hot reload ile native eklenti kaydı olmaz; tam derleme gerekir.

## Proje belgeleri

API ve mimari: [`resources/AIDATPANEL.md`](../resources/AIDATPANEL.md), faz durumu: [`resources/yol-haritası/FAZ_DURUMU.md`](../resources/yol-haritası/FAZ_DURUMU.md), backend: [`backend/README.md`](../backend/README.md).

---

*AidatPanel — aidat ve site işlerini telefonda toparlayan yardımcınız.*
