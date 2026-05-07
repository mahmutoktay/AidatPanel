# AidatPanel Mobil Tasarım Kılavuzu

> Bu belge, AidatPanel Flutter uygulamasının görsel tasarım sistemini tanımlar.
> Amacı: Yeni ekranlar veya bileşenler eklenirken tasarım bütünlüğünün korunması.
> Hedef kitle: Bu projeye katkı sağlayan geliştiriciler ve yapay zeka asistanlar.

---

## İçindekiler

1. [Tasarım Felsefesi](#1-tasarım-felsefesi)
2. [Renk Sistemi](#2-renk-sistemi)
3. [Tipografi](#3-tipografi)
4. [Boyut ve Spacing](#4-boyut-ve-spacing)
5. [Ekran Layout Pattern'ı](#5-ekran-layout-patternı)
6. [Shared Widget Kataloğu](#6-shared-widget-kataloğu)
7. [Kart ve Liste Tasarımı](#7-kart-ve-liste-tasarımı)
8. [Durum Göstergeleri](#8-durum-göstergeleri)
9. [Kritik Kurallar](#9-kritik-kurallar)

---

## 1. Tasarım Felsefesi

**Hedef Kitle:** 50+ yaş apartman sakinleri ve yöneticileri.

**Üç Temel İlke:**

| İlke | Açıklama |
|------|----------|
| Okunabilirlik | Minimum 13sp metin, tercihan 16sp+. Yüksek kontrast. |
| Dokunabilirlik | Minimum 48dp dokunma alanı, tercihan 56dp. |
| Sadelik | Her ekranda tek ana aksiyon. Gereksiz öğe yok. |

**Görsel Dil:**
- Koyu lacivert (`#1B3A6B`) güven ve kurumsal hissi verir.
- Gradient hero alanı ekrana kimlik kazandırır.
- Yuvarlak köşeler (16dp kart, 12dp buton/input) modern ve soft bir his yaratır.
- Beyaz form alanı gradient üzerine "kağıt" gibi oturur.

---

## 2. Renk Sistemi

**Dosya:** `mobile/lib/core/theme/app_colors.dart`

Tüm renk referansları `AppColors.xxx` üzerinden yapılır. Ham hex veya `Colors.xxx` kullanılmaz (istisnalar aşağıda belirtilmiştir).

### Ana Renkler

| Token | Hex | Kullanım |
|-------|-----|----------|
| `AppColors.primary` | `#1B3A6B` | Buton bg, ikon rengi, başlık vurgusu, gradient başlangıcı |
| `AppColors.primaryLight` | `#2D5FA8` | Gradient sonu, badge bg tonu, avatar bg |
| `AppColors.accent` | `#F59E0B` | Özel vurgu (badge, önemli metrik). Nadiren kullanılır. |

### Durum Renkleri

| Token | Hex | Kullanım |
|-------|-----|----------|
| `AppColors.success` | `#16A34A` | Ödendi badge, PasswordCriterion met, pozitif durum |
| `AppColors.successLight` | `#10B981` | Hafif yeşil vurgu |
| `AppColors.successBg` | `#DCFCE7` | Başarı badge arka planı |
| `AppColors.error` | `#DC2626` | Hata mesajı, PasswordCriterion unmet, gecikmiş ödeme |
| `AppColors.errorBg` | `#FEE2E2` | Hata badge arka planı |
| `AppColors.warning` | `#F59E0B` | Bekleyen ödeme, uyarı durumu |
| `AppColors.warningBg` | `#FEF3C7` | Uyarı badge arka planı |
| `AppColors.info` | `#2563EB` | Bilgi toast'ı |

### Nötr Renkler

| Token | Hex | Kullanım |
|-------|-----|----------|
| `AppColors.background` | `#F8FAFC` | `Scaffold.backgroundColor`, ekran arka planı |
| `AppColors.surface` | `#FFFFFF` | Kart bg, form alanı bg, white hero sheet |
| `AppColors.border` / `AppColors.borderColor` | `#E2E8F0` | Kart kenarlık, ayırıcı çizgi |
| `AppColors.textPrimary` | `#0F172A` | Ana metin (başlık, gövde) |
| `AppColors.textSecondary` | `#475569` | İkincil metin (açıklama, hint) |
| `AppColors.textDisabled` | `#94A3B8` | Devre dışı öğe metni, NavigationBar etkin olmayan ikon |

### Beyaz Renk Kullanımı (İstisna)

Gradient arka plan üzerindeki öğelerde `Colors.white` ve yarı saydam türevleri kullanılır:

```dart
// İkon container arka planı (hero alanında)
color: Colors.white.withValues(alpha: 0.15)

// İkon / başlık rengi (hero üzerinde)
color: Colors.white

// Alt başlık / açıklama (hero üzerinde)
color: Colors.white.withValues(alpha: 0.85)

// Bölücü çizgi (gradient kart içinde)
color: Colors.white.withValues(alpha: 0.3)

// Konum ikonu (gradient kart içinde)
color: Colors.white.withValues(alpha: 0.7)
```

---

## 3. Tipografi

**Dosya:** `mobile/lib/core/theme/app_typography.dart`  
**Font:** Nunito (tüm ağırlıklar)

Tüm metin stilleri `AppTypography.xxx` üzerinden kullanılır. Renk atamak için `.copyWith(color: ...)` kullanılır.

### Stil Tablosu

| Token | Boyut | Ağırlık | Kullanım |
|-------|-------|---------|----------|
| `AppTypography.h1` | 30sp | w800 | Splash/onboarding büyük başlık |
| `AppTypography.h2` | 24sp | w800 | Ekran başlığı (login, register, form üstü) |
| `AppTypography.h3` | 18sp | w700 | Kart başlığı, section başlığı |
| `AppTypography.h4` | 16sp | w700 | Alt section başlığı, liste öğesi başlığı |
| `AppTypography.body1` | 16sp | w500 | Form etiket değerleri, genel metin |
| `AppTypography.body2` | 16sp | w700 | Vurgulu gövde metni, alt başlık, metrik değer |
| `AppTypography.bodyLarge` | 17sp | w600 | Önemli bilgi metni |
| `AppTypography.label` | 14sp | w700 | Form label, küçük başlık, tag |
| `AppTypography.caption` | 13sp | w500 | Yardımcı metin, copyright, badge içi |
| `AppTypography.button` | 16sp | w800 | Buton etiketi (tema otomatik uygular) |
| `AppTypography.small` | 16sp | w600 | Yardım metinleri, footer notu |

### Kullanım Örneği

```dart
// Başlık — beyaz üzerinde
Text(
  context.t.features.auth.appTitle,
  style: AppTypography.h2.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.w700,
  ),
)

// Kart başlığı
Text(
  building.name,
  style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
)

// İkincil metin
Text(
  context.t.common.perMonth,
  style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
)
```

---

## 4. Boyut ve Spacing

**Dosya:** `mobile/lib/core/theme/app_sizes.dart`

### Spacing Scale

| Token | Değer | Kullanım |
|-------|-------|----------|
| `AppSizes.spacingXS` | 6dp | Çok küçük boşluk (ikon-metin arası, başlık-alt başlık arası) |
| `AppSizes.spacingS` | 12dp | Küçük boşluk (form öğeleri arasında sıkışık durumlarda) |
| `AppSizes.spacingM` | 20dp | Standart boşluk (form öğeleri arası, section arası) |
| `AppSizes.spacingL` | 28dp | Büyük boşluk (major section geçişleri) |
| `AppSizes.spacingXL` | 36dp | Çok büyük boşluk (ekran alt padding, büyük section) |
| `AppSizes.spacingXXL` | 56dp | Maksimum boşluk (nadiren) |

### Boyutlar

| Token | Değer | Kullanım |
|-------|-------|----------|
| `AppSizes.cardRadius` | 16dp | Kart köşe yarıçapı |
| `AppSizes.buttonRadius` | 12dp | Buton köşe yarıçapı |
| `AppSizes.inputRadius` | 12dp | TextField köşe yarıçapı |
| `AppSizes.dialogRadius` | 20dp | Dialog/bottom sheet köşe yarıçapı |
| `AppSizes.iconSize` | 28dp | Standart ikon boyutu (form prefix, nav) |
| `AppSizes.iconSizeSmall` | 20dp | Küçük ikon (badge içi, yardımcı) |
| `AppSizes.iconSizeLarge` | 32dp | Büyük ikon (hero alanı) |
| `AppSizes.iconTouchTarget` | 56dp | IconButton minimum touch area |
| `AppSizes.screenPadding` | 24dp | Ekran yatay padding |
| `AppSizes.cardPadding` | 20dp | Kart iç padding |
| `AppSizes.avatarSize` | 56dp | Avatar/profil fotoğrafı boyutu |

### Buton Yüksekliği

Tema `ElevatedButton` için `minimumSize: Size(double.infinity, 48)` tanımlıdır (global).  
Özel durumlarda override için:

```dart
// Küçük buton
ElevatedButton(
  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
  ...
)
```

---

## 5. Ekran Layout Pattern'ı

### Auth Ekranları (Login / Register / Join)

Tüm auth ekranları aynı temel yapıyı paylaşır:

```
Scaffold
  body: Stack
    ├── Positioned.fill → Container(gradient)          ← Tam ekran gradient arka plan
    ├── Positioned.fill → SafeArea(bottom:false)        ← İçerik katmanı
    │     Column(crossAxisAlignment: stretch)
    │       ├── SizedBox(height: H)                    ← HERO ALANI (gradient üzerinde)
    │       │     Column(mainAxisAlignment: center)
    │       │       ├── Container(60x60, circle, white 15%) → Icon(apartment, white, 32)
    │       │       ├── SizedBox(spacingM)
    │       │       ├── Text(appTitle, h2, white, w700)
    │       │       ├── SizedBox(spacingXS)
    │       │       └── Text(subtitle, body2, white 85%)
    │       └── Expanded                               ← FORM ALANI (beyaz sheet)
    │             Container(bg: background, borderRadius: top 28)
    │               SingleChildScrollView(padding: spacingL)
    │                 Column(crossAxisAlignment: stretch)
    │                   └── [form içeriği...]
    └── Positioned(top:0, left:0)                      ← GERİ BUTONU (overlay)
          SafeArea → IconButton(arrow_back, white)
```

**Hero yüksekliği:**
- Login: `200dp` (form daha kısa)
- Register: `160dp` (form daha uzun)
- Join: `140dp` (form en uzun — scrollable)

### Hero Alanı Kodu

```dart
SizedBox(
  height: 200, // ekrana göre ayarla
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 32),
      ),
      const SizedBox(height: AppSizes.spacingM),
      Text(
        context.t.features.auth.appTitle,
        style: AppTypography.h2.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: AppSizes.spacingXS),
      Text(
        context.t.features.auth.appSubtitle,
        style: AppTypography.body2.copyWith(color: Colors.white.withValues(alpha: 0.85)),
      ),
    ],
  ),
),
```

### Form Alanı Kodu

```dart
Expanded(
  child: Container(
    decoration: const BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // form öğeleri...
        ],
      ),
    ),
  ),
),
```

### Geri Butonu (Overlay)

```dart
Positioned(
  top: 0,
  left: 0,
  child: SafeArea(
    child: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: authState.isLoading ? null : () => context.pop(),
    ),
  ),
),
```

### Diğer Ekranlar (Dashboard, Detail)

Dashboard ekranları `Scaffold + AppBar + body` yapısını kullanır:

```dart
Scaffold(
  backgroundColor: AppColors.background,
  appBar: AppBar(title: Text(...), centerTitle: true), // tema otomatik primary bg
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(AppSizes.spacingL),
    child: Column(...),
  ),
)
```

---

## 6. Shared Widget Kataloğu

### AltActionButton

**Dosya:** `mobile/lib/shared/widgets/alt_action_button.dart`  
**Amaç:** İkincil aksiyon butonu — kart görünümlü, ikon + başlık + ok oku.

```dart
AltActionButton(
  icon: Icons.person_add_outlined,
  title: context.t.features.auth.noAccount,
  onTap: authState.isLoading ? null : () => context.push('/register'),
  isEnabled: !authState.isLoading,
)
```

**Görünüm:** Beyaz (`AppColors.surface`) arka plan, `AppColors.primary` kenarlık (0.3 alfa), yuvarlak köşe (cardRadius), ikon solda, ok sağda.

---

### PasswordField

**Dosya:** `mobile/lib/shared/widgets/password_field.dart`  
**Amaç:** Görünürlük toggle'lı şifre alanı. Opsiyonel kriter listesi ve helper text desteği.

```dart
PasswordField(
  controller: _passwordController,
  obscureText: _obscurePassword,
  labelText: context.t.features.auth.password,
  hintText: context.t.features.auth.passwordHint,
  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
  enabled: !authState.isLoading,
  onChanged: (value) { /* şifre kriterlerini güncelle */ },
  focusNode: _passwordFocusNode,
  passwordCriteria: _passwordFocusNode.hasFocus ? Column(children: [...]) : null,
)
```

**Not:** `passwordCriteria` sadece alan odaklanınca gösterilir (focus-driven).

---

### PasswordCriterion

**Dosya:** `mobile/lib/shared/widgets/password_criterion.dart`  
**Amaç:** Tek bir şifre kuralını ikon + metin ile gösterir.

```dart
PasswordCriterion(
  text: context.t.features.auth.minLength,
  isMet: _hasMinLength, // bool
)
```

- `isMet: true` → `Icons.check_circle` + `AppColors.success`
- `isMet: false` → `Icons.cancel` + `AppColors.error`

**Register/Join şifre kriterleri:**
1. En az 6 karakter
2. Büyük harf
3. Küçük harf
4. Rakam
5. Özel karakter (`@$!%*?&.`)

---

### EmptyStateWidget

**Dosya:** `mobile/lib/shared/widgets/empty_state_widget.dart`  
**Amaç:** İçerik olmadığında merkezi boş durum göstergesi.

```dart
EmptyStateWidget(
  icon: Icons.receipt_long_outlined,
  title: context.t.common.noTransactions,    // veya hardcoded
  subtitle: context.t.common.noTransactionsSub, // opsiyonel
)
```

**Görünüm:** 72dp daire container (`primaryLight` %12 alfa bg) + ikon (primary, 36dp) + h4 başlık + opsiyonel body2 alt başlık.

---

### ToastOverlay

**Dosya:** `mobile/lib/shared/widgets/toast_overlay.dart`  
**Amaç:** Riverpod tabanlı bildirim sistemi. Maksimum 3 toast, 3 saniye otomatik kapanma.

```dart
// Provider üzerinden kullan — doğrudan widget oluşturma
ref.read(toastProvider.notifier).show(
  'Mesaj metni',
  type: ToastType.error, // .success | .warning | .info | .error
);
```

**Toast tipleri ve renkleri:**

| Tip | İkon | Renk |
|-----|------|------|
| `success` | `check_circle` | `AppColors.success` |
| `error` | `error` | `AppColors.error` |
| `warning` | `warning_amber` | `AppColors.warning` |
| `info` | `info` | `AppColors.info` |

**Kurulum:** `main.dart` içinde `ToastOverlay` `MaterialApp.router` builder'ına sarılıdır. Ayrıca setup gerekmez.

---

## 7. Kart ve Liste Tasarımı

### Gradient Bilgi Kartı

Bina/daire üst bilgisi, resident dashboard hoş geldin kartı gibi önemli bilgiler için:

```dart
Container(
  padding: const EdgeInsets.all(AppSizes.spacingL),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.primary, AppColors.primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(AppSizes.cardRadius), // 16
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // İkon satırı
      Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.apartment, color: Colors.white, size: 28),
        ),
        const SizedBox(width: AppSizes.spacingM),
        Text(title, style: AppTypography.h3.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: AppSizes.spacingM),
      // Konum satırı
      Row(children: [
        Icon(Icons.location_on_outlined, size: 18, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(address, style: AppTypography.body2.copyWith(color: Colors.white.withValues(alpha: 0.7))),
        ),
      ]),
    ],
  ),
)
```

### Surface Kart (Liste Öğesi)

```dart
Container(
  margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius), // 16
    border: Border.all(color: AppColors.borderColor),
  ),
  child: Padding(
    padding: const EdgeInsets.all(AppSizes.spacingM),
    child: /* içerik */,
  ),
)
```

**Kural:** Kart arka planı daima `AppColors.surface` (`#FFFFFF`). `Colors.white` kullanılmaz.

### Status Badge

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.success.withValues(alpha: 0.12), // tip'e göre success/warning/error
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    label,
    style: AppTypography.caption.copyWith(
      color: AppColors.success, // tip'e göre
      fontWeight: FontWeight.w700,
    ),
  ),
)
```

**Renk eşleşmesi:**

| Durum | Arka Plan | Metin |
|-------|-----------|-------|
| Ödendi | `success.withValues(alpha: 0.12)` | `success` |
| Bekliyor | `warning.withValues(alpha: 0.12)` | `warning` |
| Gecikmiş | `error.withValues(alpha: 0.12)` | `error` |

### Avatar (Daire Numarası / Baş Harf)

```dart
Container(
  width: 44, height: 44,
  decoration: BoxDecoration(
    color: AppColors.primaryLight.withValues(alpha: 0.15),
    shape: BoxShape.circle,
  ),
  alignment: Alignment.center,
  child: Text(
    initials, // '1', 'AK', vb.
    style: AppTypography.body1.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
    ),
  ),
)
```

---

## 8. Durum Göstergeleri

### Yükleniyor

```dart
// Buton içi
authState.isLoading
    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
    : Text(context.t.features.auth.login)

// Ekran ortası
const Center(child: CircularProgressIndicator())
```

### Hata Durumu (AsyncValue)

```dart
asyncData.when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.error_outline, size: 48, color: AppColors.error),
      const SizedBox(height: AppSizes.spacingM),
      Text(e.toString(), style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
      const SizedBox(height: AppSizes.spacingM),
      ElevatedButton(onPressed: retry, child: Text(context.t.features.buildings.tekrarDene)),
    ]),
  ),
  data: (data) => /* içerik */,
)
```

---

## 9. Kritik Kurallar

### withValues vs withOpacity

```dart
// DOĞRU
Colors.white.withValues(alpha: 0.15)
AppColors.primary.withValues(alpha: 0.12)

// YANLIŞ — projede kullanılmaz
Colors.white.withOpacity(0.15)   // eski API
AppColors.primary.withOpacity(0.12)
```

### const Kuralı

`const` keyword yalnızca tamamen sabit (compile-time constant) widget'lara eklenebilir.  
Eğer widget `.withValues()`, `.copyWith()` veya herhangi bir method çağrısı içeriyorsa `const` **kaldırılmalıdır**.

```dart
// DOĞRU
const Icon(Icons.apartment_rounded, color: Colors.white, size: 32)

// YANLIŞ — derleme hatası
const Icon(Icons.apartment_rounded, color: Colors.white.withValues(alpha: 0.5), size: 32)
// DOĞRU olan:
Icon(Icons.apartment_rounded, color: Colors.white.withValues(alpha: 0.5), size: 32)
```

### Renk Referansı

```dart
// DOĞRU
color: AppColors.surface
color: AppColors.textPrimary

// YANLIŞ
color: Colors.white       // → AppColors.surface
color: Color(0xFFFFFFFF)  // → AppColors.surface
color: Colors.black87     // → AppColors.textPrimary
color: Colors.grey        // → AppColors.textSecondary veya textDisabled
color: Colors.green       // → AppColors.success
color: Colors.red         // → AppColors.error
```

**İstisna:** `Colors.white` yalnızca gradient arka plan üzerindeki öğelerde (hero, gradient kart) kullanılabilir. Form/kart arka planı için daima `AppColors.surface`.

### CrossAxisAlignment.stretch Kuralı

`Column` içindeki çocukların tam genişlik alması için:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch, // ← ŞART
  children: [
    // Bu çocuklar parent'ın tam genişliğini alır
  ],
)
```

Gradient hero içeren layout'larda `CrossAxisAlignment.stretch` olmadan hero alanı ekran genişliğini doldurmaz.

### Form Alan Sıralaması (Auth Ekranları)

```
Başlık (h2)
spacingL
[form alanları — aralarında spacingM]
spacingM
ElevatedButton (primary, tam genişlik)
spacingS
[ikincil butonlar]
spacingL veya spacingXL
copyright (caption, center, textSecondary)
```

### Navigasyon Kuralları

- `context.go('/route')` → Stack'i temizler, yeni ekrana gider
- `context.push('/route')` → Stack'e ekler, geri dönülebilir
- Auth başarısı: `go('/manager-dashboard')` veya `go('/resident-dashboard')`
- Kayıt başarısı: `go('/login')` (stack temizlenir)

---

## Dosya Yapısı Referansı

```
mobile/lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       ← Renk sabitleri
│   │   ├── app_typography.dart   ← Metin stilleri
│   │   ├── app_sizes.dart        ← Boyut ve spacing sabitleri
│   │   └── app_theme.dart        ← Material ThemeData
│   ├── constants/
│   │   └── app_constants.dart    ← appVersion, sabit değerler
│   └── utils/
│       └── input_validators.dart ← Email, şifre, telefon validasyonu
├── shared/
│   ├── widgets/
│   │   ├── alt_action_button.dart    ← Kart-style ikincil buton
│   │   ├── password_field.dart       ← Şifre input alanı
│   │   ├── password_criterion.dart   ← Şifre kural göstergesi
│   │   ├── empty_state_widget.dart   ← Boş liste göstergesi
│   │   └── toast_overlay.dart        ← Bildirim sistemi
│   └── utils/
│       └── auth_validators.dart      ← Davet kodu, telefon format
└── features/
    ├── auth/presentation/screens/
    │   ├── login_screen.dart         ← Gradient hero, email/telefon login
    │   ├── register_screen.dart      ← Gradient hero, kayıt formu
    │   └── join_screen.dart          ← Gradient hero, davet koduyla katıl
    ├── apartments/presentation/screens/
    │   └── resident_dashboard_screen.dart
    └── buildings/presentation/screens/
        ├── manager_dashboard_screen.dart
        └── building_residents_screen.dart
```
