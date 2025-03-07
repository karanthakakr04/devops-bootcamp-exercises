<#
.SYNOPSIS
    Installs kubectl on Windows systems using official release binaries.

.DESCRIPTION
    This script downloads and installs kubectl from the official Kubernetes release binaries.
    It handles the download, verification, and addition to PATH for easier access.

.NOTES
    - The script defaults to kubectl v1.32.0.
    - An internet connection is required for installation.
    - For system-wide installation, run the script as Administrator.
#>

# Function to install kubectl using direct binary download
function Install-KubectlBinary {
    Write-Host "Installing kubectl via direct binary download..." -ForegroundColor Cyan
    
    # Ask for version or use default
    $defaultVersion = "v1.32.0"
    $version = Read-Host "Enter kubectl version (default: $defaultVersion)"
    if ([string]::IsNullOrWhiteSpace($version)) {
        $version = $defaultVersion
    }
    
    # Download the kubectl binary
    $kubectlUrl = "https://dl.k8s.io/release/$version/bin/windows/amd64/kubectl.exe"
    $outputPath = "$env:TEMP\kubectl.exe"
    
    Write-Host "Downloading kubectl $version..."
    try {
        Invoke-WebRequest -Uri $kubectlUrl -OutFile $outputPath
    }
    catch {
        Write-Host "Failed to download kubectl. Error: $_" -ForegroundColor Red
        exit
    }
    
    # Optionally validate the binary
    $validateBinary = Read-Host "Do you want to validate the binary? (Y/N)"
    if ($validateBinary -eq "Y" -or $validateBinary -eq "y") {
        $checksumUrl = "https://dl.k8s.io/release/$version/bin/windows/amd64/kubectl.exe.sha256"
        
        try {
            $checksumFile = "$env:TEMP\kubectl.exe.sha256"
            Invoke-WebRequest -Uri $checksumUrl -OutFile $checksumFile
            $expectedChecksum = Get-Content $checksumFile -Raw
            $actualChecksum = (Get-FileHash -Path $outputPath -Algorithm SHA256).Hash.ToLower()
            
            if ($expectedChecksum.Trim() -eq $actualChecksum) {
                Write-Host "Checksum validation passed!" -ForegroundColor Green
            }
            else {
                Write-Host "Checksum validation failed. The downloaded file may be corrupted." -ForegroundColor Red
                Write-Host "Expected: $($expectedChecksum.Trim())" -ForegroundColor Red
                Write-Host "Actual: $actualChecksum" -ForegroundColor Red
                exit
            }
            
            Remove-Item $checksumFile -Force
        }
        catch {
            Write-Host "Failed to validate checksum. Error: $_" -ForegroundColor Red
            Write-Host "Continuing installation anyway..." -ForegroundColor Yellow
        }
    }
    
    # Ask for installation directory
    $defaultInstallDir = "$env:USERPROFILE\kubectl"
    $installDir = Read-Host "Enter installation directory (default: $defaultInstallDir)"
    if ([string]::IsNullOrWhiteSpace($installDir)) {
        $installDir = $defaultInstallDir
    }
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Write-Host "Created directory: $installDir" -ForegroundColor Green
    }
    
    # Copy kubectl to installation directory
    $kubectlPath = Join-Path $installDir "kubectl.exe"
    Copy-Item -Path $outputPath -Destination $kubectlPath -Force
    
    # Add to PATH if not already there
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$installDir*") {
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$installDir", "User")
        $env:Path += ";$installDir"
        Write-Host "Added $installDir to your PATH environment variable." -ForegroundColor Green
    }
    
    # Clean up
    Remove-Item $outputPath -Force
    
    Write-Host "kubectl $version has been installed to $kubectlPath" -ForegroundColor Green
}

# Function to verify kubectl installation
function Test-KubectlInstallation {
    Write-Host "Verifying kubectl installation..." -ForegroundColor Cyan
    
    try {
        $kubectlVersion = kubectl version --client
        Write-Host "kubectl is installed and working correctly:" -ForegroundColor Green
        Write-Host $kubectlVersion -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to verify kubectl installation." -ForegroundColor Red
        Write-Host "Make sure kubectl is in your PATH and try running 'kubectl version --client' manually." -ForegroundColor Yellow
        Write-Host "You may need to restart your PowerShell session for PATH changes to take effect." -ForegroundColor Yellow
        return $false
    }
}

# Function to display post-installation information
function Show-PostInstallationInfo {
    Write-Host ""
    Write-Host "================ Post-Installation Information ================" -ForegroundColor Cyan
    Write-Host "1. kubectl is now installed on your system."
    Write-Host "2. To configure kubectl to connect to a cluster, you need a kubeconfig file."
    Write-Host "   By default, kubectl looks for a config file at: $env:USERPROFILE\.kube\config"
    Write-Host ""
    Write-Host "3. To test your configuration, run: kubectl cluster-info"
    Write-Host "4. If you need to switch between multiple clusters, use: kubectl config use-context <context-name>"
    Write-Host "5. To see all available contexts: kubectl config get-contexts"
    Write-Host ""
    Write-Host "For more information, visit: https://kubernetes.io/docs/tasks/tools/"
    Write-Host "==============================================================" -ForegroundColor Cyan
}

# Main script
Clear-Host
Write-Host "====== Kubectl Installer for Windows ======" -ForegroundColor Cyan
Write-Host "This script will install kubectl on your Windows system using the official release binary." -ForegroundColor Cyan
Write-Host ""

# Install kubectl
Install-KubectlBinary

# Verify installation
if (Test-KubectlInstallation) {
    Show-PostInstallationInfo
}

Write-Host "kubectl installation process completed." -ForegroundColor Green