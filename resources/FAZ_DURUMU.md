# AidatPanel — Canlı Faz Durumu

**Bu dosya, faz geçişlerinin tek yetkili kaynağıdır.**  
**AI asistanlar bu dosyayı her oturumun başında okur ve yalnızca AKTİF fazda çalışır.**

---

## MEVCUT AKTİF FAZ

```
▶ FAZ 1 — Tur 5: Backend uyum aksiyon listesi
  Hedef: ~2026-05-15
  Durum: AKTİF — backend P0/P1/P2 tamam, mobile UI sırası başladı
  Aksiyon: aşağıdaki §FAZ 1 / Tur 5 görev listesi
  Devam koşulu: 6 madde de [x] olunca Furkan onayı + FAZ 2'ye geçiş
```

> Mobile FAZ 1 koru (Tur 1-4) tamamlandı (ONAY: Furkan ✅, 2026-05-10).
> Backend `backend/yedek` (commit `8cc2152`) ile mobile'ın §3 P0–P2
> taleplerinin tümü karşılandı. Tur 5'te bu uçların mobile UI bağlamasını
> yapıyoruz. Detaylar `resources/MOBILE-TO-BACKEND.md` §10'da; her madde
> tamamlandıkça hem buraya hem oraya `[x]` işareti gelir.
>
> FAZ 2 (Notifications + Expenses) hâlâ backend bekliyor; Tur 5 bittikten
> sonra geçilebilir.

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

## FAZ 1 — Dues (Aidat) + Dashboard ✅ TAMAMLANDI

**Durum:** TAMAMLANDI ✅
**Tamamlanma:** 2026-05-10
**ONAY: Furkan ✅** (Tur 1 + Tur 2 + Tur 3 + Tur 4 dahil)

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

#### Tur 3 — Yönetim CRUD Tamamlama (bina + daire düzenleme/silme UI)
Backend uçları FAZ 0'dan beri hazırdı (Belge §5, §6) ama UI yoktu. Yönetici binayı/daireyi sadece oluşturup listeleyebiliyordu — düzenleme/silme yapamıyordu. FAZ 2/3 backend bekliyor; bu eksiği FAZ 1 içinde kapatıyoruz.

- [x] **🔴 BUG FIX**: `BuildingModel.toEntity()` `city`'yi `address` ile concat ediyordu ("Adres, Şehir") → düzenleme ekranında ayrı alan olarak gösterilemiyordu. `BuildingEntity`'ye ayrı `city` alanı eklendi; UI'da `displayAddress` getter'ı ile birleşik gösterim sağlanıyor (`building_residents_screen.dart`, `manager_dashboard_screen.dart`, `invite_code_screen.dart` güncellendi).
- [x] **🔴 BUG FIX**: `BuildingResidentsScreen._buildResidentCard` `apt.phone != null` ile `isOccupied` belirliyordu → telefon paylaşmamış sakinler "BOŞ" görünüyordu. `apt.isOccupied` (resident != null) kullanımına geçildi; telefon satırı `apt.phone != null` kontrolüyle ayrıca koşullandı (null safety).
- [x] `ApartmentsNotifier.editApartment()` eklendi (datasource + repository zaten vardı). Backend yanıtında `resident` dönmediği için merge ile mevcut sakini koruyor (`copyWith(resident: existing.resident)`).
- [x] `BuildingsNotifier.updateBuilding()` ve `removeBuilding()` artık hata olduğunda `AsyncValue.error` set etmek yerine **rethrow** ediyor (state'i bozmuyor). Aynı düzeltme `ApartmentsNotifier.removeApartment()` ve `editApartment()` için de uygulandı. UI snackbar gösteriyor.
- [x] `EditBuildingBottomSheet` widget'ı (name + address + city; sadece değişen alanlar PUT body'sine konur).
- [x] `DeleteBuildingDialog` widget'ı (tip-to-confirm: bina adı yazılmadan sil butonu pasif; FK hatası "Bu binayı silemezsiniz: hâlâ daire/sakin/aidat var..." mesajına insanlaştırılıyor).
- [x] `EditApartmentBottomSheet` widget'ı (number + floor; floor backend §6 §6 -5..200 aralığında doğrulanıyor).
- [x] `DeleteApartmentDialog` widget'ı (basit AlertDialog; FK hatası "Önce sakin hesabını kapatmalı" mesajına insanlaştırılıyor).
- [x] `ManagerDashboardScreen` "Binalarım" sekmesinde her bina kartının sağ üstüne `PopupMenuButton` (Düzenle / Sil) eklendi.
- [x] `BuildingResidentsScreen` her daire kartına `PopupMenuButton` (Düzenle / Sil) eklendi.
- [x] Bina kartına bina başına aylık aidat tutarı rozeti eklendi (`dueAmount` > 0 iken `monthlyDuesPerApartment` etiketiyle).
- [x] i18n: `editBuilding`, `deleteBuilding`, `buildingUpdated`, `buildingDeleted`, `buildingUpdateFailed`, `buildingDeleteFailed`, `buildingDeleteFailedFK`, `deleteBuildingHeader`, `deleteBuildingTypeHint`, `deleteBuildingTypeFieldLabel`, `buildingNameMismatch`, `editApartment`, `deleteApartment`, `apartmentUpdated`, `apartmentDeleted`, `apartmentUpdateFailed`, `apartmentDeleteFailed`, `apartmentDeleteFailedFK`, `deleteApartmentConfirm`, `apartmentNumberLabel`, `floorLabel2`, `floorOptional`, `buildingNameField`, `buildingAddressField`, `buildingCityField`, `monthlyDuesPerApartment` anahtarları TR + EN eklendi (slang regenerate edildi).

> **NOT — Sakin atamayı kaldırma:** Backend belgesinde (Belge §6) bir manager'ın sakini bir daireden çıkaracağı endpoint yok. `PUT /buildings/:bId/apartments/:id` body'si yalnızca `number` ve `floor` kabul ediyor. Bu özellik için backend ekibinden `DELETE /buildings/:bId/apartments/:id/resident` (veya `PATCH .../apartments/:id { resident: null }`) ucu açılması gerekir. Şimdilik daire silmek implicit olarak resident ilişkisini de kaldırır (FK hatası olmazsa); fakat aidat geçmişini de siler — kullanıcı önce sakinin `DELETE /me` (KVKK soft delete) ile hesabını kapatmasını beklemelidir. **Backend ekibine talep iletilmeli.**

#### Tur 4 — Submit Guard (rapid-tap koruması) ve Dev Preview altyapısı
Manuel test sırasında "Bina Oluştur" butonuna art arda basılınca aynı binanın 10+ kez oluştuğu fark edildi (her bina ayrıca N daire seed ettiği için 10×N daire). 50+ yaş kullanıcı kuralında dürtüklenme sık; kapsamlı çift katman koruma uygulandı.

- [x] **🔴 BUG FIX (rapid-tap)**: `BuildingsNotifier.addBuilding`'e `_isCreating` in-flight bayrağı eklendi (defansif katman). `ApartmentsNotifier.addApartment`, `DuesNotifier.updateStatus` ve `DuesNotifier.updateBuildingDueAmount` aynı pattern'le korundu. Aynı submit boyunca ikinci çağrı sessizce yutulur (`return null` / `return false`).
- [x] **AddBuildingScreen UI fix**: `_submitting` state eklendi. Submit boyunca: birincil buton disable + spinner + "Yükleniyor…" etiketi, "Vazgeç" butonu disable, AppBar geri ok disable, form alanları `AbsorbPointer` ile kilitli, sistem geri tuşu `PopScope(canPop: !_submitting)` ile bastırılıyor (yarım state oluşmasın: bina yaratıldı ama daireler seed edilmedi gibi).
- [x] **Dev Preview altyapısı**: Sunucu yokken UI test etmek için `lib/dev/dev_mocks.dart` (in-memory `MockAuthRepository`, `MockBuildingRepository`, `MockApartmentRepository`, `MockDuesRepository`; bina silmede FK simülasyonu var) ve `lib/main_dev.dart` (ProviderScope.overrides ile mock'ları inject eder, sağ üstte turuncu `DEV` rozeti gösterir) eklendi. Çalıştırma: `flutter run -t lib/main_dev.dart`. Production main.dart bu dosyaları import etmediği için zarar yok.
- [x] `authRepositoryProvider` `Provider<AuthRepository>` olarak interface tipinde (eskiden `Provider<AuthRepositoryImpl>` örtük tip — mock override edilemiyordu). Mock ProviderScope.override için gerekli.

#### Tur 5 — Backend uyum aksiyon listesi (▶ AKTİF)
Abdullah'ın `backend/yedek` branch'i (commit `8cc2152`) ile mobile §3 talepleri **5/5** karşılandı (sakin çıkar, profil, KVKK, şifre sıfırlama, sakin aidat). Mobile bu uçları sırasıyla UI'ya bağlıyor. Detay + tahminler: `resources/MOBILE-TO-BACKEND.md` §10.

- [ ] **1 — Sakin çıkarma UI** (`DELETE /apartments/:id/resident`): `BuildingResidentsScreen` daire kart menüsüne "Sakini Çıkar" + AlertDialog onayı + apartments invalidate. Backend 403/404 mesajları insanlaştırılacak. (~1.5 sa)
- [ ] **2 — Bina formu uyumu** (`POST /buildings`): `AddBuildingScreen`'de `totalFloors` (1-200) + `apartmentsPerFloor` (1-50) zorunlu hale gel; `_seedApartmentsIfNeeded` fallback loop'u sil (backend transaction içinde otomatik seed ediyor — `buildingService.createBuildingService` doğrulandı). (~2 sa)
- [ ] **3 — Server-side dues filter** (`GET /buildings/:id/dues?month=&year=&status=`): `manager_dues_tab.dart` ay/yıl filtresi değişince repo çağrısına query param ekle; client-side filtreleme kalksın (büyük listede performans). `getMyDues` aynı şekilde sakin tarafında da. (~1.5 sa)
- [ ] **4 — Şifre değiştir UI** (`PUT /me/password`): Ayarlar tab'ında yeni ekran. Başarı sonrası backend `refreshTokenVersion++` yaptığı için **otomatik logout + login**. (~2 sa)
- [ ] **5 — Hesabı kapat UI** (`DELETE /me`): Ayarlar tab'ında "Hesabı Kapat" + tip-to-confirm. **409 yöneticide bina var** mesajı insanlaştırılacak ("Önce binaları silin veya başka yöneticiye devredin"). (~1 sa)
- [ ] **6 — Şifremi unuttum akışı** (`POST /auth/forgot-password` + `POST /auth/reset-password`): Login'e link + 2 ekran (email gir → 6 char kod + yeni şifre). Backend her zaman 200 döner (enumeration leak yok), kod alfabesi `23456789ABCDEFGHJKLMNPQRSTUVWXYZ`. (~3 sa)

> **Toplam tahmin:** ~11 saat. Tur 5 bittiğinde mobile FAZ 1'in tüm backend ucu karşılanmış olur; FAZ 2'ye geçilebilir.
>
> **Backend'den küçük P3 talep:** `GET /buildings` yanıtına `_count.apartments` (mobile dashboard kart doğruluğu için). Tur 5 boyunca paralel — bloklayıcı değil.

### Çıkış Kapısı
Yukarıdaki tüm `[ ]` → `[x]` olmadan ve Furkan onayı olmadan Faz 2 başlamaz.

---

## ⏸ FAZ 2 — Notifications + Expenses (BACKEND BEKLEMEDE)

**Durum:** BEKLEMEDE — backend uçları açılana kadar başlatılamıyor
**Hedef:** ~2026-06-05
**FAZ 1 onay:** ✅ alındı, ön koşul tamam

> ⚠️ **BACKEND BAĞIMLILIK UYARISI** (FLUTTER-BACKEND.md §12)
> Bu fazın çoğu görevi backend'in henüz açmadığı uçlara ihtiyaç duyar.
> Faz 2'yi başlatmadan önce backend ekibinden açılan uçların listesi alınmalıdır.
> **Talep dosyası:** `resources/MOBILE-TO-BACKEND.md` (mobile→backend rapor).

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

> **NOT:** Şifre değiştirme + KVKK hesap kapatma + Şifremi unuttum akışları
> FAZ 1 / Tur 5'e **erkene çekildi** (backend bu uçları öne aldı). Aşağıda
> kalan maddeler ileri seviye iyileştirmeler ve sunucuya dil tercihi
> yazımı; "Tüm cihazlardan çıkış" gibi opsiyonel ekler.

- [ ] Profil bilgileri ekranı: `GET /me` ile yeniden yükle, `PUT /me` ile name/phone güncelle (Tur 5 §10/4 ile birlikte gelen şifre değiştir UI'sının yanına eklenebilir)
- [ ] `PUT /me/language` — UI zaten lokalde dil değiştiriyor; sunucuya yansıtmak (bildirim e-postaları için lazım, FAZ 2'ye kadar düşük öncelik)
- [ ] "Tüm cihazlardan çıkış yap" — backend `refreshTokenVersion++` ile aslında zaten tek noktadan çıkış yapıyor; kullanıcıya görünür kontrol gerekirse not düşülür

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
