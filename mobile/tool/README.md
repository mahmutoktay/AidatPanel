# i18n Araçları

AidatPanel'in çeviri sistemi [Slang](https://pub.dev/packages/slang) kullanır.
Çeviriler `lib/l10n/` klasöründeki iki JSON dosyasında tutulur:

- `strings_tr.i18n.json` — Türkçe
- `strings_en.i18n.json` — İngilizce
- `strings.g.dart` — Slang tarafından otomatik üretilir, elle dokunma

---

## Kurulum (bir kez)

1. [deepl.com/pro-api](https://www.deepl.com/pro-api) adresinden ücretsiz hesap aç
2. API key'ini kopyala (ücretsiz key'ler `:fx` ile biter)
3. `mobile/tool/.deepl_key` dosyası oluştur, içine sadece key'i yaz:
   ```
   xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:fx
   ```
   > Bu dosya `.gitignore`'da, repo'ya gitmez.

---

## İş Akışı

1. Kodu yaz — hardcoded string'ler olsa da sorun değil:
   ```dart
   Text('Arıza Bildir')
   hintText: 'Bina adı girin'
   ```

2. Uygulamayı test et, her şey çalışıyor mu kontrol et

3. Hazır olunca tek komutla tüm çevirileri düzelt:
   ```bash
   dart run tool/i18n_scan.dart
   ```
   Veya VS Code: `Terminal → Run Task → "i18n: Sync"`

Sistem otomatik olarak:
1. `lib/` altındaki tüm `.dart` dosyalarını tarar
2. Hardcoded string'leri tespit eder
3. Key üretir: `features.issues.arizaBildir`
4. DeepL ile İngilizceye çevirir
5. Her iki JSON dosyasına ekler
6. Kaynak kodda `Text(context.t.features.issues.arizaBildir)` olarak günceller
7. `strings.g.dart`'ı yeniler

---

## Örnek Çıktı

```
Taranıyor... (47 dosya)

+ features.issues.arizaBildir
  TR: Arıza Bildir
  EN: Report Malfunction
  → lib/features/issues/presentation/screens/issues_screen.dart

+ features.buildings.binaAdiGirin
  TR: Bina adı girin
  EN: Enter building name
  → lib/features/buildings/presentation/screens/add_building_screen.dart

  strings.g.dart güncellendi

Tamamlandı: 2 string eklendi, 2 dosya güncellendi.
```

---

## Kodda Kullanım

```dart
Text(context.t.features.issues.arizaBildir)
```

---

## Key Formatı

Nokta ile ayrılmış namespace yapısı — dosya yolundan otomatik belirlenir:

| Namespace | Ne zaman kullanılır |
|-----------|-------------------|
| `common.xxx` | Genel UI (butonlar, başlıklar, genel mesajlar) |
| `features.issues.xxx` | Arızalar ekranına özel |
| `features.buildings.xxx` | Bina yönetimine özel |
| `features.auth.xxx` | Giriş/kayıt ekranlarına özel |
| `features.apartments.xxx` | Daire yönetimine özel |
| `validation.xxx` | Form doğrulama hata mesajları |

---

## Manuel Ekleme

İki dili de kendin belirlemek istersen:
```bash
dart run tool/add_translation.dart features.issues.title "Arıza Bildir" "Report Issue"
```

Sadece Türkçeyi yaz, İngilizce DeepL ile otomatik çevrilir:
```bash
dart run tool/add_translation.dart features.issues.title "Arıza Bildir"
```

---

## Hardcoded String Tarama (Rapor)

Değişiklik yapmadan sadece rapor almak için:
```bash
dart run tool/check_translations.dart
```

---

## VS Code Task'ları

| Task | Ne yapar |
|------|----------|
| `i18n: Sync` | Tüm dosyaları tara → çevir → güncelle |
| `Slang: Watch` | Sadece JSON→strings.g.dart günceller |
| `Slang: Generate` | Tek seferlik generate |
| `i18n: Çevrilmemiş String Tara` | Hardcoded string raporu (değişiklik yapmaz) |

`Terminal → Run Task` menüsünden erişilebilir.
