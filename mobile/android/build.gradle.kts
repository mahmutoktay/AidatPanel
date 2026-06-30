import com.android.build.gradle.LibraryExtension
import org.gradle.api.JavaVersion
import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
        // image_cropper (ucrop) — yalnızca com.github.*; io.flutter JitPack'te aranmasın
        maven {
            url = uri("https://jitpack.io")
            content {
                includeGroupByRegex("com\\.github.*")
            }
        }
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

// evaluationDependsOn'dan ÖNCE: pdfx vb. eklentilerde Java/Kotlin JVM 17 hizası (Kotlin 2.x + AGP 8).
// file_picker hariç: K2 + dairesel FileUtils/FilePickerDelegate referansı derleme hatası (#2070).
subprojects {
    if (name == "app" || name == "file_picker") return@subprojects
    afterEvaluate {
        extensions.findByType<LibraryExtension>()?.compileOptions?.apply {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }
    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions.jvmTarget.set(
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17,
        )
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

// :app GeneratedPluginRegistrant.java — Kotlin eklenti sınıfları önce derlensin.
gradle.projectsEvaluated {
    val app = rootProject.findProject(":app") ?: return@projectsEvaluated
    app.tasks.withType<JavaCompile>().configureEach {
        val variant = when {
            name.contains("Debug", ignoreCase = true) -> "Debug"
            else -> "Release"
        }
        rootProject.subprojects.forEach { pluginProject ->
            if (pluginProject.name == "app") return@forEach
            pluginProject.tasks.findByName("compile${variant}Kotlin")?.let { dependsOn(it) }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
