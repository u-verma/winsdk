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
        Import-Module "$ScriptDir\Uninstall-WinSDK.psm1" -Force
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

# Function to check if running as Administrator
function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
