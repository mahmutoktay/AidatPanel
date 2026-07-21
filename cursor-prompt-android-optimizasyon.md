# Görev: Android Release Build Optimizasyonu (R8 / Minify / Shrink) — Crash Riski Sıfıra İndirilerek

## Bağlam
Bu proje bir Flutter uygulaması. Google Play Console, mevcut yüklenen .aab için şu skorları gösteriyor:
- Optimizasyon ekleme: **Düşük**
- Kod karartma skoru: **%3**
- Küçültme skoru: **-**
- R8 yapılandırması: **-**

Bunun sebebi `android/app/build.gradle` (veya `.kts`) dosyasındaki release build type'ında minify ve resource shrink'in kapalı ya da eksik olması. Amaç bunları açmak ama **hiçbir native/reflection tabanlı kütüphanede runtime crash yaratmadan** yapmak.

## Yapılacaklar (sırayla uygula, her adımdan sonra durum raporu ver)

### 1. Mevcut yapılandırmayı incele
- `android/app/build.gradle` (veya `.kts`) dosyasını oku, mevcut `buildTypes { release { ... } }` bloğunu göster.
- `android/app/proguard-rules.pro` dosyası var mı, içeriği ne, kontrol et. Yoksa oluştur.
- `pubspec.yaml` içindeki tüm dependency'leri listele — özellikle şunları işaretle: Firebase (auth, messaging, firestore), gRPC/Prisma benzeri network kütüphaneleri, JSON serialization (json_serializable, freezed), yerel platform kanalı kullanan (Platform Channel / MethodChannel) paketler, kamera/OCR/ML kit paketleri, ödeme/SMS/OTP ile ilgili native SDK'lar (bu projede Netgsm/Twilio SMS entegrasyonu olabilir, native tarafı varsa dikkat).

### 2. build.gradle'da release block'u güncelle
Şu ayarları ekle/güncelle (Kotlin DSL veya Groovy, mevcut dosya formatına göre uyarlanmış şekilde):

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        signingConfig = signingConfigs.getByName("release")
    }
}
```

Eğer `debug` build type'ında yanlışlıkla minify açıksa kapat (debug'da kapalı kalmalı, aksi halde debug build'lerde de obfuscation nedeniyle debug zorlaşır).

### 3. proguard-rules.pro dosyasına gerekli keep kurallarını ekle
Flutter'ın kendi engine/embedding sınıfları için genelde ek kurala gerek yok (Flutter Gradle plugin bunu otomatik hallediyor) ama şu paketler için proje bağımlılıklarına göre keep kuralı ekle:

- Kullanılan her plugin için (firebase_messaging, firebase_core, vs. varsa) ilgili resmi ProGuard kurallarını GitHub'daki plugin repo'sundan veya paketin kendi `consumer-rules.pro` dosyasından kontrol et — çoğu plugin bunu zaten kendi AAR'ı içinde taşıyor, bu yüzden gereksiz keep kuralı EKLEME (fazladan keep, optimizasyon skorunu düşürür).
- Eğer JSON serialization için model sınıfları reflection ile parse ediliyorsa (örn. `json_annotation` ile generate edilmemiş, manuel `fromJson`/`toJson` değilse), o modellerin field'larının silinmemesi için:
  ```
  -keepclassmembers class ** {
      @com.google.gson.annotations.SerializedName <fields>;
  }
  ```
  (Sadece gerçekten kullanılıyorsa ekle, kullanılmıyorsa bu kuralı atla.)
- Native platform channel (MethodChannel/EventChannel) kullanan özel Kotlin/Java sınıfları varsa (örn. OTP/SMS okuma, cihaza özel entegrasyon), o sınıfları isimle koru:
  ```
  -keep class com.aidatpanel.** { *; }
  ```
  (Gerçek package adını projeden teyit ederek uyarla, kör kopyalama yapma.)
- Genel güvenlik payı için crash log'larını okunur tutmak istersen (opsiyonel, obfuscation skorunu düşürmez):
  ```
  -keepattributes SourceFile,LineNumberTable
  -renamesourcefileattribute SourceFile
  ```

### 4. Mapping dosyasını sakla
`android/app/build.gradle` içine mapping file çıktısının nerede saklanacağını doğrula (varsayılan: `build/app/outputs/mapping/release/mapping.txt`). Bu dosya crash raporlarını (Firebase Crashlytics veya Play Console'daki "deobfuscation") okunur hale getirmek için gerekli — Play Console'a her yüklemede bu dosyanın da otomatik yüklendiğinden emin ol (Play Console > App bundle explorer, "Deobfuscation file" kontrolü).

### 5. Build al ve doğrula
- `flutter clean`
- `flutter build appbundle --release`
- Build başarılıysa, çıkan .aab'yi `bundletool` ile lokal APK'ya çevirip gerçek cihaza veya emülatöre yükle (mümkünse fiziksel cihaz tercih et).

### 6. Manuel regresyon testi listesi çıkar ve uygula
Build sonrası uygulamada şu akışları elle test et, her birinin sonucunu raporla:
- [ ] Giriş / OTP doğrulama akışı
- [ ] Firebase push notification alma (varsa)
- [ ] API çağrıları (backend ile network isteği) — response parse doğru mu
- [ ] Dekont/görsel yükleme, kamera veya galeri erişimi (varsa)
- [ ] Uygulama kapat-aç sonrası local storage / SharedPreferences verisi kayboldu mu
- [ ] Herhangi bir crash veya "ClassNotFoundException" / "NoSuchMethodError" log'u var mı (`adb logcat` ile kontrol)

### 7. Sorun çıkarsa
Eğer belirli bir ekranda crash oluşursa, `adb logcat` çıktısındaki `ClassNotFoundException`, `NoSuchMethodError` veya `NoSuchFieldError` hatalarını yakala, hatada geçen sınıf/paket adını proguard-rules.pro'ya spesifik `-keep` kuralı olarak ekle (genel/kapsayıcı keep kuralları EKLEME, optimizasyon skorunu geri düşürür — sadece crash veren spesifik sınıfı koru).

## Kısıtlamalar
- Gereksiz/kapsayıcı `-keep class ** { *; }` gibi kurallar EKLEME — bunlar optimizasyon skorunu sıfırlar.
- Debug build type'ında minify açma.
- Her değişiklikten sonra hangi dosyaları değiştirdiğini ve neden değiştirdiğini özetle.
- Emin olmadığın bir keep kuralı eklemeden önce, o kütüphanenin resmi dokümantasyonunda ProGuard/R8 talimatı olup olmadığını kontrol et, tahminle kural ekleme.
