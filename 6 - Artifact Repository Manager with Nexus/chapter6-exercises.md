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

- [x] Task 1: Create Repository Access Role
  - **Access Roles:**
    - Click on the gear icon on the top-left side of the Nexus UI to access the administration settings.
    - From the left-hand menu, select `Roles` under the `Security` section.
  - **Create npm Repository Access Role:**
    - Click on the `Create role` button.
    - In the `Role Type` dropdown, select `Nexus role`.
    - Set the `Role ID` to `nx-mvn-repo-p2`.
    - Set the `Role name` to `nx-mvn-repo-p2`.
    - Provide a meaningful `Description` for the role, e.g., `Project 2 mvn Role`.
    - In the `Applied Privileges` section, click on `Modify Applied Privileges` and search for `nx-repository-admin-maven2-maven-hosted-repo-*`.
    - Select the `nx-repository-admin-maven2-maven-hosted-repo-*` privilege and click on `Confirm`.
    - Click on `Save` to create the role configuration.

- [x] Task 2: Create a New User with mvn Repository Access
  - **Access User Management:**
    - From the left-hand menu, select `Users` under the `Security` section.
  - **Create a New User:**
    - Click on the `Create user` button.
    - Set a meaningful `User ID` for the new user, e.g., `project2-team`.
    - Provide the `First name` and `Last name` for the user.
    - Set the user's `Email` address.
    - Choose a strong `Password` for the user and confirm it.
    - Set the user's `Status` to `Active`.
    - In the `Roles` section:
      - Locate the `nx-mvn-repo-p2` role under the `Available` column.
      - Select `nx-mvn-repo-p2` and click the right arrow button to move it to the `Granted` column, thereby assigning the role to the new user.
  - **Save the User:**
    - Click on the `Create local user` button to save the new user configuration.

## Exercise 7

- [x] Task 1: Configure Maven Publish Plugin in `build.gradle`
  - **Add Maven Publish Plugin:**
    - Open the `build.gradle` file in your project.
    - Add the following line to apply the Maven Publish plugin:

      ```groovy
      apply plugin: 'maven-publish'
      ```

  - **Configure Publication Settings:**
    - In the `build.gradle` file, add the following block to configure the publication settings:

      ```groovy
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
                      username project.nexusUsername
                      password project.nexusPassword
                  }
              }
          }
      }
      ```

    - Replace `my-app` with your project's name and `$version` with the version number.
    - Update the `url` with the correct URL of your Nexus repository.
    - Set the `nexusUsername` and `nexusPassword` variables with the appropriate credentials inside `gradle.properties` file in the root directory.

      ```groovy
      repoUser=user
      repoPassword=pwd
      ```

- [x] Task 2: Build and Publish the JAR File
  - **Build the JAR:**
    - Open a terminal or command prompt.
    - Navigate to the root directory of your project.
    - Run the following command to build the JAR file:

      ```bash
      ./gradlew build
      ```

  - **Publish the JAR:**
    - After the build is successful, run the following command to publish the JAR to the Nexus repository:

      ```bash
      ./gradlew publish
      ```

    - The JAR file will be published to the specified Nexus repository using the team 2 user credentials.

- [x] Task 3: Verify the Published JAR
  - **Access Nexus Repository:**
    - Open a web browser and navigate to your Nexus repository's URL.
    - Log in with the team 2 user credentials.
  - **Verify the JAR:**
    - Navigate to the repository where the JAR was published that is `maven-hosted-repo`.
    - Verify that the JAR file is present in the repository.
    - Check that the JAR file has the correct version and metadata.

Note: Make sure you have the correct permissions and access rights configured for the team 2 user to publish artifacts to the Nexus repository.

## Exercise 8

- [x] Task 1: Create Repository Access Role
  - **Access Roles:**
    - Click on the gear icon on the top-left side of the Nexus UI to access the administration settings.
    - From the left-hand menu, select `Roles` under the `Security` section.
  - **Create a New Role:**
    - Click on the `Create role` button.
    - In the `Role Type` dropdown, select `Nexus role`.
    - Set the `Role ID` to `nx-npm-mvn-repo-access`.
    - Set the `Role name` to `nx-npm-mvn-repo-access`.
    - Provide a meaningful `Description` for the role, e.g., `Access role for both NPM and Maven repositories`.
    - In the `Applied Privileges` section, click on `Modify Applied Privileges` and search for the following privileges:
      - `nx-repository-admin-npm-npm-hosted-repo-*`
      - `nx-repository-admin-maven2-maven-hosted-repo-*`
    - Select both privileges and click on `Confirm`.
    - Click on `Save` to create the role configuration.

- [x] Task 2: Create a New User with Repository Access
  - **Access User Management:**
    - From the left-hand menu, select `Users` under the `Security` section.
  - **Create a New User:**
    - Click on the `Create user` button.
    - Set a meaningful `User ID` for the new user, e.g., `droplet-server-user`.
    - Provide the `First name` and `Last name` for the user.
    - Set the user's `Email` address.
    - Choose a strong `Password` for the user and confirm it.
    - Set the user's `Status` to `Active`.
    - In the `Roles` section:
      - Locate the `nx-npm-mvn-repo-access` role under the `Available` column.
      - Select `nx-npm-mvn-repo-access` and click the right arrow button to move it to the `Granted` column, thereby assigning the role to the new user.
  - **Save the User:**
    - Click on the `Create local user` button to save the new user configuration.

- [x] Task 3: Fetch Download URL for the Latest NodeJS App Artifact
  - **SSH into the DigitalOcean Droplet:**
    - Open a terminal or command prompt.
    - Use SSH to connect to your DigitalOcean Droplet:

      ```bash
      ssh -i <path_to_droplet_key> user@droplet-ip
      ```

    - Replace `user` with your Droplet's username and `droplet-ip` with the IP address of your Droplet. Also, specify the SSH key path `<path_to_droplet_key>` for the droplet.
  - **Fetch Download URL using Nexus REST API:**
    - Execute the following command to fetch the download URL for the latest NodeJS app artifact:

      ```bash
      curl -H "Authorization: Bearer {bearer-token}" -X GET 'http://{nexus-ip}:8081/service/rest/v1/components?repository={node-repo}&sort=version'
      ```

    - Replace `Bearer {bearer-token}` with the token saved in your `.npmrc` file created in Task 4.
    - Replace `{nexus-ip}` with the IP address of your Nexus server.
    - Replace `{node-repo}` with the name of your NodeJS repository in Nexus.

- [x] Task 4: Download the Latest NodeJS App Artifact
  - **Download the Artifact:**
    - Use the download URL obtained from Task 3 to download the latest NodeJS app artifact:

      ```bash
      curl -H "Authorization: Bearer {bearer-token}" -L -O {download-url}
      ```

    - Replace `Bearer {bearer-token}` with the token saved in your `.npmrc` file created in Task 4.
    - Replace `{download-url}` with the download URL obtained from the previous task.
    - The `-L` flag follows redirects, and the `-O` flag saves the artifact with its original filename.

- [x] Task 5: Unzip and Run the NodeJS App
  - **Unzip the Artifact:**
    - Extract the downloaded artifact using the `tar` command:

      ```bash
      tar -xvzf {artifact-filename}
      ```

    - Replace `{artifact-filename}` with the filename of the downloaded artifact.
  - **Run the NodeJS App:**
    - Navigate to the extracted directory:

      ```bash
      cd {app-directory}
      ```

    - Replace `{app-directory}` with the name of the directory created after extracting the artifact.
    - Install the app dependencies:

      ```bash
      npm install
      ```

    - Start the NodeJS app:

      ```bash
      npm start
      ```

Note: Make sure you have `Node.js` and `npm` installed on your DigitalOcean Droplet before running the NodeJS app.

## Exercise 9

- [ ] Task 1: Create a Script to Fetch and Run the Latest Version
  - **Create a new script file:**
    - Open a text editor on your local machine or the droplet server.
    - Create a new file named `fetch_and_run.sh`.
  - **Add the necessary variables:**
    - Set the `NEXUS_IP` variable to the IP address of your Nexus server.
    - Set the `NEXUS_REPO` variable to the name of your npm repository in Nexus.
    - Set the `BEARER_TOKEN` variable to the bearer token for authentication.
  - **Implement the `check_dependencies` function:**
    - Check if Node.js and npm are installed. If not, install them using NVM (Node Version Manager).
    - Install the latest LTS version of Node.js using NVM.
    - Check if the `jq` package is installed. If not, install it using the appropriate package manager.
  - **Implement the `fetch_download_url` function:**
    - Use the `curl` command with the bearer token to fetch the download URL of the latest artifact from the Nexus repository.
    - Extract the download URL from the JSON response using `jq`.
  - **Implement the `download_artifact` function:**
    - Use the `curl` command with the bearer token and the download URL to download the latest artifact.
    - Handle any errors during the download process and display appropriate error messages.
  - **Implement the `extract_artifact` function:**
    - Extract the downloaded artifact using the `tar` command.
    - Handle any errors during the extraction process.
    - Set the `APP_DIRECTORY` variable to the name of the extracted directory (e.g., "package").
  - **Implement the `run_app` function:**
    - Change to the extracted app directory.
    - Check if the `package.json` file exists.
    - If `package.json` exists, run `npm install` to install the app dependencies and then run `npm start` to start the application.
    - Handle any errors during the npm commands execution.
  - **Add the main script section:**
    - Call the `check_dependencies` function to ensure the necessary dependencies are installed.
    - Call the `fetch_download_url` function to fetch the download URL of the latest artifact.
    - Call the `download_artifact` function to download the latest artifact.
    - Call the `extract_artifact` function to extract the downloaded artifact.
    - Call the `run_app` function to install dependencies and start the application.
  - **Save the script file.**

  Example:
  ```bash
  #!/bin/bash
  
  # Set variables
  NEXUS_IP="<nexus-ip>"
  NEXUS_REPO="<node-repo>"
  BEARER_TOKEN="<bearer-token>"
  
  # Function to check dependencies
  check_dependencies() {
    # Check if Node.js and npm are installed, if not, install them using NVM
    # Install the latest LTS version of Node.js using NVM
    # Check if jq package is installed, if not, install it
  }
  
  # Function to fetch download URL
  fetch_download_url() {
    # Use curl with bearer token to fetch download URL from Nexus repository
    # Extract download URL from JSON response using jq
  }
  
  # Function to download artifact
  download_artifact() {
    # Use curl with bearer token and download URL to download the latest artifact
    # Handle download errors and display error messages
  }
  
  # Function to extract artifact
  extract_artifact() {
    # Extract downloaded artifact using tar command
    # Handle extraction errors
    # Set APP_DIRECTORY variable to the extracted directory name
  }
  
  # Function to run the application
  run_app() {
    # Change to the extracted app directory
    # Check if package.json exists
    # If package.json exists, run npm install and npm start
    # Handle npm command errors
  }
  
  # Main script
  check_dependencies
  fetch_download_url
  download_artifact
  extract_artifact
  run_app
  ```

- [ ] Task 2: Execute the Script on the Droplet
  - **Copy the script to the droplet:**
    - Use `scp` command to securely copy the `fetch_and_run.sh` script from your local machine to the droplet server.
      ```bash
      scp -i <path_to_droplet_key> fetch_and_run.sh <user>@<droplet-ip>:~/
      ```
    - Replace `<path_to_droplet_key>` with the path to your droplet's SSH key, `<user>` with the droplet's username, and `<droplet-ip>` with the IP address of your droplet.
  - **Connect to the droplet via SSH:**
    - Open a terminal or command prompt.
    - Use SSH to connect to your DigitalOcean droplet:
      ```bash
      ssh -i <path_to_droplet_key> <user>@<droplet-ip>
      ```
    - Replace `<path_to_droplet_key>`, `<user>`, and `<droplet-ip>` with the appropriate values.
  - **Make the script executable:**
    - On the droplet server, navigate to the directory where the `fetch_and_run.sh` script is located.
    - Run the following command to make the script executable:
      ```bash
      chmod +x fetch_and_run.sh
      ```
  - **Execute the script:**
    - Run the following command to execute the script:
      ```bash
      ./fetch_and_run.sh
      ```
    - The script will fetch the latest version from the npm repository, download and extract the artifact, and start the application on the server.
  - **Monitor the script execution:**
    - Watch the terminal output for any error messages or indications of success.
    - If the script runs successfully, the latest version of the application should be up and running on the droplet server.

Note: Make sure to replace `<nexus-ip>`, `<node-repo>`, `<bearer-token>`, `<path_to_droplet_key>`, `<user>`, and `<droplet-ip>` with the actual values specific to your setup.

By following these tasks, you will create a script that automates the process of fetching the latest version from the npm repository, downloading and extracting the artifact, and running the application on the droplet server. The script will handle dependencies, error handling, and the necessary steps to start the application.