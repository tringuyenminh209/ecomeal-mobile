import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Public mobile Maps key is supplied through ignored env.json, never committed here.
val dartDefines = (project.findProperty("dart-defines") as? String).orEmpty()
    .split(",").filter { it.isNotEmpty() }.associate {
        val decoded = String(Base64.getDecoder().decode(it), Charsets.UTF_8)
        val separator = decoded.indexOf('=')
        if (separator < 0) decoded to "" else decoded.substring(0, separator) to decoded.substring(separator + 1)
    }

android {
    namespace = "com.ecomeal.ecomeal_mobile"
    // CameraX 1.6.1 (QR scanner) requires Android API 36 or later.
    compileSdk = maxOf(36, flutter.compileSdkVersion)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ecomeal.ecomeal_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // flutter_line_sdk (Chương 18) cần Android 7.0 (API 24) trở lên
        minSdk = maxOf(24, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = dartDefines["GOOGLE_MAPS_ANDROID_API_KEY"].orEmpty()
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ADR-007 / ADR-015: 1 codebase → 4 app. Chọn bằng --flavor (và -t cho điểm khởi động Dart):
    //   app khách   : flutter run --flavor customer                          (lib/main.dart)
    //   app tài xế  : flutter run --flavor driver -t lib/main_driver.dart
    //   app nhà hàng: flutter run --flavor store -t lib/main_store.dart
    //   app vận hành: flutter run --flavor admin -t lib/main_admin.dart
    // Icon của từng app nằm ở src/<flavor>/res (sinh bằng design/logo-kit/rev04/export-app-icons.cjs).
    // Key Google Maps Android giới hạn theo package — package của app tài xế phải được thêm vào giới hạn của key.
    flavorDimensions += "app"
    productFlavors {
        create("customer") {
            dimension = "app"
            resValue("string", "app_name", "EcoMeal")
        }
        create("driver") {
            dimension = "app"
            applicationId = "com.ecomeal.ecomeal_driver"
            resValue("string", "app_name", "EcoMeal Driver")
        }
        // ADR-015: app cho nhà hàng / vận hành (lib/main_store.dart, lib/main_admin.dart)
        create("store") {
            dimension = "app"
            applicationId = "com.ecomeal.ecomeal_store"
            resValue("string", "app_name", "EcoMeal Store")
        }
        create("admin") {
            dimension = "app"
            applicationId = "com.ecomeal.ecomeal_admin"
            resValue("string", "app_name", "EcoMeal Admin")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
