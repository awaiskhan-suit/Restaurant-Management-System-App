plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.resturent"
    compileSdk = 36   // or flutter.compileSdkVersion if you’ve defined it in gradle.properties

    defaultConfig {
        applicationId = "com.example.resturent"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1        // put your app version code here
        versionName = "1.0"    // put your app version name here
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("release") {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

