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
      - `tar -xvzf latest-unix.tar.gz > /dev/null`
    - Create a symbolic link to the Nexus directory for easier management:
      - `sudo ln -s /opt/nexus/nexus-repository-manager /opt/nexus/nexus-latest`
  - **Isolate Nexus Service Account Privileges:**
    - Update permissions for the nested folder structure:
      - `sudo chmod -R 770 /opt/nexus`
      - `sudo chown -R root:nexus /opt/nexus`
  - **Configure Nexus as a Service:**
    - Open the `nexus.rc` file for editing:
      - `vim /opt/nexus/nexus-latest/nexus-3.65.0-02/bin/nexus.rc`
    - Look for the `run_as_user` setting. It should look like this:
      - `run_as_user="nexus"`
      - If commented out, uncomment it by removing the `#` at the beginning of the line.
      - Save the file and exit the editor.
    - Create a systemd service file for Nexus:
      - `vim /etc/systemd/system/nexus.service`
    - Add the following content to the file:

      ```(systemd config)
      [Unit]
      Description=Nexus Repository Manager  # Human-readable description
      After=network.target  # Start after the network is up

      [Service]
      Type=forking  # Background process
      LimitNOFILE=65536  # Limit file descriptors
      ExecStart=/opt/nexus/nexus-latest/nexus-3.65.0-02/bin/nexus start  # Start Nexus service
      ExecStop=/opt/nexus/nexus-latest/nexus-3.65.0-02/bin/nexus stop  # Stop Nexus service
      User=nexus  # Run as user
      Group=nexus  # Run under group
      Restart=on-abort  # Restart on failure

      [Install]
      WantedBy=multi-user.target  # Target for enabling the service
      ```

      - Save and close the file.
    - Reload the systemd manager configuration to apply the changes:
      - `sudo systemctl daemon-reload`
    - Enable the Nexus service to start on server boot:
      - `sudo systemctl enable nexus`
    - Start the Nexus repository manager service:
      - `sudo systemctl start nexus`
    - Verify Nexus service status and operations:
      - `sudo systemctl status nexus`
    - ***(Optional)*** View real-time Nexus logs and progress:
      - `sudo journalctl -u nexus`
  - **Access Nexus Web Interface:**
    - Nexus by default runs on port `8081`, so you need to allow access on this port using a firewall rule. Once that is done, open your web browser and navigate to `http://your-server-ip:8081`. You will need to wait for a few seconds for the page to show up.

> [!NOTE]
> I have created a script for installing Nexus using the workflow mentioned above. Please read this page to understand the script before running.

## Exercise 2

To create a new `npm` hosted repository in Nexus Repository Manager for a Node.js application, along with a new blob store, you can follow this task list.

- [] Task 1: Log In to Nexus Repository Manager as Administrator
  - **Access Nexus Repository Manager:**
    - Open a web browser and navigate to the Nexus Repository Manager interface. By default, this is `http://<your_nexus_host>:8081`.
  - **Find the Default Admin Password:**
    - Log in to the server where Nexus Repository Manager is installed.
    - Locate the `admin.password` file within the `sonatype-work/nexus3` directory. Use the command appropriate for your installation path, for example:

     ```bash

     cat /opt/nexus/nexus-latest/sonatype-work/nexus3/admin.password

     ```

    - If you're unsure about the file's location or if the directory structure has changed in newer versions of Nexus, you can use the find command to search for it starting from the symbolic link's target directory:

    ```bash

      sudo find /opt/nexus/nexus-latest/ -name admin.password

    ```

    - Note the password contained in this file for the next step.
  - **Log In:**
    - Log in with the administrative credentials found in the previous step (default admin username is `admin`).
- [] Task 2: Create a User with Limited Administrative Permissions
  - **Navigate to User Management:**
    - In the Nexus Repository Manager interface, click on the gear icon in the top-right corner to access the administration settings.

## Exercise 3

## Exercise 4

## Exercise 5

## Exercise 6

## Exercise 7

## Exercise 8

## Exercise 9
