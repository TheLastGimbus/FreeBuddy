buildscript {
    extra.set("kotlin_version", "1.8.21")
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:7.4.1")
        classpath(kotlin("gradle-plugin", version = "1.8.21"))
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app")
}

tasks {
    task<Delete>("clean") {
        delete(rootProject.buildDir)
    }
}
