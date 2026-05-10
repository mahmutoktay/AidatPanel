# AidatPanel — Faz 1 tamamlama planı (sıralı)

Bu dosya, Faz 1’in **eksiksiz ve sorunsuz** kapanması için önerilen iş sırasını tanımlar.

## Süreç kuralı (Cursor / geliştirme)

- **Her adım başlamadan önce** senin **onayın** veya **fikrin** alınacak (atlamak, birleştirmek, ertelemek serbest).
- Bir adım “tamamlandı” sayılmadan bir sonraki adıma geçilmemesi önerilir; ancak **0 ve 1** birlikte ele alınabilir (aynı karar turunda).

---

## 0 — API sözleşmesi ve rota çakışması (karar / onay)

**Amaç:** Aidat endpoint’lerinin URL’lerini netleştirmek; Express’te **çakışma** riskini sıfırlamak.

**Durum (çözüldü — Seçenek A):** Aidat listesi / durum / bina aidat bedeli **`buildingRoutes`** altında: `GET/PATCH /api/v1/buildings/:id/...`. Sakin için **`GET /api/v1/me/dues`** ayrı **`meRoutes`** ile. Eski `dueRoutes.js` kaldırıldı.

**Senden istenen karar (örnek seçenekler):**

- **A)** Aidatları bina altında topla: `GET/PATCH ...` → `/api/v1/buildings/:buildingId/dues` vb. (`buildingRoutes` içine nested veya ayrı mount ama path’ler bina altında).
- **B)** Aidatları ayrı prefix altında topla: `/api/v1/dues/...` (mevcut handler path’leri buna göre yeniden düzenlenir).
- **C)** Senin önerdiğin başka bir isimlendirme (mobil ekiple uyumlu olmalı).

**Çıktı:** Seçilen URL tablosu (1 sayfa) + Flutter `api_constants` ile hizalama notu.

**Onay:** [x] Adım 0 — Seçenek A (bina altı + `/me/dues`)

---

## 1 — Aidat rotalarını uygulamaya bağlama (fonksiyonel kapanış)

**Amaç:** Aidat API’sinin gerçekten dinlenmesi.

**İşler:**

- `buildingRoutes.js` + `meRoutes.js` + `index.js` (`/api/v1/me`).
- Controller / Zod şemaları ile path uyumu (`id`, `dueId`).

**Onay:** [x] Adım 1 (kod tarafı uygulandı; senden “kabul / ek düzeltme” onayı beklenir)

---

## 2 — Yetkilendirme (rol) katmanı: MANAGER / RESIDENT

**Amaç:** Faz 1’de “sakin yönetici endpoint’ine erişemez” garantisi.

**İşler:**

- `authMiddleware` sonrası `requireRole(['MANAGER'])` gibi ince bir middleware.
- Özellikle: bina/daire CRUD, davet kodu üretimi, aidat yönetimi → **MANAGER**.
- Sakin tarafı: `GET .../me/dues` (veya seçtiğin eşdeğer) → **RESIDENT** (ve gerekiyorsa “daire atanmış kullanıcı” kontrolü).

**Senden danışılacak:** Rol kontrolünü şimdilik sadece kritik endpoint’lerde mi yapalım, yoksa tüm `/api/v1/buildings/**` için mi zorunlu olsun?

**Onay:** [x] Adım 2 — `requireRoles`: bina/daire/davet/aidat → `MANAGER`; `GET /me/dues` → `RESIDENT`

---

## 3 — Bina oluşturma transaction güvenliği (deadlock / paralellik)

**Amaç:** `createBuildingService` içinde tek transaction’da çok sayıda paralel `INSERT` (`Promise.all`) kaynaklı **deadlock** riskini azaltmak.

**İşler:**

- Daire ve aidat oluşturmayı **sıralı** (veya kontrollü batch) hale getirmek.
- İşlem süresi uzarsa: kullanıcıya dönüş mesajı / timeout stratejisi (isteğe bağlı, kısa not).

**Onay:** [x] Adım 3 — daire + aidat INSERT sıralı; transaction `timeout: 60s`, `maxWait: 10s`

---

## 4 — `dueDate` ve zaman dilimi (Türkiye tutarlılığı)

**Amaç:** Sunucu UTC iken aidat son gününün “bir gün kayması” problemini engellemek.

**İşler:**

- Aidat son tarihi üretiminde **Europe/Istanbul** (veya ürün kararı: tamamen UTC) politikası seçmek.
- Kodda `new Date(y, m, d, ...)` yerine seçilen politikaya uygun üretim.

**Senden danışılacak:** Tek tenant TR mi, yoksa ileride çok ülke düşünülüyor mu?

**Karar:** Tek tenant TR — `endOfDueDayIstanbul` (TRT UTC+3, gün sonu); aidat üretiminde “şu anki ay” için `getIstanbulYearMonth` (`Intl`, `Europe/Istanbul`).

**Onay:** [x] Adım 4 tamam

---

## 5 — Aidat listeleme performansı (N+1)

**Amaç:** `getDuesByBuildingService` içindeki daire/sakin sorgularını tek veya sabit sayıda sorguya indirgemek.

**Onay:** [x] Adım 5 — `getDuesByBuildingService` tek `findMany` + `apartment.resident` include; yanıtta `resident` kökte (önceki sözleşme)

---

## 6 — Kod sağlığı: tekrarları kaldırma

**Amaç:** `validateInviteCode` gibi iki yerde tanımlı mantığı tek kaynağa indirmek; ölü/çift import riskini azaltmak.

**İşler:**

- `inviteCodeController.js` vs `authService.js` ayrıştırması netleşsin (tek modül: örn. `inviteCodeService.js`).

**Onay:** [x] Adım 6 — `validateInviteCode` → `inviteCodeService.js`; controller/authService tekrarı kaldırıldı; kullanılmayan `markInviteCodeAsUsed` silindi

---

## 7 — Paket / script temizliği

**Amaç:** “Çalıştırınca kırılan” komutları kaldırmak.

**İşler:**

- `package.json` içindeki `update-reports` script’i: ya kaldır, ya script’i geri getir.

**Onay:** [x] Adım 7 — `package.json` içindeki kırık `update-reports` script’i kaldırıldı

---

## 8 — Güvenlik: örnek ortam dosyası ve sırlar

**Amaç:** Repoda **gerçek credential** izi bırakmamak.

**İşler:**

- `.env.example` içeriğini placeholder’a çevirmek.
- Eğer gerçek URL/sırlar repoya girdiyse: **rotate** (DB şifresi, JWT secret vb.) prosedür notu.

**Onay:** [x] Adım 8 — `.env.example` yerel placeholder; gerçek Neon URL kaldırıldı; rotate notu eklendi

---

## 9 — Auth sertleştirme (Faz 1 minimum bar)

**Amaç:** Zayıf şifre ve stateless JWT pratiklerini Faz 1 seviyesinde toparlamak.

**Kararlar:**

- Şifre minimum **6** karakter (register / join).
- **phone** opsiyonel; `join` şemasına eklendi + boş string `optionalPhone` ile temizlenir (Zod’un bilinmeyen alan silmesi sorunu giderildi).
- **logout:** `User.refreshTokenVersion` + refresh JWT içinde `rv` — çıkışta sürüm artırılır; ek tablo/Redis yok. Eski refresh token’lar reddedilir. Access token en fazla mevcut süresine kadar (ör. 15 dk) geçerli kalabilir; kabul edilen trade-off.

**Onay:** [x] Adım 9 tamam — DB migration: `refreshTokenVersion`

---

## 10 — Eksik Faz 1 endpoint’leri (ürün ihtiyacına göre)

**AIDATPANEL.md** ve KVKK notu ile uyum için adaylar:

- `GET /api/v1/me` (profil)
- `PUT /api/v1/me` (profil güncelleme — alanları sen seç)
- `DELETE /api/v1/me` (KVKK silme — soft delete mi hard delete mi? **Danışma gerekli**)
- `POST /api/v1/auth/forgot-password` + `POST /api/v1/auth/reset-password` (Resend) — **Faz 1’e şart mı, yoksa 1.1 mi?** (**Danışma gerekli**)

**Uygulama (2026-05-10):** Profil + şifre + dil + FCM token + **KVKK soft delete** (PII maskesi, yöneticide bina varsa 409) + **forgot/reset** (Resend opsiyonel; yoksa geliştirmede konsola token log). `AIDATPANEL.md` Faz 1 maddesi 672–680: backend çekirdek auth/aidat satırları bu uçlarla hizalanır; **FCM push gönderimi**, **RevenueCat**, **landing** hâlâ ayrı işler (mobil/web).

**Onay:** [x] Adım 10 tamam (alt küme: profil + KVKK soft + şifre sıfırlama + FCM token saklama)

---

## 11 — Otomatik test (minimum ama gerçek)

**Amaç:** Regresyonu yakalamak; özellikle rota mount + rol + aidat akışı.

**İşler:**

- Jest/Vitest + supertest ile birkaç “happy path” + birkaç “403/401”.
- `test.py`’yi ya güncelle ya da “manuel smoke” olarak README notu (kullanıcı kuralına göre: sen README istemediğin sürece sadece plan notu).

**Onay:** [ ] Adım 11 tamam

---

## 12 — Dokümantasyon senkronu (tek kaynak)

**Amaç:** `AIDATPANEL.md` endpoint örneklerini **gerçek `/api/v1`** şemasına çekmek; Prisma snippet’ini “canonical schema: prisma/schema.prisma” diye düzeltmek.

**Not:** Bu adım kod davranışını değiştirmez; ekip uyumu için değerlidir.

**Onay:** [ ] Adım 12 tamam

---

## 13 — Dağıtım / operasyon checklist (Faz 1 kapanış)

**Amaç:** VPS’de PM2 + reverse proxy + migrate akışının tek sayfada tekrarlanabilir olması.

**İşler:**

- `npx prisma migrate deploy`, health check endpoint (isteğe bağlı), log formatı notu.

**Onay:** [ ] Adım 13 tamam

---

## Faz 1 “tanımı done” kriterleri (özet)

- [ ] Aidat endpoint’leri **çakışmasız** ve **mount edilmiş**
- [ ] Rol ayrımı kritik yüzeyde garanti
- [ ] Bina oluşturma + aidat üretimi **transaction güvenli** ve **tarih politikası net**
- [ ] Liste endpoint’lerinde bariz N+1 yok
- [ ] Repoda sırlı `.env.example` yok; gerekirse rotate yapıldı
- [x] Karar verilen auth/KVKK endpoint’leri tamam (Adım 10)
- [ ] Minimum otomatik test yeşil

---

## Sonraki adım (şimdi)

**Adım 11** — otomatik test (Vitest/Jest + supertest veya `test.py` genişletmesi + CI).
