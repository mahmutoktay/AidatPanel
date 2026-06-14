# Dekont dosyası 404 / upload 500 — sorun giderme

## Belirtiler

| İstek | Durum | Anlam |
|-------|-------|--------|
| `GET /api/v1/dekonts/:id` | **200** | Kayıt DB'de var |
| `GET /api/v1/dekonts/:id/file` | **404** | Dosya diskte yok veya kayıt >2 dk (kayıt silinir) |
| `GET /api/v1/dekonts/:id/file` | **503** | Dosya henüz hazırlanıyor (kayıt ≤2 dk) |
| `POST /api/v1/dekonts/upload` | **502** | Genelde reverse proxy — Node süreci upload sırasında çöktü / yeniden başladı; log: `[api] Unhandled Rejection` veya `[dekont] upload failed` |
| `POST /api/v1/dekonts/upload` | **503** | Disk yazılamadı |
| `POST /api/v1/dekonts/upload` | **201** | Başarılı |

404 mesajı (güncel): `Dekont dosyası kaydedilememiş. Lütfen dekontu yeniden yükleyin.`

## Kontrol listesi (üretim)

1. **Ortam değişkeni**  
   `DEKONT_UPLOAD_DIR` (varsayılan: `./uploads/dekonts`) — **mutlak path** ve kalıcı volume önerilir (ör. `/var/aidatpanel/uploads/dekonts`).

2. **Dosya yolu**  
   DB `storedPath`: `{buildingId}/{dekontId}.pdf`  
   Tam yol: `{DEKONT_UPLOAD_DIR}/{storedPath}`

3. **Çoklu API instance**  
   Upload ve indirme aynı paylaşımlı disk/NFS üzerinde olmalı.

4. **Deploy / restart**  
   Container yeniden oluşunca `uploads/` silinmemeli (volume mount).

5. **Log** (`DEKONT_DEBUG` varsayılan açık, `DEKONT_DEBUG=false` kapatır):
   - `[dekont] upload file saved before db` → `fileOnDisk: true/false`
   - `[dekont] upload failed:` → stack trace
   - `[dekont] GET file unavailable` → `storedPath`, `exists`, `stale`
   - `[api] unhandled error` → dekont route'unda maskelenmemiş 500

## Upload teşhis (curl)

```bash
# Yükleme
curl -s -w "\nHTTP %{http_code}\n" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@dekont.pdf;type=application/pdf" \
  -F "dueId=YOUR_DUE_UUID" \
  https://api.aidatpanel.com/api/v1/dekonts/upload

# Beklenen: HTTP 201 ve JSON data.id

# Metadata
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://api.aidatpanel.com/api/v1/dekonts/{DEKONT_ID}"

# Dosya
curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  "https://api.aidatpanel.com/api/v1/dekonts/{DEKONT_ID}/file"
# Beklenen: 200
```

Sunucuda dosya varlığı:

```bash
ls -la "$DEKONT_UPLOAD_DIR/{buildingId}/"
```

## Mobil taraf

- Yükleme sonrası önizleme: bellek + uygulama documents önbelleği (`aidat_dekont_preview`).
- Kalıcı görüntüleme **sunucu dosyasına** bağlıdır; `GET .../file` 200 değilse yeniden yükleme gerekir.
- Oturum kapanınca bellek önbelleği temizlenir; documents önbelleği logout'ta silinir.

## Production süreç yönetimi (PM2 + nginx)

**Önerilen:** Yerel makineden `powershell -ExecutionPolicy Bypass -File backend/scripts/deploy.ps1` (SSH + sync + migrate + `pm2 restart aidapanel-api`). Ayrıntı: `resources/AIDATPANEL.md` (Deployment).

### PM2 — API sürekli çalışsın

`npm run dev` (nodemon) SSH oturumu kapanınca durabilir. Üretimde PM2 kullanın:

```bash
cd /home/aidatpanel-api/htdocs/api.aidatpanel.com   # proje kökü
npm ci --omit=dev
npx prisma migrate deploy
pm2 start index.js --name aidapanel-api
pm2 save
pm2 startup   # sunucu yeniden başlayınca otomatik kalkması için
```

Deploy sonrası:

```bash
git pull
npm ci --omit=dev
npx prisma migrate deploy
pm2 restart aidapanel-api
pm2 logs aidapanel-api --lines 100
```

Kontrol:

```bash
pm2 status
curl -s -o /dev/null -w "%{http_code}" https://api.aidatpanel.com/api/v1/health
```

### Nginx — upload boyutu ve timeout

Multipart upload + OCR yanıt süresi için örnek site bloğu:

```nginx
client_max_body_size 12m;
proxy_read_timeout 180s;
proxy_connect_timeout 60s;
proxy_send_timeout 180s;
```

Değişiklikten sonra: `sudo nginx -t && sudo systemctl reload nginx`

| Ayar | Önerilen | Neden |
|------|----------|-------|
| `client_max_body_size` | `12m` | Dekont max ~10 MB + form overhead |
| `proxy_read_timeout` | `180s` | Büyük upload / yavaş disk |
| `DEKONT_UPLOAD_DIR` | mutlak path + volume | Deploy sonrası dosya kaybı önlenir |
