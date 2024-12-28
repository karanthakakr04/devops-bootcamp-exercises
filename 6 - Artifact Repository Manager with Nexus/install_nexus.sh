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

# Setup logging
setup_logging() {
    # Check if log file already exists and is writable
    if [ -f "$LOG_FILE" ] && [ -w "$LOG_FILE" ]; then
        echo "Using existing log file: $LOG_FILE"
        return 0
    fi

    # Create log directory with proper permissions if it doesn't exist
    sudo mkdir -p "$(dirname "$LOG_FILE")"
    sudo touch "$LOG_FILE"
    sudo chown "$(id -u):$(id -g)" "$LOG_FILE"
    echo "Created new log file at $LOG_FILE"
}

# Setup logging and redirect output
setup_logging

# Redirect output after log file is created
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
        echo "Java 17 is already installed, skipping installation."
        return 0
    fi

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
    echo
}

# Check and configure JAVA_HOME environment variable
configure_java_home() {
    echo "Checking JAVA_HOME configuration..."
    
    # Check if JAVA_HOME is already set correctly
    if [ -n "${JAVA_HOME:-}" ] && [ -d "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
        echo "JAVA_HOME is already correctly configured to: $JAVA_HOME"
        return 0
    fi

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
    echo "Checking Nexus user and directory setup..."
    
    # Check if nexus user exists
    if id "nexus" &>/dev/null; then
        echo "Nexus user already exists, skipping user creation."
    else
        echo "Creating nexus user..."
        sudo groupadd nexus
        sudo useradd -r -g nexus -d /home/nexus -s /bin/bash nexus
    fi

    # Check if directories exist
    if [ -d "${NEXUS_HOME}" ]; then
        echo "Nexus home directory already exists at ${NEXUS_HOME}"
    else
        echo "Creating Nexus directories..."
        sudo mkdir -p /home/nexus "${NEXUS_HOME}"
    fi

    # Check file handle limits configuration
    if grep -q "^nexus.*nofile" /etc/security/limits.conf; then
        echo "File handle limits already configured for nexus user."
    else
        echo "Configuring file handle limits for nexus user..."
        echo "nexus - nofile 65536" | sudo tee -a /etc/security/limits.conf > /dev/null
        echo "nexus - nproc 65536" | sudo tee -a /etc/security/limits.conf > /dev/null
    fi

    # Check system-wide limits
    if [ -f "/etc/systemd/system.conf.d/limits.conf" ]; then
        echo "System-wide limits already configured."
    else
        echo "Configuring system-wide limits..."
        sudo mkdir -p /etc/systemd/system.conf.d
        cat <<EOT | sudo tee /etc/systemd/system.conf.d/limits.conf > /dev/null
[Manager]
DefaultLimitNOFILE=65536
DefaultLimitNPROC=65536
EOT
    fi

    # Ensure proper ownership and permissions
    sudo chown -R nexus:nexus /home/nexus "${NEXUS_HOME}"
    sudo chmod -R 770 "${NEXUS_HOME}"
    
    echo "User and directory setup complete."
    echo
}

# Download and setup Nexus
download_and_setup_nexus() {
    echo "Downloading and setting up Nexus ${NEXUS_VERSION}..."
    
    # Verify NEXUS_HOME directory exists and we have permissions
    if [ ! -d "${NEXUS_HOME}" ]; then
        echo "Error: ${NEXUS_HOME} directory does not exist"
        exit 1
    fi
    
    # Test write permissions
    if [ ! -w "${NEXUS_HOME}" ]; then
        echo "Error: No write permission in ${NEXUS_HOME}"
        exit 1
    fi
    
    cd "${NEXUS_HOME}"
    
    # Install curl if not present
    if ! [ -x "$(command -v curl)" ]; then
        echo "curl not found, installing..."
        sudo apt install -y curl 1>>/dev/null 2>&1
        echo
    fi

    # Download Nexus
    echo "Downloading Nexus from ${NEXUS_DOWNLOAD_URL}..."
    if ! curl -L --fail "${NEXUS_DOWNLOAD_URL}" -o "nexus-${NEXUS_VERSION}-unix.tar.gz" 2>/dev/null; then
        echo "Failed to download Nexus. Status code: $?"
        echo "Please verify the URL is accessible: ${NEXUS_DOWNLOAD_URL}"
        exit 1
    fi
    
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