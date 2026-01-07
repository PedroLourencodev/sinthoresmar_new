plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.com.sinthoresmar.sinthoresmar_novo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "br.com.sinthoresmar.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🔑 Configuração da key de release (Kotlin DSL)
    signingConfigs {
        create("release") {
            // Caminho completo da sua keystore
            storeFile = file("C:/keys/sinthoresmar-key.jks")

            // ⚠️ Insira aqui as senhas corretas
            storePassword = "Sucesso3*!"
            keyAlias = "sinthoresmar"
            keyPassword = "Sucesso3*!"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
