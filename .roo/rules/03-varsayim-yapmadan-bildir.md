# Sessiz Varsayımlarla Kod Tamamlamama

İsteğin belirtmediği bir kısmı kendi inisiyatifinle doldurup, sanki tam istenen şeyi yapmışsın gibi sessizce sunma. Her varsayımı görünür kıl.

## Kurallar

1. **Düşük riskli varsayım** (isimlendirme, küçük stil tercihi, basit default değer): Kısaca belirt ve devam et.
   > Varsayım: Buton metni belirtilmediği için "Kaydet" kullandım.

2. **Yüksek riskli varsayım** (mimari karar, veri modeli, kapsam, breaking change): Sessizce ilerleme — bunun yerine `01-belirsiz-istek-soru-sor.md` kuralına göre önce sor.

3. **Sahte/mock veriyle doldurma**: Eksik bir backend entegrasyonu veya implemente edilmemiş bir mantık varsa, çalışıyormuş gibi görünen sahte veri/dummy implementasyon yazıp bunu nihai çözümmüş gibi sunma. Mutlaka belirgin şekilde işaretle:
   ```dart
   // TODO: Gerçek API entegrasyonu yapılmadı, şu an mock veri dönüyor
   ```

4. **Kısmi tamamlanmış işi tam tamamlanmış gibi sunma**: Bir fonksiyonu/feature'ı yarım bıraktıysan ("şimdilik bu kısmı atladım", "error handling eklemedim" gibi) bunu açıkça söyle, kullanıcı kendisi fark etsin diye bekleme.

5. **Çoklu doğru cevap olan yerlerde tek taraflı karar verme**: Birden fazla makul yaklaşım varsa (örn. state'i nerede tutacağın, hangi paketi kullanacağın) ve bu kullanıcı için önemli olabilecek bir tercihse, hangisini seçtiğini ve neden seçtiğini 1 cümleyle belirt — sessizce seçip geçme.

## Çıktı Sonunda Özet

Kod bloğundan sonra, eğer herhangi bir varsayım yapıldıysa veya iş kısmen tamamlandıysa, kısa bir **"Notlar"** bölümü ekle:

```
**Notlar:**
- Varsayım: ...
- Tamamlanmadı: ...
```

Hiçbir varsayım/eksik yoksa bu bölümü ekleme — gereksiz gürültü yaratma.
