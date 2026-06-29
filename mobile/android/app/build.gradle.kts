import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.aidatpanel.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.aidatpanel.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "env"
    productFlavors {
        // Çalıştırma: flutter run --flavor dev -t lib/main_dev.dart
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Aidat Paneli Dev")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Aidat Paneli")
        }
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                val storePath = keystoreProperties.getProperty("storeFile")!!
                val keystoreFile = rootProject.file(storePath)
                storeFile = keystoreFile
                require(keystoreFile.exists()) {
                    "Keystore bulunamadı: ${keystoreFile.absolutePath}. android/key.properties içindeki storeFile yolunu kontrol edin."
                }
                keyAlias = keystoreProperties.getProperty("keyAlias")!!
                keyPassword = keystoreProperties.getProperty("keyPassword")!!
                storePassword = keystoreProperties.getProperty("storePassword")!!
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(
                if (keystorePropertiesFile.exists()) "release" else "debug",
            )

            // Release çökme (R8 + reflection): minify kapalı. APK ve appbundle aynı release tipi.
            // Minify tekrar açılacaksa proguard-rules.pro + check_plugin_registrant + cihaz smoke zorunlu.
            // Obfuscation notu: flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Java GeneratedPluginRegistrant Kotlin sınıflarını derleyemez — Kotlin kayıt kullanılıyor.
tasks.register<Delete>("deleteGeneratedPluginRegistrant") {
    delete(file("src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"))
}
tasks.configureEach {
    if (name.contains("compile") && (name.contains("Java") || name.contains("Kotlin"))) {
        dependsOn("deleteGeneratedPluginRegistrant")
    }
}
