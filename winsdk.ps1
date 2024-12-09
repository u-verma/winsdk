<#
.SYNOPSIS
WinSDK - A tool to manage SDKs on Windows.

.DESCRIPTION
Provides commands to install, use, list, current, and uninstall SDKs, including self-uninstallation and updates.

.PARAMETER Action
The action to perform: install, use, list, current, uninstall, update.

.PARAMETER SDK
The SDK to manage (e.g., java, winsdk).

.PARAMETER Version
The version of the SDK to manage.

.EXAMPLE
winsdk install java 17

.EXAMPLE
winsdk uninstall winsdk

.EXAMPLE
winsdk --help
Displays available commands and their descriptions.
#>

# Import utility modules
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Import-Module "$ScriptDir\modules\Utils\Utils.psm1" -Force
Import-Module "$ScriptDir\modules\Environment\EnvironmentManager.psm1" -Force

# Dispatcher logic
param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('install', 'use', 'list', 'current', 'uninstall', 'update', '--help')]
    [string]$Action,

    [Parameter(Position = 1)]
    [string]$SDK,

    [Parameter(Position = 2)]
    [string]$Version
)

if ($Action -eq '--help') {
    Show-Help
    Exit 0
}

switch ($SDK.ToLower()) {
    'java' {
        Import-Module "$ScriptDir\modules\Java\Install-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Switch-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\List-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Current-JavaVersion.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Uninstall-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Get-JavaDownloadUrl.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Get-AvailableJavaVersions.psm1" -Force

        switch ($Action.ToLower()) {
            'install' {
                if (-not $Version) {
                    Write-Error "Please specify the Java version identifier to install."
                    Exit 1
                }
                Install-Java -Identifier $Version
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
                Current-JavaVersion
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
        Import-Module "$ScriptDir\modules\WinSDK\Uninstall-WinSDK.psm1" -Force
        Import-Module "$ScriptDir\modules\WinSDK\Update-WinSDK.psm1" -Force

        switch ($Action.ToLower()) {
            'update' {
                Update-WinSDK
            }
            'uninstall' {
                Uninstall-WinSDK
            }
            default {
                Write-Error "Unsupported action for 'winsdk'. Only 'update' and 'uninstall' are supported."
                Exit 1
            }
        }
    }
    default {
        Write-Error "Unsupported SDK: $SDK"
        Exit 1
    }
}

# Function to show help
function Show-Help {
    Write-Host "WinSDK Management Tool" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available Commands:"
    Write-Host "  install <sdk> <version>     Installs the specified SDK and version."
    Write-Host "  use <sdk> <version>         Switches to the specified SDK version."
    Write-Host "  list <sdk>                  Lists available versions of the SDK."
    Write-Host "  current <sdk>               Displays the current version of the SDK in use."
    Write-Host "  uninstall <sdk> <version>   Uninstalls the specified version of the SDK."
    Write-Host "  update winsdk               Updates WinSDK to the latest version."
    Write-Host "  --help                      Displays this help message."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  winsdk install java 17"
    Write-Host "  winsdk uninstall winsdk"
    Write-Host "  winsdk --help"
}
