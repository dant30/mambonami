import com.android.build.api.dsl.LibraryExtension
import com.android.build.api.dsl.ApplicationExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Fallback: after the whole project is evaluated, ensure any Android extension
// has the expected compileSdk. This covers modules that initialized their
// Android extension earlier than our plugin hooks.
gradle.projectsEvaluated {
    subprojects.forEach { p ->
        try {
            val androidExt = p.extensions.findByName("android")
            if (androidExt != null) {
                when (androidExt) {
                    is com.android.build.api.dsl.LibraryExtension -> androidExt.compileSdk = 36
                    is com.android.build.api.dsl.ApplicationExtension -> androidExt.compileSdk = 36
                }
            }
        } catch (_: Exception) {
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    // Configure library modules when the Android library plugin is applied
    plugins.withId("com.android.library") {
        try {
            configure<LibraryExtension> {
                compileSdk = 36
            }
        } catch (_: Exception) {
        }
    }

    // Configure application modules when the Android application plugin is applied
    plugins.withId("com.android.application") {
        try {
            configure<ApplicationExtension> {
                compileSdk = 36
            }
        } catch (_: Exception) {
        }
    }
}
