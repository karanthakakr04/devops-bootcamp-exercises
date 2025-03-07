#!/bin/bash

# Function to check if the script is running with sudo privileges
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run with sudo privileges. Exiting..."
        exit 1
    fi
}

# Function to install kind
install_kind() {
    echo "Installing kind..."

    # Prompt for the desired version
    read -p "Enter the desired version of kind (default: v0.27.0): " version
    version=${version:-v0.27.0}

    # Validate the version format
    if ! [[ $version =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Invalid version format. Please use the format: vX.Y.Z"
        exit 1
    fi

    # Determine the architecture
    case $(uname -m) in
        x86_64)
            arch="amd64"
            ;;
        aarch64)
            arch="arm64"
            ;;
        *)
            echo "Unsupported architecture. Exiting..."
            exit 1
            ;;
    esac

    # Download the kind binary
    echo "Downloading kind version $version for $arch..."
    if ! curl -Lo ./kind "https://kind.sigs.k8s.io/dl/$version/kind-linux-$arch"; then
        echo "Failed to download kind. Please check your network connection and try again."
        exit 1
    fi

    # Verify the binary checksum
    echo "Verifying the binary checksum..."
    curl -Lo ./kind.sha256 "https://kind.sigs.k8s.io/dl/$version/kind-linux-$arch.sha256"
    if ! sha256sum --check --status ./kind.sha256; then
        echo "Checksum verification failed. Please try again."
        rm ./kind ./kind.sha256
        exit 1
    fi
    rm ./kind.sha256

    # Make the kind binary executable
    chmod +x ./kind

    # Prompt for confirmation before moving the binary
    read -p "Move kind to /usr/local/bin? [Y/n]: " confirm
    confirm=${confirm:-Y}
    if [[ $confirm =~ ^[Yy]$ ]]; then
        sudo mv ./kind /usr/local/bin/kind
        echo "kind $version installed successfully to /usr/local/bin/kind."
    else
        echo "kind binary not moved to /usr/local/bin. You can manually move it if desired."
    fi
}

# Function to test kind installation
test_kind_installation() {
    if ! command -v kind &> /dev/null; then
        echo "kind is not installed in PATH. Checking current directory..."
        if [[ -f "./kind" ]]; then
            echo "Testing kind in current directory..."
            ./kind version
        else
            echo "kind is not found. Installation may have failed."
            exit 1
        fi
    else
        echo "Testing kind installation..."
        kind version
    fi
}

# Main script
check_sudo
install_kind
test_kind_installation

echo "kind installation completed successfully!"