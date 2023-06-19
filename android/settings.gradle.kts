import java.util.*

include(":app")

val properties = Properties().apply {
    load(File(rootProject.projectDir, "local.properties").apply { assert(exists()) }.reader())
}

val flutterSdkPath =
    properties.getProperty("flutter.sdk") ?: throw GradleException("flutter.sdk not set in local.properties")
apply("$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")

pluginManagement {
    repositories {
        google()
        mavenCentral()
    }
}