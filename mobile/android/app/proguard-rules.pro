# AidatPanel ProGuard Rules
# NOT: release buildType'ta isMinifyEnabled=false iken bu dosya uygulanmaz.
# Minify açılınca PluginRegistrant reflection + flutter_local_notifications için zorunlu.

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dio ve Network
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keepattributes Signature
-keepattributes Exceptions

# JSON Serialization (freezed, json_serializable)
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# flutter_local_notifications (arka plan isolate / release)
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# package_info_plus / share_plus (PluginRegistrant reflection — R8 release)
-keep class dev.fluttercommunity.plus.packageinfo.PackageInfoPlugin { *; }
-keep class dev.fluttercommunity.plus.share.SharePlusPlugin { *; }
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }

# JNI (path_provider_android vb.)
-keep class com.github.dart_lang.jni.** { *; }
-keep class com.github.dart_lang.jni_flutter.** { *; }

# pdfx (dekont PDF önizleme)
-keep class io.scer.pdfx.** { *; }

# Riverpod
-keep class flutter_riverpod.** { *; }
-keepclassmembers class * {
    flutter_riverpod.** *;
}

# RevenueCat (Purchases Flutter)
-keep class com.revenuecat.purchases.** { *; }
-keep class com.revenuecat.purchases_flutter.** { *; }

# Dio Cookie Manager (varsa)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# Generics
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile
-keepattributes LineNumberTable

# Prevent R8 from leaving data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter Play Core (deferred components) - R8 fix
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

# Keep Flutter Play Store components
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager { *; }
