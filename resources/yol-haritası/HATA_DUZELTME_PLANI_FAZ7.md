# AidatPanel — FAZ 7 Kapsamlı Hata Düzeltme ve İmplementasyon Planı

Bu belge, analiz aşamasında tespit edilen hataların atomik düzeyde parçalara ayrılmış halini ve adım adım düzeltme planını içermektedir. Çözümler öncelik sırasına göre (Kritik -> Yüksek -> Orta) sınıflandırılmıştır.

---

## 🔴 1. KRİTİK GÜVENLİK VE ÇÖKME HATALARI (ÖNCELİKLİ)

### 1.1. Dart Derleme (Syntax) Hatası
- **Etkilenen Dosya:** `mobile/lib/features/dues/data/datasources/dues_remote_datasource.dart`
- **Hata Türü:** Compile Error (Uygulamanın derlenmesini engeller)
- **Kök Neden:** Map tanımında `?month` gibi Dart dilinde olmayan geçersiz bir syntax kullanılması.
- **Düzeltme Yöntemi:** Geçerli Dart collection-if syntax'ına geçiş.
- **Adım Adım Uygulama:**
  1. İlgili dosyayı aç.
  2. Query parametreleri oluşturulurken `{'month': ?month}` yerine `if (month != null) 'month': month` yapısını kullan.
  3. `flutter analyze` ile dosyanın hatasız olduğunu doğrula.

### 1.2. RevenueCat Webhook İmza Doğrulaması Eksikliği
- **Etkilenen Dosya:** `backend/src/controllers/subscriptionController.js`
- **Hata Türü:** Security Zafiyeti
- **Kök Neden:** Webhook uç noktasına gelen POST isteklerinin RevenueCat'ten geldiği doğrulanmıyor.
- **Düzeltme Yöntemi:** `Authorization` header kontrolü yapan bir middleware eklemek.
- **Adım Adım Uygulama:**
  1. `backend/src/middlewares/revenueCatWebhookAuth.js` dosyası oluştur.
  2. Gelen istekteki `req.headers.authorization` değerini `process.env.REVENUECAT_WEBHOOK_SECRET` ile eşleştir (Bearer token olarak).
  3. `backend/src/routes/subscriptionRoutes.js` dosyasında bu middleware'i webhook rotasına dahil et.

### 1.3. Express "Headers Already Sent" Çökmesi
- **Etkilenen Dosya:** `backend/src/controllers/dekontController.js`
- **Hata Türü:** Runtime Crash (Sunucuyu çökertir)
- **Kök Neden:** Dosya stream'i sırasında (getDekontFile) hata fırlatıldığında, yanıt başlıkları (headers) çoktan gönderilmişse `next(err)` çağrılması.
- **Düzeltme Yöntemi:** Stream hata yakalayıcısında (error handler) `res.headersSent` kontrolü yapmak.
- **Adım Adım Uygulama:**
  1. `getDekontFile` fonksiyonundaki `stream.on('error', ...)` olay dinleyicisini bul.
  2. Eğer `res.headersSent === true` ise `res.end()` çağır, değilse `next(err)` ile ilerle.

### 1.4. Certificate Pinning Bypass ve Tek Pin Riski
- **Etkilenen Dosya:** `mobile/lib/core/network/certificate_pinning.dart`
- **Hata Türü:** Security / Availability
- **Kök Neden:** `http` scheme'ine sahip URL'ler kontrolü atlıyor ve tek bir hash (pin) var.
- **Düzeltme Yöntemi:** Pinning mantığını sıkılaştırmak ve yedek (backup) sertifika hash'i eklemek.
- **Adım Adım Uygulama:**
  1. `if (uri.scheme != 'https') return;` satırını `if (uri.scheme != 'https') throw Exception('Yalnızca HTTPS kabul edilir');` olarak değiştir.
  2. Sunucu için 2 adet geçerli SHA-256 pin dizisi (List<String>) oluştur ve eşleşmeyi ikisinden biriyle yapacak şekilde düzenle.

---

## 🟠 2. VERİ BÜTÜNLÜĞÜ VE EŞZAMANLILIK (RACE CONDITIONS)

### 2.1. OCR Yüklemesinde Manuel Muhasebe Verisinin Silinmesi
- **Etkilenen Dosya:** `backend/src/services/expenseService.js`
- **Hata Türü:** Data Loss (Veri Kaybı)
- **Kök Neden:** Makbuz yüklendiğinde, daha önceden formda elle girilen `amount` değerleri sıfırlanıp (`null`) OCR sonucu bekleniyor.
- **Düzeltme Yöntemi:** Mevcut değerleri korumak ve sadece OCR'dan yeni bir değer gelirse onu (veya güven oranı yüksekse) `ocrReceiptsJson` vb. alanlara yazmak.
- **Adım Adım Uygulama:**
  1. `uploadExpenseProofsService` içinde `amount` ve `perUnitAmount` alanlarını sıfırlayan `null` atamalarını sil.
  2. İşlemi sadece makbuz URL'ini kaydedecek şekilde daralt.

### 2.2. Token Replay (Eşzamanlı Yenileme) Zafiyeti
- **Etkilenen Dosya:** `backend/src/services/authService.js`
- **Hata Türü:** Concurrency / Security
- **Kök Neden:** Yeni token üretilirken paralel gelen istekleri engellemek için Row-Level Lock (Satır Kilitleme) yok.
- **Düzeltme Yöntemi:** `$transaction` ve raw SQL ile satır kilitlemek.
- **Adım Adım Uygulama:**
  1. `refreshAccessTokenService` içindeki işlemleri `$transaction` içine al.
  2. İşlemin başında `prisma.$queryRawUnsafe('SELECT * FROM "UserSession" WHERE id = $1 FOR UPDATE', sessionId)` ile kilitleme sağla.

### 2.3. Zamanlanmış Görev (Cron Job) Çakışması
- **Etkilenen Dosya:** `backend/src/jobs/dueAutoGenerateJob.js`
- **Hata Türü:** Concurrency
- **Kök Neden:** Veritabanı işlemi uzun sürdüğünde `setInterval`'ın önceki iş bitmeden tekrar tetiklenmesi.
- **Düzeltme Yöntemi:** Rekürsif `setTimeout` veya bir `isWorking` state'i (kilidi) kullanmak.
- **Adım Adım Uygulama:**
  1. Modülün en üstünde `let isWorking = false;` tanımla.
  2. Fonksiyon başında `if (isWorking) return; isWorking = true;` kontrolü yap.
  3. `finally` bloğunda `isWorking = false;` yapmayı unutma.

---

## 🟡 3. MİMARİ VE UYGULAMA İŞLEYİŞ HATALARI

### 3.1. Ağ Kopmasında Oturumun (Session) Aniden Kapatılması
- **Etkilenen Dosya:** `mobile/lib/core/network/token_refresh_service.dart`
- **Hata Türü:** Bug (Kötü UX)
- **Kök Neden:** `catch (_)` bloğunun ayrım yapmadan `clearAuth()` çağırması.
- **Düzeltme Yöntemi:** Yalnızca HTTP 401/403 gibi kesin oturum hatalarında çıkış yaptırmak.
- **Adım Adım Uygulama:**
  1. `catch (e)` şeklinde yakala.
  2. Eğer `e is DioException` ve `e.type == DioExceptionType.connectionError` vb. ise `throw e;` diyerek hatayı yukarı ilet ve `clearAuth()`'u atla.
  3. Yalnızca backend'den dönen ret (status 401) durumunda auth state'ini temizle.

### 3.2. Clean Architecture: Repository Katmanının Atlanması
- **Etkilenen Dosyalar:** `ReportsNotifier`, `SubscriptionNotifier`, `ProfileNotifier`, `DekontProvider`, `TicketsNotifier`
- **Hata Türü:** Architecture Violation
- **Kök Neden:** Provider'ların direkt Data Source çağırması.
- **Düzeltme Yöntemi:** Araya Repository ve Abstract interface'ler eklemek.
- **Adım Adım Uygulama:**
  1. Her feature için `domain/repositories/xxx_repository.dart` interface'i oluştur.
  2. `data/repositories/xxx_repository_impl.dart` üzerinden DataSource'u bağla ve hataları (`ApiException`) sarmala.
  3. Provider'larda Datasource bağımlılığını silip Repository'i inject et.

### 3.3. State'in Hatalı Okunması ile Veri Kaybı (Buildings Store)
- **Etkilenen Dosya:** `mobile/lib/features/buildings/data/buildings_store.dart`
- **Hata Türü:** Runtime Bug
- **Kök Neden:** `removeBuilding` işleminde `state.value ?? []` kullanımı.
- **Düzeltme Yöntemi:** `state.valueOrNull` kullanmak.
- **Adım Adım Uygulama:**
  1. `removeBuilding` metodunda mevcut veriyi `final current = state.valueOrNull ?? [];` şeklinde al.
  2. Liste boş dönse dahi işlem sonrasında AsyncValue'yu sadece güncellenen değerlerle değiştir.

---

## 🟢 4. I18N (ÇOKLU DİL) VE UI KALİTESİ

### 4.1. Statik Metinlerin (Hardcoded Strings) Taşınması
- **Etkilenen Dosyalar:**
  - `features/reports/presentation/screens/reports_screen.dart`
  - `features/subscription/presentation/screens/subscription_screen.dart`
  - `features/profile/presentation/screens/profile_screen.dart`
  - `features/dashboard/presentation/screens/manager_dashboard_screen.dart`
  - `features/dashboard/presentation/screens/resident_dashboard_screen.dart`
  - `features/auth/presentation/screens/login_screen.dart`
  - `core/utils/input_validators.dart`
- **Hata Türü:** i18n Violation
- **Kök Neden:** Uygulamada Türkçe kelimelerin direkt yazılması.
- **Düzeltme Yöntemi:** `strings_tr.i18n.json` ve `strings_en.i18n.json` içerisine almak.
- **Adım Adım Uygulama:**
  1. Belirtilen dosyalardaki tırnak içi ('Kayıt Ol', 'Giriş Yap' vb.) metinleri bul.
  2. Bu metinleri JSON dosyalarına anahtar-değer (key-value) çifti olarak ekle.
  3. `flutter pub run build_runner build --delete-conflicting-outputs` çalıştır.
  4. Dart tarafında `context.t.xxx` ile çağır.

---
## ÖNERİLEN ÇALIŞMA SIRASI
Çözüme başlarken öncelikle **1. Bölüm'deki Kritik Hataları (1.1, 1.2, 1.3, 1.4)** ele almanız önerilir. Bu işlemler API'nin çökmesini engelleyecek ve mobil uygulamanın derlenebilmesini sağlayacaktır.
