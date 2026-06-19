# API Yazmadan Önce Planla

Bu kural her mesajda geçerlidir. Yeni bir API endpoint'i veya backend servisi
yazılmadan önce zorunlu kontrol adımlarını uygula.

---

## Tetiklenme

Şu ifadeler geçtiğinde bu kuralı uygula:
- "endpoint ekle / yaz / oluştur"
- "route ekle"
- "controller yaz"
- "API'ye bağla"
- "veri çek / gönder / kaydet"
- "backend'e ekle"

---

## Zorunlu Kontroller (koddan önce)

### 1. Benzer Endpoint Var mı?
Mevcut kod tabanında:
- Aynı veriyi döndüren başka bir endpoint var mı?
- Mevcut endpoint genişletilebilir mi, yeni endpoint açmak gerekiyor mu?

Eğer mevcut kodu okumadan bu soruya cevap veremiyorsan → önce ilgili dosyayı oku, tahmin etme.

### 2. Her İki Tarafı Birlikte Düşün

Endpoint yazılırken şunları aynı anda planla:
```
Backend:
  □ Route path ve method
  □ Request validation
  □ Prisma sorgusu
  □ Response şekli

Flutter:
  □ Dart model (fromJson/toJson)
  □ Repository metodu
  □ UseCase (gerekiyorsa)
  □ UI'da nasıl kullanılacak
```

Sadece backend yazıp "Flutter'ı sonra bağlarız" deme — kontrat şimdi netleşsin.

### 3. Error Handling Her İki Tarafta

Backend'de:
```javascript
// Her endpoint try/catch ile sarılmalı
try {
  // ...
} catch (error) {
  res.status(500).json({ success: false, message: error.message });
}
```

Flutter'da:
```dart
// Repository'de exception fırlat, UI'da yakala
try {
  final result = await repository.fetchXxx();
} catch (e) {
  // State'e hata yansıt — print ile geçme
}
```

**Kural:** Backend'de hata yönetimi yoksa Flutter tarafını da yazma — önce backend'i tamamla.

---

## Kısayol Yasağı

Şu "kısayolları" kullanma:

| Kısayol | Neden Yanlış |
|---------|-------------|
| `any` tipi Dart'ta | Tip güvenliği kaybolur |
| `dynamic` fromJson dönüşü | Parse hatası runtime'a kaçar |
| Hardcoded URL | Ortam değişkeni olmalı |
| `print()` ile hata yönetimi | Üretimde iz bırakmaz |
| Mock data bırakma | Gerçek entegrasyon gecikir |

---

## Raporlama

Her endpoint tamamlandığında şunu sun:

```
✅ Endpoint tamamlandı: [METHOD] /path

Backend:
  - Dosya: src/routes/...
  - Validasyon: Evet/Hayır
  - Hata yönetimi: Evet/Hayır

Flutter:
  - Model: lib/.../model.dart
  - Repository metodu: fetchXxx()
  - Bağlantı test edilmeli: Evet

Kalan adımlar:
  - [ ] Migration çalıştır (schema değiştiyse)
  - [ ] Postman/test ile doğrula
  - [ ] Flutter'da bağlantıyı test et
```
