#!/bin/bash

# Setting shell options for robust error handling:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status, or zero if no command exited with a non-zero status
set -euo pipefail

# Define the log file location
LOG_FILE="/var/log/install_nexus.log"

# Redirect all output and errors to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Update and upgrade the system
update_and_upgrade_system() {
    echo "Updating and upgrading the system..."
    sudo apt update
    sudo apt upgrade -y
}

# Check if Java 8 is installed
check_java_installation() {
    if java -version 2>&1 | grep -q 'java version "1.8'; then
        echo "Java 8 is already installed."
    else
        echo "Java 8 is not installed. Installing..."
        sudo apt install -y openjdk-8-jdk
    fi
}

# Create Nexus service account and directories
setup_nexus_user_and_directories() {
    echo "Setting up Nexus user and directories..."
    sudo mkdir -p /home/nexus /opt/nexus/nexus-repository-manager
    sudo groupadd nexus || echo "Group 'nexus' already exists"
    sudo useradd -r -g nexus -d /home/nexus -s /bin/bash nexus || echo "User 'nexus' already exists"
}

# Download and setup Nexus
download_and_setup_nexus() {
    echo "Downloading and setting up Nexus..."
    cd /opt/nexus/nexus-repository-manager
    wget https://download.sonatype.com/nexus/3/nexus-3.65.0-02-unix.tar.gz
    tar -xvzf nexus-3.65.0-02-unix.tar.gz > /dev/null
    sudo ln -sfn /opt/nexus/nexus-repository-manager /opt/nexus/nexus-latest
    sudo chmod -R 770 /opt/nexus
    sudo chown -R nexus:nexus /opt/nexus
}

# Configure Nexus as a service
configure_nexus_service() {
    echo "Configuring Nexus as a service..."
    sudo sed -i 's|#run_as_user=""|run_as_user="nexus"|' /opt/nexus/nexus-latest/nexus-3.65.0-02/bin/nexus.rc
    cat <<EOT | sudo tee /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/nexus-latest/nexus-3.65.0-02/bin/nexus start
ExecStop=/opt/nexus/nexus-latest/nexus-3.65.0-02/bin/nexus stop
User=nexus
Group=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

    sudo systemctl daemon-reload
    sudo systemctl enable nexus
    sudo systemctl start nexus
}

# Check Nexus Service Status
check_nexus_service_status() {
    echo "Checking Nexus service status..."
    sudo systemctl status nexus | grep 'active (running)' && echo "Nexus is running as expected." || echo "There may be an issue with the Nexus service."
    
    # Verify Nexus process is running as 'nexus' user
    if ps aux | grep '[n]exus' | grep -q 'nexus'; then
        echo "Nexus process is running under the 'nexus' user."
    else
        echo "Nexus process is not running under the 'nexus' user as expected."
    fi
}

main() {
    echo "Starting Nexus Repository Manager setup..."
    update_and_upgrade_system
    check_java_installation
    setup_nexus_user_and_directories
    download_and_setup_nexus
    configure_nexus_service
    check_nexus_service_status
    echo "Nexus Repository Manager setup completed."
}

# Invoke the main function and pass all script arguments to it.
# This setup allows for future extensibility of the script to handle command-line arguments if needed.
main "$@"
