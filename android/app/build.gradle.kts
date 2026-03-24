// android/app/build.gradle.kts (App-level)
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Google Services plugin — Firebase ke liye zaroori
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yashsoftware.quiztech"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.yashsoftware.quiztech"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
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
    // Firebase BoM — automatically compatible versions
    implementation(platform("com.google.firebase:firebase-bom:34.11.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // Google Sign In
    implementation("com.google.android.gms:play-services-auth:21.0.0")

    // MultiDex
    implementation("androidx.multidex:multidex:2.0.1")
}
