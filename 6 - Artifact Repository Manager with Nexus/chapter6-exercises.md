# TASK BREAK DOWN

## Exercise 1

- [x] Task 1: Steps to Install Nexus Repository Manager on Ubuntu 22.04 LTS
  - **Prerequisites:**
    - Ensure you have a clean Ubuntu 22.04 LTS server with sufficient resources (CPU, memory, disk space).
    - Install Java 8, as Nexus Repository Manager recommends Java 8 for compatibility.

      ```bash
      sudo apt update
      sudo apt upgrade -y
      sudo apt install openjdk-8-jdk
      ```

    - Verify Java installation:

      ```bash
      java -version
      ```

  - **Provision Nexus Service Account:**
    - Create a user for Nexus:

      ```bash
      sudo mkdir -p /home/nexus
      sudo groupadd nexus
      sudo useradd -r -g nexus -d /home/nexus -s /bin/bash nexus
      ```

  - **Download Nexus Repository Manager:**
    - Create nested folder structure:

      ```bash
      sudo mkdir -p /opt/nexus/nexus-repository-manager
      ```

    - Visit the [Sonatype Nexus Download Page](https://help.sonatype.com/repomanager3/product-information/download) to find the link to the latest Nexus Repository Manager.
    - Copy the Unix archive download link for the latest version.
  - **Initialize Nexus Environment:**
    - On your Ubuntu server, use `wget` or `curl` to download the Nexus tar.gz file. For example:

      ```bash
      wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
      ```

      - > Before using `wget` or `curl`, make sure you are in the `/opt/nexus/nexus-repository-manager` directory.
    - Extract the downloaded archive. For example:

      ```bash
      tar -xvzf latest-unix.tar.gz > /dev/null
      ```

    - Create a symbolic link to the Nexus directory for easier management:

      ```bash
      sudo ln -s /opt/nexus/nexus-repository-manager /opt/nexus/nexus-latest
      ```

  - **Isolate Nexus Service Account Privileges:**
    - Update permissions for the nested folder structure:

      ```bash
      sudo chmod -R 770 /opt/nexus
      sudo chown -R root:nexus /opt/nexus
      ```

  - **Configure Nexus as a Service:**
    - Open the `nexus.rc` file for editing:

      ```bash
      vim /opt/nexus/nexus-latest/nexus-3.66.0-02/bin/nexus.rc
      ```

    - Look for the `run_as_user` setting. It should look like this:

      ```bash
      run_as_user="nexus"
      ```

      - If commented out, uncomment it by removing the `#` at the beginning of the line.
      - Save the file and exit the editor.
    - Create a systemd service file for Nexus:

      ```bash
      vim /etc/systemd/system/nexus.service
      ```

    - Add the following content to the file:

      ```(systemd config)
      [Unit]
      Description=Nexus Repository Manager  # Human-readable description
      After=network.target  # Start after the network is up

      [Service]
      Type=forking  # Background process
      LimitNOFILE=65536  # Limit file descriptors
      ExecStart=/opt/nexus/nexus-latest/nexus-3.66.0-02/bin/nexus start  # Start Nexus service
      ExecStop=/opt/nexus/nexus-latest/nexus-3.66.0-02/bin/nexus stop  # Stop Nexus service
      User=nexus  # Run as user
      Group=nexus  # Run under group
      Restart=on-abort  # Restart on failure

      [Install]
      WantedBy=multi-user.target  # Target for enabling the service
      ```

      - Save and close the file.
    - Reload the systemd manager configuration to apply the changes:

      ```bash
      sudo systemctl daemon-reload
      ```

    - Enable the Nexus service to start on server boot:

      ```bash
      sudo systemctl enable nexus
      ```

    - Start the Nexus repository manager service:

      ```bash
      sudo systemctl start nexus
      ```

    - Verify Nexus service status and operations:

      ```bash
      sudo systemctl status nexus
      ```

    - ***(Optional)*** View real-time Nexus logs and progress:

      ```bash
      sudo journalctl -u nexus
      ```

  - **Access Nexus Web Interface:**
    - Nexus by default runs on port `8081`, so you need to allow access on this port using a firewall rule. Once that is done, open your web browser and navigate to `http://your-server-ip:8081`. You will need to wait for a few seconds for the page to show up.

> [!NOTE]
> I have created a script for installing Nexus using the workflow mentioned above. Please read this page to understand the script before running.

## Exercise 2

To create a new `npm` hosted repository in Nexus Repository Manager for a Node.js application, along with a new blob store, you can follow this task list.

- [x] Task 1: Log In to Nexus Repository Manager as Administrator
  - **Access Nexus Repository Manager:**
    - Open a web browser and navigate to the Nexus Repository Manager interface. By default, this is `http://<your_nexus_host>:8081`.
  - **Find the Default Admin Password:**
    - Log in to the server where Nexus Repository Manager is installed.
    - Locate the `admin.password` file within the `sonatype-work/nexus3` directory. Use the command appropriate for your installation path, for example:

     ```bash
      cat /opt/nexus/nexus-latest/sonatype-work/nexus3/admin.password; echo
     ```

    - If you're unsure about the file's location or if the directory structure has changed in newer versions of Nexus, you can use the find command to search for it starting from the symbolic link's target directory:

    ```bash
      sudo find /opt/nexus/nexus-latest/ -name admin.password; echo
    ```

    - Note the password contained in this file for the next step.
  - **Log In:**
    - Log in with the administrative credentials found in the previous step (default admin username is `admin`).

- [x] Task 2: Create Manager Role
  - **Access Administration Settings:**
    - Click on the gear icon on the top-left side of the Nexus UI to access the administration settings.
  - **Navigate to Roles:**  
    - From the left-hand menu, select `Security` and then click on `Roles`.
  - **Create a New Role:**
    - Click on the `Create Role` button.
    - In the `Role Type` dropdown, select `Nexus role`.
    - Set the `Role ID` to `nx-manager`.
    - Set the `Role Name` to `nx-manager`.
    - In the `Role Description` field, enter a description like `Manager Role`.
  - **Assign Privileges:**
    - Under `Applied Privileges`, click on `Modify Applied Privileges`.
    - In the privilege selection dialog, search for and select the following privileges:
      - `nx-repository-admin-*-*-*` (All privileges for all repository administration)
      - `nx-blobstores-all` (All permissions for Blobstores)
      - `nx-capabilities-all` (All permissions for Capabilities)
      - `nx-datastores-all` (All permissions for Datastores)
      - `nx-ldap-all` (All permissions for Ldap)
      - `nx-logging-all` (All permissions for Logging)
      - `nx-metrics-all` (All permissions for Metrics)
      - `nx-roles-all` (All permissions for Roles)
    - Click `Confirm` to apply the selected privilege.
  - **Save the Role:**
    - Click `Save` to create the new role.

- [x] Task 3: Create a User with Limited Administrative Permissions
  - **Navigate to User Management:**
    - In the Nexus Repository Manager interface, click on the gear icon on the top-left side of the screen to access the administration settings.
    - From the administration menu on the left, select `Security` to manage security-related configurations.
    - Under the `Security` section, click on `Users` to manage user accounts.
  - **Create a New User:**
    - Click on the `Create local user` button to initiate the user creation process.
    - Fill in the required information for the new user:
      - User ID: Enter a unique identifier for the user.
      - First Name: Enter the user's first name.
      - Last Name: Enter the user's last name.
      - Email: Enter the user's email address.
      - Password: Enter a strong password for the user.
      - Confirm Password: Re-enter the password for confirmation.
      - Status: Set the user's status to `Active`.
      - Roles: Assign appropriate role to the user based on their responsibilities.
  - **Assign Administrative Roles:**
    - To grant the user administrative permissions without full admin access, assign the following roles:
      - `nx-manager`
    - You can assign this role by selecting them from the available roles list or by searching for them using the search functionality.
  - **Save the User:**
    - After assigning the appropriate role, click on the `Create local user` button to save the user account.
    - > Login with the new user once you are done with Task 3.

- [x] Task 4: Create a New Blob Store
  - **Access Blob Stores:**
    - Click on the gear icon in the top-left corner of the Nexus UI to access the administration settings.
    - From the left sidebar, select `Blob Stores` under the `Repository` section.
  - **Create a New Blob Store:**
    - Click on the `Create blob store` button.
    - Enter a unique name for the blob store in the `Name` field, e.g., `npm-hosted-blob-store`.
    - Specify the absolute path or a path relative to `data-directory/blobs` in the `Path` field, e.g., `/opt/nexus/nexus-repository-manager/sonatype-work/nexus3/blobs`.
    - Select `File` as the `Type` of the blob store.
    - Leave the `Soft Quota` option disabled.
    - Click the `Save` button to create the new blob store configuration.

- [x] Task 5: Create an npm Hosted Repository
  - **Access Repositories:**
    - From the left-hand menu, select `Repositories` under the `Repository` section.
  - **Create a New Repository:**
    - Click on the `Create repository` button.
    - Choose `npm (hosted)` as the repository recipe.
  - **Configure Repository Settings:**
    - Provide a unique name for the repository in the `Name` field, e.g., `npm-hosted-repo`.
    - Set the `Online` checkbox to ensure the repository is accessible.
    - Choose the newly created blob store, e.g., `npm-hosted-blob-store`, from the `Blob store` dropdown menu.
    - Enable `Strict Content Type Validation` to enforce content type restrictions.
    - Optionally, if you want to allow overwriting existing packages, set the `Deployment Policy` to `Allow redeploy`.
    - Optionally, configure the `Cleanup Policies` based on your requirements, such as removing associated components when repository content is deleted.
  - **Save the Repository:**
    - Click on the `Create repository` button to save the new npm hosted repository configuration.

## Exercise 3

- [x] Task 1: Create Repository Access Role
  - **Access Roles:**
    - Click on the gear icon on the top-left side of the Nexus UI to access the administration settings.
    - From the left-hand menu, select `Roles` under the `Security` section.
  - **Create npm Repository Access Role:**
    - Click on the `Create role` button.
    - In the `Role Type` dropdown, select `Nexus role`.
    - Set the `Role ID` to `nx-npm-repo-p1`.
    - Set the `Role name` to `nx-npm-repo-p1`.
    - Provide a meaningful `Description` for the role, e.g., `Project 1 npm Role`.
    - In the `Applied Privileges` section, click on `Modify Applied Privileges` and search for `nx-repository-admin-npm-npm-hosted-repo-*`.
    - Select the `nx-repository-admin-npm-npm-hosted-repo-*` privilege and click on `Confirm`.
    - Click on `Save` to create the role configuration.

- [x] Task 2: Create a New User with npm Repository Access
  - **Access User Management:**
    - From the left-hand menu, select `Users` under the `Security` section.
  - **Create a New User:**
    - Click on the `Create local user` button.
    - Set a meaningful `User ID` for the new user, e.g., `project1-team`.
    - Provide the `First name` and `Last name` for the user.
    - Set the user's `Email` address.
    - Choose a strong `Password` for the user and confirm it.
    - Set the user's `Status` to `Active`.
    - In the `Roles` section:
      - Locate the `nx-npm-repo-p1` role under the `Available` column.
      - Select `nx-npm-repo-p1` and click the right arrow button to move it to the `Granted` column, thereby assigning the role to the new user.
  - **Save the User:**
    - Click on the `Create local user` button to save the new user configuration.

## Exercise 4

- [x] Task 1: Prepare the Node.js project
  - **Navigate to the Project Directory:**
    - Open a terminal or command prompt.
    - Navigate to the root directory of your Node.js project.
  - **Verify Package Configuration:**
    - Open the `package.json` file in a text editor.
    - Ensure that the `name`, `version`, and other relevant fields are correctly configured.
    - Save the changes if any modifications were made.

- [x] Task 2: Build the npm package
  - **Install Dependencies:**
    - Run the following command to install the project dependencies:

      ```bash
      npm install
      ```

    - Wait for the installation to complete.
  - **Create the Package:**
    - Run the following command to create the npm package:

      ```bash
      npm pack
      ```

    - This command will create a `.tgz` file in the project directory, representing the npm package.

- [x] Task 3: Activate npm Bearer Token Realm
  - **Access Realms Configuration:**
    - In the Nexus Repository Manager, click the gear icon to open the Administration console.
    - On the left sidebar, under `Security`, select `Realms`.
  - **Enable npm Bearer Token Realm:**
    - Locate the `npm Bearer Token Realm` in the list of available realms.
    - Click on `npm Bearer Token Realm` to automatically transfer it to the 'Active' list.
    - Click `Save` at the bottom to confirm the changes.

- [x] Task 4: Publish the npm package to the Nexus repository
  - **Configure npm Registry and Authentication:**
    - Execute the command below to authenticate with the Nexus repository. This will prompt you to input your username and password:

      ```bash
      npm login --registry=http://{nexus-ip}:{nexus-port}/repository/{npm-repo}/ --always-auth --userconfig=./.npmrc
      ```

      - Replace `{nexus-ip}` with the IP address of your Nexus server, `{nexus-port}` with the port number (default is 8081), and `{npm-repo}` with the name of your npm repository.
    - Upon successful authentication, this command will generate a .npmrc file in the current directory. This file securely stores your authentication token, enabling npm to interact with the Nexus repository without the need to re-enter credentials.
  - **Publish the Package:**
    - Run the following command to publish the npm package to the Nexus repository:

      ```bash
      npm publish --registry=http://{nexus-ip}:{nexus-port}/repository/{npm-repo}/ {package-name}.tgz
      ```

      - Replace `{nexus-ip}`, `{nexus-port}`, and `{npm-repo}` with the appropriate values, and `{package-name}` with the actual name of your package file.

- [x] Task 5: Verify the published package
  - **Check Repository:**
    - Open a web browser and navigate to your Nexus repository's web interface.
    - Access the npm repository where the package was published.
  - **Verify Package Presence:**
    - Look for the published package in the repository.
    - Ensure that the package name, version, and other details match your expectations.

## Exercise 5

- [x] Task 5: Create a Maven Hosted Repository
  - **Access Repository Management:**
    - Click on the gear icon in the top-left corner of the Nexus UI to access the administration settings.
    - From the left sidebar, select `Repositories` under the `Repository` section.
  - **Initiate Repository Creation:**
    - Click on the `Create repository` button.
    - Select `maven2 (hosted)` as the recipe for the new repository.
  - **Configure Maven Repository:**
    - Provide a unique name for the repository in the `Name` field, e.g., `maven-hosted-repo`.
    - Ensure the `Online` checkbox is selected to make the repository accessible.
    - Select the appropriate `Version policy`:
      - `Release` for stable release artifacts.
      - `Snapshot` for development versions.
      - `Mixed` if the repository will contain both types.
    - Choose a `Layout policy`:
      - `Strict` if only Maven 2 repository format paths should be allowed.
      - `Permissive` to allow paths that are not compliant with Maven 2 repository format.
    - Decide on `Content Disposition`:
      - `Inline` to display content such as images or text in the browser.
      - `Attachment` if content should be downloaded and not displayed inline.
    - Set the `Blob store` to `default`.
    - Set the `Strict Content Type Validation` based on your requirements:
      - Enable it to enforce strict content type validation for uploaded artifacts. (default)
      - Disable it if you want to allow more flexibility in the uploaded content types.
    - Decide on `Deployment Policy`:
      - `Allow redeploy` to allow overwriting existing artifacts.
      - `Disable redeploy` to prevent overwriting artifacts.
      - `Read-only` to block any artifact deployment.
      - `Deploy by Replication Only` for replication-controlled deployments.
    - Select the desired `Cleanup Policies` from the available options based on your needs.
  - **Save Repository Configuration:**
    - Review all settings and click `Create repository` to finalize the Maven repository setup.

## Exercise 6

- [x] Task 1: Navigate to the Users section
  - **Access User Management:**
    - Click on the gear icon in the top-left corner of the Nexus UI to access the administration settings.
    - From the left sidebar, select `Users` under the `Security` section.

- [x] Task 2: Create a new user
  - **Create a New User:**
    - Click on the `Create user` button.
    - Provide the necessary details for the user:
      - Enter a unique username in the `Username` field, e.g., `p2-t2-user`.
      - Specify the user's first name in the `First name` field.
      - Specify the user's last name in the `Last name` field.
      - Enter the user's email address in the `Email` field.
      - Set the user's password in the `Password` field.
      - Confirm the password in the `Password confirmation` field.
      - Set the user's status to `Active` to enable their access.
    - Click the `Create user` button to save the user details.

- [x] Task 3: Assign the user to a role
  - **Create a New Role:**
    - Navigate to the `Roles` section under the `Security` menu in the left sidebar.
    - Click on the `Create role` button.
    - Provide a name for the role in the `Role ID` field, e.g., `p2-t2-maven-repo-user`.
    - Add a description for the role in the `Description` field (optional).
    - In the `Privileges` section, search for and select the appropriate privileges for accessing the Maven hosted repository. For example:
      - `nx-repository-view-maven2-*-browse` (allows browsing the repository)
      - `nx-repository-view-maven2-*-read` (allows reading artifacts from the repository)
    - Click the `Create role` button to save the role configuration.
  - **Assign the Role to the User:**
    - Go back to the `Users` section and locate the newly created user.
    - Click on the user to open their details page.
    - In the `Roles` section, click on the `Add` button.
    - Search for and select the role you just created, e.g., `p2-t2-maven-repo-user`.
    - Click the `Add role` button to assign the role to the user.

- [x] Task 4: Verify the user's access
  - **Log in as the New User:**
    - Log out of the Nexus UI and log back in as the newly created user.
  - **Verify Repository Access:**
    - Navigate to the Maven hosted repository.
    - Verify that the user can browse and access the repository based on the assigned privileges.

## Exercise 7

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

## Exercise 8

## Exercise 9
