# 🚫 Project Rules — Tekrar Edilmemesi Gereken Hatalar
## Flutter + Node.js / Prisma / PostgreSQL

Bu kurallar, geçmiş kod analizinde tespit edilen gerçek hatalardan üretilmiştir.
Her yeni kod yazarken bu listeyi kontrol et.

---

## 🔴 KRİTİK — Asla Yapma

### [RULE-01] Boş catch bloğu yazma
```js
// ❌ YASAK
try {
  await pdfjs.getDocument(buffer).promise;
} catch (err) { }

// ✅ DOĞRU
try {
  await pdfjs.getDocument(buffer).promise;
} catch (err) {
  logger.error({ err }, 'pdfjs-dist parse hatası');
  throw new AppError('PDF okunamadı', 500);
}
```
> Boş catch = sessiz hata = ayıklanamaz bug. Her catch bloğu en az loglama yapmalı.

---

### [RULE-02] Pino'da `serializers` kullanma — `formatters` veya `redact` kullan
```js
// ❌ YASAK (Pino v8+ çalışmaz)
const logger = pino({ serializers: { req: ... } });

// ✅ DOĞRU
const logger = pino({
  redact: ['req.headers.authorization'],
  formatters: {
    log(obj) { return { ...obj }; }
  }
});
```
> `serializers` Pino v8+'da kaldırıldı. Bu projede Pino v8+ kullanılıyor.

---

### [RULE-03] `messageFormat` içinde varsayılan olmayan Pino alanı kullanma
```js
// ❌ YASAK — {context} Pino'da varsayılan değil, undefined yazar
messageFormat: '{msg} {context}'

// ✅ DOĞRU — Sadece gerçek Pino alanlarını kullan
messageFormat: '{msg}'
// ya da log çağrısında context'i kendin ekle:
logger.info({ context: 'auth' }, 'kullanıcı giriş yaptı');
```

---

## 🟡 ORTA — Bu Projede Geçerli Standartlar

### [RULE-04] Export ettiğin kodu aynı PR'da bir yerde kullan
```js
// ❌ YASAK — export var ama hiçbir yerde import yok
export const asyncHandler = (fn) => ...   // asyncHandler.js'de var ama kullanılmıyor
export const reqLogger = (req) => ...     // logger.js'de var ama kullanılmıyor

// ✅ DOĞRU
// Yeni bir utility/middleware yazdıysan aynı commit'te en az bir yerde bağla:
// - asyncHandler → ilgili controller'larda kullan
// - requestLogger → index.js'e mount et
```
> "Sonra bağlarım" diye yarım bırakılan kod, ölü kod olarak kalıyor.

---

### [RULE-05] Yeni middleware yazdıysan index.js'e mount et
```js
// ❌ YASAK — logger.js'de requestLogger tanımlı ama index.js'de yok
// index.js:
app.use(express.json());
// requestLogger yok!

// ✅ DOĞRU
import { requestLogger } from './config/logger.js';
app.use(requestLogger);
app.use(express.json());
```

---

### [RULE-06] Sabit dosyasındaki değişken adını kullanan dosyayla senkronize et
```js
// ❌ YASAK — limiterConstants.js'de şu var:
export const DEKONT_UPLOAD_WINDOW_MS = 60000;

// ama rateLimitMiddleware.js hala eski adı kullanıyor:
windowMs: DEKONT_UPLOAD_RATE_WINDOW_MS  // bu import edilmedi bile!

// ✅ DOĞRU — sabit adını değiştirirsen kullanan dosyayı da güncelle
windowMs: DEKONT_UPLOAD_WINDOW_MS
```
> Sabit rename = kullanan tüm dosyaları da güncelle. Aksi halde eski ad hayalet olarak kalır.

---

### [RULE-07] `req.id` kullanmadan önce middleware kontrolü yap
```js
// ❌ YASAK — Express'te req.id varsayılan gelmez
logger.info({ requestId: req.id });  // undefined loglanır

// ✅ DOĞRU — ya express-request-id ekle:
import expressRequestId from 'express-request-id';
app.use(expressRequestId());

// ya da fallback kullan:
logger.info({ requestId: req.id ?? crypto.randomUUID() });
```

---

## 🟢 PERFORMANS — Dart / Flutter

### [RULE-08] Polling döngüsünde sabit veriyi tekrar çekme
```dart
// ❌ YASAK — fetchStorePrices() her polling denemesinde tekrar çağrılıyor
Future<void> _loadWithPolling() async {
  for (int i = 0; i < 3; i++) {
    await getMySubscription();
    await fetchStorePrices();  // fiyatlar değişmez, neden 3 kez çekiyoruz?
    await Future.delayed(Duration(seconds: 1));
  }
}

// ✅ DOĞRU — sabit veriyi döngü dışında bir kere çek
Future<void> _loadWithPolling() async {
  await fetchStorePrices();  // bir kere yeterli
  for (int i = 0; i < 3; i++) {
    await getMySubscription();
    if (subscriptionActive) break;
    await Future.delayed(Duration(seconds: 1));
  }
}
```

---

## 📋 Yeni Kod Yazarken Kontrol Listesi

Her dosyayı commit'lemeden önce şunları sor:

- [ ] Export ettiğim her fonksiyon/middleware en az bir yerde kullanılıyor mu?
- [ ] catch bloklarım boş mu? (boşsa → log + throw ekle)
- [ ] Pino kullanıyorsam `serializers` yerine `formatters`/`redact` mi kullandım?
- [ ] Sabit adını değiştirdiysem kullanan tüm dosyaları güncelledim mi?
- [ ] `req.id` kullanıyorsam express-request-id middleware'i var mı?
- [ ] Yeni middleware yazdıysam index.js'e mount ettim mi?
- [ ] Polling/döngü içinde sabit veriyi tekrar tekrar çekiyor muyum?
