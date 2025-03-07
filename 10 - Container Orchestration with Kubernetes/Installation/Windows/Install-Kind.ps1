<#
.SYNOPSIS
    Installs kind (Kubernetes in Docker) on Windows.

.DESCRIPTION
    This script downloads and installs kind from the official release binaries.
    It verifies the downloaded binary through checksum validation and adds it to the PATH.

.NOTES
    - The script currently uses kind version v0.27.0. Update the version if needed.
    - Docker Desktop must be installed separately.
#>

# Function to install kind using release binaries
function Install-KindWithReleaseBinaries {
    Write-Host "Installing kind from release binaries..."
    
    # Ask for version
    $defaultVersion = "v0.27.0"
    $kindVersion = Read-Host "Enter the desired version of kind (default: $defaultVersion)"
    if ([string]::IsNullOrWhiteSpace($kindVersion)) {
        $kindVersion = $defaultVersion
    }
    
    # Validate version format
    if ($kindVersion -notmatch '^v\d+\.\d+\.\d+$') {
        Write-Host "Invalid version format. Please use the format: vX.Y.Z" -ForegroundColor Red
        exit
    }
    
    # Download kind binary
    $kindUrl = "https://kind.sigs.k8s.io/dl/$kindVersion/kind-windows-amd64"
    $outputPath = "$env:TEMP\kind-windows-amd64.exe"
    
    Write-Host "Downloading kind $kindVersion..."
    try {
        Invoke-WebRequest -Uri $kindUrl -OutFile $outputPath
    }
    catch {
        Write-Host "Failed to download kind. Error: $_" -ForegroundColor Red
        exit
    }
    
    # Download and verify checksum
    Write-Host "Verifying binary checksum..."
    $checksumUrl = "https://kind.sigs.k8s.io/dl/$kindVersion/kind-windows-amd64.sha256"
    try {
        $expectedChecksum = (Invoke-WebRequest -Uri $checksumUrl).Content.Trim()
        $actualChecksum = (Get-FileHash -Path $outputPath -Algorithm SHA256).Hash.ToLower()
        
        if ($expectedChecksum -ne $actualChecksum) {
            Write-Host "Checksum verification failed. Expected: $expectedChecksum, Got: $actualChecksum" -ForegroundColor Red
            Remove-Item $outputPath -Force
            exit
        }
        Write-Host "Checksum verification passed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to verify checksum. Error: $_" -ForegroundColor Red
        Remove-Item $outputPath -Force
        exit
    }
    
    # Ask user where to install
    $installDir = $env:USERPROFILE + "\kind"
    $customDir = Read-Host "Enter installation directory (default: $installDir)"
    if (-not [string]::IsNullOrWhiteSpace($customDir)) {
        $installDir = $customDir
    }
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir | Out-Null
    }
    
    # Move kind to installation directory
    $kindPath = Join-Path $installDir "kind.exe"
    Move-Item -Path $outputPath -Destination $kindPath -Force
    
    # Add to PATH if not already there
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$installDir*") {
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$installDir", "User")
        $env:Path += ";$installDir"
        Write-Host "Added $installDir to your PATH environment variable." -ForegroundColor Green
    }
    
    Write-Host "kind $kindVersion has been installed to $kindPath" -ForegroundColor Green
}

# Function to test if Docker is installed
function Test-DockerInstallation {
    Write-Host "Checking for Docker installation..."
    
    try {
        $docker = Get-Command docker -ErrorAction Stop
        $dockerVersion = docker version --format '{{.Server.Version}}'
        
        Write-Host "Docker is installed. Version: $dockerVersion" -ForegroundColor Green
        
        # Check Docker version for compatibility with kind
        if ($dockerVersion -match '^(\d+)\.(\d+)') {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            
            if ($major -lt 20 -or ($major -eq 20 -and $minor -lt 10)) {
                Write-Host "WARNING: kind v0.20.0+ requires Docker 20.10.0+ for full compatibility." -ForegroundColor Yellow
                Write-Host "Your Docker version: $dockerVersion" -ForegroundColor Yellow
            }
        }
        
        return $true
    }
    catch {
        Write-Host "Docker is not installed or not in PATH." -ForegroundColor Yellow
        Write-Host "kind requires Docker Desktop for Windows to function." -ForegroundColor Yellow
        Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
        
        $continueAnyway = Read-Host "Do you want to continue with kind installation anyway? (Y/N)"
        return ($continueAnyway -eq "Y" -or $continueAnyway -eq "y")
    }
}

# Function to test kind installation
function Test-KindInstallation {
    Write-Host "Testing kind installation..." -ForegroundColor Green
    
    try {
        $kindVersion = kind version
        Write-Host "kind $kindVersion has been successfully installed." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to verify kind installation. The 'kind' command isn't recognized." -ForegroundColor Red
        Write-Host "You may need to restart your terminal or system for PATH changes to take effect." -ForegroundColor Yellow
        return $false
    }
}

# Function to display post-installation information
function Show-PostInstallationInfo {
    Write-Host ""
    Write-Host "=============== Post-Installation Information ===============" -ForegroundColor Cyan
    Write-Host "- To create a cluster: kind create cluster"
    Write-Host "- To delete a cluster: kind delete cluster"
    Write-Host "- To view available clusters: kind get clusters"
    Write-Host "- For more information, see: https://kind.sigs.k8s.io/docs/user/quick-start/"
    Write-Host ""
    Write-Host "IMPORTANT: If you're using a local registry with kind, make sure you're using"
    Write-Host "the config_path mode for containerd registry config. This is required for"
    Write-Host "containerd 2.x used in kind v0.27.0+."
    Write-Host "See: https://kind.sigs.k8s.io/docs/user/local-registry/"
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
}

# Main script
Clear-Host
Write-Host "======== kind (Kubernetes in Docker) Installer ========" -ForegroundColor Cyan

# Check for Docker installation
if (Test-DockerInstallation) {
    # Install kind
    Install-KindWithReleaseBinaries
    
    # Test kind installation
    if (Test-KindInstallation) {
        # Show post-installation information
        Show-PostInstallationInfo
    }
}

Write-Host "kind installation process completed." -ForegroundColor Green