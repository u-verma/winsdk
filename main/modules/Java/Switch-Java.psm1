function Switch-Java {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    $JavaInstallDir = Get-InstallDirectory -SDKName 'Java'
    $JavaVersionDir = "$JavaInstallDir\jdk-$Version"

    if (-not (Test-Path $JavaVersionDir)) {
        Write-Error "Java version $Version is not installed."
        return
    }

    # Update environment variables
    Update-EnvironmentVariables -SDKName 'Java' -SDKPath $JavaVersionDir

    Write-Host "Switched to Java version $Version."
}
