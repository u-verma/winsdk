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