function Switch-Java {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    # Determine the installation directory for Java
    $JavaInstallDir = Get-InstallDirectory -SDKName 'Java'
    $JavaVersionDir = "$JavaInstallDir\jdk-$Version"
    $CurrentJavaDir = "$JavaInstallDir\current"

    # Determine SDKPath from WINSDK_HOME environment variable
    $SDKPath = [Environment]::GetEnvironmentVariable("WINSDK_HOME", "Machine")
    if (-not $SDKPath) {
        Write-Warning "WINSDK_HOME is not set for Machine. Skipping environment updates for Machine."
        return
    }

    # Ensure the requested Java version is installed
    if (-not (Test-Path $JavaVersionDir)) {
        Write-Error "Java version $Version is not installed."
        return
    }

    # Import the Remove-SDKEnvironment module dynamically
    $RemoveEnvironmentModulePath = Join-Path $SDKPath "modules\Environment\Remove-SDKEnvironment.psm1"
    $SetEnvironmentModulePath = Join-Path $SDKPath "modules\Environment\Set-SDKEnvironment.psm1"

    if (Test-Path $RemoveEnvironmentModulePath) {
        Import-Module $RemoveEnvironmentModulePath -Force
    } else {
        Write-Warning "Remove-SDKEnvironment module not found: $RemoveEnvironmentModulePath"
    }
    
    if (Test-Path $SetEnvironmentModulePath) {
        Import-Module $SetEnvironmentModulePath -Force
    } else {
        Write-Warning "Set-SDKEnvironment module not found: $SetEnvironmentModulePath"
    }

    try {
        Write-Host "Switching to Java version $Version..."

        # Clean up the current Java directory if it exists
        if (Test-Path $CurrentJavaDir) {
            Write-Host "Removing existing 'current' Java directory..."
            Remove-Item -Recurse -Force -Path $CurrentJavaDir
        }

        # Copy the selected Java version to the 'current' folder
        Write-Host "Copying Java version $Version to 'current' directory..."
        Copy-Item -Recurse -Force -Path $JavaVersionDir -Destination $CurrentJavaDir

        # Remove old JAVA_HOME and PATH entries
        Remove-SDKEnvironment -SDKName "java" -Scope "User"
        Remove-SDKEnvironment -SDKName "java" -Scope "Machine"

        # Set new JAVA_HOME and update PATH
        Set-SDKEnvironment -SDKName "java" -SDKPath $CurrentJavaDir -Scope "User" -IncludeBin
        Set-SDKEnvironment -SDKName "java" -SDKPath $CurrentJavaDir -Scope "Machine" -IncludeBin

        Write-Host "Successfully switched to Java version $Version."
    } catch {
        Write-Error "An error occurred while switching to Java version $Version : $_"
    }
}
