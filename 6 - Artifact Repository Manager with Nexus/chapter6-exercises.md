# TASK BREAK DOWN

## Exercise 1

- [] Task 1: Steps to Install Nexus Repository Manager on Ubuntu 22.04 LTS
  - **Prerequisites:**
    - Ensure you have a clean Ubuntu 22.04 LTS server with sufficient resources (CPU, memory, disk space).
    - Install Java 8, as Nexus Repository Manager recommends Java 8 for compatibility.
      - `sudo apt update`
      - `sudo apt upgrade -y`
      - `sudo apt install openjdk-8-jdk`
    - Verify Java installation:
      - `java -version`
  - **Provision Nexus Service Account & Isolate Privileges**
    - Create a user for Nexus:
      - `sudo mkdir -p /home/nexus`
      - `sudo groupadd nexus`
      - `sudo useradd -r -g nexus -d /home/nexus -s /bin/bash nexus`
    - Create nested folder structure:
      - `sudo mkdir -p /opt/nexus/nexus-repository-manager`
    - Update permissions for the nested folder structure:
      - `sudo chmod 770 /opt/nexus`
      - `sudo chown -R root:nexus /opt/nexus`
  - **Download Nexus Repository Manager:**
    - Visit the [Sonatype Nexus Download Page](https://help.sonatype.com/repomanager3/product-information/download) to find the link to the latest Nexus Repository Manager.
    - Copy the Unix archive download link for the latest version.
  - **Download and Extract:**
    - On your Ubuntu server, use `wget` or `curl` to download the Nexus tar.gz file. For example:
      - `wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz`
      - > Before using `wget` or `curl`, make sure you are in the `/opt/nexus/nexus-repository-manager` directory.
    - Extract the downloaded archive. For example:
      - `tar -xvzf latest-unix.tar.gz > /dev/null`
  - **Configure Nexus as a Service:**
    - Create a symbolic link to the Nexus directory for easier management:
      - `sudo ln -s /opt/nexus/nexus-repository-manager /opt/nexus/nexus-latest`
    - Open the `nexus.rc` file for editing:
      - `sudo -u nexus vim /opt/nexus/bin/nexus.rc`
    - Look for the `run_as_user` setting. It should look like this:
      - `run_as_user="nexus"`
      - If commented out, uncomment it by removing the `#` at the beginning of the line.
      - Save the file and exit the editor.
    - Create a systemd service file for Nexus:
      - `sudo -u nexus vim /etc/systemd/system/nexus.service`
    - Add the following content to the file:

      ```(systemd config)
      [Unit]
      Description=Nexus Repository Manager  # Human-readable description
      After=network.target  # Start after the network is up

      [Service]
      Type=forking  # Background process
      LimitNOFILE=65536  # Limit file descriptors
      ExecStart=/opt/nexus-latest/bin/nexus start  # Start Nexus service
      ExecStop=/opt/nexus-latest/bin/nexus stop  # Stop Nexus service
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
    - Nexus by default runs on port `8081`, so you need to allow access on this port using a firewall rule. Once that is done, open your web browser and navigate to `http://your-server-ip:8081`.

## Exercise 2

## Exercise 3

## Exercise 4

## Exercise 5

## Exercise 6

## Exercise 7

## Exercise 8

## Exercise 9
