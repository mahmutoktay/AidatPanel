# AidatPanel — Canlı Faz Durumu

**Bu dosya, faz geçişlerinin tek yetkili kaynağıdır.**  
**AI asistanlar bu dosyayı her oturumun başında okur ve yalnızca AKTİF fazda çalışır.**

---

## MEVCUT AKTİF FAZ

```
▶ FAZ 1 — Dues (Aidat) + Dashboard
  Hedef: ~2026-05-22
  Onay: BEKLİYOR
```

---

## FAZ 0 — Foundation

**Durum:** TAMAMLANDI ✅  
**ONAY: Furkan ✅**

### Auth
- [x] Login (email + şifre, JWT token alma)
- [x] Register (yönetici kaydı)
- [x] Join (davet koduyla sakin kaydı)
- [x] Token refresh (otomatik, 401'de devreye girer)
- [x] Logout (token temizleme)
- [x] Splash screen (role-based routing: manager / resident)

### Buildings
- [x] Bina listeleme
- [x] Bina oluşturma (AddBuildingScreen)
- [x] Davet kodu üretme ve görüntüleme (InviteCodeScreen)
- [x] Sakin listesi görüntüleme (BuildingResidentsScreen)
- [x] Manager Dashboard ekranı

### Apartments
- [x] Daire listeleme
- [x] Daire oluşturma ve silme
- [x] Sakin atama
- [x] Resident Dashboard ekranı

### Güvenlik
- [x] JWT access + refresh token yönetimi
- [x] flutter_secure_storage (Android: EncryptedSharedPreferences, iOS: Keychain)
- [x] HTTPS zorlaması
- [x] LogInterceptor yalnızca kDebugMode'da aktif
- [x] JWT exp claim'inden expiry parsing
- [x] Input validation (email, şifre, telefon, isim, tutar)
- [x] Kullanıcıya teknik hata mesajı gösterilmemesi

### i18n
- [x] Slang (TR + EN), 213 anahtar/dil
- [x] Runtime dil değiştirme
- [x] Dil tercihi SecureStorage'da kalıcı
- [x] Tüm mevcut ekranlar Türkçe + İngilizce

### Core Altyapı
- [x] Clean Architecture (domain / data / presentation)
- [x] Riverpod 2.5 (StateNotifier pattern)
- [x] GoRouter 13 (auth guard, role-based redirect)
- [x] DioClient (JWT interceptor, refresh logic)
- [x] 76+ API endpoint tanımlı (api_constants.dart)

---

## FAZ 1 — Dues (Aidat) + Dashboard ▶ AKTİF

**Durum:** DEVAM EDİYOR  
**Hedef:** ~2026-05-22  
**ONAY:** BEKLİYOR — `ONAY: Furkan ✅` satırı Furkan tarafından yazılacak

### Dues (features/dues/)
- [x] DueEntity tanımı (features/dues/domain/entities/due_entity.dart)
- [x] DueModel (JSON serialization, features/dues/data/models/)
- [x] DuesRemoteDataSource:
  - [x] GET /buildings/{id}/dues — bina aidat listesi
  - [x] GET /apartments/{id}/dues — daire aidat listesi
  - [x] GET /me/dues — sakin kendi aidatları
  - [x] PATCH /dues/{id}/status — ödeme durumu güncelleme
  - [x] POST /buildings/{id}/dues/bulk — toplu aidat oluşturma
- [x] DuesRepository + impl
- [x] DuesNotifier (Riverpod StateNotifier)
- [x] Yönetici: Aidat listesi ekranı (bina bazlı, ödendi/bekliyor filtresi)
- [x] Yönetici: Manuel ödeme durumu güncelleme
- [x] Yönetici: Toplu aidat oluşturma formu
- [x] Sakin: Kendi aidat geçmişi ekranı

### Dashboard (features/dashboard/)
- [x] Manager Dashboard'u tam ekrana taşı (şu an buildings/presentation içinde)
- [x] Resident Dashboard'u tam ekrana taşı (şu an apartments/presentation içinde)
- [x] Dashboard summary card'ları (toplam daire, ödeme oranı, gecikme sayısı)

### Teknik Borç Temizliği
- [x] ListView.children → ListView.builder (invite_code_screen.dart:304)
- [x] ListView.children → ListView.builder (add_building_screen.dart:56)
- [x] ListView.children → ListView.builder (invite_code_result_view.dart:38)

### Çıkış Kapısı
Yukarıdaki tüm `[ ]` → `[x]` olmadan ve Furkan onayı olmadan Faz 2 başlamaz.

---

## 🔒 FAZ 2 — Notifications + Expenses

**Durum:** KİLİTLİ — Faz 1 tamamlanmadan açılamaz  
**Hedef:** ~2026-06-05

### Notifications (features/notifications/)
- [ ] NotificationEntity tanımı
- [ ] NotificationsRemoteDataSource (GET /notifications, PATCH /notifications/{id}/read, POST /me/fcm-token)
- [ ] FCM token kayıt akışı (uygulama açılışında)
- [ ] Bildirim listesi ekranı
- [ ] Push notification handler (foreground + background)

### Expenses (features/expenses/)
- [ ] ExpenseEntity tanımı
- [ ] ExpensesRemoteDataSource (GET/POST /buildings/{id}/expenses, GET /expenses/{id}, POST /expenses/{id}/proof)
- [ ] Gider listesi ekranı
- [ ] Gider ekleme formu (kategori + tutar + açıklama)
- [ ] Makbuz fotoğrafı yükleme

---

## 🔒 FAZ 3 — Tickets + Reports

**Durum:** KİLİTLİ — Faz 2 tamamlanmadan açılamaz  
**Hedef:** ~2026-06-19

### Tickets (features/tickets/)
- [ ] TicketEntity + TicketUpdateEntity tanımları
- [ ] TicketsRemoteDataSource
- [ ] Ticket listesi ekranı (yönetici + sakin)
- [ ] Ticket detay + güncelleme ekranı
- [ ] Ticket oluşturma formu

### Reports (features/reports/)
- [ ] GET /buildings/{id}/reports bağlama
- [ ] Aylık özet rapor ekranı
- [ ] PDF export

---

## 🔒 FAZ 4 — Subscription + Profile

**Durum:** KİLİTLİ — Faz 3 tamamlanmadan açılamaz  
**Hedef:** ~2026-07-03

- [ ] RevenueCat SDK entegrasyonu
- [ ] Abonelik ekranı (plan seçimi, aktif plan gösterimi)
- [ ] Profil bilgileri ekranı (GET /me)
- [ ] Şifre değiştirme ekranı (POST /me/password)
- [ ] Dil değiştirme (POST /me/language)
- [ ] Logout ekranı/butonu

---

## 🔒 FAZ 5 — Hardening + Testing

**Durum:** KİLİTLİ — Faz 4 tamamlanmadan açılamaz  
**Hedef:** ~2026-07-10

- [ ] Certificate pinning aktifleştirme
- [ ] Build flavors (dev / staging / prod)
- [ ] Obfuscation (--obfuscate --split-debug-info)
- [ ] Auth provider unit testleri
- [ ] DioClient interceptor testleri
- [ ] Widget testleri (Login, Register)
- [ ] Integration test (login → dashboard akışı)
- [ ] Hedef: %30+ test coverage
- [ ] API response önbellekleme
- [ ] Pagination implementasyonu

---

## 🔒 FAZ 6 — v1.0.0 Lansman

**Durum:** KİLİTLİ — Faz 5 tamamlanmadan açılamaz  
**Hedef:** ~2026-07-14

- [ ] App Store (iOS) submit
- [ ] Google Play Store submit
- [ ] Landing page güncelleme
- [ ] Firebase Analytics entegrasyonu
- [ ] Firebase Crashlytics
- [ ] v1.0.0 release tag

---

## Nasıl Kullanılır

1. **AI asistan** her oturumda bu dosyayı okur, hangi fazın aktif olduğunu görür.
2. **Sadece aktif fazın** görevlerini yapar; kilitli fazlara dokunmaz.
3. Aktif fazın tüm `[ ]` öğeleri `[x]` olunca AI, Furkan'a "Faz X tamamlandı, onaylar mısın?" diye sorar.
4. **Furkan** bu dosyayı açar, onay satırını yazar: `ONAY: Furkan ✅`
5. AI bir sonraki oturumda bu satırı görür ve bir sonraki fazı AKTİF olarak işler.
