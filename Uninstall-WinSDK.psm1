<#
.SYNOPSIS
Uninstalls the WinSDK for both user and machine scopes.

.DESCRIPTION
Removes all files related to WinSDK and cleans up environment variables at both user and machine levels.

.PARAMETER Force
Skips the confirmation prompt if specified.

#>

function Uninstall-WinSDK {
    [CmdletBinding()]
    param (
        [Switch]$Force
    )

    Write-Host "Starting WinSDK uninstallation for both user and machine..."

    # Confirmation prompt
    if (-not $Force) {
        $confirmation = Read-Host "Are you sure you want to uninstall WinSDK? (Y/N)"
        if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
            Write-Host "Uninstallation canceled."
            Exit 0
        }
    }

    try {
        # Handle both User and Machine scopes
        $Scopes = @("User", "Machine")
        foreach ($Scope in $Scopes) {
            Write-Host "Processing scope: $Scope"

            # Path where WinSDK is installed
            $SDKPath = [Environment]::GetEnvironmentVariable("WINSDK_HOME", $Scope)

            if (-not $SDKPath) {
                Write-Warning "WINSDK_HOME is not set for $Scope. Falling back to default path."
                $SDKPath = "C:\Program Files\WinSDK"
            }

            # Remove SDK files
            if (Test-Path $SDKPath) {
                Write-Host "Removing files from $SDKPath for $Scope..."
                Remove-Item -Recurse -Force -Path $SDKPath
                Write-Host "Files removed successfully for $Scope."
            }
            else {
                Write-Warning "WinSDK directory does not exist at $SDKPath for $Scope."
            }

            # Remove WINSDK_HOME environment variable
            Write-Host "Removing WINSDK_HOME environment variable for $Scope..."
            [Environment]::SetEnvironmentVariable("WINSDK_HOME", $null, $Scope)

            # Clean up PATH environment variable
            Write-Host "Cleaning up PATH environment variable for $Scope..."
            $OldPath = [Environment]::GetEnvironmentVariable("Path", $Scope)
            if ($OldPath) {
                # Remove SDKPath from PATH
                $PathEntries = $OldPath -split ';' | Where-Object { $_.Trim() -ne $SDKPath }
                $NewPath = ($PathEntries | Select-Object -Unique) -join ';'
                [Environment]::SetEnvironmentVariable("Path", $NewPath, $Scope)
                Write-Host "PATH cleaned successfully for $Scope."
            }
            else {
                Write-Warning "No PATH entries found for $Scope."
            }
        }

        Write-Host "WinSDK uninstallation completed successfully for both user and machine scopes."
    } catch {
        Write-Error "An error occurred during WinSDK uninstallation: $_"
    }
}
