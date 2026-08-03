plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.gameturbo.x"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // GANTI applicationId ini sebelum publish jika Anda punya paket sendiri.
        applicationId = "com.gameturbo.x"
        // Support Android 9 (API 28) sampai Android 16 (API 36 saat rilis).
        minSdk = 28
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: ganti dengan signing config rilis Anda sendiri sebelum
            // upload ke Play Console. Signing config debug dipakai sementara
            // agar `flutter build apk` tidak gagal saat development.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("androidx.multidex:multidex:2.0.1")
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("androidx.multidex:multidex:2.0.1")
}
