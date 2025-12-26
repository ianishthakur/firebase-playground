plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.firebase-perf")
    id("com.google.firebase.crashlytics")
}

configurations.all {
    resolutionStrategy {
        // Force a newer version of firebase-iid that is compatible with messaging 25+
        force("com.google.firebase:firebase-iid:21.1.0")
    }
}

android {
    namespace = "com.firebase.playground"
    compileSdk = flutter.compileSdkVersion
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
        applicationId = "com.firebase.playground"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

        // Use the BoM to manage versions automatically
        implementation(platform("com.google.firebase:firebase-bom:33.7.0"))

        // Firebase dependencies (BoM handles these versions)
        implementation("com.google.firebase:firebase-analytics")
        implementation("com.google.firebase:firebase-messaging")
        implementation("com.google.firebase:firebase-perf")
        
        // Manual fix for the Dynamic Links deprecation
        implementation("com.google.firebase:firebase-dynamic-links:22.1.0")
        
        // 2. Add this specific line to bridge the gap between ML Kit and Messaging
        implementation("com.google.firebase:firebase-iid:21.1.0")
    }
}

flutter {
    source = "../.."
}
