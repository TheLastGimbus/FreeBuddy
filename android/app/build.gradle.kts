import java.nio.charset.Charset
import java.util.*

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.reader(Charset.forName("UTF-8")))
}

val flutterRoot = localProperties.getProperty("flutter.sdk")
    ?: throw GradleException("Flutter SDK not found. valine location with flutter.sdk in the local.properties file.")

val flutterVersionCode = localProperties.getProperty("flutter.versionCode").toInt() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"


// Properties for signing
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

plugins {
    id("com.android.application")
    kotlin("android")
}
apply(from = "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle.kts")

android {
    compileSdk = 33
    namespace = "com.lastgimbus.the.freebuddy"
    ndkVersion = localProperties.getProperty("flutter.ndkVersion")

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets.getByName("main").java {
        srcDir("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.lastgimbus.the.freebuddy"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-build-configuration.
        minSdkVersion(21)
        targetSdkVersion(localProperties.getProperty("flutter.targetSdkVersion") as String)
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile =
                if (file(keystoreProperties["storeFile"] as String).exists()) file(keystoreProperties["storeFile"] as String) else null
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                println("No key.properties found - Signing with debug keys")
                signingConfig = signingConfigs.getByName("debug")
            }
        }
        getByName("debug") {
            applicationIdSuffix = ".debug"
        }
        getByName("profile") {
            applicationIdSuffix = ".profile"
        }
    }
}

//flutter {
//    source("../..")
//}
project.extensions.getByName("flutter").apply {
    this::class.java.getMethod("source", String::class.java).invoke(this, "../..")
}

dependencies {
    // todo
    implementation(kotlin("stdlib-jdk7"))
}
