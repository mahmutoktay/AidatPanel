---
name: flutter-refactoring
description: Flutter/Dart kodunu refactor ederken kullan. Kullanıcı "bu kodu temizle", "refactor et", "bu widget'ı böl", "kod tekrarını azalt", "bu sınıfı sadeleştir" gibi bir istekte bulunduğunda bu beceriyi kullan.
---

# Flutter/Dart Refactoring Rehberi

## Temel Kural

Refactor sırasında davranış değişmemeli — sadece yapı iyileşmeli. Refactor öncesi/sonrası fonksiyonel olarak aynı sonucu üretmeli. Mevcut test varsa, refactor sonrası testlerin hâlâ geçerli olduğunu kullanıcıya hatırlat.

## Yaygın Refactor Kalıpları

### Extract Widget
`build()` metodu 80+ satır olduğunda veya aynı widget yapısı 2+ yerde tekrarlandığında, ayrı bir `StatelessWidget`/`StatefulWidget` sınıfına çıkar.

```dart
// Önce: build() içinde gömülü
Widget build(BuildContext context) {
  return Column(children: [
    Container(/* 20 satır karmaşık widget */),
  ]);
}

// Sonra: ayrı widget
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(/* aynı 20 satır */);
  }
}
```

### Extract Method
Bir metod içinde birden fazla mantıksal blok varsa, her birini isimli bir özel metoda çıkar (kod okurken "ne yaptığı" isimden anlaşılsın).

### const Constructor Ekleme
Statik/sabit widget ağaçlarına `const` ekle — gereksiz rebuild'i önler. Refactor sırasında bunu tara ve ekle.

### Nested Callback → async/await
İç içe `.then()` zincirlerini `async/await` ile düzleştir, okunabilirliği artır.

### God Widget/Class Bölme
500+ satırlık bir widget/sınıf birden fazla sorumluluk taşıyorsa (örn. hem network hem UI hem validation), Single Responsibility prensibine göre böl — gerekirse Clean Architecture katmanlarına dağıt (bkz. `flutter-clean-architecture-planning` becerisi).

### Magic Number/String Temizliği
Kod içine gömülü sabit değerleri (renk kodu, boşluk değeri, string literal) isimli sabitlere veya tema/sabitler dosyasına taşı.

## Refactor Süreci

1. Mevcut davranışı kısaca özetle ("şu an bu widget şunu yapıyor")
2. Hangi kalıbın uygulanacağını söyle ve neden (1-2 cümle)
3. Diff şeklinde göster — sessizce tüm dosyayı yeniden yazma, değişen kısımları net belirt
4. Davranış değişikliği olup olmadığını açıkça belirt (olmamalı, ama varsa mutlaka uyar)

## Kaçınılması Gerekenler

- Tek seferde çok fazla şeyi birden değiştirmek — büyük refactor'leri adımlara böl
- Davranışı sessizce değiştiren "refactor" (örn. edge case handling'i kaybetmek)
- Gereksiz yeniden adlandırma (değişken/metod isimlerini sebepsiz değiştirmek, diff gürültüsü yaratır)
