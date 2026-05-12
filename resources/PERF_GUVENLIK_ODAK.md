# Performans + güvenlik odaklı iyileştirme (geçici not)

> **Amaç:** FAZ 2 ve sonrası entegrasyon işleri **ertelendi**; başkaları üretip repoya bağlayacak, sonrasında kod analizi yapılacak.  
> **Şimdiki görev:** Bugüne kadar yapılan mobil uygulama için **performans testi**, **güvenlik taraması** ve **iyileştirme**.  
> Bu dosya **isteğe bağlıdır** — sprint bitince veya gerekmeyince **silinebilir**.

**Referans:** `resources/FAZ_DURUMU.md` (MEVCUT DURUM), `resources/MOBILE-TO-BACKEND.md`, `CLAUDE.md`.

---

## 1. Performans

| # | Konu | Not |
|---|------|-----|
| P1 | Soğuk / sıcak açılış | Splash → `restoreSession` → ilk ekran süresi (DevTools Timeline) |
| P2 | Liste ekranları | Aidat / bina listesi — gereksiz rebuild; `ListView.builder`, Riverpod `select` |
| P3 | Ağ kullanımı | Yinelenen API çağrısı, invalidate sonrası cascade yükleme |
| P4 | Büyük veri | Çok kayıtlı senaryoda kaydırma ve bellek (sayfalama yoksa en azından gözlem) |
| P5 | Animasyon | Projede max ~200 ms, `Curves.easeInOut` uyumu |

---

## 2. Güvenlik

| # | Konu | Not |
|---|------|-----|
| G1 | Token saklama | Yalnızca `SecureStorage`; SharedPreferences’ta token yok |
| G2 | Loglar | Token/log-out hassas veri loglanmıyor; `LogInterceptor` yalnızca `kDebugMode` |
| G3 | Ağ | Üretim base URL / HTTPS; (ileride) certificate pinning — `FAZ_DURUMU` FAZ 5 |
| G4 | Girdi doğrulama | Auth ve formlar — teknik hata kullanıcıya sızmıyor |
| G5 | Bağımlılıklar | `flutter pub outdated`; kritik paket güncellik / CVE gözden geçirme |

---

## 3. Genel iyileştirme

| # | Konu | Not |
|---|------|-----|
| I1 | Regresyon | Login, bina, daire, aidat, davet, şifre, silme akışları |
| I2 | Loading / hata | Async işlerde görünür yükleme; hatalar sade Türkçe |
| I3 | Erişilebilirlik | Min font / dokunma alanı (`TASARIM_KILAVUZU.md`) |

---

## 4. Komutlar (hızlı başlangıç)

```bash
cd mobile
flutter analyze
flutter test
# Release profil (performans gözlemi için):
flutter run --release
```

Derinlemesine: Flutter DevTools → Performance, Network; gerektiğinde `--profile` build.

---

*Son güncelleme: 2026-05-12 — Furkan eklendi; gerektiğinde sil.*
