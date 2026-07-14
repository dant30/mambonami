import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mambonami.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.mambonami.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Inject Maps API key from local.properties via manifest placeholders
        manifestPlaceholders["com.google.android.geo.API_KEY"] = (project.findProperty("MAPS_API_KEY") ?: "")
    }

    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        // Release signing config using the secure key.properties file.
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            keyAlias = keystoreProperties["keyAlias"] as String
            storePassword = keystoreProperties["storePassword"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }

    buildTypes {
        debug {
            // Debug builds should never shrink or minify.
            isMinifyEnabled = false
            isShrinkResources = false
        }

        release {
            // Use the production signing config for release builds.
            signingConfig = signingConfigs.getByName("release")

            // Disable minification for now to avoid ProGuard complexity.
            isMinifyEnabled = false
            isShrinkResources = false
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

// Apply the Google Services plugin to read google-services.json and generate resources
apply(plugin = "com.google.gms.google-services")