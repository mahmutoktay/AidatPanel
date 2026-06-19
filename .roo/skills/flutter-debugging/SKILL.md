---
name: flutter-debugging
description: Flutter/Dart hatalarını ayıklarken kullan. Kullanıcı "bu hatayı çöz", "neden çalışmıyor", "exception alıyorum", "crash oluyor", "widget render olmuyor", "state güncellenmiyor", "kırmızı ekran (red screen) hatası" gibi bir sorunla karşılaştığında bu beceriyi kullan.
---

# Flutter/Dart Debug Süreci

## Sistematik Yaklaşım

1. **Tam stack trace'i oku** — sadece son satırı değil, hatanın hangi widget/satırdan geldiğini bul.
2. **Hatayı yeniden üretilebilir hale getir** — hangi adımda, hangi state'te oluşuyor?
3. **Kök neden hipotezi kur** — düzeltmeden önce neden olduğunu açıkla, sonra minimal fix uygula.
4. Fix'ten sonra yan etkisi olabilecek başka yerleri kontrol et (aynı pattern başka yerde de var mı?).

## Sık Görülen Flutter Hataları ve Kök Nedenleri

### "RenderFlex overflowed by X pixels"
- Sebep: Row/Column içinde sabit boyutlu içerik mevcut alana sığmıyor.
- Çözüm: `Expanded`/`Flexible` sar, ya da `SingleChildScrollView` ekle, ya da içeriği `Wrap` ile sarmalandır.

### "setState() called after dispose()"
- Sebep: Async işlem tamamlandığında widget artık ağaçta değil.
- Çözüm: Async callback içinde `if (!mounted) return;` kontrolü ekle.

### "Null check operator used on a null value"
- Sebep: `!` ile zorla null olmayan kabul edilen bir değer aslında null.
- Çözüm: `!` kullanılan yeri bul, kaynağın (API response, controller, provider) neden null döndüğünü incele; `?? defaultValue` veya doğru null kontrolüyle değiştir.

### "LateInitializationError: Field has not been initialized"
- Sebep: `late` değişken kullanılmadan önce set edilmemiş.
- Çözüm: Başlatma sırasını kontrol et (örn. `initState` içinde mi set ediliyor, yoksa controller `build`'den önce mi çağrılıyor?).

### "Looking up a deactivated widget's ancestor is unsafe"
- Sebep: `context` widget dispose olduktan sonra kullanılıyor (genelde async callback içinde `Navigator.of(context)` veya `Theme.of(context)`).
- Çözüm: Async işlemden önce gereken context-bağımlı referansları al, ya da `mounted` kontrolü ekle.

### State management'a özgü sorunlar
- **Bloc/Cubit emit etmiyor**: `emit` çağrısının `isClosed` durumunda olup olmadığını, event handler'ın doğru kayıtlı olup olmadığını kontrol et.
- **Riverpod provider güncellenmiyor**: `ref.watch` yerine yanlışlıkla `ref.read` kullanılmış olabilir (rebuild tetiklenmez).
- **Provider/setState ile UI güncellenmiyor**: `notifyListeners()` çağrılıyor mu, `Consumer`/`context.watch` doğru yerde mi kullanılmış kontrol et.

## Araçlar

- `flutter run` çıktısındaki tam log'u iste (kırpılmış log yetersizdir)
- DevTools → Widget Inspector ile layout sorunlarını görsel incele
- DevTools → Performance sekmesi ile gereksiz rebuild'leri tespit et
- `debugPrint` ile (yeterli olmadığında) belirli noktalarda state izleme

## Çıktı Formatı

1. **Hipotez**: Hatanın kök nedeni ne (kısa)
2. **Kanıt**: Stack trace/kod içindeki hangi satır bu hipotezi destekliyor
3. **Minimal düzeltme**: Sadece gerekli değişiklik, gereksiz refactor ekleme
4. **Benzer riskler**: Aynı pattern projede başka yerde tekrarlanıyor mu (varsa belirt)
