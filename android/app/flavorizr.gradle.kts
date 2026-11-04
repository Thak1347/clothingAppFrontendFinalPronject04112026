import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)
val localEnvFile = project.rootProject.projectDir.parentFile.resolve(".env")
val mapsKeyFromLocalEnv = if (localEnvFile.isFile) {
    localEnvFile.useLines { lines ->
        lines.firstNotNullOfOrNull { line ->
            val entry = line.trim()
            val separator = entry.indexOf('=')
            if (entry.isEmpty() ||
                entry.startsWith("#") ||
                separator < 0 ||
                entry.substring(0, separator).trim() != "GOOGLE_MAPS_API_KEY"
            ) {
                null
            } else {
                entry.substring(separator + 1)
                    .trim()
                    .removeSurrounding("\"")
                    .removeSurrounding("'")
                    .takeIf { it.isNotBlank() }
            }
        }
    }
} else {
    null
}
val googleMapsApiKey = project.providers.gradleProperty("googleMapsApiKey")
    .orNull
    ?: project.providers.environmentVariable("GOOGLE_MAPS_API_KEY").orNull
    ?: mapsKeyFromLocalEnv

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.clothingapp.dev"
            resValue(type = "string", name = "Clothing_Dev", value = "Clothing Dev")
            resValue(
                type = "string",
                name = "google_maps_key",
                value = googleMapsApiKey.orEmpty()
            )
        }
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.clothingapp.staging"
            resValue(type = "string", name = "Clothing_Staging", value = "Clothing Staging")
            resValue(
                type = "string",
                name = "google_maps_key",
                value = googleMapsApiKey.orEmpty()
            )
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.clothingapp"
            resValue(type = "string", name = "Clothing", value = "Clothing")
            resValue(
                type = "string",
                name = "google_maps_key",
                value = googleMapsApiKey.orEmpty()
            )
        }
    }

    buildFeatures.resValues = true
}

project.tasks.configureEach {
    if (name.startsWith("preDev") ||
        name.startsWith("preStaging") ||
        name.startsWith("preProd")
    ) {
        doFirst {
            check(!googleMapsApiKey.isNullOrBlank()) {
                "Google Maps API key is missing. Set GOOGLE_MAPS_API_KEY or pass -PgoogleMapsApiKey=..."
            }
        }
    }
}