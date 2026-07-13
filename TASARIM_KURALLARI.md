# AidatPanel — Tasarım, İşlev ve Akış Kuralları

Bu doküman, uygulama genelinde tutarlılığı sağlamak için belirlenen kuralları içerir. 
Cursor'a **tüm projeyi tek seferde değil, modül modül** (örn. "sadece Binalar sekmesini 
bu kurallara göre incele") gözden geçirmesi için referans olarak verilmelidir. Her 
modül için önce PLAN MODUNDA çalış, planı incele, sonra uygula.

## 1. Veri Tekrarını Önle
- Aynı istatistik/bilgi (tahsilat oranı, daire sayısı, aidat tutarı vb.) birden fazla 
  ekranda tam detaylı şekilde TEKRARLANMAZ. Her bilginin bir "ana" gösterim yeri vardır 
  (örn. detay sayfası), liste/özet ekranlarda sadece minimal bir işaretçi bulunur.
- Liste kartları (bina, daire, işlem vb.) sadece tanımlayıcı bilgi içerir (isim, adres, 
  tutar). Detaylı istatistikler (tahsilat oranı, progress bar, "X/Y ödedi" gibi) SADECE 
  ilgili detay sayfasında/modalinde gösterilir.

## 2. Durum Bilgisi Her Zaman Otomatik Hesaplanır
- Aidat durumu (Ödendi / Bekliyor / Gecikmiş) elle set edilemez. "Gecikmiş" durumu 
  SADECE son ödeme tarihi + ödeme kaydına göre otomatik hesaplanır.
- Yöneticinin elle yapabileceği TEK aksiyon: bir kaydı "Ödendi" olarak işaretlemek 
  (dekont onayı veya elden ödeme manuel girişi).

## 3. Aksiyonlar İçin 3 Nokta Menüsü Kullanılmaz
- Sayfa/bina/kayıt bazlı aksiyonlar (Düzenle, Sil, Rapor İndir, Çoklu Seç vb.) 3 nokta 
  (overflow) menüsü yerine SABİT ALT ARAÇ ÇUBUĞU (bottom toolbar) içinde yer alır.
- Kayıt bazlı hızlı aksiyonlar (örn. ödeme alma) için TIKLA (detay modalı aç) + 
  KAYDIR (swipe, doğrudan aksiyon) ikisi birden desteklenir, aynı alt akışı kullanır.

## 4. Boş Daireler Tahsilat İstatistiklerine Dahil Edilmez
- Sakin atanmamış (boş) daireler için aidat kaydı OLUŞTURULMAZ.
- Boş daireler; aidat listelerinde, "Bekliyor/Gecikmiş" sayılarında, toplam 
  tutarlarda ve tahsilat oranı hesaplarında YER ALMAZ.
- Boş daire kartlarında sadece "Boş / Sakin atanmadı" durumu ve "Davet Et" aksiyonu 
  gösterilir, tahsilat/bakiye bilgisi gösterilmez.

## 5. Standart Özet Kartı: Bankacılık Tarzı
- Portföy/bina geneli özet gösterimlerinde standart format: "Toplanan / Beklenen" 
  tutar (büyük/bold + soluk), altında ince progress bar, altında gecikmiş sayısı 
  (kırmızı, minimal).
- Çok kutulu (3-6 kutulu) istatistik gridleri KULLANILMAZ, yerine bu tek kart 
  formatı kullanılır.
- İstisna: Aidatlar sekmesindeki Ödendi/Bekliyor/Gecikmiş 3'lü kartlar, aynı zamanda 
  TIKLANABİLİR HIZLI FİLTRE görevi görür (bkz. madde 9), bu nedenle korunur.

## 6. Bina/Site Seçimi: Aranabilir + Gruplu Bottom Sheet
- Bina/site seçici, basit dropdown yerine arama kutulu, siteler altında binaların 
  gruplandığı (collapsible), bağımsız binaların ayrı bölümde listelendiği bir 
  bottom sheet olarak tasarlanır.

## 7. Görünüm Modu Geçişleri: Segmented Pill Tab
- "Binalar / Siteler" gibi iki görünüm modu arasında geçiş dropdown İLE DEĞİL, 
  dolgulu (filled/pill) segmented tab control ile yapılır.

## 8. Ortak Bileşenler, Kod Tekrarı Yok
- Aynı görsel öğe (işlem/ödeme satırı, sayı grid seçici, step indicator vb.) birden 
  fazla ekranda kullanılıyorsa, TEK bir reusable widget olarak yazılır ve her yerde 
  aynısı kullanılır. Kopyala-yapıştır ile çoğaltılan varyantlar kabul edilmez.
- Aynı veri (örn. bir ödeme kaydı) farklı ekranlarda farklı alan setleriyle 
  gösterilmez — hangi ekranda gösterilirse gösterilsin aynı bilgi seti/aynı bileşen 
  kullanılır (ekrana özgü gizlenmesi gereken alanlar hariç, örn. sakin bazlı 
  listede isim tekrar gösterilmez çünkü zaten başlıkta var).

## 9. Sayı Girişleri: Grid Seçim
- Kat sayısı, daire sayısı gibi küçük aralıklı sayısal girişler klavye ile 
  YAZDIRILMAZ. Bunun yerine grid halinde seçenekler sunulur (örn. 1-15 arası), 
  bir değere tıklanınca otomatik ilerlenir. "Daha Fazla" seçeneği ile aralık 
  dışı manuel giriş desteklenir.

## 10. Wizard/Adım Adım Formlar
- Çok alanlı formlar (bina ekleme, site ekleme vb.) tek sayfa yerine adım adım 
  ilerleyen bir yapıda olur. Her adımda tek bir soru/alan grubu bulunur. Seçime 
  dayalı adımlarda (grid seçim gibi) seçim yapılır yapılmaz otomatik ilerlenir, 
  ekstra onay butonu istenmez.

## 11. Ekranlar Arası Bağlam (Context) Korunur
- Bir ekrandan başka bir ekrana geçişte (örn. Ana Sayfa'da seçili bina → Aidat 
  İşlem Geçmişi), mevcut seçim/bağlam parametre olarak taşınır. Hedef ekran kendi 
  başına farklı bir varsayılan (örn. alfabetik ilk öğe) SEÇMEZ.
- Alt ekranlarda yapılan geçici değişiklikler (örn. bina filtresini değiştirme) 
  üst ekranın durumunu ETKİLEMEZ (tek yönlü veri akışı).

## 12. Metin/Etiket Netliği
- Belirsiz, çift anlamlı veya teknik jargon içeren etiketler sadeleştirilir 
  (örn. "Hesap Sahibi / Alıcı Unvanı" → "Alıcı Adı"). Yeni bir ekran/form 
  yazılırken veya mevcut biri düzenlenirken bu tür ifadeler taranır ve 
  uygulanmadan önce raporlanır.

## 13. Buton Durum Geri Bildirimleri Layout Kaymasına Sebep Olmaz
- Buton metni/ikonu geçici olarak değiştiğinde (örn. "Kopyala" → "Kopyalandı" + 
  tik ikonu), buton genişliği SABİT kalır, geçiş yumuşak animasyonla olur, belirli 
  bir süre sonra otomatik eski haline döner.

## 14. Hint/Placeholder Metinleri Bağlama Uygun Olmalı
- Form alanlarındaki örnek/hint metinleri (placeholder), o alanın gerçek 
  kullanım bağlamına uygun olmalı. Örneğin bir alan tüm kullanıcılar için 
  ortak/sabit bir değer alacaksa, hint kişiye özel bir örnek İÇERMEMELİ 
  (örn. 'Daire 5' gibi tek bir sakine özel bir örnek, paylaşılan/sabit bir 
  alan için yanıltıcıdır).
- Yeni bir form alanı eklenirken veya mevcut biri düzenlenirken, hint 
  metninin alanın gerçek davranışını (sabit mi, kişiye özel mi, şablon mu) 
  doğru yansıttığı kontrol edilmeli.

---

## KULLANIM TALİMATI (Cursor için)
Bu dosyayı okuduktan sonra:
1. Bana hangi modülü/ekranı incelemem gerektiğini söyle (örn. "Binalar sekmesi", 
   "Sakinler modalleri", "Aidatlar sekmesi").
2. O modüldeki İLGİLİ dosyaları bul ve yukarıdaki 14 kuraldan hangilerinin ihlal 
   edildiğini listele (kod değişikliği YAPMADAN önce).
3. Her ihlal için: hangi dosya, hangi satır/bileşen, hangi kural, önerilen düzeltme.
4. Onay aldıktan sonra uygula, modül tamamlanınca bir sonraki modüle geç.
