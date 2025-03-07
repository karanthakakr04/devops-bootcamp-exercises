#!/bin/bash

# Install kubectl on Linux
# This script provides multiple installation options for kubectl on Linux-based systems

# Function to check if script is running with sudo privileges
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script requires sudo privileges for system-wide installation."
        echo "Please run with sudo or as root."
        exit 1
    fi
}

# Function to install kubectl using curl (direct binary)
install_kubectl_binary() {
    echo "Installing kubectl binary with curl..."
    
    # Ask for version or use stable
    read -p "Enter kubectl version (leave empty for latest stable): " version
    
    if [[ -z "$version" ]]; then
        echo "Downloading latest stable kubectl version..."
        curl_command="curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(get_arch)/kubectl\""
    else
        echo "Downloading kubectl version $version..."
        curl_command="curl -LO \"https://dl.k8s.io/release/$version/bin/linux/$(get_arch)/kubectl\""
    fi
    
    # Download kubectl binary
    eval $curl_command
    
    # Validate the binary (optional)
    echo "Would you like to validate the kubectl binary? (y/n)"
    read validate
    if [[ "$validate" =~ ^[Yy]$ ]]; then
        echo "Downloading checksum file..."
        if [[ -z "$version" ]]; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(get_arch)/kubectl.sha256"
        else
            curl -LO "https://dl.k8s.io/release/$version/bin/linux/$(get_arch)/kubectl.sha256"
        fi
        
        # Verify the kubectl binary
        echo "Validating kubectl binary..."
        if echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check; then
            echo "kubectl binary validation successful!"
        else
            echo "kubectl binary validation failed! The binary may be corrupted."
            echo "Please try downloading again."
            exit 1
        fi
        rm kubectl.sha256
    fi
    
    # Make kubectl executable
    chmod +x kubectl
    
    # Move kubectl to a directory in PATH
    echo "Moving kubectl to /usr/local/bin/"
    sudo mv kubectl /usr/local/bin/kubectl
    
    echo "kubectl binary installation completed successfully!"
}

# Function to install kubectl using native package management
install_kubectl_package() {
    echo "Installing kubectl using native package management..."
    
    # Detect Linux distribution
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
    else
        echo "Unable to detect Linux distribution. Please install kubectl manually."
        exit 1
    fi
    
    case $DISTRO in
        debian|ubuntu|pop|mint|kali)
            echo "Detected Debian-based distribution: $DISTRO"
            install_kubectl_debian
            ;;
        fedora|centos|rhel|rocky|alma)
            echo "Detected Red Hat-based distribution: $DISTRO"
            install_kubectl_redhat
            ;;
        opensuse*|suse|sles)
            echo "Detected SUSE-based distribution: $DISTRO"
            install_kubectl_suse
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            echo "Falling back to binary installation..."
            install_kubectl_binary
            ;;
    esac
}

# Function to install kubectl on Debian-based distributions
install_kubectl_debian() {
    echo "Installing kubectl on Debian-based system..."

    # Update apt package index and install required packages
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
    
    # Add Kubernetes apt repository key
    echo "Adding Kubernetes apt repository signing key..."
    if ! [ -d /etc/apt/keyrings ]; then
        sudo mkdir -p -m 755 /etc/apt/keyrings
    fi
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    
    # Add Kubernetes apt repository
    echo "Adding Kubernetes apt repository..."
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
    
    # Update apt and install kubectl
    sudo apt-get update
    sudo apt-get install -y kubectl
    
    echo "kubectl installation completed via apt!"
}

# Function to install kubectl on Red Hat-based distributions
install_kubectl_redhat() {
    echo "Installing kubectl on Red Hat-based system..."
    
    # Add Kubernetes yum repository
    echo "Adding Kubernetes yum repository..."
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF
    
    # Install kubectl with yum/dnf
    if command -v dnf &> /dev/null; then
        sudo dnf install -y kubectl
    else
        sudo yum install -y kubectl
    fi
    
    echo "kubectl installation completed via yum/dnf!"
}

# Function to install kubectl on SUSE-based distributions
install_kubectl_suse() {
    echo "Installing kubectl on SUSE-based system..."
    
    # Add the Kubernetes zypper repository
    echo "Adding Kubernetes zypper repository..."
    cat <<EOF | sudo tee /etc/zypp/repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF
    
    # Install kubectl using zypper
    sudo zypper update
    sudo zypper install -y kubectl
    
    echo "kubectl installation completed via zypper!"
}

# Function to verify kubectl installation
verify_kubectl() {
    echo "Verifying kubectl installation..."
    
    if command -v kubectl &> /dev/null; then
        echo "kubectl is installed successfully!"
        kubectl version --client
        echo
        echo "For cluster configuration, ensure you have a valid kubeconfig file."
        echo "By default, kubectl looks for config at ~/.kube/config"
        echo
        echo "To check your cluster connection, run:"
        echo "kubectl cluster-info"
    else
        echo "kubectl installation verification failed."
        echo "Please check your installation and ensure kubectl is in your PATH."
        exit 1
    fi
}

# Function to get architecture
get_arch() {
    arch=$(uname -m)
    case $arch in
        x86_64)
            echo "amd64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        *)
            echo "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Main script execution
echo "=== Kubectl Installation Script ==="
echo "This script will install kubectl on your Linux system."
echo

echo "Please select installation method:"
echo "1. Direct binary installation (recommended)"
echo "2. Package manager installation (apt, yum, zypper)"
read -p "Enter your choice (1-2): " choice

case $choice in
    1)
        install_kubectl_binary
        ;;
    2)
        check_sudo
        install_kubectl_package
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Verify the installation
verify_kubectl

echo "kubectl installation completed!"
echo "For more information, visit: https://kubernetes.io/docs/tasks/tools/"