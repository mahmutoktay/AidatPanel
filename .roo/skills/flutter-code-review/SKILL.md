---
name: flutter-code-review
description: Flutter/Dart kodu incelerken kullan. Kullanıcı "bu kodu incele", "code review yap", "bu PR'ı gözden geçir", "bu dosyayı/widget'ı kontrol et", "bunu beğendin mi" gibi bir istekte bulunduğunda veya yeni yazılmış/değiştirilmiş Dart kodunun kalitesini değerlendirmesi gerektiğinde bu beceriyi kullan.
---

# Flutter/Dart Kod İnceleme Kontrol Listesi

İncelemeyi şu kategorilere göre yap ve bulguları kategori başlıkları altında, dosya:satır referansıyla listele.

## 1. Mimari / Katman İhlalleri
- Domain katmanında Flutter/HTTP importu var mı?
- Widget içinde doğrudan business logic / API çağrısı var mı?
- Model (DTO) doğrudan UI'da kullanılıyor mu (Entity'ye map edilmeden)?

## 2. State Management
- Kullanılan araç (Bloc/Cubit/Riverpod/Provider/GetX) projenin geri kalanıyla tutarlı mı?
- Gereksiz `setState` çağrıları var mı (zaten state management aracı varken)?
- State sınıfları immutable mı (Equatable/freezed kullanımı)?

## 3. Performans
- `const` constructor kullanılabilecek yerlerde kullanılmamış mı?
- `build()` metodu içinde ağır işlem (liste filtreleme, sıralama, yeni obje oluşturma) yapılıyor mu?
- `ListView.builder` yerine `ListView` + `children` ile büyük liste mi render ediliyor?
- Gereksiz pahalı widget'lar mı kullanılmış (`Opacity`, gereksiz `ClipRRect` vb.)?

## 4. Null Safety & Hata Yönetimi
- `!` (null check operator) gereksiz/riskli yerlerde mi kullanılmış?
- `late` değişkenler güvenli mi başlatılıyor?
- Hata yönetimi var mı (try/catch, Either<Failure, T>, Result tipi)? Yoksa sessizce yutulan hata var mı?

## 5. Async/Stream Yönetimi
- `await` unutulmuş `Future` var mı (fire-and-forget riski)?
- `StreamController`, `AnimationController`, `TextEditingController`, listener'lar `dispose()` içinde kapatılıyor mu?
- `setState` çağrısı widget unmount olduktan sonra (`mounted` kontrolü olmadan) yapılıyor mu?

## 6. Kod Stili / Okunabilirlik
- Effective Dart isimlendirme kurallarına uyuluyor mu (UpperCamelCase sınıf, lowerCamelCase metod/değişken)?
- Widget ağacı çok derin mi (3+ seviye nested) — extract widget gerekir mi?
- Tekrar eden kod bloğu var mı (extract method/widget önerisi)?

## 7. Test Edilebilirlik
- UseCase/Repository mock'lanabilir mi (interface üzerinden mi çağrılıyor)?
- Widget test'i kolay yazılabilir mi (key'ler, finder'lar için uygun yapı var mı)?

## Çıktı Formatı

Bulguları önem sırasına göre 3 gruba ayır:

**🔴 Kritik** (bug'a, crash'e, memory leak'e yol açabilir)
**🟡 Öneri** (mimari/performans iyileştirmesi)
**🔵 Stil** (isimlendirme, format, küçük temizlik)

Her bulgu için: `dosya.dart:satır` — sorun açıklaması — önerilen düzeltme (kısa kod örneğiyle).

Genel kod tekrar yazımı önerme; sadece somut, satır bazlı geri bildirim ver.
