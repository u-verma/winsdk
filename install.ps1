# PowerShell script to install WinSDK

# Set execution policy to allow script execution temporarily
Set-ExecutionPolicy Bypass -Scope Process -Force

# Variables
$InstallDir = "C:\Program Files\WinSDK"
$RepoZipUrl = "https://github.com/u-verma/winsdk/archive/refs/heads/main.zip"
$TempZip = "$env:TEMP\winsdk.zip"

# Function to check if running as Administrator
function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

try {
    # Check for admin privileges
    if (-not (Test-IsAdministrator)) {
        Write-Warning "It's recommended to run this script as Administrator to modify machine-level settings."
    }

    # Download the repository
    Write-Host "Downloading WinSDK..."
    Invoke-WebRequest -Uri $RepoZipUrl -OutFile $TempZip -UseBasicParsing

    # Extract the repository
    Write-Host "Installing WinSDK..."
    Expand-Archive -Path $TempZip -DestinationPath $env:TEMP -Force

    # Locate the extracted folder
    $ExtractedFolder = Get-ChildItem -Path $env:TEMP -Directory | Where-Object { $_.Name -like "winsdk-*" } | Select-Object -First 1
    if (-not $ExtractedFolder) {
        Write-Error "Failed to locate the extracted WinSDK folder."
        throw "Extraction error: Folder not found."
    }

    # Move extracted files to InstallDir
    if (Test-Path $InstallDir) {
        Remove-Item -Recurse -Force -Path $InstallDir
    }
    Move-Item -Path $ExtractedFolder.FullName -Destination $InstallDir

    # Remove the zip file and temporary folder
    Remove-Item $TempZip -Force
    Remove-Item -Path "$env:TEMP\winsdk-*" -Recurse -Force

    # Import the Set-SDKEnvironment module from the installed directory
    $SDKEnvironmentModule = Join-Path $InstallDir "modules\Environment\Set-SDKEnvironment.psm1"
    if (Test-Path $SDKEnvironmentModule) {
        Import-Module $SDKEnvironmentModule -Force
    } else {
        Write-Error "Set-SDKEnvironment module not found in $SDKEnvironmentModule."
        throw "Installation error: Required module missing."
    }

    # Configure environment variables
    Write-Host "Configuring environment variables..."
    Set-SDKEnvironment -SDKName "winsdk" -SDKPath $InstallDir -Scope "User"
    Set-SDKEnvironment -SDKName "winsdk" -SDKPath $InstallDir -Scope "Machine"

    Write-Host "WinSDK has been installed successfully."
    Write-Host "Please close and reopen your command prompt or PowerShell to start using the 'winsdk' command."
} catch {
    Write-Error "An error occurred during the installation: $_"
    Cleanup-WinSDKInstallation -InstallDir $InstallDir -TempZip $TempZip
    Exit 1
}

# Function to clean up temporary files and directories
function Cleanup-WinSDKInstallation {
    param (
        [Parameter(Mandatory = $true)]
        [string]$InstallDir,

        [Parameter(Mandatory = $true)]
        [string]$TempZip
    )

    Write-Host "Cleaning up temporary files and partially installed directories..."
    try {
        # Remove the temporary zip file
        if (Test-Path $TempZip) {
            Remove-Item $TempZip -Force
            Write-Host "Removed temporary zip file: $TempZip"
        }

        # Remove extracted temporary directories
        if (Test-Path "$env:TEMP\winsdk-*") {
            Remove-Item -Path "$env:TEMP\winsdk-*" -Recurse -Force
            Write-Host "Removed temporary extracted directories."
        }

        # Remove partially installed directory
        if (Test-Path $InstallDir) {
            Remove-Item -Recurse -Force -Path $InstallDir
            Write-Host "Removed partially installed directory: $InstallDir"
        }
    } catch {
        Write-Warning "An error occurred during cleanup: $_"
    }
}
