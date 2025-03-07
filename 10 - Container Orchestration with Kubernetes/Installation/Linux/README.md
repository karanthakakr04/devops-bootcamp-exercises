# Kubernetes Tools Installation Scripts (Linux)

This repository contains shell scripts to automate the installation of `kubectl` and `kind` on Linux systems.

## Prerequisites

Before running the installation scripts, ensure that you have the following prerequisites:

- **Bash Shell**: The scripts are written for the Bash shell, which is available on most Linux distributions by default.
- **sudo privileges**: Administrative privileges are required for system-wide installation.
- **curl**: Required to download binaries. Install it using your distribution's package manager if not already available.
- **Docker**: Required for `kind` to function properly. You can install Docker by following the official documentation for your Linux distribution.
  - Docker 20.10.0+ is required for full compatibility with kind v0.27.0+.
  - Alternatively, podman or nerdctl can also be used with kind.

## Scripts

### install_kubectl.sh

This script automates the installation of `kubectl`, the command-line tool for interacting with Kubernetes clusters. It provides the following installation methods:

1. **Direct binary installation (recommended)**:
   - Downloads the official kubectl binary from Kubernetes repositories
   - Verifies the binary through SHA256 checksum validation
   - Makes kubectl executable and installs it to `/usr/local/bin`
   - Supports both amd64 and arm64 architectures
   - Allows installation of specific versions or the latest stable release

2. **Package manager installation**:
   - Automatically detects your Linux distribution
   - **Debian/Ubuntu**: Installs kubectl using the official Kubernetes apt repository
   - **CentOS/RHEL/Fedora**: Installs kubectl using the official Kubernetes yum repository
   - **SUSE**: Installs kubectl using the official Kubernetes zypper repository

The script verifies the installation and provides basic guidance on kubectl configuration.

### install_kind.sh

This script automates the installation of `kind` (Kubernetes IN Docker), a tool for running local Kubernetes clusters using Docker containers as nodes.

Features:

- Detects system architecture (amd64 or arm64) automatically
- Downloads the appropriate kind binary from the official release
- Verifies the binary through SHA256 checksum validation
- Makes kind executable and installs it to `/usr/local/bin` (with your permission)
- Defaults to version v0.27.0, but allows installation of any specific version
- Tests the installation to ensure kind works correctly

## Usage

1. Clone this repository to your local machine or download the scripts directly.

2. Make the scripts executable:

   ```bash
   chmod +x install_kubectl.sh install_kind.sh
   ```

3. Run the scripts with sudo privileges:
   - To install kubectl:

     ```bash
     sudo ./install_kubectl.sh
     ```

   - To install kind:

     ```bash
     sudo ./install_kind.sh
     ```

4. Follow the interactive prompts in each script:
   - For kubectl, select your preferred installation method
   - For kind, confirm or specify the version you want to install

5. After installation, both tools will be available from the command line:
   - Verify kubectl: `kubectl version --client`
   - Verify kind: `kind version`

## Creating Your First Cluster

After installing both tools, you can create your first Kubernetes cluster:

1. Create a cluster using kind:

   ```bash
   kind create cluster
   ```

2. Verify the cluster is running:

   ```bash
   kubectl cluster-info
   ```

3. When you're done, delete the cluster:

   ```bash
   kind delete cluster
   ```

## Troubleshooting

### Kind Issues

- **Docker not running**: Ensure Docker is started with `sudo systemctl start docker`
- **Permission issues**: Make sure your user is in the Docker group or run with sudo
- **IPv6 issues**: If you experience network problems, try disabling IPv6 in Docker settings
- **containerd registry configuration**: For kind v0.27.0+, if using a local registry, make sure to use the `config_path` mode for containerd registry config

### Kubectl Issues

- **"kubectl: command not found"**: Ensure the script completed successfully and `/usr/local/bin` is in your PATH
- **Connection issues**: Check that your cluster is running with `kind get clusters`
- **Configuration issues**: Ensure your `~/.kube/config` file exists and has the correct permissions

## What are kubectl and kind?

- **kubectl** is the official command-line tool for Kubernetes. It allows you to run commands against Kubernetes clusters to deploy applications, inspect and manage cluster resources, and view logs.

- **kind** (Kubernetes IN Docker) is a tool for running local Kubernetes clusters using Docker containers as "nodes". It was primarily designed for testing Kubernetes itself, but is perfect for local development and CI.

By using these tools together, you can quickly set up a local Kubernetes environment for development, testing, or learning purposes.

## Additional Resources

- [Official kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [Official kind Documentation](https://kind.sigs.k8s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
