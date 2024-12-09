function Uninstall-Java {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    # Determine the installation directory for Java
    $JavaInstallDir = Get-InstallDirectory -SDKName 'Java'
    $JavaVersionDir = "$JavaInstallDir\jdk-$Version"

    if (-not (Test-Path $JavaVersionDir)) {
        Write-Error "Java version $Version is not installed."
        return
    }

    try {
        Write-Host "Uninstalling Java version $Version..."

        # Remove the Java installation directory
        Remove-Item -Path $JavaVersionDir -Recurse -Force
        Write-Host "Removed Java version $Version directory: $JavaVersionDir"

        # Check if this version is the active version
        $CurrentJavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
        if ($CurrentJavaHome -eq $JavaVersionDir) {
            # Clean up JAVA_HOME and PATH
            Remove-SDKEnvironment -SDKName "java" -Scope "User"
            Remove-SDKEnvironment -SDKName "java" -Scope "Machine"
            Write-Host "Cleaned up JAVA_HOME and PATH for Java version $Version."
        } else {
            Write-Host "Java version $Version was not set as the current version. No environment cleanup needed."
        }

        Write-Host "Java version $Version uninstalled successfully."
    } catch {
        Write-Error "An error occurred while uninstalling Java version $Version : $_"
    }
}
