function Switch-Java {
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
