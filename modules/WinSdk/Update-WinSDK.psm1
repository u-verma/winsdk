<#
.SYNOPSIS
Updates WinSDK to the latest version from the GitHub repository.

.DESCRIPTION
The Update-WinSDK function removes the current installation of WinSDK and reinstalls it by invoking the remote install.ps1 script.

.EXAMPLE
Update-WinSDK
Updates the WinSDK to the latest version.
#>

function Update-WinSDK {
    [CmdletBinding()]
    param ()

    Write-Host "Starting WinSDK update process..."

    try {
        # Uninstall the current version
        Write-Host "Uninstalling current WinSDK..."
        Uninstall-WinSDK -Force

        # Invoke the install.ps1 script from GitHub
        Write-Host "Installing the latest version of WinSDK..."
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/u-verma/winsdk/refs/heads/main/install.ps1'))

        Write-Host "WinSDK has been updated successfully."
        Write-Host "Please close and reopen your command prompt or PowerShell to start using the updated 'winsdk' command."
    } catch {
        Write-Error "An error occurred during the WinSDK update process: $_"
    }
}
