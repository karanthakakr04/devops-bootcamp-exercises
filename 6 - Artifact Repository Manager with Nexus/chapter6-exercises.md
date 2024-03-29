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
      sudo find /opt/nexus/nexus-latest/ -name admin.password
    ```

    - Note the password contained in this file for the next step.
  - **Log In:**
    - Log in with the administrative credentials found in the previous step (default admin username is `admin`).
- [x] Task 2: Create Repository View Role
  - **Access Administration Settings:**
    - Click on the gear icon on the top-left side of the Nexus UI to access the administration settings.
  - **Navigate to Roles:**  
    - From the left-hand menu, select `Security` and then click on `Roles`.
  - **Create a New Role:**
    - Click on the `Create Role` button.
    - In the `Role Type` dropdown, select `Nexus role`.
    - Set the `Role ID` to `nx-repository-view-all`.
    - Set the `Role Name` to `nx-repository-view-all`.
    - In the `Role Description` field, enter a description like `Role for viewing all repositories`.
  - **Assign Privileges:**
    - Under `Applied Privileges`, click on `Modify Applied Privileges`.
    - In the privilege selection dialog, search for and select the following privilege:
      - `nx-repository-view-*-*-*` (View all repositories)
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
      - `nx-repository-view-all`: This role grants read access to all repositories, enabling the user to view and browse repository contents.
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
    - Configure the `Cleanup Policies` based on your requirements, such as removing associated components when repository content is deleted.
  - **Save the Repository:**
    - Click on the `Create repository` button to save the new npm hosted repository configuration.

## Exercise 3

- [] Task 1: Create Repository View Role
  - **Access Roles:**
    - Click on the gear icon on the top-left side of the Nexus UI to access the administration settings.
    - From the left-hand menu, select `Roles` under the `Security` section.
  - **Create npm Repository View Role:**
    - Click on the `Create role` button.
    - Set the "Role ID" to `npm-repo-view`.
    - Provide a meaningful `Role name` and `Description` for the role, e.g., `npm Repository View`.
    - In the `Privileges` section, click on `Add privilege` and search for `nx-repository-view-npm-*-*`.
    - Select the `nx-repository-view-npm-*-*` privilege and click on `Add selected`.
    - Click on `Create role` to save the role configuration.
- [] Task 2: Create a New User
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
- [] Task 3: Assign Roles to the User
  - **Access User Roles:**
    - From the list of users, click on the newly created `project1-developer` user.
    - In the user details page, click on the `Roles` tab.
  - **Assign Roles:**
    - Click on the `Modify user roles` button.
    - In the role selection dialog, search for and select the previously created roles:
      - `npm-repo-view` (to grant read access to npm repositories)
    - Click on the `Add selected roles` button to assign the selected roles to the user.
  - **Save the User Roles:**
    - Click on the `Save` button to apply the role changes.

## Exercise 4

## Exercise 5

## Exercise 6

## Exercise 7

## Exercise 8

## Exercise 9
