# Explanation

When building and publishing a JAR file to a Maven repository using Gradle, you need to add the following line in your `build.gradle` file:

```groovy
apply plugin: 'maven-publish'
```

Adding this line is necessary to enable the Maven Publish plugin in your Gradle project. The Maven Publish plugin is used to publish artifacts, such as JAR files, to a Maven repository.

Here's why you need to add this line:

1. **Enabling Maven Publish Plugin:** By applying the `maven-publish` plugin, you are enabling the functionality to publish artifacts to a Maven repository. This plugin provides the necessary tasks and configurations to generate the required metadata and publish your artifacts.

2. **Publishing Artifacts:** With the Maven Publish plugin enabled, you can define the artifacts you want to publish, such as your project's JAR file. The plugin will generate the necessary Maven metadata files, including the `pom.xml` file, which describes your project's dependencies and other information required by Maven repositories.

3. **Configuring Publication:** Once the plugin is applied, you can configure the publication settings in your `build.gradle` file. This includes specifying the repository URL where you want to publish your artifacts, the artifact's group ID, artifact ID, version, and any additional metadata or dependencies.

4. **Running Publication Task:** With the Maven Publish plugin configured, you can use the `publish` task provided by the plugin to publish your artifacts to the specified Maven repository. This task will build your project, generate the necessary metadata, and upload the artifacts to the repository.

### Configuring Maven Publish Plugin

Here's an example of how you can configure the Maven Publish plugin in your `build.gradle` file:

```groovy
apply plugin: 'maven-publish'

publishing {
    publications {
        maven(MavenPublication) {
            artifact("build/libs/my-app-$version" + ".jar") {
                extension 'jar'
            }
        }
    }
    repositories {
        maven {
            url 'http://localhost:8081/repository/maven-releases/'
            allowInsecureProtocol = true
            credentials {
                username nexusUsername
                password nexusPassword
            }
        }
    }
}
```

In this example, the `maven-publish` plugin is applied, and the publication settings are configured.  

The `publications` block defines the artifact to be published. It specifies the path to the JAR file using the `artifact` method, which points to the JAR file located in the `build/libs` directory. The `extension` property is set to `'jar'` to indicate that the artifact is a JAR file. The `$version` variable is used to include the version number in the JAR file name.  

The `repositories` block specifies the target Maven repository URL and the credentials required to authenticate and publish to the repository.

### Storing Credentials Securely

It's important to note that storing sensitive information like usernames and passwords directly in the `build.gradle` file is not recommended, as it poses security risks, especially if the file is version-controlled or shared with others.

The best practice is to store sensitive information, such as credentials, in a separate `gradle.properties` file. The `gradle.properties` file is usually located in the project's root directory or in the `~/.gradle/` directory (user home directory) for global configuration.

Here's how you can store the username and password in the `gradle.properties` file and reference them in your `build.gradle` file:

1. Create a `gradle.properties` file in your project's root directory (if it doesn't exist already).

2. Add the following lines to the `gradle.properties` file, replacing `your_username` and `your_password` with your actual credentials:

   ```groovy
   nexusUsername=your_username
   nexusPassword=your_password
   ```

3. In your `build.gradle` file, update the `repositories` block to reference the properties defined in `gradle.properties`:

   ```groovy
   repositories {
       maven {
           url 'http://localhost:8081/repository/maven-releases/'
           allowInsecureProtocol = true
           credentials {
               username nexusUsername
               password nexusPassword
           }
       }
   }
   ```

   In this updated configuration, the `credentials` block now references the `nexusUsername` and `nexusPassword` properties instead of hardcoding the values directly.

By storing the username and password in the `gradle.properties` file, you separate the sensitive information from the `build.gradle` file. The `gradle.properties` file should be added to your `.gitignore` file (or equivalent) to prevent it from being version-controlled and accidentally shared.

When Gradle runs, it automatically reads the properties defined in the `gradle.properties` file and uses them in the build configuration.

Remember to replace `your_username` and `your_password` in the `gradle.properties` file with your actual Nexus repository credentials.

This approach enhances security by keeping sensitive information separate from the main build configuration file and allows for easier management of credentials across different environments or users.

### Allowing Insecure Protocol (HTTP)

If you are accessing the Nexus repository using HTTP instead of HTTPS, you need to add the `allowInsecureProtocol = true` configuration inside the `maven` block in your `build.gradle` file.

```groovy
repositories {
    maven {
        url 'http://localhost:8081/repository/maven-releases/'
        allowInsecureProtocol = true
        credentials {
            username nexusUsername
            password nexusPassword
        }
    }
}
```

The reason for adding this configuration is that, by default, Gradle enforces secure communication over HTTPS when interacting with repositories. However, if your Nexus repository is set up to use HTTP instead of HTTPS, Gradle will raise an error and refuse to connect to the repository due to the insecure protocol.

By setting `allowInsecureProtocol = true`, you are explicitly allowing Gradle to connect to the Nexus repository over HTTP, even though it is not a secure protocol. This configuration tells Gradle to bypass the security check and proceed with the insecure connection.

It's important to note that using HTTP for communication with a repository is not recommended, especially in production environments. HTTP is an insecure protocol and can be vulnerable to eavesdropping and man-in-the-middle attacks. Whenever possible, it is strongly advised to configure your Nexus repository to use HTTPS for secure communication.

If you have the ability to configure your Nexus repository to use HTTPS, it is highly recommended to do so. In that case, you would not need to add the `allowInsecureProtocol = true` configuration in your `build.gradle` file.

However, if you are in a development or testing environment and using HTTP is the only option available, adding `allowInsecureProtocol = true` allows Gradle to connect to the Nexus repository over HTTP as a temporary workaround.

Remember, this configuration should be used with caution and only in situations where using HTTPS is not feasible. It's always best to prioritize security and use HTTPS for secure communication between Gradle and the Nexus repository.
