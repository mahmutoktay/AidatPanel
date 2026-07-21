pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.13.2" apply false
    // FlutterFire — google-services.json (FCM)
    // Crashlytics Gradle plugin 3.x → google-services 4.4.1+ (mapping upload)
    id("com.google.gms.google-services") version("4.4.2") apply false
    // Crashlytics — dSYM + mapping upload
    id("com.google.firebase.crashlytics") version("3.0.4") apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
