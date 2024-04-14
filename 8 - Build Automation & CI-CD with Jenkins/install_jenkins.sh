#!/bin/bash

# Set variables
LOG_FILE="/var/log/jenkins_install.log"
JENKINS_PORT=8080

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
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
        apt update &>> $LOG_FILE
        apt install -y fontconfig openjdk-17-jre &>> $LOG_FILE
    elif [[ $OS == "fedora" ]]; then
        dnf install -y fontconfig java-17-openjdk &>> $LOG_FILE
    elif [[ $OS == "rhel" || $OS == "centos" || $OS == "almalinux" || $OS == "rocky" ]]; then
        yum install -y fontconfig java-17-openjdk &>> $LOG_FILE
    else
        log "Unsupported operating system. Please install Java 17 manually."
        exit 1
    fi
}

# Function to install Jenkins
install_jenkins() {
    log "Installing Jenkins..."
    if [[ $OS == "ubuntu" || $OS == "debian" ]]; then
        wget -q -O /usr/share/keyrings/jenkins-keyring.asc \
          https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
        echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
          https://pkg.jenkins.io/debian-stable binary/ | tee \
          /etc/apt/sources.list.d/jenkins.list > /dev/null
        apt-get update &>> $LOG_FILE
        apt-get install -y jenkins &>> $LOG_FILE
    elif [[ $OS == "fedora" ]]; then
        wget -q -O /etc/yum.repos.d/jenkins.repo \
            https://pkg.jenkins.io/redhat-stable/jenkins.repo
        rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
        dnf upgrade -y &>> $LOG_FILE
        dnf install -y jenkins &>> $LOG_FILE
        systemctl daemon-reload
    elif [[ $OS == "rhel" || $OS == "centos" || $OS == "almalinux" || $OS == "rocky" ]]; then
        wget -q -O /etc/yum.repos.d/jenkins.repo \
            https://pkg.jenkins.io/redhat-stable/jenkins.repo
        rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
        yum upgrade -y &>> $LOG_FILE
        yum install -y jenkins &>> $LOG_FILE
        systemctl daemon-reload
    else
        log "Unsupported operating system. Please install Jenkins manually."
        exit 1
    fi
}

# Function to configure firewall
configure_firewall() {
    log "Checking firewall..."
    if command -v firewall-cmd >/dev/null 2>&1; then
        if firewall-cmd --state >/dev/null 2>&1; then
            log "Firewall (firewalld) is active."
            if ! firewall-cmd --list-ports | grep -q $JENKINS_PORT; then
                log "Jenkins port ($JENKINS_PORT) is not open. Configuring firewall..."
                firewall-cmd --permanent --new-service=jenkins
                firewall-cmd --permanent --service=jenkins --set-short="Jenkins ports"
                firewall-cmd --permanent --service=jenkins --set-description="Jenkins port exceptions"
                firewall-cmd --permanent --service=jenkins --add-port=$JENKINS_PORT/tcp
                firewall-cmd --permanent --add-service=jenkins
                firewall-cmd --reload
            else
                log "Jenkins port ($JENKINS_PORT) is already open."
            fi
        else
            log "Firewall (firewalld) is not active."
        fi
    elif command -v ufw >/dev/null 2>&1; then
        if ufw status | grep -q "active"; then
            log "Firewall (ufw) is active."
            if ! ufw status | grep -q $JENKINS_PORT; then
                log "Jenkins port ($JENKINS_PORT) is not open. Configuring firewall..."
                ufw allow $JENKINS_PORT/tcp
                ufw reload
            else
                log "Jenkins port ($JENKINS_PORT) is already open."
            fi
        else
            log "Firewall (ufw) is not active."
        fi
    elif command -v iptables >/dev/null 2>&1; then
        if iptables -L -n | grep -q "ACCEPT"; then
            log "Firewall (iptables) is active."
            if ! iptables -L -n | grep -q $JENKINS_PORT; then
                log "Jenkins port ($JENKINS_PORT) is not open. Configuring firewall..."
                iptables -A INPUT -p tcp --dport $JENKINS_PORT -j ACCEPT
                iptables-save > /etc/sysconfig/iptables
            else
                log "Jenkins port ($JENKINS_PORT) is already open."
            fi
        else
            log "Firewall (iptables) is not active."
        fi
    else
        log "No firewall management tool found. Please check firewall manually."
    fi
}

# Check if Java 17 is installed
if ! check_java_17; then
    install_java_17
fi

# Install Jenkins
install_jenkins

# Configure firewall
configure_firewall

# Start Jenkins service
systemctl enable jenkins &>> $LOG_FILE
systemctl start jenkins &>> $LOG_FILE

log "Jenkins installation completed successfully."
echo "Access Jenkins by opening a web browser and navigating to http://your-server-ip:$JENKINS_PORT"