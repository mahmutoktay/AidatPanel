---
name: flutter-documentation
description: Flutter/Dart projelerinde dokümantasyon yazarken veya güncellerken kullan. Kullanıcı "bunu dokümante et", "yorum satırları ekle", "README yaz/güncelle", "bu sınıfı/metodu açıkla" gibi bir istekte bulunduğunda bu beceriyi kullan.
---

# Flutter/Dart Dokümantasyon Standartları

## Dartdoc Yorum Formatı

Dart'ta dokümantasyon yorumları `///` ile yazılır (tek satır `//` değil). İlk cümle özet niteliğinde olmalı (Dartdoc tool'larında özet olarak gösterilir).

```dart
/// Kullanıcının profil bilgilerini sunucudan getirir.
///
/// [userId] boş olamaz. Kullanıcı bulunamazsa [UserNotFoundException]
/// fırlatılır.
///
/// Örnek:
/// ```dart
/// final user = await getUser('123');
/// ```
Future<User> getUser(String userId) async { ... }
```

## Ne Dokümante Edilmeli

- **Public API'ler** (export edilen sınıf, metod, değişken) — mutlaka
- **Karmaşık/açık olmayan mantık** (neden böyle yapıldığı, "ne" değil "neden")
- **Widget'ların beklediği parametreler** (özellikle zorunlu/opsiyonel ayrımı, varsayılan davranış)
- Private (`_` ile başlayan) ve self-explanatory (örn. basit getter) kod için aşırı yorum ekleme — gürültü yaratır

## Sınıf Dokümantasyonu Şablonu

```dart
/// {sınıfın ne işe yaradığının kısa özeti}
///
/// {Varsa daha detaylı açıklama, kullanım senaryosu}
///
/// Bağlı olduğu katman: {Domain/Data/Presentation}
class ExampleUseCase {
  ...
}
```

## Widget Dokümantasyonu Şablonu

```dart
/// {Widget'ın görsel/işlevsel amacı}
///
/// Parametreler:
/// - [title]: Üstte gösterilecek başlık (zorunlu)
/// - [onTap]: null bırakılırsa widget tıklanamaz hale gelir
class CustomCard extends StatelessWidget {
  const CustomCard({required this.title, this.onTap, super.key});

  final String title;
  final VoidCallback? onTap;
  ...
}
```

## README Yapısı (Flutter Paketi/Modülü için)

```markdown
# Paket Adı

Kısa açıklama (1-2 cümle).

## Kurulum
## Kullanım
## Mimari Notlar (varsa, hangi katmana ait, bağımlılıkları)
## Test
```

## Mimari Karar Notu (ADR) Şablonu

Clean Architecture'da önemli bir mimari karar alındığında (örn. neden Riverpod yerine Bloc seçildi) kısa bir not:

```markdown
## Karar: {başlık}
**Tarih:** {tarih}
**Durum:** Kabul edildi / Tartışılıyor

**Bağlam:** Neden bu karara ihtiyaç duyuldu?
**Karar:** Ne seçildi?
**Sonuç:** Bunun artıları/eksileri neler?
```

## Kaçınılması Gerekenler

- Kodun ne yaptığını birebir tekrar eden yorumlar (`// i'yi 1 artır` gibi — kod zaten bunu söylüyor)
- Güncel olmayan/yanlış yorumları düzeltmeden bırakmak — kod değiştiyse yorumu da güncelle
- Aşırı uzun, paragraf paragraf yorumlar — özlü ve net ol
