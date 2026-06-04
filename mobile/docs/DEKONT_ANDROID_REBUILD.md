# Dekont PDF önizleme — Android tam derleme

`pdfx` native eklentisi **hot reload ile kayıt olmaz**.

## Kontrol

1. [`PluginRegistrant.kt`](../android/app/src/main/kotlin/com/aidatpanel/app/PluginRegistrant.kt) içinde `PdfxPlugin()` satırı var mı?
2. `cd mobile` → `.\scripts\check_plugin_registrant.ps1` yeşil mi?

## Derleme

```powershell
cd mobile
flutter run
# veya release
flutter build apk --release
```

Çalışan oturumu **q** ile kapatıp yeniden başlatın.

## Hata: PlatformException channel-error

- Eksik `PdfxPlugin` kaydı veya eski APK.
- Yukarıdaki adımları tekrarlayın.
