# Davet sayfası (`/join`)

Mobil uygulama paylaşım linki: `https://aidatpanel.com/join?code=AP3-B12-A9F0`

Bu klasör `web/` sitesinin parçasıdır; `aidatpanel.com` köküne `web/` içeriği yüklendiğinde `/join` olarak sunulur.

## Dosya yapısı

```
web/
├── join/
│   ├── index.html    → /join?code=...
│   ├── join.css
│   ├── join.js
│   └── README.md
└── .well-known/
    ├── assetlinks.json
    └── apple-app-site-association
```

## Yayın öncesi

1. **Android `web/.well-known/assetlinks.json`:** Release keystore SHA-256 parmak izi:
   ```bash
   keytool -list -v -keystore YOUR_RELEASE_KEY.jks -alias YOUR_ALIAS
   ```
   `REPLACE_WITH_RELEASE_KEY_SHA256` değerini güncelleyin.

2. **iOS `web/.well-known/apple-app-site-association`:** `REPLACE_WITH_TEAM_ID` → Apple Developer Team ID.

3. **App Store:** `join/index.html` ve `join.js` içindeki App Store URL’sini gerçek uygulama sayfasıyla güncelleyin (ana sayfadaki `index.html` ile aynı tutun).

## Sunucu (CloudPanel / Nginx)

`/join` isteği `join/index.html` dosyasına düşmeli; `?code=` query string korunmalı.

```nginx
location /join {
  try_files /join/index.html =404;
}

location /.well-known/ {
  default_type application/json;
}
```

## Akış

1. Yönetici uygulamadan **Davet et** ile `https://aidatpanel.com/join?code=...` paylaşır.
2. Uygulama yoksa: bu sayfa → mağaza rozetleri.
3. Kurulumdan sonra aynı linke tekrar dokunulur → App Link / Universal Link / `aidatpanel://join?code=...` → uygulama, sakin **telefon** ekranı (davet kodu arka planda; tekrar sorulmaz).
4. Telefon → SMS → (yeni kullanıcıysa) isim → kayıt tamamlanır.
