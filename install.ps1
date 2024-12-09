# PowerShell script to install WinSDK

# Set execution policy to allow script execution temporarily
Set-ExecutionPolicy Bypass -Scope Process -Force

# Variables
$InstallDir = "C:\Program Files\WinSDK"
$RepoZipUrl = "https://github.com/u-verma/winsdk/archive/refs/heads/main.zip"
$TempZip = "$env:TEMP\winsdk.zip"

try {
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
        Exit 1
    }

    # Move extracted files to InstallDir
    if (Test-Path $InstallDir) {
        Remove-Item -Recurse -Force -Path $InstallDir
    }
    Move-Item -Path $ExtractedFolder.FullName -Destination $InstallDir

    # Remove the zip file and temporary folder
    Remove-Item $TempZip -Force
    Remove-Item -Path "$env:TEMP\winsdk-*" -Recurse -Force

    # Configure environment variables
    Write-Host "Configuring environment variables..."
    # Set WINSDK_HOME for both User and Machine
    [Environment]::SetEnvironmentVariable('WINSDK_HOME', $InstallDir, 'User')
    [Environment]::SetEnvironmentVariable('WINSDK_HOME', $InstallDir, 'Machine')

    # Add InstallDir to PATH for both User and Machine
    foreach ($Scope in @('User', 'Machine')) {
        $OldPath = [Environment]::GetEnvironmentVariable('Path', $Scope)
        if (-not $OldPath) {
            $OldPath = ""
        }
        if ($OldPath -notlike "*$InstallDir*") {
            $NewPath = ($OldPath -split ';' + $InstallDir) -join ';'
            [Environment]::SetEnvironmentVariable('Path', $NewPath, $Scope)
        }
    }

    Write-Host "WinSDK has been installed successfully."
    Write-Host "Please close and reopen your command prompt or PowerShell to start using the 'winsdk' command."
} catch {
    Write-Error "An error occurred during the installation: $_"
    Exit 1
}
