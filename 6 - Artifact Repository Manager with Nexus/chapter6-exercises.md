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
    - Click `OK` to apply the selected privilege.
  - **Save the Role:**
    - Click `Create Role` to save the new role.

- [x] Task 3: Create a User with Limited Administrative Permissions
  - **Navigate to User Management:**
    - In the Nexus Repository Manager interface, click on the gear icon on the top-left side of the screen to access the administration settings.
    - From the administration menu on the left, select `Security` to manage security-related configurations.
    - Under the `Security` section, click on `Users` to manage user accounts.
  - **Create a New User:**
    - Click on the "Create local user" button to initiate the user creation process.
    - Fill in the required information for the new user:
      - User ID: Enter a unique identifier for the user.
      - First Name: Enter the user's first name.
      - Last Name: Enter the user's last name.
      - Email: Enter the user's email address.
      - Password: Enter a strong password for the user.
      - Confirm Password: Re-enter the password for confirmation.
      - Status: Set the user's status to `Active`.
      - Roles: Assign appropriate roles to the user based on their responsibilities.
  - **Assign Administrative Roles:**
    - To grant the user administrative permissions without full admin access, assign the following roles:
      - `nx-manager`: This role grants admin access to all repositories, enabling the user to create, modify, and delete repositories.
    - You can assign these roles by selecting them from the available roles list or by searching for them using the search functionality.
  - **Save the User:**
    - After assigning the appropriate roles, click on the `Create local user` button to save the user account.
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

- [x] Task 1: Create Repository View Role
  - **Access Roles:**
    - Click on the gear icon on the top-left side of the Nexus UI to access the administration settings.
    - From the left-hand menu, select `Roles` under the `Security` section.
  - **Create npm Repository View Role:**
    - Click on the `Create role` button.
    - In the `Role Type` dropdown, select `Nexus role`.
    - Set the `Role ID` to `nx-npm-repo-p1`.
    - Provide a meaningful `Role name` and `Description` for the role, e.g., `npm Repository View`.
    - In the `Privileges` section, click on `Add privilege` and search for `nx-repository-view-npm-*-*`.
    - Select the `nx-repository-view-npm-*-*` privilege and click on `Add selected`.
    - Click on `Create role` to save the role configuration.

- [x] Task 2: Create a New User
  - **Access User Management:**
    - From the left-hand menu, select `Users` under the `Security` section.
  - **Create a New User:**
    - Click on the `Create local user` button.
    - Set a meaningful `User ID` for the new user, e.g., `project1-developer`.
    - Provide the `First name` and `Last name` for the user (optional).
    - Set the user's `Email` address (optional).
    - Choose a strong `Password` for the user and confirm it.
    - Set the user's `Status` to `Active`.
  - **Save the User:**
    - Click on the `Create local user` button to save the new user configuration.

- [x] Task 3: Assign Roles to the User
  - **Access User Roles:**
    - From the list of users, click on the newly created `project1-developer` user.
    - In the user details page, click on the `Roles` tab.
  - **Assign Roles:**
    - Click on the `Modify user roles` button.
    - In the role selection dialog, search for and select the previously created roles:
      - `nx-npm-repo-p1` (to grant read access to npm repositories)
    - Click on the `Add selected roles` button to assign the selected roles to the user.
  - **Save the User Roles:**
    - Click on the `Save` button to apply the role changes.

## Exercise 4

## Exercise 5

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

## Exercise 8

## Exercise 9
