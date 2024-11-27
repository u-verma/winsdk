function Uninstall-Java {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    Ensure-Administrator

    $JavaInstallDir = Get-InstallDirectory -SDKName 'Java'
    $JavaVersionDir = "$JavaInstallDir\jdk-$Version"

    if (-not (Test-Path $JavaVersionDir)) {
        Write-Error "Java version $Version is not installed."
        return
    }

    # Check if this version is currently in use
    $CurrentJavaHome = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'Machine')
    if ($CurrentJavaHome -eq $JavaVersionDir) {
        Write-Host "Java version $Version is currently in use."
        # Switch to another version if available
        $AvailableVersions = Get-ChildItem -Path $JavaInstallDir -Directory | Where-Object { $_.Name -ne "jdk-$Version" } | ForEach-Object { $_.Name -replace 'jdk-', '' }
        if ($AvailableVersions.Count -gt 0) {
            Write-Host "Switching to Java version $($AvailableVersions[0])..."
            Switch-Java -Version $AvailableVersions[0]
        } else {
            Write-Error "No other Java versions are installed. Cannot uninstall the current version."
            return
        }
    }

    # Remove the Java version
    Remove-Item -Recurse -Force $JavaVersionDir

    Write-Host "Java version $Version has been uninstalled."
}
