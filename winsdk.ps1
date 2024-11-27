<#
.SYNOPSIS
WinSDK - A tool to manage SDKs on Windows.

.DESCRIPTION
Provides commands to install, use, list, current, and uninstall SDKs, including self-uninstallation.

.PARAMETER Action
The action to perform: install, use, list, current, uninstall.

.PARAMETER SDK
The SDK to manage (e.g., java, winsdk).

.PARAMETER Version
The version of the SDK to manage.

.EXAMPLE
winsdk install java 17

.EXAMPLE
winsdk uninstall winsdk

#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('install', 'use', 'list', 'current', 'uninstall')]
    [string]$Action,

    [Parameter(Position = 1, Mandatory = $true)]
    [string]$SDK,

    [Parameter(Position = 2)]
    [string]$Version
)

# Import modules
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Import-Module "$ScriptDir\modules\Utils\Utils.psm1" -Force
Import-Module "$ScriptDir\modules\Environment\EnvironmentManager.psm1" -Force

switch ($SDK.ToLower()) {
    'java' {
        Import-Module "$ScriptDir\modules\Java\Install-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Switch-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\List-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Current-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Uninstall-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Get-JavaDownloadUrl.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Get-AvailableJavaVersions.psm1" -Force

        switch ($Action.ToLower()) {
            'install' {
                if (-not $Version) {
                    Write-Error "Please specify the Java version to install."
                    Exit 1
                }
                Install-Java -Version $Version
            }
            'use' {
                if (-not $Version) {
                    Write-Error "Please specify the Java version to use."
                    Exit 1
                }
                Switch-Java -Version $Version
            }
            'list' {
                List-Java
            }
            'current' {
                Current-Java
            }
            'uninstall' {
                if (-not $Version) {
                    Write-Error "Please specify the Java version to uninstall."
                    Exit 1
                }
                Uninstall-Java -Version $Version
            }
            default {
                Write-Error "Unknown action: $Action"
                Exit 1
            }
        }
    }
    'winsdk' {
        if ($Action.ToLower() -ne 'uninstall') {
            Write-Error "The only supported action for 'winsdk' is 'uninstall'."
            Exit 1
        }

        # Perform self-uninstallation
        Uninstall-WinSDK
    }
    default {
        Write-Error "Unsupported SDK: $SDK"
        Exit 1
    }
}

# Function to uninstall WinSDK
function Uninstall-WinSDK {
    param ()

    # Ensure script is running as Administrator
    if (-not (Test-IsAdministrator)) {
        Write-Error "This action requires administrative privileges. Please run the command prompt or PowerShell as Administrator."
        Exit 1
    }

    # Confirmation prompt
    $confirmation = Read-Host "Are you sure you want to uninstall WinSDK? (Y/N)"
    if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-Host "Uninstallation canceled."
        Exit 0
    }

    # Variables
    $InstallDir = "C:\Program Files\WinSDK"

    # Remove WinSDK installation directory
    if (Test-Path $InstallDir) {
        Write-Host "Removing WinSDK installation directory..."
        try {
            Remove-Item -Path $InstallDir -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Error "Failed to remove installation directory: $_"
            Exit 1
        }
    } else {
        Write-Host "WinSDK installation directory not found."
    }

    # Remove WinSDK from the system Path
    Write-Host "Updating system Path..."
    $CurrentPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $NewPathEntries = $CurrentPath -split ';' | Where-Object { $_ -and ($_ -notmatch [Regex]::Escape($InstallDir)) } | ForEach-Object { $_.Trim() }
    $NewPath = ($NewPathEntries | Select-Object -Unique) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $NewPath, 'Machine')

    # Remove SDK-specific environment variables (e.g., JAVA_HOME)
    $EnvVariables = @('JAVA_HOME') # Add other variables if needed
    foreach ($EnvVar in $EnvVariables) {
        Write-Host "Removing environment variable: $EnvVar"
        [Environment]::SetEnvironmentVariable($EnvVar, $null, 'Machine')
    }

    Write-Host "WinSDK has been uninstalled successfully."
    Write-Host "Please restart your computer to apply the changes."
}

# Function to check if running as Administrator
function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
