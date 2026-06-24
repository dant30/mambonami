plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Updated package name
    namespace = "com.mambonami.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // Updated Application ID to match your Google Play package
        applicationId = "com.mambonami.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // For development (debug) – uses the debug keystore
        create("debug") {
            // The debug keystore is generated automatically by Android Studio
            // No need to specify credentials for debug
        }
        // For release – you must create your own keystore
        // Uncomment and configure this block before building a release
        // create("release") {
        //     storeFile = file("path/to/your/keystore.jks")
        //     storePassword = "your_store_password"
        //     keyAlias = "your_key_alias"
        //     keyPassword = "your_key_password"
        // }
    }

    buildTypes {
        release {
            // TODO: Replace with your release signing config
            // For now, signing with debug keys (DO NOT USE FOR PRODUCTION)
            signingConfig = signingConfigs.getByName("debug")
            // When you have your keystore ready, replace the line above with:
            // signingConfig = signingConfigs.getByName("release")
            
            // Proguard (optional, but recommended)
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}