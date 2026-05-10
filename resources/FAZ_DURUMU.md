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
  - [x] GET /me/dues — sakin kendi aidatları
  - [x] PATCH /buildings/{buildingId}/dues/{dueId}/status — ödeme durumu güncelleme
  - [x] PATCH /buildings/{id}/due-amount — aidat tutarı güncelleme (`affectCurrent` opsiyonu ile mevcut PENDING aidatlara da uygular)
- [x] DuesRepository + impl
- [x] DuesNotifier (Riverpod StateNotifier)
- [x] Yönetici: Aidat listesi ekranı (bina bazlı, ödendi/bekliyor filtresi)
- [x] Yönetici: Manuel ödeme durumu güncelleme
- [x] Yönetici: Aidat tutarı güncelleme formu (PATCH /buildings/{id}/due-amount)
- [x] Sakin: Kendi aidat geçmişi ekranı

### Dashboard (features/dashboard/)
- [x] Manager Dashboard'u tam ekrana taşı (şu an buildings/presentation içinde)
- [x] Resident Dashboard'u tam ekrana taşı (şu an apartments/presentation içinde)
- [x] Dashboard summary card'ları (toplam daire, ödeme oranı, gecikme sayısı)

### Teknik Borç Temizliği
- [x] ListView.children → ListView.builder (invite_code_screen.dart:304)
- [x] ListView.children → ListView.builder (add_building_screen.dart:56)
- [x] ListView.children → ListView.builder (invite_code_result_view.dart:38)

### Faz 2 Öncesi Kritik Düzeltmeler
- [x] Oturum kalıcılığı: app cold start'ta SecureStorage'daki token okunup kullanıcı otomatik giriş yapmış sayılır (AuthNotifier.restoreSession + AuthRepository.restoreSession + AuthRemoteDataSource.refreshToken)
- [x] Splash, sabit 2 sn gecikme yerine restoreSession'ı bekler (min 800 ms branding süresi korunur)
- [x] Token süresi dolduysa /auth/refresh ile sessizce yenilenir; ağ hatasında stale token korunup ilk istekte interceptor'ın yenilemesi beklenir
- [x] Geri tuşu uygulamayı kapatmaz, arka plana atar (Android `moveTaskToBack(true)` köprüsü: MainActivity.kt + core/platform/system_navigator_bridge.dart). Process yaşamaya devam eder, kullanıcı tekrar açtığında splash gözükmeden aynı state'te uyanır.
- [x] Navigasyon sıfırlama: sekme indeksi diske yazılmaz; yalnızca process yaşarken bellekte tutulur. Yeni process (recents'tan kapatma, RAM öldürmesi, cold start) → splash'te manager/resident tab 0 ile temiz başlangıç; oturum (token) yine restoreSession ile korunur.

### Backend Sözleşme Senkronizasyonu (FLUTTER-BACKEND.md, 2026-05-10)
Backend ekibinin yayımladığı API sözleşmesine göre yapılan zorunlu uyum düzeltmeleri. Bu maddeler tamamlanmadan dues ekranı runtime'da 404 dönerdi ve birkaç başka modül de hatalı çalışıyordu.

#### Tur 1 — Dues uyumu
- [x] `PATCH /dues/{id}/status` → `PATCH /buildings/{buildingId}/dues/{dueId}/status` migrasyonu (datasource + repository + provider + manager_dues_tab.dart'a `buildingId` taşındı)
- [x] `GET /apartments/{id}/dues` çağrısı kaldırıldı (backend'de uç yok); sakin/yönetici akışları yalnızca `GET /me/dues` ve `GET /buildings/{id}/dues` üzerinden
- [x] `POST /buildings/{id}/dues/bulk` (yok) yerine `PATCH /buildings/{id}/due-amount` (`dueAmount`, `dueDay?`, `currency?`, `affectCurrent`) UI'sı; `affectCurrent=true` iken bina aidat listesi otomatik tazelenir
- [x] `apartmentDues`, `dueStatus(dueId)`, `bulkDues`, `buildingInviteCode`, `inviteCode`, `due(dueId)` ölü/yanlış sabitleri `api_constants.dart`'tan silindi; yerine `buildingDueStatus(buildingId, dueId)` ve `buildingDueAmount(buildingId)` eklendi
- [x] `DueModel` + `DueEntity` alanları sözleşmeye genişletildi: `dueDate` (DateTime?), `overdueDays` (int); ayrıca PATCH yanıtındaki `apartment.number` fallback'i ile `apartmentNumber` parse edildi (yönetici PATCH yanıtında düz `apartmentNumber` alanı gelmiyor)
- [x] Yönetici Dues kartında gecikme rozeti (overdueDays > 0 iken `OVERDUE` rengiyle) eklendi
- [x] i18n: `bulkCreate` / `createDues` / `duesCreated` anahtarları kaldırıldı; `updateDueAmount`, `dueAmountUpdated`, `dueAmountUpdateFailed`, `dueDay`, `affectCurrentDues`, `affectCurrentDuesHint`, `update`, `overdueDays`, `dueDateLabel` anahtarları TR + EN eklendi (slang regenerate edildi)

#### Tur 2 — Auth, Apartment, Building genişletmeleri
- [x] **🔴 BUG FIX**: `ApartmentModel` `resident` alanını parse etmiyordu → `BuildingResidentsScreen` tüm daireleri "BOŞ" gösteriyordu. Şimdi `ResidentInfo` value object eklendi (apartments/domain), `ApartmentModel.resident` → `ResidentModel` parse edilip entity'ye geçiriliyor. `ApartmentEntity.residentName`/`phone` getter olarak yeniden tanımlandı (geriye uyum), `isOccupied` getter eklendi. `apartments_store.dart` magic-string `'Boş Daire'` kontrolü `isOccupied` ile değiştirildi.
- [x] **🔴 GÜVENLİK**: `AuthRepositoryImpl.logout()` sunucuya `POST /auth/logout` (Bearer) atmıyordu (refresh token sunucuda invalid edilmiyordu). Şimdi `AuthRemoteDataSource.logout()` eklendi, repository önce sunucuya, sonra `SecureStorage.clearAuth()` çağırıyor; sunucu hatası yutuluyor (kullanıcı yine "çıkmış" sayılır).
- [x] `UserData` + `UserEntity` ve `RegisterResponse`'a `apartmentId` (String?) eklendi (Belge §2.1 — sakin için backend'den gelen daire bağlantısı). `UserEntity.props` da güncellendi.
- [x] `BuildingModel`'e `dueAmount` (double?, Decimal string parse), `dueDay` (int?), `currency` (String?) eklendi. `BuildingEntity` aynı alanlarla genişletildi; `toEntity()` `totalMonthlyDues = dueAmount * totalApartments` olarak hesaplıyor.
- [x] `apartment(apartmentId)` ve `apartmentResident(apartmentId)` ölü/yanlış sabitleri `api_constants.dart`'tan silindi (Belge §6: daire CRUD'u nested path altında, düz path yok). Açıklayıcı yorum bırakıldı.
- [x] `LoginRequest.email` field'ı semantik doğru şekilde `identifier` olarak yeniden adlandırıldı (Belge §3 — body `identifier` email **veya** telefon). `AuthRepository.login(identifier, password)`, `AuthNotifier.login(identifier, password, ref)` imzaları güncellendi. `LoginScreen` zaten phone/email toggle (`_usePhoneLogin`, `+90$raw` prefix) ile çalıştığı için UI değişikliği gerekmedi.

### Çıkış Kapısı
Yukarıdaki tüm `[ ]` → `[x]` olmadan ve Furkan onayı olmadan Faz 2 başlamaz.

---

## 🔒 FAZ 2 — Notifications + Expenses

**Durum:** KİLİTLİ — Faz 1 tamamlanmadan açılamaz  
**Hedef:** ~2026-06-05

> ⚠️ **BACKEND BAĞIMLILIK UYARISI** (FLUTTER-BACKEND.md §12)
> Bu fazın çoğu görevi backend'in henüz açmadığı uçlara ihtiyaç duyar.
> Faz 2'yi başlatmadan önce backend ekibinden açılan uçların listesi alınmalıdır.

### Notifications (features/notifications/)
| Görev | Backend Durumu |
|-------|----------------|
| `PUT /me/fcm-token` (FCM token kayıt) | ✅ canlı (Belge §4) |
| `GET /notifications` (bildirim listesi) | ❌ **YOK** — backend açacak |
| `PATCH /notifications/{id}/read` (okundu işaretleme) | ❌ **YOK** — backend açacak |

- [ ] **🟢 backend hazır** — NotificationEntity tanımı (FCM payload'a göre)
- [ ] **🟢 backend hazır** — `PUT /me/fcm-token` datasource + provider; Firebase Messaging onTokenRefresh'i bağla
- [ ] **🟢 backend hazır** — Push notification handler (foreground + background) ve deep-link routing
- [ ] **⚠️ backend bekliyor** — NotificationsRemoteDataSource (GET /notifications, PATCH /notifications/{id}/read)
- [ ] **⚠️ backend bekliyor** — Bildirim listesi ekranı

### Expenses (features/expenses/)
| Görev | Backend Durumu |
|-------|----------------|
| Tüm Expense uçları (`GET/POST /buildings/{id}/expenses`, `POST /expenses/{id}/proof`) | ❌ **YOK** — backend açacak |

- [ ] **⚠️ backend bekliyor** — ExpenseEntity tanımı
- [ ] **⚠️ backend bekliyor** — ExpensesRemoteDataSource
- [ ] **⚠️ backend bekliyor** — Gider listesi ekranı
- [ ] **⚠️ backend bekliyor** — Gider ekleme formu (kategori + tutar + açıklama)
- [ ] **⚠️ backend bekliyor** — Makbuz fotoğrafı yükleme (multipart)

---

## 🔒 FAZ 3 — Tickets + Reports

**Durum:** KİLİTLİ — Faz 2 tamamlanmadan açılamaz  
**Hedef:** ~2026-06-19

> ⚠️ **TAM BACKEND BAĞIMLILIĞI** (FLUTTER-BACKEND.md §12)
> Bu fazın **TAMAMI** backend'in henüz açmadığı uçlara dayanır.
> Backend tickets/reports modüllerini canlıya almadan Faz 3 AKTİF edilemez.

### Tickets (features/tickets/)
| Görev | Backend Durumu |
|-------|----------------|
| Tüm Ticket uçları | ❌ **YOK** — backend açacak |

- [ ] **⚠️ backend bekliyor** — TicketEntity + TicketUpdateEntity tanımları
- [ ] **⚠️ backend bekliyor** — TicketsRemoteDataSource
- [ ] **⚠️ backend bekliyor** — Ticket listesi ekranı (yönetici + sakin)
- [ ] **⚠️ backend bekliyor** — Ticket detay + güncelleme ekranı
- [ ] **⚠️ backend bekliyor** — Ticket oluşturma formu

### Reports (features/reports/)
| Görev | Backend Durumu |
|-------|----------------|
| `GET /buildings/{id}/reports`, PDF export | ❌ **YOK** — backend açacak |

- [ ] **⚠️ backend bekliyor** — GET /buildings/{id}/reports bağlama
- [ ] **⚠️ backend bekliyor** — Aylık özet rapor ekranı
- [ ] **⚠️ backend bekliyor** — PDF export

---

## 🔒 FAZ 4 — Subscription + Profile

**Durum:** KİLİTLİ — Faz 3 tamamlanmadan açılamaz  
**Hedef:** ~2026-07-03

> Backend ekibi profil ve şifre sıfırlama uçlarını **canlıya almış** (Belge §3, §4).
> Sadece RevenueCat webhook backend'de henüz yok — onun için satın alma akışı yine eklenebilir, webhook ileride tamamlanır.

### Profil (features/profile/)
| Görev | Backend Durumu |
|-------|----------------|
| `GET /me`, `PUT /me`, `DELETE /me` (KVKK soft delete) | ✅ canlı |
| `PUT /me/password` (NOT POST — belge `PUT` diyor) | ✅ canlı |
| `PUT /me/language` (NOT POST — belge `PUT` diyor) | ✅ canlı |
| `POST /auth/forgot-password`, `POST /auth/reset-password` | ✅ canlı (6 haneli kod, Resend ile e-posta) |

- [ ] Profil bilgileri ekranı: `GET /me` ile yeniden yükle, `PUT /me` ile name/phone/language güncelle
- [ ] Şifre değiştirme ekranı: `PUT /me/password` (`currentPassword`, `newPassword`); başarıdan sonra `refreshTokenVersion` arttığı için sessiz logout + login akışı
- [ ] Dil değiştirme: `PUT /me/language` (UI zaten lokalde dil değiştirebiliyor, sunucuya da yansıt)
- [ ] **🆕** KVKK Hesap Kapatma ekranı: `DELETE /me` (yönetici hesabıysa 409 → "Önce binalarınızı silmelisiniz" hata mesajı)
- [ ] **🆕** Şifremi Unuttum akışı: LoginScreen'e link → `POST /auth/forgot-password` (her zaman 200 döner — enumeration yok); ardından kod giriş ekranı → `POST /auth/reset-password` (6 karakter alfabesi `23456789ABCDEFGHJKLMNPQRSTUVWXYZ`, sunucu trim + büyük harf)
- [ ] Logout ekranı/butonu (FAZ 1 Tur 2'de sunucu çağrısı eklendi; FAZ 4'te ek olarak "Tüm cihazlardan çıkış yap" çağrısı için backend ek uç gerekirse not düşülecek)

### Subscription (features/subscription/)
| Görev | Backend Durumu |
|-------|----------------|
| RevenueCat webhook | ❌ **YOK** — backend açacak |

- [ ] **⚠️ backend bekliyor** — RevenueCat SDK entegrasyonu (mobile tarafı eklenebilir, ama webhook olmadan abonelik durumu sunucuya yansımaz)
- [ ] **⚠️ backend bekliyor** — Abonelik ekranı (plan seçimi, aktif plan gösterimi — sunucu durumunu okuyamaz)

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
