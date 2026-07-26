# AidatPanel ProGuard / R8 rules (release minify + shrink)
#
# İlkeler:
# - Blanket keep (io.flutter.**, com.google.firebase.**, vb.) YOK — skor düşürür.
# - Dart-only (Riverpod, freezed, Dio) kuralları YOK — Android bytecode'da karşılığı yok.
# - PluginRegistrant.kt içindeki Class.forName(...) hedefleri sınıf + public ctor ile korunur.
# - Kütüphane AAR consumer-rules / proguard-rules (jni, purchases_flutter, file_picker) zaten birleşir.

# --- Crash okunabilirliği (obfuscation skorunu düşürmez) ---
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Play R8: koruma kuralları dışındaki sınıfları üst pakete taşıyarak DEX'i sıkıştır.
-repackageclasses

# --- Flutter Play Core (deferred components; runtime'da yoksa dontwarn yeter) ---
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# --- PluginRegistrant.kt: reflection ile yüklenen eklenti sınıfları ---
# Yalnızca sınıf adı + public no-arg ctor; paket-geneli keep yok.
-keep class dev.fluttercommunity.plus.packageinfo.PackageInfoPlugin { <init>(); }
-keep class com.kasem.receive_sharing_intent.ReceiveSharingIntentPlugin { <init>(); }
-keep class dev.fluttercommunity.plus.share.SharePlusPlugin { <init>(); }
-keep class studio.midoridesign.gal.GalPlugin { <init>(); }
-keep class com.llfbandit.app_links.AppLinksPlugin { <init>(); }
-keep class com.revenuecat.purchases_flutter.PurchasesFlutterPlugin { <init>(); }
-keep class io.flutter.plugins.firebase.crashlytics.FlutterFirebaseCrashlyticsPlugin { <init>(); }
-keep class io.flutter.plugins.firebase.analytics.FlutterFirebaseAnalyticsPlugin { <init>(); }
-keep class io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin { <init>(); }
-keep class com.google.flutter.recaptcha.RecaptchaEnterprisePlugin { <init>(); }
-keep class dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin { <init>(); }
-keep class com.tekartik.sqflite.SqflitePlugin { <init>(); }
-keep class io.flutter.plugins.urllauncher.UrlLauncherPlugin { <init>(); }

# flutter_local_notifications — arka plan/receiver (consumer rules yoksa yedek)
-keep class com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin { *; }
-keep class com.dexterous.flutterlocalnotifications.**Receiver { *; }
-keep class com.dexterous.flutterlocalnotifications.**Service { *; }
