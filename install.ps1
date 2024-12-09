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

# Function to set environment variables
function Set-EnvironmentVariable {
    param (
        [string]$VariableName,
        [string]$Value,
        [string]$Scope
    )
    switch ($Scope.ToLower()) {
        "user" {
            [System.Environment]::SetEnvironmentVariable($VariableName, $Value, [System.EnvironmentVariableTarget]::User)
        }
        "machine" {
            if (-not (Test-IsAdministrator)) {
                Write-Error "You must run this script as Administrator to modify machine-level environment variables."
                Exit 1
            }
            [System.Environment]::SetEnvironmentVariable($VariableName, $Value, [System.EnvironmentVariableTarget]::Machine)
        }
        default {
            Write-Error "Invalid scope: $Scope. Allowed values are 'User' or 'Machine'."
            Exit 1
        }
    }
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
    Set-EnvironmentVariable -VariableName "WINSDK_HOME" -Value $InstallDir -Scope "User"
    Set-EnvironmentVariable -VariableName "WINSDK_HOME" -Value $InstallDir -Scope "Machine"

   # Add InstallDir to PATH for both User and Machine
foreach ($Scope in @('User', 'Machine')) {
    $OldPath = [Environment]::GetEnvironmentVariable('Path', $Scope)
    if (-not $OldPath) {
        $OldPath = ""
    }

    Write-Host "old path value: $OldPath"

    # Split Path into individual entries and check for an exact match
    $PathEntries = $OldPath -split ';' | ForEach-Object { $_.Trim() }
    if ($PathEntries -notcontains $InstallDir) {
        $NewPath = ($PathEntries + $InstallDir) -join ';'
        Set-EnvironmentVariable -VariableName "Path" -Value $NewPath -Scope $Scope
        Write-Host "Updated PATH for $Scope : ${NewPath}"
    } else {
        Write-Host "PATH already contains $InstallDir for $Scope."
    }
}


    Write-Host "WinSDK has been installed successfully."
    Write-Host "Please close and reopen your command prompt or PowerShell to start using the 'winsdk' command."
} catch {
    Write-Error "An error occurred during the installation: $_"
    Exit 1
}
