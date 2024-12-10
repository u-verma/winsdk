<#
.SYNOPSIS
WinSDK - A tool to manage SDKs on Windows.

.DESCRIPTION
Provides commands to install, use, list, current, and uninstall SDKs, including self-uninstallation.

.PARAMETER Action
The action to perform: install, use, list, current, uninstall, update, help.

.PARAMETER SDK
The SDK to manage (optional for general actions like update, uninstall, or help).

.PARAMETER Version
The version of the SDK to manage.

.EXAMPLE
winsdk install java 17

.EXAMPLE
winsdk uninstall

.EXAMPLE
winsdk help
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet('install', 'use', 'list', 'current', 'uninstall', 'update', 'help')]
    [string]$Action,

    [Parameter(Position = 1)]
    [string]$SDK,

    [Parameter(Position = 2)]
    [string]$Version
)

# Import utility modules
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Import-Module "$ScriptDir\modules\Utils\Utils.psm1" -Force

# Handle general commands (help, update, uninstall)
switch ($Action.ToLower()) {
    'help' {
        Import-Module "$ScriptDir\modules\WinSdk\Show-Help.psm1" -Force
        Show-Help
        return
    }
    'update' {
        Import-Module "$ScriptDir\modules\WinSdk\Update-WinSDK.psm1" -Force
        Update-WinSDK
        return
    }
    'uninstall' {
        if (-not $SDK) {
            # Uninstall WinSDK if no SDK is specified
            Import-Module "$ScriptDir\modules\WinSdk\Uninstall-WinSDK.psm1" -Force
            Uninstall-WinSDK
            return
        } else {
            <# Action when all if and elseif conditions are false #>
            Write-Host "Unspecified action for SDK: $SDK"
        }
    }
}

# Ensure SDK is specified for SDK-specific actions
if (-not $SDK) {
    Write-Error "Please specify an SDK for actions like install, use, list, or current."
    Exit 1
}

# Load SDK-specific modules
$SDKModulePath = "$ScriptDir\modules\$SDK"
if (-not (Test-Path $SDKModulePath)) {
    Write-Error "Unsupported SDK: $SDK"
    Exit 1
}

Import-Module "$SDKModulePath\Install-$SDK.psm1" -Force
Import-Module "$SDKModulePath\Switch-$SDK.psm1" -Force
Import-Module "$SDKModulePath\Show-Available$SDK.psm1" -Force
Import-Module "$SDKModulePath\Show-CurrentActive$SDK.psm1" -Force
Import-Module "$SDKModulePath\Uninstall-$SDK.psm1" -Force

# Perform the specified action
switch ($Action.ToLower()) {
    'install' {
        if (-not $Version) {
            Write-Error "Please specify the $SDK version identifier to install."
            Exit 1
        }
        Invoke-Expression "Install-$SDK -Identifier $Version"
    }
    'use' {
        if (-not $Version) {
            Write-Error "Please specify the $SDK version to use."
            Exit 1
        }
        Invoke-Expression "Switch-$SDK -Version $Version"
    }
    'list' {
        Invoke-Expression "Show-Available$SDK"
    }
    'current' {
        Invoke-Expression "Show-CurrentActive$SDK"
    }
    'uninstall' {
        if (-not $Version) {
            Write-Error "Please specify the $SDK version to uninstall."
            Exit 1
        }
        Invoke-Expression "Uninstall-$SDK -Version $Version"
    }
    default {
        Write-Error "Unknown action: $Action"
        Exit 1
    }
}
