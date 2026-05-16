import com.android.build.gradle.LibraryExtension

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
subprojects {
    if (name == "isar_flutter_libs") {
        val manifestFile = file("src/main/AndroidManifest.xml")
        if (manifestFile.exists()) {
            val original = manifestFile.readText()
            val cleaned = original.replace(
                "\n    package=\"dev.isar.isar_flutter_libs\"",
                "",
            )
            if (cleaned != original) {
                manifestFile.writeText(cleaned)
            }
        }
    }

    plugins.withId("com.android.library") {
        extensions.configure<LibraryExtension>("android") {
            if (namespace == null) {
                namespace = if (project.name == "isar_flutter_libs") {
                    "dev.isar.isar_flutter_libs"
                } else {
                    "com.stellantis.app.${project.name.replace("-", "_")}"
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
