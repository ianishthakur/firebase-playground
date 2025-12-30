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
        applicationId = "com.firebase.playground"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    packagingOptions {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            setProguardFiles(listOf(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"))
        }
    }

    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

        // Use the BoM to manage versions automatically
        implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
        implementation(platform("com.google.firebase:firebase-appcheck-playintegrity"))
        implementation(platform("com.google.firebase:firebase-appcheck-debug"))

        // Firebase dependencies (BoM handles these versions)
        implementation("com.google.firebase:firebase-analytics")
        implementation("com.google.firebase:firebase-messaging")
        implementation("com.google.firebase:firebase-perf")

        implementation("com.google.mlkit:text-recognition-chinese:16.0.0")
        implementation("com.google.mlkit:text-recognition-devanagari:16.0.0")
        implementation("com.google.mlkit:text-recognition-japanese:16.0.0")
        implementation("com.google.mlkit:text-recognition-korean:16.0.0")
        
        implementation("com.google.firebase:firebase-dynamic-links:22.1.0")
        implementation("com.google.firebase:firebase-iid:21.1.0")
    }
}

flutter {
    source = "../.."
}
