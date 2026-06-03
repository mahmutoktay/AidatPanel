## AidatPanel – İyileştirme ve Risk Önlemleri Listesi

### 1. Rate‑limit ve DDoS Koruması
- **Prod ortamda API limitlerini sıkılaştır**: `apiLimiter` → 15 dk/60 istek (eski 100). 
- **IP‑bazlı blacklist/whitelist** ekle (ör. Cloudflare, Azure Front Door). 
- **Auth endpoint** için `authLimiter` → 3 istek/15 dk (eski 5). 

### 2. Hata Yönetimi ve Loglama
- **Prod’da stack trace gizle**; sadece `message` ve `code` döndür. 
- **Yapılandırılmış loglama** (p. e. `pino` veya `winston`) ekle; hata seviyeleri (`error`, `warn`, `info`) ayrı dosyalara yönlendirilsin. 
- **Kritik hatalar için alert** (Slack, Teams) entegrasyonu kur. 

### 3. Token Revocation & Oturum Güvenliği
- **Access token süresini 10 dk** olarak kısalt; kritik işlemler (ödeme, dekont eşleştirme) için **her istekte token yeniden doğrulaması** yap. 
- **Refresh token rotation**: her refresh işleminde yeni bir refresh token üret ve eskiyi iptal et. 
- **Refresh token çalınması durumunda** `refreshTokenVersion` artışıyla tüm oturumları sonlandır. 

### 4. Dekont OCR ve İş Akışı
- **OCR doğruluğunu artır**: Tesseract yerine Google Cloud Vision API veya Azure OCR entegrasyonu dene. 
- **Düşük güvenilirlik (`PARSE_LOW_CONFIDENCE`)** durumunda otomatik **manuel inceleme kuyruğu** oluştur. 
- **Dosya boyutu kontrolü**: `multer` ile maksimum 5 MB sınırı koy, `file-type` ile MIME doğrulaması yap. 
- **Virüs taraması**: `clamav` veya benzeri bir tarayıcı ile yükleme öncesi tarama ekle. 

### 5. Gerçek Zamanlı (WebSocket) İyileştirmeleri
- **Heartbeat / ping‑pong** mekanizması ekle; bağlantı kaybı anında otomatik yeniden bağlan. 
- **Auth token yenileme**: WebSocket handshake sırasında JWT doğrulaması, token süresi dolduğunda `401` ve yeniden bağlanma isteği. 
- **Rate‑limit**: WebSocket mesaj başına `maxMessagesPerSecond` sınırı koy. 

### 6. Mobil Uygulama – Offline & Cache
- **Local cache** (sqflite / hive) ekle; API yanıtlarını önbellekle ve offline modda göster. 
- **İstek kuyruğu**: `dio` interceptor’da başarısız (ör. 401, 503) istekleri kuyrukla ve ağ geri geldiğinde tekrar gönder. 
- **Refresh token otomatik yenileme**: `dio` interceptor’da 401 alındığında refresh token akışını tetikle, yeni access token al ve orijinal isteği yeniden gönder. 

### 7. CI/CD ve Test Kapsamı
- **GitHub Actions** pipeline oluştur: `npm ci`, `prisma generate`, `npm test`, `docker build`, `deploy`. 
- **Unit & integration test**: Auth, Payment, Dekont OCR, WebSocket akışları için Jest + Supertest testleri ekle. 
- **Kod kalite kontrolü**: ESLint + Prettier, TypeScript (eğer eklenirse) statik tip kontrolü. 

### 8. Güvenlik Politikaları
- **Content‑Security‑Policy (CSP)**: Helmet üzerinden `script-src`, `style-src` vb. kısıtlamaları ekle. 
- **SQL Injection**: Prisma zaten parametreli sorgular kullanıyor; fakat tüm endpointlerde **Zod** ile giriş doğrulaması zorunlu kıl. 
- **CORS**: `ALLOWED_ORIGINS` listesine sadece güvenilir domainleri ekle, wildcard (`*`) kullanımını kaldır. 

### 9. Dokümantasyon & API Tanımları
- **OpenAPI/Swagger** dosyası oluştur; tüm endpointler, request/response şemaları ve auth açıklamaları yer alsın. 
- **Postman collection** güncelle; yeni eklenen endpointler ve örnek payload’lar eklensin. 

### 10. Performans ve Ölçeklenebilirlik
- **Prisma query optimizasyonu**: `select`/`include` ile sadece gerekli alanları çek, `@@index`’leri gözden geçir. 
- **Redis cache**: Sık kullanılan sorgular (ör. `unreadCountForUser`, `listForUser`) için kısa vadeli cache ekle. 
- **Dockerize**: Backend ve PostgreSQL’i Docker Compose ile izole et, prod’da Kubernetes/Helm ile ölçeklendir. 

---

**Uygulama Önceliği (Önerilen Sıra)**
1. **Güvenlik & Token** (3, 8) – En yüksek risk. 
2. **Rate‑limit & DDoS** (1) – Servis sürekliliği. 
3. **OCR ve Dosya Güvenliği** (4) – Kullanıcı verisi bütünlüğü. 
4. **Realtime & Mobile Offline** (5, 6) – Kullanıcı deneyimi. 
5. **CI/CD & Test** (7) – Sürekli entegrasyon ve hatasız dağıtım. 
6. **Dokümantasyon** (9) – API tüketicileri ve yeni geliştiriciler. 
7. **Performans** (10) – Ölçeklenebilirlik ve maliyet optimizasyonu. 

Bu liste, mevcut riskleri azaltmak ve sistemin güvenilirliğini, performansını ve geliştirilebilirliğini artırmak için öncelikli adımları içerir.

