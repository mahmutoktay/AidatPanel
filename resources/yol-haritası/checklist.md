# AidatPanel — Fiziksel Cihaz Regresyon Checklist

**Amaç:** Play submit öncesi gerçek cihazda doğrulama  
**Sürüm:** `0.6.13+2000000022` (prod AAB / Play internal)  
**Güncelleme:** 2026-08-15  
**Kaynak:** `FAZ_DURUMU.md` FAZ 7 fiziksel regresyon + lansman kontrolleri

> Play’den kurulu AAB ile test et. Lisans test hesabı + abonelik ürünleri Active olmadan §3 tam geçmez.

---

## 0. Kurulum / smoke

- [ ] Play internal (veya yüklediğin track) → kurulum, soğuk açılış, splash FATAL yok
- [ ] Uygulamayı kill → yeniden aç → oturum kalır
- [ ] Ayarlar → Uygulama bilgisi: sürüm `0.6.13` / `2000000022`
- [ ] Bildirim izni isteniyor / veriliyor

---

## 1. Yönetici auth

- [ ] E-posta ile giriş («Tekrar hoş geldiniz» + isim)
- [ ] Telefon ile yönetici giriş/kayıt
- [ ] Şifremi unuttum (e-posta; phone-only ise SMS)
- [ ] Çıkış → yeniden giriş
- [ ] «Diğer cihazlardan çıkış» (ikinci cihaz varsa)

---

## 2. Sakin auth (SMS kritik)

- [ ] Yeni sakin: davet kodu elle (`AP…` + hex, örn. `P` içeren)
- [ ] Deep link: `https://aidatpanel.com/join?code=...` → uygulama / mağaza → telefon ekranı (kod tekrar sorulmasın)
- [ ] OTP hücreleri ortalı; 6 hane → devam
- [ ] Operatör SMS: mümkünse Turkcell / TT / Vodafone
- [ ] Mevcut sakin: «Tekrar hoş geldiniz» + isimli toast
- [ ] Profil: telefon değiştirme OTP

---

## 3. Abonelik / kota (RevenueCat + Play lisans test)

- [ ] **Aboneliksiz** yönetici: listeler okunur; yeni bina/site bloğu → paywall / 403 mesajı
- [ ] Abonelik ekranı: plan adı (isim yok), varsayılan **Aylık**, Temel/Business kartlar, fiyat `,99` formatı
- [ ] Admin hediyesi varsa: hediye bandı + ∞ / kota barı
- [ ] Temel aylık satın al → ACTIVE, limit 20, webhook sonrası ekran güncellenir
- [ ] Temel: 20. bina OK, 21. → kota dolu + Business yükselt
- [ ] Business yükselt → sınırsız; 21+ bina OK
- [ ] Hediye varken satın alma: bitiş `max` korunur; Business hediye Temel satın almada düşmez
- [ ] Play abonelikler listesinde yalnızca mağaza ürünü görünür (hediye görünmez — beklenen)

---

## 4. Site / bina (FAZ 8 E2E)

- [ ] Yeni site → blok ekle → Siteler | Binalar segmenti
- [ ] Tekil bina ekle
- [ ] Site ortak gider → daire aidat breakdown’ta görünür
- [ ] Liste yenileme: oluştur/sil sonrası Mülkler güncel

---

## 5. Aidat / gider / talep

- [ ] Yönetici: aidat listesi, durum, breakdown
- [ ] Gider ekle + makbuz; sakin gider listesi
- [ ] Talep oluştur + ek (kamera/galeri)
- [ ] Sakin hızlı işlemler 2×2

---

## 6. Dekont

- [ ] Sakin: ödeme yap → dekont yükle (foto/PDF)
- [ ] OCR polling / durum geçişleri
- [ ] Yönetici: dekont incele (onay/red)
- [ ] Bildirim (uygulama açık + tray)

---

## 7. Rapor PDF

- [ ] Bina aylık + yıllık: indir / önizle / paylaş
- [ ] Site aylık + yıllık: indir / paylaş

---

## 8. Bildirim / realtime

- [ ] FCM tray (uygulama kapalı)
- [ ] Ön planda yerel bildirim
- [ ] Liste + sheet; ilgili kayda git
- [ ] Badge güncellenir

---

## 9. Deep link / paylaşım

- [ ] `aidatpanel.com/join?code=` App Link (assetlinks SHA doluysa)
- [ ] `aidatpanel://join?code=`
- [ ] Dekont/share intent (varsa)

---

## 10. Profil / dil / tema

- [ ] Profil güncelle, dil TR↔EN
- [ ] Tema (açık/koyu) kalıcılığı
- [ ] textScale büyük → taşma/kırılma yok (50+ kritik ekranlar)

---

## Öncelik sırası

1. Kurulum + yönetici/sakin giriş + OTP  
2. Abonelik Temel/Business + kota  
3. Dekont + PDF  
4. Site E2E + FCM + davet linki  

---

## Notlar

- Mapping: önce AAB, sonra `mapping.txt` (App bundle explorer → ilgili sürüm → ReTrace / deobfuscation).
- Hediye abonelik Play Console’da görünmez; uygulama içi `GET /me/subscription` kaynağıdır.
- 1.0.0 sürüm adına geçiş yalnızca açık kullanıcı onayı ile.
