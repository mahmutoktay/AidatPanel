# Belirsiz İsteklerde Önce Soru Sor

Bir istek eksik veya birden fazla şekilde yorumlanabilir olduğunda, tahmin yürütüp kod yazmaya başlama. Önce kısa, somut sorular sor.

## Ne Zaman Soru Sorulmalı

Aşağıdaki bilgilerden biri eksikse, kodlamaya başlamadan önce sor:

- **Veri modeli belirsizliği**: Hangi alanlar zorunlu/opsiyonel, tipleri ne (örn. "kullanıcı profili" istendi ama hangi alanları içereceği belirtilmedi)
- **Edge case davranışı**: Yükleniyor/hata/boş liste durumlarında UI ne göstermeli — istekte belirtilmemişse varsayma
- **Mimari/araç seçimi**: Projede birden fazla state management aracı varsa (örn. hem Bloc hem Provider kullanılmışsa) hangisinin kullanılacağı net değilse sor
- **Kapsam belirsizliği**: "Şunu ekle" gibi geniş bir istek, hangi ekranları/akışları etkileyeceği net değilse netleştir
- **API sözleşmesi**: Backend endpoint'inin request/response şekli net değilse, varsayımla mock yazmadan önce sor

## Ne Zaman SORMA (gereksiz sürtünme yaratma)

- İstek zaten yeterince detaylıysa veya tek bir mantıklı yorumu varsa
- Cevap, projenin mevcut konvansiyonlarından (kod stilinden, klasör yapısından) net şekilde çıkarılabiliyorsa — bu durumda varsayımı kısaca belirtip devam et, sormaya gerek yok
- Kullanıcı zaten "sen karar ver" / "nasıl uygun görüyorsan" demişse

## Soru Formatı

- En fazla 2-3 soru, numaralı/maddeli, kısa ve spesifik
- "Ne istersin?" gibi genel sorular yerine somut seçenekler sun: "A) X şekilde yapayım B) Y şekilde yapayım, hangisi?"
- Sorulara cevap gelmeden büyük yapısal kod (yeni dosya, yeni katman, schema değişikliği) yazmaya başlama; küçük/geri alınabilir adımlar için (örn. bir fonksiyonun gövdesi) bekletmeden devam edilebilir
