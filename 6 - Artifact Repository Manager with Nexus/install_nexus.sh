#!/bin/bash

# Setting shell options for robust error handling:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status
set -euo pipefail

# Define variables
NEXUS_VERSION="3.75.1-01"
NEXUS_DOWNLOAD_URL="https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz"
INSTALL_DIR="/opt/nexus"
NEXUS_HOME="${INSTALL_DIR}/nexus-repository-manager"
LOG_FILE="/var/log/install_nexus.log"

# Redirect all output and errors to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Update and upgrade the system
update_and_upgrade_system() {
    echo
    echo "Updating and upgrading the system..."
    sudo apt update 1>>/dev/null 2>&1
    sudo apt upgrade -y 1>>/dev/null 2>&1
    echo
}

# Check if Java 17 is installed
check_java_installation() {
    echo "Checking Java installation..."
    if java -version 2>&1 | grep -q 'version "17'; then
        echo "Java 17 is already installed."
    else
        echo "Java 17 is not installed. Installing OpenJDK 17..."
        # First, search for available OpenJDK packages
        sudo apt-cache search openjdk 1>>/dev/null 2>&1
        # Install OpenJDK 17
        sudo apt install -y openjdk-17-jdk 1>>/dev/null 2>&1
        
        # Verify Java installation
        if ! java -version 2>&1 | grep -q 'version "17'; then
            echo "Failed to install Java 17. Please check your system and try again."
            exit 1
        fi
    fi
    echo
}

# Configure JAVA_HOME environment variable
configure_java_home() {
    echo "Configuring JAVA_HOME environment variable..."
    JAVA_PATH=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
    
    # Verify Java installation path
    if [ ! -d "${JAVA_PATH}" ]; then
        echo "Error: Java installation path not found at ${JAVA_PATH}"
        exit 1
    fi
    echo "Verified Java installation path at: ${JAVA_PATH}"
    
    # Set JAVA_HOME in /etc/environment
    if ! grep -q "^JAVA_HOME=" /etc/environment; then
        echo "JAVA_HOME=\"${JAVA_PATH}\"" | sudo tee -a /etc/environment > /dev/null
    else
        sudo sed -i "s#^JAVA_HOME=.*#JAVA_HOME=\"${JAVA_PATH}\"#" /etc/environment
    fi
    
    # Load the new environment variable
    source /etc/environment
    echo "JAVA_HOME has been set to: $JAVA_HOME"
    echo
}

# Create Nexus service account and directories
setup_nexus_user_and_directories() {
    echo "Setting up Nexus user and directories..."
    sudo mkdir -p /home/nexus "${NEXUS_HOME}"
    sudo groupadd nexus 2>/dev/null || echo "Group 'nexus' already exists"
    sudo useradd -r -g nexus -d /home/nexus -s /bin/bash nexus 2>/dev/null || echo "User 'nexus' already exists"
    
    # Configure file handle limits for nexus user
    echo "Configuring file handle limits for nexus user..."
    
    # Add or update limits in /etc/security/limits.conf
    if ! grep -q "^nexus" /etc/security/limits.conf; then
        echo "nexus - nofile 65536" | sudo tee -a /etc/security/limits.conf > /dev/null
        echo "nexus - nproc 65536" | sudo tee -a /etc/security/limits.conf > /dev/null
    fi
    
    # Also add system-wide limits to ensure systemd service has adequate limits
    sudo mkdir -p /etc/systemd/system.conf.d
    cat <<EOT | sudo tee /etc/systemd/system.conf.d/limits.conf > /dev/null
[Manager]
DefaultLimitNOFILE=65536
DefaultLimitNPROC=65536
EOT
    
    echo "File handle limits configured."
    echo
}

# Download and setup Nexus
download_and_setup_nexus() {
    echo "Downloading and setting up Nexus ${NEXUS_VERSION}..."
    cd "${NEXUS_HOME}"
    
    # Install curl if not present
    if ! [ -x "$(command -v curl)" ]; then
        echo "curl not found, installing..."
        sudo apt install -y curl 1>>/dev/null 2>&1
        echo
    fi

    # Download Nexus
    echo "Downloading Nexus from ${NEXUS_DOWNLOAD_URL}..."
    curl -sSfLJO "${NEXUS_DOWNLOAD_URL}" 1>>/dev/null 2>&1 || {
        echo "Failed to download Nexus. Please check the version number and URL."
        exit 1
    }
    
    # Verify download was successful and file exists
    if [ ! -f "nexus-${NEXUS_VERSION}-unix.tar.gz" ]; then
        echo "Error: Failed to download Nexus version ${NEXUS_VERSION}"
        exit 1
    fi
    echo "Successfully downloaded Nexus ${NEXUS_VERSION}"
    
    # Verify the downloaded file size is not zero
    if [ ! -s "nexus-${NEXUS_VERSION}-unix.tar.gz" ]; then
        echo "Error: Downloaded Nexus file is empty"
        exit 1
    fi

    # Extract the archive
    echo "Extracting Nexus archive..."
    if ! tar -xzf "nexus-${NEXUS_VERSION}-unix.tar.gz" 1>>/dev/null 2>&1; then
        echo "Error: Failed to extract Nexus archive"
        exit 1
    fi
    echo "Successfully extracted Nexus archive"
    
    # Verify extraction created the expected directory
    if [ ! -d "nexus-${NEXUS_VERSION}" ]; then
        echo "Error: Expected Nexus directory not found after extraction"
        exit 1
    fi
    
    # Create symbolic link
    sudo ln -sfn "${NEXUS_HOME}" "${INSTALL_DIR}/nexus-latest"
    
    # Set permissions
    sudo chmod -R 770 "${INSTALL_DIR}"
    sudo chown -R nexus:nexus "${INSTALL_DIR}"
    echo
}

# Configure Nexus as a service
configure_nexus_service() {
    echo "Configuring Nexus as a service..."
    # Update the run_as_user in nexus.rc
    sudo sed -i 's|#run_as_user=""|run_as_user="nexus"|' "${NEXUS_HOME}/nexus-${NEXUS_VERSION}/bin/nexus.rc"

    # Create systemd service file
    cat <<EOT | sudo tee /etc/systemd/system/nexus.service >/dev/null
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=${NEXUS_HOME}/nexus-${NEXUS_VERSION}/bin/nexus start
ExecStop=${NEXUS_HOME}/nexus-${NEXUS_VERSION}/bin/nexus stop
User=nexus
Group=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

    # Reload systemd and enable/start Nexus service
    sudo systemctl daemon-reload
    sudo systemctl enable nexus
    sudo systemctl start nexus
    echo
}

# Check Nexus Service Status
check_nexus_service_status() {
    echo "Checking Nexus service status..."
    # Wait for service to start (up to 5 minutes)
    echo "Waiting for Nexus service to start (this may take a few minutes)..."
    for i in {1..30}; do
        if sudo systemctl is-active --quiet nexus; then
            echo "Nexus service is running."
            break
        fi
        if [ $i -eq 30 ]; then
            echo "Timeout waiting for Nexus service to start. Please check the logs."
            exit 1
        fi
        sleep 10
    done
    
    # Verify process ownership
    if ps aux | grep '[n]exus' | grep -q 'nexus'; then
        echo "Nexus process is running under the 'nexus' user."
    else
        echo "Warning: Nexus process is not running under the 'nexus' user as expected."
    fi
    echo
}

main() {
    echo
    echo "Starting Nexus Repository Manager ${NEXUS_VERSION} setup..."
    echo "Note: This installation requires Java 17 and will only work on Ubuntu systems"
    update_and_upgrade_system
    check_java_installation
    configure_java_home
    setup_nexus_user_and_directories
    download_and_setup_nexus
    configure_nexus_service
    check_nexus_service_status
    echo "Nexus Repository Manager ${NEXUS_VERSION} setup completed."
    echo "Please allow a few minutes for Nexus to fully start. You can monitor the status using: sudo journalctl -u nexus -f"
    echo
}

# Invoke the main function and pass all script arguments to it
main "$@"