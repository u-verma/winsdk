# PowerShell script to install WinSDK

# Set execution policy to allow script execution temporarily
Set-ExecutionPolicy Bypass -Scope Process -Force

# Variables
$InstallDir = "C:\Program Files\WinSDK"
$RepoZipUrl = "https://github.com/u-verma/winsdk/archive/refs/heads/main.zip"
$TempZip = "$env:TEMP\winsdk.zip"

# Download the repository
Write-Host "Downloading WinSDK..."
Invoke-WebRequest -Uri $RepoZipUrl -OutFile $TempZip -UseBasicParsing

# Extract the repository
Write-Host "Installing WinSDK..."
Expand-Archive -Path $TempZip -DestinationPath $env:TEMP -Force

# Move extracted files to InstallDir
$ExtractedFolder = Get-ChildItem -Path $env:TEMP -Directory | Where-Object { $_.Name -like "winsdk-*" } | Select-Object -First 1
Move-Item -Path $ExtractedFolder.FullName -Destination $InstallDir -Force

# Remove the zip file and temporary folder
Remove-Item $TempZip -Force
Remove-Item -Path "$env:TEMP\winsdk-*" -Recurse -Force

# Add script directory to system PATH
Write-Host "Configuring environment variables..."
$OldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
if ($OldPath -notlike "*$InstallDir*") {
    $NewPath = "$OldPath;$InstallDir"
    [Environment]::SetEnvironmentVariable('Path', $NewPath, 'Machine')
}

Write-Host "WinSDK has been installed successfully."
Write-Host "Please close and reopen your command prompt or PowerShell to start using the 'winsdk' command."
