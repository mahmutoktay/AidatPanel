# Mobil bağımlılık yükseltme planı

Tamamlandı: 2026-06-04

| Faz | Paketler | Durum |
|-----|----------|-------|
| A | permission_handler 12, package_info_plus 10, share_plus 13, google_fonts 8, flutter_secure_storage 10, file_picker 12-beta | ✅ |
| B | firebase_core 4, firebase_messaging 16 | ✅ |
| C | flutter_riverpod 3 (+ `legacy.dart` StateNotifier) | ✅ |
| D | go_router 17 | ✅ |
| E | slang 4, intl 0.20 | ✅ |
| F | `flutter_local_notifications` 21, `build_runner` 2.12, transitive `dependency_overrides` | ✅ |

Doğrulama: `flutter analyze`, `flutter test` (58), `flutter build appbundle --release` ✅

## Kalan 1 uyarı (bilinçli)

`image_picker_android` **0.8.13+19** — Dart **3.12** istiyor; mevcut Flutter **3.41.9** yalnızca **3.11** (yükseltilemez, SDK güncellemesi gerekir).

## Flutter SDK güncellemesi checklist (image_picker ve genel)

Yeni **Flutter stable** (Dart 3.12+) çıktığında veya ekip `flutter upgrade` yapacağında sırayla:

### 1. Ortam

- [ ] `flutter --version` — Dart sürümünün **≥ 3.12** olduğunu doğrula
- [ ] `cd mobile && flutter doctor` — Android toolchain yeşil
- [ ] Bu dosyadaki mevcut Flutter/Dart sürümünü not et (karşılaştırma için)

### 2. Bağımlılıklar

- [ ] `flutter pub upgrade` (`mobile/` içinde)
- [ ] `flutter pub outdated` — hedef: **`image_picker_android` 0.8.13+19** çözülmüş olsun
- [ ] `image_picker_android` için **`dependency_overrides` ekleme** — pub çözümü kendi seçsin
- [ ] Gerekirse `dependency_overrides` bloğunu gözden geçir: SDK ile artık gereksiz satırları kaldır (analyzer/meta/test vb. Flutter’ın kilitlediği paketler)

### 3. image_picker doğrulama

- [ ] `pubspec.lock` içinde `image_picker_android` → **0.8.13+19** (veya daha yeni stable)
- [ ] Derleme hatası yok: `language version 3.12 ... too high` **olmamalı**
- [ ] Manuel test: gider fişi / makbuz fotoğrafı seçimi (`expense_receipt_section` — galeri)
- [ ] Android release: `flutter build appbundle --release` başarılı

### 4. Regresyon

- [ ] `flutter analyze` — 0 issue
- [ ] `flutter test` — tüm testler geçer
- [ ] FCM yerel bildirim: `initialize(settings: …)` / `show(id: …)` (flutter_local_notifications 21)
- [ ] Play yüklemeden önce `pubspec.yaml` version code (`+` sonrası) **+1**

### 5. Hâlâ +19 çözülmüyorsa

- [ ] `image_picker` sürümünü `pubspec.yaml`’da güncelle: `flutter pub add image_picker`
- [ ] Flutter henüz Dart 3.12 vermiyorsa: **bekle**; override ile +19 zorlama (derleme kırılır)
- [ ] Sorunu `mobile/docs/DEPENDENCY_UPGRADE.md` “Kalan uyarı” bölümüne tarih + SDK sürümü ile not et

### Komut özeti

```bash
cd mobile
flutter --version
flutter upgrade
flutter pub upgrade
flutter pub outdated
flutter analyze
flutter test
flutter build appbundle --release
```

## dependency_overrides

Transitive paketler (analyzer, meta, test, xml, image, `flutter_secure_storage_darwin` vb.) `pubspec.yaml` altında sabitlendi; `flutter pub outdated` → **Found no outdated packages** (yalnızca +19 istisnası yukarıda).

## Android release (APK + Google Play AAB)

**Güncelleme:** 2026-06-04 — release açılış çökmesi ve Play yükleme notları.

### Kök neden (özet)

- `GeneratedPluginRegistrant.java` → `package_info_plus` / `share_plus` (Kotlin) Java derleyicisinde `cannot find symbol`.
- Geçici çözüm: manuel [`PluginRegistrant.kt`](../android/app/src/main/kotlin/com/aidatpanel/app/PluginRegistrant.kt).
- R8 (`isMinifyEnabled = true`) reflection ile yüklenen eklentileri siliyordu → açılışta native crash.

### Mevcut yapılandırma

| Bileşen | Davranış |
|---------|----------|
| [`MainActivity.kt`](../android/app/src/main/kotlin/com/aidatpanel/app/MainActivity.kt) | `PluginRegistrant.register()` — `super.configureFlutterEngine` **yok** |
| `PluginRegistrant.kt` | Java/Kotlin eklentiler doğrudan; `package_info_plus` / `share_plus` **reflection** (hata → log, crash yok) |
| [`app/build.gradle.kts`](../android/app/build.gradle.kts) | `isMinifyEnabled = false`, `isShrinkResources = false` |
| `deleteGeneratedPluginRegistrant` | Üretilen `GeneratedPluginRegistrant.java` Java compile öncesi silinir |
| [`main.dart`](../lib/main.dart) | `initFirebase` / `initAppInfo` / `initLocale` try/catch + `developer.log` (release logcat) |
| [`proguard-rules.pro`](../android/app/proguard-rules.pro) | Minify kapalıyken etkisiz; minify açılınca **zorunlu** |

### APK vs AAB (Play Console)

`flutter build apk --release` ve `flutter build appbundle --release` **aynı Gradle `release` tipini** kullanır. Play ek R8 uygulamaz; yüklediğiniz `.aab` içindeki kod dağıtılır. Düzeltme sonrası **yeni AAB** + `pubspec.yaml` sürüm kodu (`+` sonrası) **+1** şart.

### Yeni native eklenti ekledikten sonra

1. `flutter pub get`
2. `mobile/scripts/check_plugin_registrant.ps1` çalıştır
3. Gerekirse `PluginRegistrant.kt` güncelle (`path_provider_android` → `jni` + `jni_flutter` yeterli)
4. `flutter build apk --release` ve cihazda cold start
5. Play öncesi: `flutter build appbundle --release` + Internal testing smoke

### Minify tekrar açılacaksa

1. `proguard-rules.pro` içinde `dev.fluttercommunity.plus.*` keep kuralları kalsın
2. `mapping/release/seeds.txt` içinde `PackageInfoPlugin` doğrula
3. Sideload APK + Play internal track smoke
4. `PluginRegistrant` içinde `throw` **kullanma** (reflection başarısız → sessiz özellik kaybı)

## Riverpod 3 notu

`StateNotifier` / `StateProvider` kullanan dosyalarda:

```dart
import 'package:flutter_riverpod/legacy.dart';
```

İleride `Notifier` API’sine taşınabilir.

## Slang 4 notu

`dart run slang` ile çeviri üretimi. Dosya adları ileride `tr.i18n.json` / `en.i18n.json` olacak şekilde yeniden adlandırılabilir (deprecation uyarısı).

## file_picker

`^12.0.0-beta.5` — win32 6 ile `package_info_plus` 10 uyumu için beta sürüm.
