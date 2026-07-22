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
    compileSdk = 37
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
            resValue("string", "app_name", "AidatPanel Dev")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "AidatPanel")
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
        debug {
            // Debug'da R8 kapalı — obfuscation debug'ı zorlaştırır.
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            // Yayın AAB için release keystore zorunlu (debug fallback yok).
            require(keystorePropertiesFile.exists()) {
                "Release build için android/key.properties gerekli."
            }
            signingConfig = signingConfigs.getByName("release")

            // R8 minify + resource shrink (Play Console optimizasyon / kod karartma).
            // Dart obfuscation ayrı: flutter build ... --obfuscate --split-debug-info=build/debug-info
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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
