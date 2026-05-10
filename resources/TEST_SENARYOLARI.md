# AidatPanel — Test Senaryoları (Manuel)

> **Hedef:** Son sprintte mobile tarafına eklenen 4 backend-bağımsız iyileştirmeyi + önceki turlardaki yenilikleri (CRUD, submit guard, dashboard rate, ay/yıl filtresi, dev_mocks) **canlı backend olmadan** uçtan uca test etmek.
> **Tarih:** 2026-05-10
> **Branch:** `mobile/app`
> **Tester:** Furkan
> **Cihaz:** Android emulator (Pixel 6, API 34) ve/veya gerçek telefon

---

## 0. Hazırlık

### 0.1 Build ortamı (Dev Preview — backend yok)

Bu mod sahte (mock) data kullanır; gerçek backend gerekmez.

```bash
cd mobile
flutter pub get
flutter run -t lib/main_dev.dart
```

Açıldığında ekranın üst kısmında turuncu **DEV** banner'ı görmelisin.

**Önceden hazır mock veriler:**
- 1 yönetici hesap (otomatik giriş yapılır, login ekranı atlanır)
- 2 bina:
  - **b1 — Çamlık Apartmanı** (4 daire, ₺600/ay, dueDay=5, 24 due)
    - 1A: Ayşe (sakinli, hep ödeyen) → 6/6 PAID
    - 1B: Mehmet (sakinli, son 2 ay PENDING) → 4 PAID + 2 PENDING
    - 2A: BOŞ → 6 PENDING
    - 2B: BOŞ → 6 PENDING
  - **b2 — Yıldız Sitesi A Blok** (2 daire, ₺750/ay, dueDay=1, 12 due)
    - 1: Zeynep (sakinli, son 2 ay OVERDUE) → 4 PAID + 2 OVERDUE
    - 2: BOŞ → 6 PENDING

**Beklenen toplam tahsilat oranı:** (10 + 4) / (24 + 12) = **14/36 ≈ %38.9**
**Beklenen overdue sayısı:** 2 (b2'deki Zeynep'in son 2 ayı)

### 0.2 Build ortamı (Real backend — Abdullah ayağa kaldırınca)

```bash
cd mobile
flutter pub get
flutter run                       # main.dart default
```

`API_BASE_URL` ortam değişkeni veya `app_constants.dart`'taki sabit gerçek backend'e işaret etmeli.

---

## 1. Resident polish — Boş/dolu daire görsel ayrımı + telefon rozeti

**Ekran:** Manager Dashboard → "Binalarım" sekmesi → Bina kartına dokun → "Sakinler" ekranı

### Adım 1.1 — Çamlık Apartmanı sakin listesi
1. Manager Dashboard'ta "Binalarım" tab'ına geç
2. **Çamlık Apartmanı** kartına dokun (bina sakinleri ekranı açılır)
3. Kart başlığında "Çamlık Apartmanı" yazmalı, alt satırda adres + şehir görmeli (`displayAddress`)
4. Aşağıdaki listede 4 daire kartı sıralı görmeli

### Adım 1.2 — Dolu daire kartı (1A — Ayşe)
**Beklenen görünüm:**
- Sol başta **mavi yuvarlak içinde "1"** rakamı (dolu)
- Üstte küçük gri yazı: "1. kat • Daire A"
- Altta kalın siyah yazı: "Ayşe"
- Sağ üstte yeşil rozet: "Ödendi" (paymentStatus paid)
- Alt satırda mavi telefon ikonu + numara (formatlı)
- Sağ altta gri "₺600/ay"

### Adım 1.3 — Dolu fakat telefonu paylaşmamış daire
> **Not:** Mevcut mock'ta her sakinli dairenin telefonu var. Bu testi yapmak için `lib/dev/dev_mocks.dart` içinde örnek bir sakinin `phone` field'ını `null` yap, hot restart et.

**Beklenen görünüm:**
- Sol başta yine mavi yuvarlak + rakam
- Sakin adı normal
- Alt satırda **mavi telefon ikonu yerine gri "phone_disabled" ikonu**
- Yanında italik gri yazı: **"Telefon paylaşılmadı"**
- Sağda "₺amount/ay" yine görünür
- Sağ üstte ödeme rozeti yine görünür

### Adım 1.4 — Boş daire (2A veya 2B)
**Beklenen görünüm:**
- Kart arka planı **soluk gri** (background tonu, surface değil)
- Kart kenarlığı normal kenarlıktan daha açık
- Sol başta **gri yuvarlak içinde `person_off_outlined` ikonu** (rakam yok)
- Üstte gri "X. kat • Daire Y"
- Altta italik gri "Boş Daire"
- Sağ üstte griye yakın rozet: **"Boş"** (vacantBadge)
- Alt satırda **gri "event_busy" ikonu + italik "Sakin atanmamış"** + sağda "₺600/ay"

✅ **PASS:** Boş daire kartı dolulardan ilk bakışta ayırt edilebiliyor.
❌ **FAIL:** Boş daire kartı dolu kartla aynı görünüyor → ekran görüntüsü al, raporla.

---

## 2. Auth klavye davranışı — Next/Done zinciri + autofill

**Ön koşul:** Çıkış yap. Manager Dashboard → Ayarlar → Çıkış. Login ekranına gel.

### Adım 2.1 — Login ekranında klavye zinciri
1. **Email** alanına dokun → klavye açılır → sağ alt tuşunda **"İleri" / ">"** ikonu görmeli (TextInputAction.next)
2. Geçerli bir email yaz, klavyeden **"İleri"**'ye bas
3. **Şifre** alanına otomatik odaklanmalı, klavye açık kalmalı
4. Klavyenin sağ alt tuşu artık **"Bitir" / "✓"** olmalı (TextInputAction.done)
5. Şifre yaz, **"Bitir"**'e bas → **otomatik login** denemesi yapılır (toast / yükleme görmeli)

### Adım 2.2 — Login ekranında telefon modu
1. "Telefon ile giriş yap" butonuna bas
2. Email field'ı telefon field'ına dönüşür (10 hane, +90 prefix)
3. Telefon yaz → "İleri" → şifre alanına geç → "Bitir" → submit

### Adım 2.3 — Klavye drag-to-dismiss
1. Login formunda email alanına dokun, klavye açıl
2. Form üzerinde aşağı veya yukarı **sürüklemeye başla**
3. Klavye **otomatik kapanmalı** (keyboardDismissBehavior.onDrag)

### Adım 2.4 — Autofill (Android Password Manager)
> **Not:** Bu adım için cihazda Google Password Manager veya benzeri etkin olmalı.

1. Login email alanına odaklan → klavyenin üstünde **kayıtlı email/username önerileri** gelmeli
2. Şifre alanında → kayıtlı şifre önerisi gelmeli
3. Bir öneri seçince ilgili alan dolar

### Adım 2.5 — Register ekranında 5'li klavye zinciri
1. Login → "Hesabın yok mu?" → Register
2. **İsim → email → telefon → şifre → şifre tekrar** sırasıyla:
   - Her alanda klavyenin sağ alt tuşu "İleri"
   - Son alanda (şifre tekrar) "Bitir"
   - "Bitir" basınca register denemesi yapılır

### Adım 2.6 — Register autofill
1. Yeni şifre alanında → klavye üstünde **"Şifre öner"** veya rastgele şifre öneri çıkmalı (newPassword hint)
2. İsim alanında → kişi adı önerileri gelebilir

### Adım 2.7 — Join (davet kodu) ekranında 6'lı klavye zinciri
1. Login → "Davet kodu ile katıl" → Join
2. **Davet kodu → email → isim → telefon → şifre → şifre tekrar** sırası çalışmalı
3. Davet kodu alanında klavye **caps lock** açık olmalı (textCapitalization.characters)

✅ **PASS:** Tüm zincir tek elle, klavye kapanmadan tamamlanabiliyor.
❌ **FAIL:** Bir alanda zincir kopuyor / klavye kapanıyor → hangi alan, hangi cihaz, raporla.

---

## 3. Splash bootstrap — Network hatası ekranı + Tekrar dene

**Hedef:** Refresh token çağrısı 12 saniye içinde dönmezse splash'ta retry UI çıkmalı.

### Adım 3.1 — Normal splash (cold start)
1. Uygulamayı arka plandan **tamamen kapat** (recents'ten swipe out)
2. İkona dokun → uygulama açılır
3. Splash ekranı gelir: AidatPanel logo + alt metin + altta **küçük beyaz spinner** (CircularProgressIndicator)
4. ~800ms sonra otomatik olarak login ekranına (cached oturum yoksa) veya dashboard'a (oturum varsa) geçer

### Adım 3.2 — Splash timeout simülasyonu (uçak modu testi)
> **Bu test için cached oturum gerekir.** Önce normal akışla login ol, başarıyla dashboard'u gör.

1. Cihazı **uçak moduna** al (WiFi + mobile data kapalı)
2. Backend zaten down olduğu için bu test gerçek backend ile yapılmalı (dev_mocks ile splash retry path'i tetiklenmez çünkü mock instant döner)
3. Uygulamayı tamamen kapat, tekrar aç
4. Splash 12 saniye boyunca spinner gösterir (token expired ise refresh çağrısı timeout'a düşer)
5. **12. saniyede:** spinner kaybolur, yerine:
   - Beyaz **`cloud_off`** ikonu (32px)
   - Bold beyaz "Sunucuya bağlanılamadı"
   - Açık beyaz "İnternet bağlantını kontrol edip tekrar dene."
   - Beyaz dolgulu **"Tekrar dene"** butonu (refresh ikonu + mor yazı)
   - Altta underline beyaz "Giriş ekranına git" linki

### Adım 3.3 — "Tekrar dene" butonu
1. Yukarıdaki retry ekranındayken **uçak modunu kapat**
2. "Tekrar dene" butonuna bas
3. Spinner geri döner, başarılı bağlanma sonrası dashboard'a geçer

### Adım 3.4 — "Giriş ekranına git" linki
1. Retry ekranındayken (uçak modu hâlâ açık olabilir)
2. Underline "Giriş ekranına git" linkine bas
3. Login ekranı açılır (cached oturum kaybolmaz, sonradan tekrar deneyebilir)

✅ **PASS:** Timeout sonrası retry UI çıkıyor, "Tekrar dene" yeniden bootstrap tetikliyor.
❌ **FAIL:** Splash sonsuz spinner'da takılıyor / hata mesajı çıkmıyor → cihaz, network durumu, log raporla.

> **Not:** Dev preview modda (mock) bu test çalışmaz çünkü mock repository instant döner. Splash retry mantığı sadece **gerçek backend + ağ sorunu** kombinasyonunda görülebilir.

---

## 4. Dashboard pull-to-refresh

**Ekran:** Manager Dashboard → "Ana Sayfa" tab'ı (default sekme)

### Adım 4.1 — Pull-to-refresh tetikleme
1. Dashboard "Ana Sayfa" tab'ında, hero kartı (toplam daire / tahsilat / gecikmiş) görünür halde
2. Listenin **en üstünde**, parmağını ekrana koyup **aşağı sürükle**
3. Üstte **mor renkli refresh spinner** belirir (RefreshIndicator)
4. Spinner ~500ms-1sn döner (mock'ta hızlı)
5. Hero kartındaki rakamlar **yeniden hesaplanır** (allBuildingsDuesProvider invalidate edildi)

### Adım 4.2 — Refresh sonrası hero card değerlerini doğrula (mock)
Hero card'da şunlar olmalı:
- "Toplam Daire": **6** (b1: 4 + b2: 2)
- "Tahsilat": **%38** (14/36 = 38.88… → toStringAsFixed(0) = 38)
- "Gecikmiş": **2** (b2'deki Zeynep'in son 2 ayı)

### Adım 4.3 — Bina kartlarındaki tahsilat % doğrulama
- **Çamlık Apartmanı** kartı → "Tahsilat" → **%42** (10/24 = 41.66…)
- **Yıldız Sitesi A Blok** kartı → "Tahsilat" → **%33** (4/12 = 33.33…)

### Adım 4.4 — Bina ekleme + refresh sonrası kontrol
1. "Yeni Bina Ekle" butonuna bas, yeni bina oluştur (örn. "Test Apartmanı", 3 daire, ₺500/ay)
2. Liste otomatik güncellenir (yeni bina kartı çıkar) ama hero card hâlâ eski değerleri gösterebilir
3. Pull-to-refresh yap → yeni binanın 0 due'su olduğu için tahsilat oranı **düşer** (örn. %38 → %33)
4. Toplam daire artar (6 → 9)

### Adım 4.5 — Boş listede pull-to-refresh
1. Dev preview'da iki binayı sil (sırasıyla "Sil" → adı yaz → onayla)
2. Ana sayfa boş kalır (binalar bölümünde "Henüz bina yok" gibi mesaj)
3. Boş listede yine **aşağı sürükle** → RefreshIndicator çıkmalı (AlwaysScrollableScrollPhysics)
4. Refresh tamam → hâlâ boş, hero card "0 daire / %0 / 0 gecikmiş"

✅ **PASS:** Pull-to-refresh hem dolu hem boş listede çalışıyor, hero card değerleri güncelleniyor.
❌ **FAIL:** Pull yapılamıyor / refresh sonrası eski değerler kalıyor → cihaz + ekran görüntüsü.

---

## 5. Önceki turlardaki yenilikler (regression testi)

### 5.1 Bina CRUD
**5.1.1 Bina düzenle:**
1. Bina kartı sağ üstte ⋯ menüsü → "Düzenle"
2. Bottom sheet açılır, isim/adres/şehir alanları dolu
3. İsmi değiştir, "Kaydet"
4. Liste güncellenir, toast: "Bina güncellendi"

**5.1.2 Bina sil (tip-to-confirm):**
1. ⋯ menüsü → "Sil"
2. AlertDialog: "Bina ismini yazarak onayla: **Çamlık Apartmanı**"
3. Yanlış isim yaz → "Sil" butonu disabled kalır
4. Doğru ismi yaz → "Sil" butonu aktif
5. Sil → liste güncellenir, toast
6. **FK error simülasyonu:** Mock'ta b1 silinirse FK error fırlatılır → "Bu binada henüz daire kayıtlı, önce daireleri sil." gibi insan dostu mesaj

### 5.2 Daire CRUD
**5.2.1 Daire düzenle:**
1. Sakinler ekranında daire kartı ⋯ → "Düzenle"
2. Bottom sheet: daire numarası + kat
3. Kat -5 ile 200 arası dışında bir değer dene → validation hatası
4. Geçerli değer kaydet → toast

**5.2.2 Daire sil:**
1. ⋯ → "Sil" → basit AlertDialog (tip-to-confirm yok)
2. Onayla → liste güncellenir

### 5.3 Submit guard (rapid-tap)
**5.3.1 Bina ekle butonu:**
1. "Yeni Bina Ekle" formunu doldur
2. "Oluştur" butonuna **çok hızlı 5-10 kez bas**
3. Beklenen: sadece **1 bina** oluşur
4. Buton tıklandığı an: spinner + "Yükleniyor…" yazısı, AppBar back ikonu disabled, form alanları AbsorbPointer ile bloklanır

### 5.4 Manager Dues — Ay/Yıl filtresi
1. Manager Dashboard → "Aidat" tab'ı
2. Bina seçici altında **Ay** + **Yıl** dropdown'ları görmeli
3. Default: **bu ay** + **bu yıl** seçili (örn. "Mayıs" + "2026")
4. Sadece bu döneme ait due'lar listelenir
5. Ay dropdown'unu "Tüm aylar" yap → liste genişler (12 ay × seçili yıl)
6. Yıl dropdown'unu "Tüm yıllar" yap → tüm dönemler görünür
7. Bina değiştir → filtre seçimleri korunur, liste yeni binaya göre filtrelenir

### 5.5 Due kartında ay+yıl gösterimi
1. Bir due kartına bak: amount altında **"Mayıs 2026"** formatında (önceden "Ay: 5 • Yıl: 2026")
2. İngilizce locale → **"May 2026"**

### 5.6 Hero card — backend collectedDues döndürmese de doğru hesaplama
- Hero card'da tahsilat % değeri **0** değil → ✅ allBuildingsDuesProvider çalışıyor

### 5.7 Aidat tutarı güncelleme (affectCurrent)
1. Aidat tab → bir bina seç
2. "Aylık aidat tutarını güncelle" → yeni amount + dueDay
3. **"Mevcut aidatları da güncelle"** switch'i kapalı → sadece sonraki ay etkilenir (mevcut due'lar değişmez)
4. Switch açık + güncelle → **PENDING durumundaki** mevcut dues amount değişir, **PAID** olanlar dokunulmaz
5. Toast: "Aidat tutarı güncellendi"

### 5.8 Aidat statü değişimi
1. Bir due kartının ⋯ menüsünden "Ödendi" / "Bekliyor" / "Gecikmiş" değiştir
2. Liste anında güncellenir
3. Hero card collectionRate de değişir (rapid-tap koruması var, hızlı bas → tek istek gider)

### 5.9 Davet kodu üretme
1. Bir binanın kartından "Davet Kodu" butonuna bas
2. Davet kodu ekranı açılır
3. Bina adı + adres (`displayAddress`) görünür
4. Kod üret → kopyala → Join ekranında dene (Logout → Join)

---

## 6. Test sonuç tablosu (doldur)

| # | Senaryo | PASS / FAIL | Not |
|---|---|---|---|
| 1.1 | Sakinler ekranı header (displayAddress) | | |
| 1.2 | Dolu daire kartı (Ayşe — telefonlu) | | |
| 1.3 | Dolu fakat telefonsuz daire | | |
| 1.4 | Boş daire kartı (vacant rozeti) | | |
| 2.1 | Login email→password→submit zinciri | | |
| 2.2 | Login telefon modu zinciri | | |
| 2.3 | Drag-to-dismiss klavye | | |
| 2.4 | Login autofill önerileri | | |
| 2.5 | Register 5'li zincir | | |
| 2.6 | Register newPassword autofill | | |
| 2.7 | Join 6'lı zincir + caps lock | | |
| 3.1 | Cold start splash + spinner | | |
| 3.2 | Splash 12sn timeout retry UI | | |
| 3.3 | "Tekrar dene" butonu | | |
| 3.4 | "Giriş ekranına git" linki | | |
| 4.1 | Hero card pull-to-refresh tetiklenmesi | | |
| 4.2 | Refresh sonrası %38 / 6 / 2 değerleri | | |
| 4.3 | Bina kartı %42 ve %33 değerleri | | |
| 4.4 | Yeni bina ekle + refresh sonrası rate düşüşü | | |
| 4.5 | Boş listede pull-to-refresh | | |
| 5.1.1 | Bina düzenle bottom sheet | | |
| 5.1.2 | Bina sil tip-to-confirm + FK error | | |
| 5.2.1 | Daire düzenle (kat validasyonu) | | |
| 5.2.2 | Daire sil basit dialog | | |
| 5.3.1 | Bina ekle rapid-tap → 1 bina | | |
| 5.4 | Aidat tab Ay/Yıl filtresi | | |
| 5.5 | Due kartında "Mayıs 2026" formatı | | |
| 5.6 | Hero card tahsilat % > 0 | | |
| 5.7 | affectCurrent switch davranışı | | |
| 5.8 | Statü değişimi anında listeye yansır | | |
| 5.9 | Davet kodu ekranı + displayAddress | | |

---

## 7. Bilinen sınırlamalar (test dışı)

Bu sprint kapsamı **mobile-only**. Aşağıdakiler **henüz mobile'a entegre edilmedi**, çünkü backend bağımlı:

- **Sakin çıkarma** (yöneticinin bir sakini daireden çıkarması) — backend endpoint yok, `MOBILE-TO-BACKEND.md` §3.1 P0
- **Bildirimler / Push** — FAZ 2 kapsamında, backend bağımlı
- **Giderler (Expenses)** — FAZ 2 kapsamında, backend bağımlı
- **Toplu davet kodu üretme** — FAZ 1.5 önerisinde, henüz scope dışı

Bunlar **bu test dokümanında yer almaz**.

---

## 8. Hata raporlama formatı

Bir senaryo FAIL olursa, lütfen şunları topla:

1. **Senaryo numarası** (örn. 4.2)
2. **Cihaz + Android sürümü** (örn. Pixel 6, Android 14)
3. **Ekran görüntüsü** veya kısa **video kaydı** (Android Studio Logcat → Camera ikonu)
4. **`flutter logs`** çıktısının ilgili kısmı
5. **Beklenen / Gerçekleşen** kısa karşılaştırma

Raporu `mobile/app` branch'ında bir GitHub issue olarak aç veya doğrudan Furkan'a ilet.
