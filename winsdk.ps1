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
    [ValidateSet('install', 'use', 'list', 'current', 'uninstall', 'update', 'help')]
    [string]$Action,

    [Parameter(Position = 1, Mandatory = $true)]
    [string]$SDK,

    [Parameter(Position = 2)]
    [string]$Version
)

# Import modules
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Import-Module "$ScriptDir\modules\Utils\Utils.psm1" -Force

switch ($SDK.ToLower()) {
    'java' {
        Import-Module "$ScriptDir\modules\Java\Install-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Switch-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Show-AvailableJava.psm1" -Force
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
                Show-AvailableJava
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
        Import-Module "$ScriptDir\modules\WinSdk\Uninstall-WinSDK.psm1" -Force
        Import-Module "$ScriptDir\modules\WinSdk\Update-WinSDK.psm1" -Force
        Import-Module "$ScriptDir\modules\WinSdk\Show-Help.psm1" -Force
        switch ($Action.ToLower()) {
            'help' {
                Show-Help
            }
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

# Function to check if running as Administrator
function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to show help