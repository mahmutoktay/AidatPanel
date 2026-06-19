# Var Olmayan API/Paket Uydurma (Halüsinasyon Önleme)

Emin olmadığın bir API, metod, parametre veya paket hakkında kendinden emin görünerek yanlış bilgi üretme. Belirsizlik varsa bunu açıkça söyle.

## Kurallar

1. **Bilmediğini bil**: Bir Flutter/Dart sınıfının, metodun veya parametrenin tam adından/imzasından emin değilsen, "bunu doğrulamam gerekiyor" de — uydurma, "muhtemelen böyledir" diyerek kod yazma.

2. **Paket kullanmadan önce kontrol et**: pub.dev'den bir paket önerirken/kullanırken:
   - Paket adının doğru yazıldığından emin ol
   - Web search aracı varsa, paketin güncel sürümünü ve API'sini doğrula
   - Doğrulayamıyorsan kullanıcıya açıkça söyle: "Bu paketin güncel API'sini doğrulayamadım, `pub.dev/packages/{paket}` üzerinden kontrol etmeni öneririm"

3. **Proje koduna referans verirken oku, tahmin etme**: Mevcut bir sınıfı/metodu/provider'ı kullanacaksan, ismine bakarak şeklini varsaymak yerine ilgili dosyayı gerçekten aç ve oku. Özellikle:
   - Bir Repository/UseCase çağırmadan önce gerçek metod imzasını kontrol et
   - Bir model sınıfının alanlarını varsaymadan önce dosyasını oku

4. **Sürüm farkındalığı**: Flutter/Dart SDK'sının yeni sürümlerinde eklenen/kaldırılan API'ler hakkında konuşurken, bilginin ne kadar güncel olduğundan emin değilsen bunu belirt ("bu API son sürümlerde değişmiş olabilir, projenin `pubspec.yaml`'ındaki Flutter/Dart sürümünü kontrol edelim").

5. **Hata mesajı/stack trace uydurma**: Bir hatayı analiz ederken gerçekte görmediğin bir stack trace veya log satırı varmış gibi davranma; kullanıcıdan tam çıktıyı iste.

## Format

Emin olmadığın bir noktayı belirtirken şu şekilde ayır:
> ⚠️ Doğrulanmadı: {ne hakkında emin değilsin} — {nasıl doğrulanabilir}
