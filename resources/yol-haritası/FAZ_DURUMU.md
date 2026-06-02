# AidatPanel — Yol Haritası ve Faz Durumu

**Tek kaynak:** Tüm fazlar, checklist, onaylar, eksikler ve mimari özeti bu dosyada.  
**Güncelleme:** 2026-06-02 · **Branch:** `mobile/app` · **Mobil:** Furkan

**AI asistanlar** her oturumda bu dosyayı okur; yalnızca **AKTİF** fazda kod yazar (`CLAUDE.md` faz kapısı).

---

## MEVCUT DURUM (özet)

| Faz | Konu | Durum | Hedef | ONAY |
|-----|------|-------|-------|------|
| 0 | Foundation | ✅ Tamam | — | ✅ |
| 1 | Aidat + Dashboard + Tur 5 | ✅ Tamam | 2026-05-15 | ✅ 2026-05-10 |
| 2 | Bildirimler + Giderler | ✅ Tamam | 2026-06-05 | ✅ 2026-05-29 |
| 3 | Tickets + Dekont/IBAN (+ Reports ertelendi) | ✅ Tamam | — | ✅ 2026-06-02 |
| 4 | Profil + Abonelik | ▶ **AKTİF** | 2026-07-03 | — |
| 5 | Test + sertleştirme | 🔒 Kilitli | 2026-07-10 | — |
| 6 | v1.0.0 Lansman | 🔒 Kilitli | 2026-07-14 | — |

```
▶ AKTİF ÇALIŞMA: FAZ 4 — Profil + Abonelik
▶ FAZ 3: kapalı (ONAY ✅ 2026-06-02) · Reports ertelendi → backlog #12
▶ FAZ 0–3: kapalı
```

**Sıradaki işler (checklist `[ ]`):**
- [x] **FAZ 3** — Tickets + Dekont/IBAN tamam · `ONAY: Furkan ✅` (2026-06-02)
- [ ] **FAZ 4** — Canlı E2E + ONAY (profil/dil/abonelik okuma tamam; RevenueCat satın alma webhook sonrası)
- [ ] Gider makbuz **dosya** upload (`POST /expenses/{id}/proof`) — FAZ 2 kalıntısı; backend yok
- [ ] FAZ 5–6 (test, store) — FAZ 4 tamamlanınca

**Ertelenen (unutma — FAZ 3 dışı backlog):**
- [ ] **Reports** — yönetici aylık özet PDF (`GET /buildings/{id}/reports`); backend yok · aşağı § Reports (ertelendi)

**Referanslar:** API → `origin/backend/yedek` · `API/FLUTTER-BACKEND.md` §12 · Dekont rehberi → `API/FLUTTER-DEKONT-IMPLEMENTATION.md` · Dev → `flutter run -t lib/main_dev.dart`

---

## FAZ 0 — Foundation

**Durum:** TAMAMLANDI ✅  
**ONAY: Furkan ✅**

### Auth
- [x] Login (email + şifre, JWT token alma)
- [x] SignUp — birleşik kayıt (`sign_up_screen.dart`: yönetici + sakin davet kodu; `/sign-up`, `/register`, `/join`)
- [x] Register (yönetici kaydı) — SignUp ile birleşik
- [x] Join (davet koduyla sakin kaydı) — SignUp ile birleşik
- [x] Şifremi unuttum + sıfırlama (`forgot_password_screen`, `reset_password_screen`)
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
- [x] API Base URL: `https://api.aidatpanel.com/api/v1` (dart-define ile override)

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

#### Tur 5 — Backend uyum aksiyon listesi ✅ TAMAMLANDI (ONAY: Furkan ✅)
Backend `backend/yedek` (referans `8cc2152`) ile §3 P0–P2 uçları hazır; mobile **6/6** Tur 5 maddesini UI’ya bağladı (sakin çıkar, bina formu, dues filtre, şifre, hesap kapat, şifremi unuttum).

- [x] **1 — Sakin çıkarma UI** (`DELETE /apartments/:id/resident`): `BuildingResidentsScreen` daire kart menüsüne "Sakini Çıkar" + AlertDialog onayı + apartments invalidate. Backend 403/404 mesajları insanlaştırıldı. **TAMAMLANDI** — `RemoveResidentDialog` widget'ı + `ApartmentsNotifier.removeResidentFromApartment` + dev mock. ~1.5 sa
- [x] **2 — Bina formu uyumu** (`POST /buildings`): `AddBuildingScreen`'de `totalFloors` (1-200) + `apartmentsPerFloor` (1-50) form-içi range validator + range hint; `_seedApartmentsIfNeeded` fallback loop'u kaldırıldı; `MockBuildingRepository.createBuilding` artık backend gibi tek transaction'da apartments seed ediyor. **TAMAMLANDI** ~2 sa
- [x] **3 — Server-side dues filter** (`GET /buildings/:id/dues?month=&year=&status=`): DataSource → Repository → Notifier zincirine `month?/year?/status?` opsiyonel parametreleri eklendi; `manager_dues_tab.dart` filtre değişince `_reloadDues()` ile sunucuya yeni query atar (client-side `where(...)` kalktı). Yıl listesi son 5 yıl + dues distinct ile sabit (filtre aktifken kullanıcı geri dönebilsin). `MockDuesRepository` filtreleri uygular. Sakin UI'a filtre eklemedik (notifier imzası geriye uyumlu). **TAMAMLANDI** ~1.5 sa
- [x] **4 — Şifre değiştir UI** (`PUT /me/password`): Ayarlar → "Şifre Değiştir" tile artık `ChangePasswordBottomSheet` açıyor (mevcut + yeni + onay). Başarı sonrası `successMsg` toast → `authNotifier.logout()` → `/login`. 401 mesajı "mevcut şifre hatalı" olarak insanlaştırıldı. `MockProfileRepository` `Eski123.` şifresini bekler. **TAMAMLANDI** ~2 sa
- [x] **5 — Hesabı kapat UI** (`DELETE /me`): Ayarlar → "Tehlikeli Bölge" → "Hesabımı Kapat" tile (kırmızı). `DeleteAccountDialog` tip-to-confirm ("HESABIMI KAPAT" yazılır). 409 mesajı "Önce binaları silin veya başka yöneticiye devredin" olarak insanlaştırıldı. Mock'ta `forceManagerConflict` flag'i 409 davranışını test etmek için. **TAMAMLANDI** ~1 sa
- [x] **6 — Şifremi unuttum akışı** (`POST /auth/forgot-password` + `POST /auth/reset-password`): Login'de "Şifremi Unuttum" linki → `ForgotPasswordScreen` (email) → `ResetPasswordScreen` (6 char kod + yeni şifre). `inputFormatters` + RegExp ile sadece backend alfabesi (`23456789ABCDEFGHJKLMNPQRSTUVWXYZ`) kabul ediliyor. Backend 400 hatası ("Invalid or expired token") "Kod hatalı veya süresi dolmuş" olarak insanlaştırıldı. Mock kabul kodu: `ABCDEF`. **TAMAMLANDI** ~3 sa

> **Toplam tahmin:** ~11 saat. Tur 5 **TAMAMLANDI** — mobile FAZ 1'in ilgili backend uçları UI'da (ONAY: Furkan ✅).
>
> **`GET /buildings` → `_count.apartments`:** ✅ Backend hotfix (`backend/yedek`, örn. `a896d18`) + ✅ mobile `BuildingModel.apartmentCountFromApi` (2026-05-12). Dolu daire sayısı için ayrı liste alanı yok → kartta `0/N` olabilir.

### Çıkış Kapısı
Checklist tamamlanmadan veya ilgili backend uçları hazır olmadan FAZ 2 başlamaz.

---

## ✅ FAZ 2 — Notifications + Expenses (TAMAMLANDI)

**Durum:** TAMAMLANDI ✅ — bildirimler + gider CRUD + özet + `receiptUrl` (E2E 2026-05-29)  
**Tamamlanma:** 2026-05-29  
**Hedef:** ~2026-06-05  
**FAZ 1 onay:** ✅ alındı

> **Dev test:** `flutter run -t lib/main_dev.dart` (turuncu DEV banner, mock veri)  
> **API sözleşmesi:** `origin/backend/yedek` → `API/FLUTTER-BACKEND.md`

### Backend bağımlılık

| Uç | Durum |
|----|--------|
| `PUT /me/fcm-token` | ✅ canlı |
| `GET /notifications`, `PATCH read`, `read-all` | ✅ canlı E2E (2026-05-29) |
| Gider CRUD + `receiptUrl` (HTTPS) | ✅ canlı E2E (2026-05-29) |
| `POST /expenses/{id}/proof` (dosya) | ⏳ backend yok — mobil 404’te uyarı; `main_dev` mock upload |

### Notifications (`features/notifications/`)

- [x] NotificationEntity, model, datasource, **repository**, notifier
- [x] Bildirim listesi, detail sheet, duyuru sheet
- [x] FCM + `notification_payload` deep-link
- [x] Dev mock
- [x] **Backend API** — `GET/PATCH /notifications` (`origin/backend/yedek`, `notificationRoutes.js`)
- [x] **Canlı E2E** — `main.dart` + gerçek API (2026-05-29)
- [x] **FCM** — Push / deep-link (canlı test, 2026-05-29)

### Expenses (`features/expenses/`)

- [x] ExpenseEntity, model, datasource, **repository**, notifier
- [x] Gider listesi + form (kategori, tutar, tarih, not)
- [x] Makbuz UI + multipart **upload altyapısı** (API açılınca bağlı)
- [x] Dev mock (`uploadReceipt`)
- [x] **Canlı E2E** — Gider listesi, ekle, düzenle, sil, ay/yıl filtresi + özet (2026-05-29)
- [x] **Makbuz `receiptUrl`** — HTTPS URL ile create/update (backend sözleşmesi)
- [x] **Makbuz fotoğrafı** — `main_dev` mock upload; canlıda 404 → kullanıcıya bilgi toast’ı

### FAZ 2 çıkış kapısı

- [x] Bildirimler — canlı backend E2E
- [x] Giderler — canlı CRUD + receiptUrl E2E
- [x] `ONAY: Furkan ✅` (2026-05-29)

---

## ✅ FAZ 3 — Tickets + Dekont/IBAN (TAMAMLANDI)

**Durum:** TAMAMLANDI ✅ (2026-06-02)  
**ONAY: Furkan ✅** (2026-06-02) — Tickets (2026-05-29) + Dekont/IBAN (2026-06-02) kapsamında resmî kapanış.

> **Tickets:** `origin/backend/yedek` + mobil `features/tickets/` — canlı E2E tamam (2026-05-29).  
> **Dekont + IBAN:** Backend Faz 2 ✅ — mobil `features/dekont/` + canlı E2E + ONAY (2026-06-02).  
> **Reports:** **ertelendi** (2026-06-02 ürün kararı) — FAZ 3 kapsamı dışı; backlog #12. Backend `GET /buildings/:id/reports` + PDF yok. Yönetici aylık özet; **aidat dekontu / arıza değil**. Backend hazır olunca mobil + E2E + ayrı ONAY.

### Tickets (features/tickets/)
| Görev | Backend Durumu |
|-------|----------------|
| Tüm Ticket uçları | ✅ `backend/yedek` + canlı E2E (2026-05-29) |

- [x] TicketEntity + TicketUpdateEntity tanımları
- [x] TicketsRemoteDataSource + repository
- [x] Ticket listesi ekranı (yönetici + sakin)
- [x] Ticket detay + güncelleme ekranı
- [x] Ticket oluşturma formu
- [x] Canlı E2E (2026-05-29)

### FAZ 3 (Tickets) çıkış kapısı

- [x] Talep modülü canlı E2E
- [x] `ONAY: Furkan ✅` (2026-05-29)

---

### Dekont + tahsilat IBAN (`features/dekont/` + `features/buildings/` tahsilat alanları)

| Modül | Kim | Backend | Mobil |
|-------|-----|---------|--------|
| **M3** Tahsilat / IBAN tanımlama | Yönetici | ✅ `POST /buildings`, `GET /collection-presets`, `PATCH .../collection` | ✅ UI + kayıtlı IBAN |
| **M4** Ödeme yap + dekont yükle | Sakin | ✅ `GET /me/payment-collection`, `POST /dekonts/upload` | ✅ |
| **M5** Dekontlarım | Sakin | ✅ `GET /me/dekonts`, `GET /dekonts/:id`, `GET .../file` | ✅ |
| **M6** Dekont inceleme | Yönetici | ✅ `GET /buildings/:id/dekonts`, `PATCH .../review` | ✅ |
| **FCM** | İkisi | ✅ `DEKONT_*` push tipleri | ✅ deep link |

**Not:** Gider makbuzu (`receiptUrl` / `POST /expenses/{id}/proof`) **FAZ 2 — Giderler** kapsamındadır; aidat dekontu değildir.

#### M3 — Yönetici: IBAN tanımlama (bina formu)

- [x] `BuildingModel` / entity: `collectionIban`, `collectionAccountTitle`, `paymentReferenceTemplate`, `isCollectionConfigured`
- [x] `api_constants`: `collection-presets`, `buildingCollection(id)`
- [x] `AddBuildingScreen`: tahsilat bloğu (IBAN, alıcı unvanı, havale açıklama şablonu)
- [x] `GET /buildings/collection-presets` — focus’ta son kullanılan setler, tek tıkla doldurma
- [x] `POST /buildings` body’de tahsilat alanları (opsiyonel; doluysa client IBAN doğrulama)
- [x] Mevcut bina: `PATCH /buildings/:id/collection` (sheet + bina menüsü)
- [x] IBAN tanımsız bina uyarısı (liste/detay, opsiyonel) — menü + bina kartı ikonu
- [x] **Canlı E2E** — bina oluştur + tahsilat PATCH (Furkan, `main.dart`)

#### M4 — Sakin: Ödeme yap + PDF/resim dekont yükleme

- [x] `features/dekont/` — datasource, repository, modeller (`Dekont`, `PaymentCollection`, `DekontStatus`)
- [x] Sakin dashboard / aidat: **Ödeme yap** girişi
- [x] `GET /me/payment-collection` — IBAN, unvan, `paymentReference` (şablon + daire no)
- [x] `isCollectionConfigured == false` → bilgi banner (yükleme yine 201 olabilir)
- [x] IBAN / unvan / açıklama **kopyala** (48dp dokunma)
- [x] PENDING aidat seçimi + tutar gösterimi
- [x] `file_picker`: PDF + JPEG/PNG
- [x] `POST /dekonts/upload` multipart (+ opsiyonel `dueId`)
- [x] Hata: 400, 409 (aynı hash), 429 (rate limit)
- [x] Upload sonrası detay veya polling

#### M5 — Sakin: Dekontlarım

- [x] `GET /me/dekonts` liste + `?status=` filtre
- [x] Detay ekranı + durum metinleri (`NEEDS_MANAGER_REVIEW`, `MATCHED`, `REJECTED`, …)
- [x] `GET /dekonts/:id/file` önizleme / indirme
- [x] `REJECTED` → yeniden yükle → ödeme ekranı
- [x] Pull-to-refresh

#### M6 — Yönetici: Dekont inceleme

- [x] Bina seçici → `GET /buildings/:id/dekonts` (`?status=`, `?apartmentId=`)
- [x] Liste: daire, yükleyen, tutar, durum rozeti
- [x] Detay + dosya önizleme
- [x] `PATCH /dekonts/:id/review` — `APPROVE` / `REJECT` (+ `note`, gerekirse `dueId`)
- [x] Onay → aidat `PAID` + `DEKONT_PAYMENT_APPLIED` bildirimi (backend)

#### FCM + bildirimler (dekont)

- [x] `notification_payload`: `dekontId` alanı + `DEKONT_*` route çözümleme
- [x] `notification_model`: dekont tipleri (UI etiketi)
- [x] Tap → dekont detay / inceleme / ödeme ekranı

#### FAZ 3 (Dekont/IBAN) çıkış kapısı

- [x] Yönetici: bina oluştururken/güncellerken IBAN E2E
- [x] Sakin: ödeme bilgisi + dekont PDF/resim upload E2E
- [x] Yönetici: inceleme onay/red E2E
- [x] `ONAY: Furkan ✅` (2026-06-02)

---

### Reports (features/reports/) — **ERTELENDİ** · backlog #12

> **FAZ 3 dışı.** Furkan kararı (2026-06-02): FAZ 3 resmî kapanış; Reports sonraya. AI asistanlar bu maddeyi backlog’da tutar; backend açılınca önceliklendirilir.

| Görev | Backend Durumu |
|-------|----------------|
| `GET /buildings/{id}/reports`, PDF export | ❌ **YOK** — backend açacak |

- [ ] **⚠️ backend bekliyor** — GET /buildings/{id}/reports bağlama
- [ ] **⚠️ backend bekliyor** — Aylık özet rapor ekranı
- [ ] **⚠️ backend bekliyor** — PDF export
- [ ] Canlı E2E + `ONAY: Furkan ✅` (Reports tamamlanınca)

---

## ▶ FAZ 4 — Subscription + Profile

**Durum:** **AKTİF** — FAZ 3 kapandı (2026-06-02); Reports FAZ 3 dışı ertelendi  
**Hedef:** ~2026-07-03

> Backend ekibi profil ve şifre sıfırlama uçlarını **canlıya almış** (Belge §3, §4).
> Sadece RevenueCat webhook backend'de henüz yok — onun için satın alma akışı yine eklenebilir, webhook ileride tamamlanır.

### Profil (features/profile/)

> **NOT:** Şifre değiştirme + KVKK hesap kapatma + Şifremi unuttum akışları
> FAZ 1 / Tur 5'e **erkene çekildi** (backend bu uçları öne aldı). Aşağıda
> kalan maddeler ileri seviye iyileştirmeler ve sunucuya dil tercihi
> yazımı; "Tüm cihazlardan çıkış" gibi opsiyonel ekler.

- [x] Profil bilgileri ekranı: `GET /me` ile yeniden yükle, `PUT /me` ile name/phone güncelle (`EditProfileBottomSheet`, `ProfileNotifier`)
- [x] `PUT /me/language` — Ayarlar dil seçimi sunucuya yazılır (`changeLocale` + `syncCachedUser`)
- [x] "Diğer cihazlardan çıkış" — `POST /auth/logout-all-devices` + Ayarlar tile (`_LogoutAllDevicesTile`); normal `logout` bu cihazı da çıkarır
- [ ] Canlı E2E — profil güncelleme + dil senkronu (`main.dart`)

### Subscription (features/subscription/)
| Görev | Backend Durumu |
|-------|----------------|
| RevenueCat webhook | ❌ **YOK** — backend açacak |

- [ ] **⚠️ backend bekliyor** — RevenueCat SDK + satın alma (webhook olmadan sunucu senkronu yok)
- [x] Abonelik ekranı — `GET /me/subscription` okuma + bilgilendirme; satın alma butonu devre dışı (`SubscriptionScreen`, yönetici ayarlar)

### FAZ 4 çıkış kapısı

- [ ] Profil + dil canlı E2E
- [ ] Abonelik okuma ekranı canlı E2E (veya backend 404 → bilgi kartı doğrulandı)
- [ ] `ONAY: Furkan ✅` (tarih)

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

## Teknik borç ve bilinen eksikler (backlog)

| # | Konu | Durum | Not |
|---|------|-------|-----|
| 1 | `ListView.children` → `builder` | ✅ | FAZ 1 |
| 2 | Certificate pinning | ⏳ | FAZ 5 — `dio_client.dart` altyapı |
| 3 | Build flavors (dev/staging/prod) | ⏳ | FAZ 5 |
| 4 | Test coverage %30+ | ⏳ | FAZ 5 — smoke + birim testler başladı |
| 5 | Pagination (büyük listeler) | ⏳ | FAZ 5 |
| 6 | Bina kartı dolu daire `0/N` | ⏳ | API’de `occupiedApartments` yok |
| 7 | Sakin aidat filtre UI | ⏳ | API var, UI yok |
| 8 | `PUT /me/language` sunucuya yazma | ✅ | FAZ 4 — mobil (2026-06-02) |
| 9 | Profil `GET/PUT /me` ekranı | ✅ | FAZ 4 — mobil (2026-06-02) |
| 13 | RevenueCat satın alma + webhook | ⏳ | FAZ 4 — okuma ekranı var; SDK/webhook bekliyor |
| 10 | Gider makbuz dosya `/proof` | ⏳ | Backend yok; `receiptUrl` HTTPS var |
| 11 | Dekont + tahsilat IBAN mobil | ✅ | **FAZ 3** — canlı E2E + ONAY tamamlandı (2026-06-02) |
| 12 | **Reports** (aylık özet PDF) | ⏳ **ertelendi** | FAZ 3 dışı backlog; `GET /buildings/{id}/reports` backend yok · unutulmasın |

---

## Tasarım kısıtları (ZORUNLU — 50+ yaş)

- Minimum font: **16sp** (`AppTypography`)
- Minimum dokunma: **48×48dp**
- **Bottom Navigation** (hamburger yasak)
- Hata mesajları: sade Türkçe, teknik terim yok
- Loading: her async işte görünür gösterge
- Animasyon: max **200ms**, `Curves.easeInOut`

Detay: `resources/tasarım/TASARIM_KILAVUZU.md`

---

## Mimari özeti (features)

```
mobile/lib/features/
├── auth/           ✅
├── buildings/      ✅ CRUD + tahsilat IBAN (M3)
├── apartments/     ✅
├── dues/           ✅
├── dashboard/      ✅
├── notifications/  ✅
├── expenses/       ✅
├── tickets/        ✅
├── dekont/         ✅ upload, inceleme, ödeme bilgisi (canlı E2E tamam)
├── reports/        ⏳ ertelendi (backlog #12; backend bekliyor)
├── profile/        ✅ GET/PUT /me + dil + şifre/KVKK (canlı E2E bekliyor)
└── subscription/   🔶 okuma ekranı; RevenueCat satın alma webhook sonrası
```

Clean Architecture: `domain` → `data` → `presentation` · Riverpod StateNotifier · GoRouter

---

## Çalıştırma modları

| Mod | Komut |
|-----|--------|
| Canlı API | `flutter run` (`main.dart`) |
| Dev mock | `flutter run -t lib/main_dev.dart` (turuncu **DEV** banner) |

---

## Nasıl Kullanılır

1. **AI asistan** her oturumda bu dosyayı okur; **MEVCUT DURUM** tablosuna ve **sıradaki işler** listesine bakar.
2. **Sadece izin verilen / aktif** fazın görevlerini yapar; **kilitli** fazlara dokunmaz (`CLAUDE.md`).
3. Bir fazın tüm checklist `[x]` olunca onay: `ONAY: Furkan ✅` (tarih ile).
4. Görev bitince bu dosyada ilgili `[ ]` → `[x]` güncelle; üst tabloyu senkron tut.
5. API sözleşmesi: `origin/backend/yedek` → `API/FLUTTER-BACKEND.md` (backend kaynağı).
