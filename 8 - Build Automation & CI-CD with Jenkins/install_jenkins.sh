#!/bin/bash

# Set variables
LOG_FILE="/var/log/jenkins_install.log"
JENKINS_PORT=8080

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | sudo tee -a $LOG_FILE
}

# Check if the script is being run with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo." >&2
    exit 1
fi

# Check the operating system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
else
    OS=$(uname -s)
fi

# Function to update the operating system and installed packages
update_system() {
    log "Updating the operating system and installed packages..."
    if [[ $OS == "ubuntu" || $OS == "debian" ]]; then
        sudo apt update &>> $LOG_FILE
        sudo apt upgrade -y &>> $LOG_FILE
    elif [[ $OS == "fedora" ]]; then
        sudo dnf upgrade -y &>> $LOG_FILE
    elif [[ $OS == "rhel" || $OS == "centos" || $OS == "almalinux" || $OS == "rocky" ]]; then
        sudo yum update -y &>> $LOG_FILE
    else
        log "Unsupported operating system. Please update the system manually."
    fi
}

# Function to check if Java 17 is installed
check_java_17() {
    if command -v java >/dev/null 2>&1; then
        java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        if [[ $java_version == "17"* ]]; then
            log "Java 17 is already installed."
            return 0
        fi
    fi
    return 1
}

# Function to install Java 17
install_java_17() {
    log "Installing Java 17..."
    if [[ $OS == "ubuntu" || $OS == "debian" ]]; then
        sudo apt install -y openjdk-17-jdk &>> $LOG_FILE
    elif [[ $OS == "fedora" ]]; then
        sudo dnf install -y java-17-openjdk &>> $LOG_FILE
    elif [[ $OS == "rhel" || $OS == "centos" || $OS == "almalinux" || $OS == "rocky" ]]; then
        sudo yum install -y java-17-openjdk &>> $LOG_FILE
    else
        log "Unsupported operating system. Please install Java 17 manually."
        exit 1
    fi
}

# Function to install Jenkins
install_jenkins() {
    log "Installing Jenkins..."
    if [[ $OS == "ubuntu" || $OS == "debian" ]]; then
        sudo wget -q -O /usr/share/keyrings/jenkins-keyring.asc \
          https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
        echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
          https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
          /etc/apt/sources.list.d/jenkins.list > /dev/null
        sudo apt update &>> $LOG_FILE
        sudo apt install -y jenkins &>> $LOG_FILE
        sudo systemctl daemon-reload
    elif [[ $OS == "fedora" ]]; then
        sudo wget -q -O /etc/yum.repos.d/jenkins.repo \
            https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
        sudo dnf install -y jenkins &>> $LOG_FILE
        sudo systemctl daemon-reload
    elif [[ $OS == "rhel" || $OS == "centos" || $OS == "almalinux" || $OS == "rocky" ]]; then
        sudo wget -q -O /etc/yum.repos.d/jenkins.repo \
            https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
        sudo yum install -y jenkins &>> $LOG_FILE
        sudo systemctl daemon-reload
    else
        log "Unsupported operating system. Please install Jenkins manually."
        exit 1
    fi
}

# Prompt the user to enter the server IP
read -p "Enter the server IP address: " server_ip

# Update the operating system and installed packages
update_system

# Check if Java 17 is installed
if ! check_java_17; then
    install_java_17
fi

# Install Jenkins
install_jenkins

# Start Jenkins service
sudo systemctl enable jenkins &>> $LOG_FILE
sudo systemctl start jenkins &>> $LOG_FILE

# Check Jenkins status
echo
echo "Checking Jenkins status..."
echo
if sudo systemctl status jenkins | grep -q "Active: active (running)"; then
    echo "Jenkins is running successfully."
    log "Jenkins installation completed successfully."
    echo
    echo "Access Jenkins by opening a web browser and navigating to http://$server_ip:$JENKINS_PORT"
    echo
    echo "Remember to configure the firewall rules through the DigitalOcean UI to allow access to the Jenkins port."
    echo
else
    echo "Jenkins is not running. Please check the logs for more information."
    log "Jenkins installation encountered an issue. Jenkins is not running."
    echo
    echo "Please check the Jenkins logs located at /var/log/jenkins/jenkins.log for more details."
    echo
fi