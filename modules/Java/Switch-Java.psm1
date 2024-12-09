function Switch-Java {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    # Determine the installation directory for Java
    $JavaInstallDir = Get-InstallDirectory -SDKName 'Java'
    $JavaVersionDir = "$JavaInstallDir\jdk-$Version"
    # Determine SDKPath from WINSDK_HOME environment variable
    $SDKPath = [Environment]::GetEnvironmentVariable("WINSDK_HOME", "Machine")

    if (-not $SDKPath) {
        Write-Warning "WINSDK_HOME is not set for Machine. Skipping SDK removal for Machine."
        continue
    }


    if (-not (Test-Path $JavaVersionDir)) {
        Write-Error "Java version $Version is not installed."
        return
    }


    # Import the Remove-SDKEnvironment module dynamically
    $RemoveEnvironmentModulePath = Join-Path $SDKPath "modules\Environment\Remove-SDKEnvironment.psm1"
    $SetEnvironmentModulePath = Join-Path $SDKPath "modules\Environment\Set-SDKEnvironment.psm1"
    if (Test-Path $RemoveEnvironmentModulePath and Test-Path $SetEnvironmentModulePath) {
        Import-Module $RemoveEnvironmentModulePath -Force
        Import-Module $SetEnvironmentModulePath -Force
    }
    else {
        Write-Warning "Remove Or set -SDKEnvironment module not found. Skipping environment cleanup for $Scope."
        continue
    }


    try {
        Write-Host "Switching to Java version $Version..."

        # Remove old JAVA_HOME and PATH entries
        Remove-SDKEnvironment -SDKName "java" -Scope "User"
        Remove-SDKEnvironment -SDKName "java" -Scope "Machine"

        # Set new JAVA_HOME and update PATH
        Set-SDKEnvironment -SDKName "java" -SDKPath $JavaVersionDir -Scope "User" -IncludeBin
        Set-SDKEnvironment -SDKName "java" -SDKPath $JavaVersionDir -Scope "Machine" -IncludeBin

        Write-Host "Successfully switched to Java version $Version."
    } catch {
        Write-Error "An error occurred while switching to Java version $Version : $_"
    }
}
