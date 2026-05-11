plugins {
  id("buildlogic.java-application-conventions")
}

import org.gradle.api.plugins.JavaApplication
import org.gradle.api.tasks.Copy

application {
    // Define the main class for the application.
    mainClass.set("js.octra.joctra.examples.ExampleRunner")
}

dependencies {
    implementation("org.apache.commons:commons-text")
}

val copyNativeLib by tasks.registering(Copy::class) {
    from("$rootDir/octra/build/cmake/liboctra.so")
    into(layout.buildDirectory.dir("libs"))
    include("liboctra.so")
}

tasks.named<JavaExec>("run") {
    dependsOn(copyNativeLib)
    // Set the library path to include the directory with the .so file
    val libraryPath = layout.buildDirectory.dir("libs").get().asFile.absolutePath
    jvmArgs = listOf("-Djava.library.path=$libraryPath")
}
