function Ensure-Administrator {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')) {
        Write-Error "This action requires administrative privileges. Please run PowerShell as Administrator."
        Exit 1
    }
}

function Get-InstallDirectory {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SDKName
    )

    $InstallRoot = "C:\Program Files\WinSDK"
    $SDKInstallDir = "$InstallRoot\$SDKName"

    # Create directories if they don't exist
    if (-not (Test-Path $InstallRoot)) {
        New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
    }
    if (-not (Test-Path $SDKInstallDir)) {
        New-Item -ItemType Directory -Path $SDKInstallDir -Force | Out-Null
    }

    return $SDKInstallDir
}
