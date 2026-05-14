# Dekont sistemi — uygulama rehberi ve plan

> **Amaç:** AidatPanel backend’ine dekont (PDF/görüntü) yükleme, metin çıkarma, banka şablonlarına göre parse, Due ile eşleştirme ve ödeme/borç güncellemesi eklenmesi.  
> **Kapsam notu:** Bu belge **yalnızca tasarım ve yol haritasıdır**; uygulama sırasında mevcut **klasör adları, dosya isimlendirme ve Express/Prisma kalıpları** korunur (`backend/src/middlewares/`, `backend/src/services/`, `backend/index.js` vb.).

---

## 1. Mevcut ana proje ile hizalama

Aşağıdaki yapı **değiştirilmeden** kullanılır; yeni kod aynı kalıplara eklenir.

| Konu | Ana projedeki karşılık |
|------|-------------------------|
| Giriş noktası | `backend/index.js` — `app.use("/api/v1/...", router)` |
| Rotalar | `backend/src/routes/*.js` |
| Controller’lar | `backend/src/controllers/*.js` |
| Servisler | `backend/src/services/*.js` |
| Middleware | `backend/src/middlewares/*.js` (çoğul; `middleware` değil) |
| Doğrulama | `backend/src/middlewares/validate.js` + mevcut `zod` şemaları |
| Auth / rol | `authMiddleware.js`, `roleMiddleware.js` |
| ORM | `backend/prisma/schema.prisma` + `prisma migrate` |
| Aidat iş mantığı | `backend/src/services/dueService.js` — dekont sonrası güncellemeler mümkün olduğunca burada veya onu çağıran ince bir serviste toplanır (tekrarlı Due mantığı yazılmaz). |

---

## 2. Özellik özeti (iş ihtiyacı)

- Flutter’dan gelen **PDF** veya **görüntü** sunucuda işlenir.
- Metin çıkarımı: **PDF** için `pdf-parse` (veya eşdeğeri; güvenlik güncellemelerine göre proje kararı), **görüntü** için `tesseract.js` (veya barındırma koşullarına göre dış OCR servisi — uzun vadede VPS yükü için değerlendirme maddesi).
- Türk bankaları dekontlarından hedef alanlar: gönderen adı, alıcı adı, alıcı IBAN, alıcı hesap numarası, tutar, tarih, banka adı, sorgu/referans no.
- Parse sonucu ve ham metin **veritabanında** saklanır; dosya **diskte** tutulur.
- **IBAN**, hesap numarası, banka veya gönderen adı** ile ilgili **Due** kaydı eşleştirilir (öncelik kuralları aşağıda).
- **Ödeme:** Tutar, hedef Due tutarına eşitse `PAID` + `paidAt` (dekont tarihi). Kısmi ödeme için **uzun vadeli sürdürülebilir model** aşağıdaki Prisma bölümünde tanımlanır (tek `Due.amount` üzerinde sessiz oynama yerine izlenebilir kayıt).

---

## 3. Banka / şablon değişikliklerine hızlı adaptasyon (sürdürülebilirlik)

Tek dev bir “regex dosyası” yerine **katmanlı ve genişletilebilir** yapı önerilir; bakım ve code review kolaylaşır.

### 3.1 Klasör stratejisi (öneri)

Tüm banka/şablon mantığı **tek bir kök altında** toplanır; derin hiyerarşi yok (2–3 seviye):

```
backend/src/config/dekont/
  index.js                 # Dışarı açılan tek giriş: registry + varsayılan sıra
  normalizeText.js         # OCR/PDF gürültüsü: boşluk, TR harf, tutar normalizasyonu (bankadan bağımsız)
  registry.js              # Hangi profil sırasıyla denenecek (priority listesi)
  profiles/
    _base.js               # Ortak yardımcılar (tutar/IBAN/tarih parse yardımcıları)
    generic-placeholder.js # MVP / bilinmeyen banka
    ziraat-v1.js           # Örnek: bir banka = bir dosya (veya aile başına bir dosya)
    garanti-v1.js
    ...
```

- **Yeni banka / yeni şablon:** `profiles/` altına yeni dosya + `registry.js` içinde sıraya ekleme. Mümkünse dosya adı: `{bankaKisaAd}-v{n}.js` (şablon değişince `v2` ile yan yana yaşatılabilir).
- **A/B ve geri alma:** Eski profil dosyası silinmeden durur; registry’de öncelik değiştirilir.
- **Denetim:** Her başarılı/başarısız parse için DB’de `patternProfileId` veya `parserVersion` alanı tutulur (hangi kural seti kullanıldı).

### 3.2 Regex yerine / regex ile birlikte

- Kısa vadede **regex + satır bazlı kurallar** yeterli olabilir.
- Orta vadede aynı profil içinde **“satır etiketi → alan”** eşlemesi (ör. `referans:` sonrası token) regex’leri küçük tutar.
- İleride JSON tabanlı “kural seti” (repo dışı deploy ile güncellenebilir) isteğe bağlı genişleme olarak not edilir; **ilk uygulamada** kod içi `profiles/` yeterli ve tip güvenliği korunur.

---

## 4. Dosya depolama — basit ve bakımı kolay yapı

**Kök:** `backend/files/dekonts/` (veya `.env` ile `DEKONT_STORAGE_ROOT` — tek değişkenle taşınabilirlik).

**Önerilen göreli yol şablonu** (çok derin olmayan, ID ile listelemesi kolay):

```text
files/dekonts/{buildingId}/{YYYY}/{MM}/{dekontId}_{slug-orijinal-ad}.{ext}
```

- **buildingId:** Liste/filtre ve yedekleme için doğal bölüm.
- **YYYY/MM:** klasör başına dosya sayısı kontrolü; tam günlük klasör (`.../2026/05/14/`) derinliği artırır — istenirse sadece `YYYY-MM` yeterli.
- **Dosya adı:** Depoda **orijinal ad güvenilir değil**; UUID (`dekontId`) önek zorunlu, orijinal ad URL-safe kısaltılmış eklenebilir.
- **`.gitignore`:** `files/dekonts/` veya tüm `files/` repo dışı kalır; üretimde yedek stratejisi ayrı tanımlanır.

**İndirme:** `GET /api/v1/dekont/:id/download` (veya file URL) — sadece yetkili kullanıcı; mümkünse kısa ömürlü imzalı link (ileri faz).

---

## 5. Güvenlik (uzun vade)

- **Boyut limiti** ve **MIME + magic byte** kontrolü (sadece uzantıya güvenilmez).
- **Rate limit:** Upload için genel API limitinden sıkı veya ayrı limit (mevcut `rateLimitMiddleware.js` ile uyumlu).
- **KVKK:** Dekont PII içerir; erişim yalnızca ilgili sakin / bina yöneticisi; silme politikası `User.deletedAt` ile uyumlu düşünülür.
- **İsteğe bağlı:** ClamAV veya benzeri (VPS kapasitesine göre roadmap).

---

## 6. Prisma — eksiklerin tamamlanması (uygulama anında)

Aşağıdaki modeller **bu belgeye göre** `schema.prisma` ve migration ile eklenecek; mevcut modellere dokunmadan ilişki kurulabilir.

### 6.1 Enum’lar

```prisma
enum DekontStatus {
  RECEIVED           // dosya alındı
  EXTRACTING         // metin çıkarılıyor
  EXTRACT_FAILED
  PARSED             // yapısal alanlar doldu
  PARSE_LOW_CONFIDENCE
  MATCHING
  MATCHED
  MATCH_AMBIGUOUS    // birden fazla aday Due
  UNMATCHED
  PAYMENT_APPLIED
  PAYMENT_PARTIAL      // kısmi ödeme kaydı oluşturuldu
  REJECTED             // politika / doğrulama reddi
  NEEDS_MANAGER_REVIEW
}

enum DekontSource {
  RESIDENT_UPLOAD
  MANAGER_UPLOAD
}
```

`NotificationType` genişletmesi (push + uygulama içi bildirim uyumu):

```prisma
// Mevcut enum'a eklenecek değer örneği:
// DEKONT_RECEIVED
// DEKONT_MATCHED
// DEKONT_PAYMENT_APPLIED
// DEKONT_NEEDS_REVIEW
```

(Flutter / `FLUTTER-BACKEND.md` ile payload sözleşmesi aynı sprintte netleştirilir.)

### 6.2 `Dekont` modeli (öneri alanlar)

- `id` (uuid), `buildingId` (veya eşleşmeden önce null — tercihe göre; pratikte upload sırasında kullanıcı bağlamından `buildingId` zorunlu kılınabilir)
- `apartmentId` (opsiyonel — biliniyorsa)
- `uploadedById` → `User`
- `dueId` (opsiyonel — eşleşince)
- `status` → `DekontStatus`
- `source` → `DekontSource`
- `storedPath` (göreli yol), `originalFilename`, `mimeType`, `sizeBytes`
- `rawText` (text, uzun olabilir — gerekirse ayrı tablo veya object storage + özet)
- `parsedJson` (`Json`) — çıkarılan alanlar + güven skorları
- `patternProfileId` veya `parserProfile` (`String`) — hangi profil kullanıldı
- `parseError` (`String?`)
- `createdAt`, `updatedAt`

İndeks önerileri: `[buildingId, createdAt]`, `[uploadedById]`, `[status]`.

### 6.3 Kısmi ödeme — sürdürülebilir kayıt (`DuePayment` veya eşdeğeri)

Tek `Due` satırında tutarı “sessizce azaltmak” raporlama ve denetimi zorlaştırır. Öneri:

```prisma
model DuePayment {
  id        String   @id @default(uuid())
  dueId     String
  due       Due      @relation(fields: [dueId], references: [id], onDelete: Cascade)
  dekontId  String?
  dekont    Dekont?  @relation(fields: [dekontId], references: [id])
  amount    Decimal  @db.Decimal(12, 2)
  paidAt    DateTime // dekonttaki işlem tarihi
  currency  String   @default("TRY")
  note      String?
  createdAt DateTime @default(now())

  @@index([dueId])
  @@index([dekontId])
}
```

- **Tam ödeme:** `DuePayment` toplamı = Due tutarı → `Due.status = PAID`, `Due.paidAt` set.
- **Kısmi:** `DuePayment` eklenir; `Due.amount` **sabit kalabilir** (borç = amount − sum(payments)) veya iş kuralı olarak `amount` sadece “dönem borcu” olarak kalıp ödemeler ayrı toplanır — **tek kaynak:** raporlama `amount` ve `DuePayment` toplamından türetilir.
- `Due` modeline `dekonts Dekont[]` ve `payments DuePayment[]` ilişkileri eklenir (`Dekont` tarafında `dueId` + isteğe `payments`).

> Uygulama ekibi: Mevcut mobil ve yönetici ekranları “kalan borç” nasıl gösterecek netleştirilir; API yanıtlarında `remainingAmount` hesaplanabilir.

---

## 7. npm bağımlılıkları (referans)

| Paket | Amaç |
|--------|------|
| `multer` | multipart upload, bellek/disk limiti |
| `pdf-parse` | PDF metin çıkarımı |
| `tesseract.js` | Görüntü OCR (alternatif: dış API) |
| İsteğe `file-type` veya `mmmagic` | Magic byte ile gerçek tip |
| İsteğe `sanitize-filename` | Güvenli dosya adı |

Versiyonlar uygulama sırasında `package.json` ile kilitlenir.

---

## 8. Oluşturulacak dosyalar (ana proje yollarıyla birebir)

| Dosya | Görev |
|--------|--------|
| `backend/src/config/dekont/` | Bölüm 3 — registry, normalize, `profiles/*` |
| `backend/src/services/dekontParserService.js` | MIME’e göre extract + profil zinciri |
| `backend/src/services/dekontMatcherService.js` | Parse çıktısı → aday Due’lar, skor / belirsizlik |
| `backend/src/services/dekontPaymentService.js` | Transaction: `DuePayment` + Due durumu; `dueService` ile uyum |
| `backend/src/services/dekontWorkflowService.js` | Upload → çıkarım → parse → eşleştirme → ödeme orkestrasyonu |
| `backend/src/services/dekontManagerService.js` | Yönetici `PATCH`: aidat bağlama / red / parse tutarıyla ödeme uygulama |
| `backend/src/middlewares/rateLimitMiddleware.js` | `dekontUploadLimiter` — yükleme için ek limit (`DEKONT_UPLOAD_RATE_LIMIT_MAX`) |
| `backend/src/services/dekontNotificationBridge.js` | **Push/bildirim hazır köprü** — senaryo sabitleri, `buildDekontPushDataPayload`, `scheduleDekontNotification`; bildirim ekibi `registerDekontNotificationSink` ile bağlar (bkz. `resources/DEKONT-BILDIRIM-KOPRU.md`) |
| `backend/src/controllers/dekontController.js` | HTTP |
| `backend/src/middlewares/dekontUploadMiddleware.js` | multer + limit + tip |
| `backend/src/routes/dekontRoutes.js` | Router |
| `backend/src/middlewares/validate.js` (genişletme) | Upload ve query şemaları |

`validators/` altında `dekontValidator.js` açılması mevcut `authValidator` kalıbı ile uyumludur.

---

## 9. API uçları

| Metot | Yol | Not |
|--------|-----|-----|
| POST | `/api/v1/dekont/upload` | multipart; parse + match + ödeme (politikaya göre otomatik veya `NEEDS_MANAGER_REVIEW`) |
| GET | `/api/v1/dekont` | Yönetici: bina filtresi, sayfalama (`buildingId` query) |
| GET | `/api/v1/dekont/:id` | Detay + ayrıştırılmış alanlar (yetki kontrolü) |
| GET | `/api/v1/dekont/:id/download` | Dosya indirme (sakin/yönetici) |
| PATCH | `/api/v1/dekont/:id` | JSON body (discriminated union `action`): **`reject`** — `{ "action": "reject", "reason"?: string }`; **`assign_due`** — `{ "action": "assign_due", "dueId": "uuid", "applyPayment"?: boolean }` (`applyPayment: true` ise `parsedJson.fields.amount` ile `DuePayment` + durum güncellenir; tutar yoksa 400). Tamamlanmış/kısmi ödenmiş dekontta 409. |

Mevcut API prefix’i: `/api/v1` (`index.js` ile aynı).

---

## 10. `index.js` router kaydı

```js
import dekontRoutes from "./src/routes/dekontRoutes.js";
// ...
app.use("/api/v1/dekont", dekontRoutes);
```

Sıra: `express.json()` sonrası; upload route’u kendi middleware’i ile `multipart` işler (JSON parser çakışması dikkat).

---

## 11. Push ve bildirim — hazır köprü (ekip entegrasyonu)

Push ve Notification listesi API’leri **henüz eklenmedi**; dekont kodu doğrudan FCM çağırmaz. Bunun yerine:

### 11.1 `dekontNotificationBridge.js`

- **`DEKONT_NOTIFICATION_SCENARIO`:** Tüm dekont yaşam döngüsü olayları tek yerde (UPLOAD_RECEIVED, MATCHED, PAYMENT_APPLIED, NEEDS_MANAGER_REVIEW, …).
- **`buildDekontPushDataPayload(...)`:** FCM `data` için düz **string** alanlar (`type`, `scenario`, `dekontId`, `dueId`, `buildingId`, `apartmentId`).
- **`scheduleDekontNotification(event)`:** Commit sonrası çağrılır; `setImmediate` ile **bloklamaz**; sink yoksa prod’da sessiz, dev’de `console.debug`.
- **`registerDekontNotificationSink(handler)`:** Bildirim ekibi bootstrap’te kaydeder; handler içinde Prisma `Notification` insert + FCM + isteğe kuyruk.

**Dekont geliştiricisi:** `dekontParserService` / `dekontMatcherService` / `dekontPaymentService` içinde anlamlı noktalarda yalnızca `scheduleDekontNotification` kullanır.

**Bildirim geliştiricisi:** `resources/DEKONT-BILDIRIM-KOPRU.md` dosyasına bakar; `NotificationType` enum genişletmesinde senaryo stringleriyle **aynı isimlendirme** kullanılır.

### 11.2 Diğer notlar

- **FCM token:** `PUT /me/fcm-token` mevcut; sink içinde kullanılır.
- **Payload sözleşmesi:** `MOBILE-TO-BACKEND.md` FCM `data` maddesi güncellendiğinde `buildDekontPushDataPayload` çıktısı ile hizalanır.
- **Uzun vade:** Yüksek hacimde sink yalnızca kuyruğa yazar; worker FCM gönderir.

---

## 12. Eşleştirme önceliği (öneri sıra)

1. Normalize **IBAN** ile daire/yönetici kayıtlarında IBAN varsa (şema genişlemesi gerekirse ayrı görev).
2. **Referans / açıklama** ile Due veya ödeme referansı eşleşmesi.
3. **Gönderen adı** + aynı binada tek aday Due (ay/yıl bağlamı upload isteğinde parametre ile verilebilir: `targetMonth`, `targetYear`).
4. Belirsiz → `MATCH_AMBIGUOUS` / `NEEDS_MANAGER_REVIEW`; otomatik ödeme uygulanmaz.

---

## 13. Test sırası (sıfırdan doğrulama)

1. Migration + boş upload (validation hataları).
2. Küçük PDF fixture → `PARSED` + placeholder profil.
3. PNG fixture → OCR yolu.
4. Eşleşen senaryo → `PAYMENT_APPLIED` + Due + DuePayment doğrulama.
5. Kısmi tutar → `DuePayment` + kalan borç hesabı.
6. Yetkisiz kullanıcı ile `403` / yanlış `buildingId`.
7. İndirme endpoint’i yetki testi.

---

## 14. Tamamlandıktan sonra — Flutter

Proje köküne **`FLUTTER-DEKONT-REHBERI.md`** eklenecek; içerik:

- Android share intent (`AndroidManifest.xml`)
- iOS Share Extension ve `Info.plist`
- `receive_sharing_intent` veya `share_handler`
- Dio ile `multipart/form-data` upload
- UI: loading / hata / başarı
- Yönetici dekont listesi
- Android ve iOS ayrı test adımları

Mobil repo ayrıysa aynı dosya bu repoda “sözleşme” olarak kalır veya mobil repoya kopyalanır.

---

## 15. Uygulama fazları (özet checklist)

1. Prisma: `Dekont`, `DekontStatus`, `DekontSource`, `DuePayment`, ilişkiler, `NotificationType` genişlemesi.  
2. Disk kökü + `.gitignore` + env.  
3. `dekontStorageService` + upload middleware.  
4. `config/dekont` registry + placeholder profiller.  
5. Parser → Matcher → Payment (transaction).  
6. REST + `index.js` kayıt.  
7. Dekont akışında `scheduleDekontNotification` çağrılarını senaryolara göre ekle; **FCM / Prisma Notification** bildirim ekibinin `registerDekontNotificationSink` implementasyonu ile tamamlanır (`resources/DEKONT-BILDIRIM-KOPRU.md`).  
8. Test + `FLUTTER-DEKONT-REHBERI.md`.

---

## 16. Uygulanan backend sistemi (mevcut kod — özet)

Bu bölüm, repoda **şu an çalışır durumda** olan dekont akışını teknik ve operasyonel olarak özetler. Tasarım hedefleri §1–§15 ile aynıdır; farklar burada not edilir.

### 16.1 Bileşenler ve dosya haritası

| Katman | Dosya / klasör |
|--------|------------------|
| Şema + migration | `backend/prisma/schema.prisma`, `backend/prisma/migrations/20260514170000_dekont_system/migration.sql` |
| HTTP girişi | `backend/index.js` → `app.use("/api/v1/dekont", dekontRoutes)` |
| Rotalar | `backend/src/routes/dekontRoutes.js` |
| Controller | `backend/src/controllers/dekontController.js` |
| Doğrulama | `backend/src/validators/dekontValidator.js` |
| Upload (multer) | `backend/src/middlewares/dekontUploadMiddleware.js` |
| Orkestrasyon | `backend/src/services/dekontWorkflowService.js` |
| Metin çıkarımı | `backend/src/services/dekontParserService.js` (PDF: `pdf-parse`, görüntü: `tesseract.js`) |
| Parse profilleri | `backend/src/config/dekont/` (`normalizeText.js`, `registry.js`, `profiles/generic-placeholder.js`, `profiles/README.md`) |
| Eşleştirme | `backend/src/services/dekontMatcherService.js` |
| Ödeme | `backend/src/services/dekontPaymentService.js` (`DuePayment` + `Due` güncelleme, transaction) |
| Yönetici müdahalesi | `backend/src/services/dekontManagerService.js` (`PATCH`) |
| Yetki / liste | `backend/src/services/dekontAccessService.js` |
| Disk | `backend/src/services/dekontStorageService.js` — kök: `DEKONT_STORAGE_ROOT` veya `backend/files/dekonts/` |
| Push köprüsü | `backend/src/services/dekontNotificationBridge.js` |
| Genel limit | `backend/src/middlewares/rateLimitMiddleware.js` içinde `apiLimiter` (mevcut) |
| Dekont yükleme limiti | `dekontUploadLimiter` — sadece `POST /upload` (§16.4) |
| Hata / Multer | `backend/src/middlewares/errorHandler.js` |
| Bağımlılıklar | `backend/package.json`: `multer`, `pdf-parse`, `tesseract.js` |
| Mobil sözleşme notu | `resources/MOBILE-TO-BACKEND.md` §3.9–§3.10 |
| Bildirim entegrasyon rehberi | `resources/DEKONT-BILDIRIM-KOPRU.md` |

### 16.2 API uçları (özet)

| Metot | Yol | Kim |
|--------|-----|-----|
| POST | `/api/v1/dekont/upload` | JWT; sakin veya yönetici |
| GET | `/api/v1/dekont?buildingId=&page=&limit=` | JWT, yönetici |
| PATCH | `/api/v1/dekont/:id` | JWT, yönetici |
| GET | `/api/v1/dekont/:id` | JWT; sakin (kendi / kendi dairesi) veya yönetici |
| GET | `/api/v1/dekont/:id/download` | Aynı yetki kuralı |

**Upload form (multipart):** alan adı `file`. İsteğe bağlı: `buildingId`, `apartmentId`, `targetMonth`, `targetYear` (çoğunlukla string; Zod coerce).

**PATCH JSON gövdesi:** `z.discriminatedUnion("action", …)`  
- `{ "action": "reject", "reason"?: "..." }`  
- `{ "action": "assign_due", "dueId": "<uuid>", "applyPayment"?: false }` — multipart’ta `"false"` string’inin yanlış `true` sayılmaması için ön işleme vardır.

### 16.3 Durum makinesi (`DekontStatus`) — pratik anlamı

Akış sırasıyla şunlar olabilir: `RECEIVED` → `EXTRACTING` → (`EXTRACT_FAILED` | `PARSED` | `PARSE_LOW_CONFIDENCE`) → eşleştirme sonucu `MATCHED` / `MATCH_AMBIGUOUS` / `UNMATCHED` / `NEEDS_MANAGER_REVIEW` → ödeme başarılıysa `PAYMENT_APPLIED` veya `PAYMENT_PARTIAL` → yönetici reddederse `REJECTED`. Ödeme uygulanamazsa `REJECTED` ve açıklama `parseError` alanında tutulabilir.

### 16.4 Güvenlik ve limitler

- **Dosya:** PDF, JPEG, PNG, WebP, GIF; boyut üst sınırı multer ile (yaklaşık 15 MB).  
- **Depo yolu:** `files/dekonts/{buildingId}/{YYYY}/{MM}/{dekontId}_{güvenli_ad}`; `..` segmentleri reddedilir.  
- **`dekontUploadLimiter`:** 15 dakikada kullanıcı başına varsayılan **15** (production) / **40** (development) yükleme; `DEKONT_UPLOAD_RATE_LIMIT_MAX` ile değiştirilebilir. Genel `apiLimiter` ayrıca geçerlidir.  
- **Prod hata mesajları:** `errorHandler` içinde yalnızca **5xx** için mesaj gizlenir; **4xx** (ör. validasyon, tutar uyuşmazlığı) mesajı döner.

### 16.5 Veri modeli özeti

- **`Dekont`:** dosya meta verisi, ham/parse edilmiş metin (`rawText`), `parsedJson`, `dueId` (eşleşince), `buildingId` / `uploadedById` / isteğe `apartmentId`.  
- **`DuePayment`:** `dueId`, isteğe `dekontId`, `amount`, `paidAt` — kısmi ödemeler birikir; tam ödeme sonrası `Due.status = PAID`.  
- **`NotificationType`:** dekont senaryoları enum’a eklenmiştir (ileride `Notification` kaydı + FCM ile kullanılacak).

### 16.6 Gerçek hayat senaryosu (uçtan uca)

**Bağlam:** “Yeşil Vadi Sitesi” yöneticisi **Mehmet**; 5 numaralı daire sakini **Ayşe** bir bankacılık uygulamasından Mayıs 2026 aidatını havale etmiş; dekont PDF’i telefonda duruyor.

1. **Ayşe (sakin)** uygulamadan `POST /api/v1/dekont/upload` ile PDF’i gönderir (`file` alanı). `buildingId` göndermez; backend kullanıcının `apartmentId` / `buildingId` bilgisini kullanır. İsteğe `targetMonth=5`, `targetYear=2026` ekleyerek eşleştirilecek aidatı daraltır.  
2. Sunucu dosyayı diske yazar, PDF’ten metin çıkarır, `generic-placeholder` profili ile tutarı (ör. 3.500,00 TL) ve mümkünse tarih/IBAN/referansı `parsedJson` içine koyar.  
3. **Eşleştirme:** Aynı dairede tek bekleyen Mayıs 2026 `Due` varsa ve tutar `Due.amount` ile ±0,02 TL içindeyse tek aday seçilir → `applyDekontPayment` çalışır → `DuePayment` oluşur, tutar tam ise `Due` **PAID** olur, dekont `PAYMENT_APPLIED`.  
4. **Bildirim köprüsü:** `scheduleDekontNotification` ile (sink henüz kayıtlı değilse prod’da sessiz) yönetici ve varsa sakin için olay üretilir; bildirim ekibi `registerDekontNotificationSink` ile FCM + DB bildirimini bağlayacaktır.  
5. **Kısmi ödeme:** Ayşe 3.500 TL yerine 2.000 TL gönderdiyse ve tek aday `Due` ile eşleştiyse `DuePayment` 2.000 TL kaydedilir, `Due` **PENDING** kalır, dekont `PAYMENT_PARTIAL`; kalan borç = `Due.amount` − toplam `DuePayment` (raporlama/API’de ayrıca hesaplanabilir).  
6. **Belirsizlik:** Aynı ay için birden fazla bekleyen kayıt veya tutar eşleşmiyorsa dekont `MATCH_AMBIGUOUS` veya `UNMATCHED` olur; köprüden yöneticiye bildirim gidebilir.  
7. **Mehmet (yönetici)** `GET /api/v1/dekont?buildingId=...` ile kuyruğu görür. Gerekirse `PATCH` ile `{ "action": "assign_due", "dueId": "<doğru-uuid>", "applyPayment": true }` der; tutar `parsedJson`’da yoksa 400 alır ve önce sadece bağlama (`applyPayment: false`) veya parse iyileştirmesi gerekir. Red için `{ "action": "reject", "reason": "..." }` kullanır.  
8. **İndirme:** Ayşe veya Mehmet (yetkiye göre) `GET .../download` ile aynı dosyayı tekrar indirebilir (ör. muhasebe e-postasına eklemek için).

Bu senaryo, **IBAN ile daire eşlemesi** veya **bankaya özel profil** henüz şemada/kodda zorunlu olmadığı için §12’deki “ileri faz” maddelerine dayanır; MVP’de ay/yıl + tutar + daire bağlamı ana sinyallerdir.

### 16.7 Dağıtım / geliştirici kontrol listesi

1. `cd backend && npm install`  
2. `npx prisma generate`  
3. `npx prisma migrate deploy` (veya geliştirme DB için `migrate dev`)  
4. İlk OCR çalışmasında Tesseract dil verilerinin indirilebileceğini unutmayın (ağ gerekir).  
5. Üretimde `DEKONT_STORAGE_ROOT` ile disk yolunu ve yedeklemeyi planlayın.

### 16.8 Bilerek yapılmayan / sonraki işler

- `FLUTTER-DEKONT-REHBERI.md` (§14) henüz oluşturulmadı.  
- Prisma `Notification` satırı + FCM gönderimi bildirim ekibine bırakıldı (köprü hazır).  
- Banka bazlı ek `profiles/*.js` dosyaları ve gerçek dekontlarla regex kalibrasyonu operasyonel süreçtir (`profiles/README.md`).

---

Bu belge güncellendikçe **banka profili ekleme / Prisma genişlemesi / yeni endpoint** maddeleri burada tutulur; ana proje kodu bu dosyayı tek başına değiştirmez.
