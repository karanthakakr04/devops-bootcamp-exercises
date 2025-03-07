# Kubernetes Tools Installation Scripts (Windows)

This repository contains PowerShell scripts to automate the installation of `kubectl` and `kind` on Windows systems.

## Prerequisites

Before running the installation scripts, ensure that you have the following prerequisites:

- **PowerShell 5.1+**: The scripts are written in PowerShell and require PowerShell 5.1 or later.
- **Administrator privileges**: Some operations may require elevated privileges.
- **Internet connection**: Required to download binaries.
- **Docker Desktop for Windows**: Required for `kind` to function properly. Docker 20.10.0+ is recommended for full compatibility with kind v0.27.0+.

## Scripts

### Install-Kubectl.ps1

This script automates the installation of `kubectl`, the command-line tool for interacting with Kubernetes clusters. It performs the following operations:

- Downloads the official kubectl binary from Kubernetes repositories
- Optionally verifies the binary with its SHA256 checksum
- Creates a dedicated installation directory (default: `%USERPROFILE%\kubectl`)
- Adds the installation directory to your PATH environment variable
- Verifies the installation by checking kubectl's version
- Provides helpful post-installation guidance

Features:

- Defaults to kubectl v1.32.0, but allows installation of any specific version
- Performs checksum validation for security
- Supports custom installation directories
- Automatic PATH configuration

### Install-Kind.ps1

This script automates the installation of `kind` (Kubernetes IN Docker), a tool for running local Kubernetes clusters using Docker containers as nodes.

Features:

- Downloads the official kind binary from the kind release repository
- Verifies the binary through SHA256 checksum validation
- Creates a dedicated installation directory (default: `%USERPROFILE%\kind`)
- Adds the installation directory to your PATH environment variable
- Defaults to version v0.27.0, but allows installation of any specific version
- Tests the installation to ensure kind works correctly
- Checks for Docker installation and compatibility

## Usage

1. Clone this repository to your local machine or download the scripts directly.

2. Open a PowerShell console with administrative privileges.

3. Navigate to the directory containing the scripts.

4. Set the PowerShell execution policy to allow script execution (if not already set):

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

5. Run the scripts:
   - To install kubectl:

     ```powershell
     .\Install-Kubectl.ps1
     ```

   - To install kind:

     ```powershell
     .\Install-Kind.ps1
     ```

6. Follow the interactive prompts in each script:
   - For both scripts, confirm or specify the version you want to install
   - Confirm or specify the installation directory

7. After installation, you may need to restart your PowerShell session for PATH changes to take effect.

8. Verify the installations:
   - Verify kubectl: `kubectl version --client`
   - Verify kind: `kind version`

## Creating Your First Cluster

After installing both tools, you can create your first Kubernetes cluster:

1. Create a cluster using kind:

   ```powershell
   kind create cluster
   ```

2. Verify the cluster is running:

   ```powershell
   kubectl cluster-info
   ```

3. When you're done, delete the cluster:

   ```powershell
   kind delete cluster
   ```

## Troubleshooting

### Common Issues

- **"XXX is not recognized as a cmdlet..."**: Restart your PowerShell session for PATH changes to take effect
- **Execution policy restrictions**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Docker not running**: Ensure Docker Desktop is started and running
- **Network connectivity issues**: Check your internet connection and proxy settings

### Kind-Specific Issues

- **Docker Desktop WSL integration**: Ensure WSL 2 integration is enabled in Docker Desktop settings
- **Docker resources**: Ensure Docker has enough resources allocated (minimum 6GB RAM recommended)
- **containerd registry configuration**: For kind v0.27.0+, if using a local registry, make sure to use the `config_path` mode for containerd registry config

### Kubectl-Specific Issues

- **Kubeconfig issues**: Ensure your `%USERPROFILE%\.kube\config` file exists with proper configuration
- **Connection issues**: Check that your cluster is running with `kind get clusters`

## What are kubectl and kind?

- **kubectl** is the official command-line tool for Kubernetes. It allows you to run commands against Kubernetes clusters to deploy applications, inspect and manage cluster resources, and view logs.

- **kind** (Kubernetes IN Docker) is a tool for running local Kubernetes clusters using Docker containers as "nodes". It was primarily designed for testing Kubernetes itself, but is perfect for local development and CI.

By using these tools together, you can quickly set up a local Kubernetes environment for development, testing, or learning purposes.

## Additional Resources

- [Official kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [Official kind Documentation](https://kind.sigs.k8s.io/)
- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
