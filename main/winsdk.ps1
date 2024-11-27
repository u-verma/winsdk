<#
.SYNOPSIS
WinSDK - A tool to manage SDKs on Windows.

.DESCRIPTION
Provides commands to install, use, list, and uninstall SDKs.

.PARAMETER Action
The action to perform: install, use, list, uninstall.

.PARAMETER SDK
The SDK to manage (e.g., java).

.PARAMETER Version
The version of the SDK to manage.

.EXAMPLE
winsdk install java 17

#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('install', 'use', 'list', 'uninstall')]
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
        Import-Module "$ScriptDir\modules\Java\Uninstall-Java.psm1" -Force
        Import-Module "$ScriptDir\modules\Java\Get-JavaDownloadUrl.psm1" -Force

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
    default {
        Write-Error "Unsupported SDK: $SDK"
        Exit 1
    }
}
