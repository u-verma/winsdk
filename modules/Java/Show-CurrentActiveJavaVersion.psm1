function Show-CurrentActiveJavaVersion {
    $JavaHome = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'Machine')

    if (-not $JavaHome -or -not (Test-Path $JavaHome)) {
        Write-Host "No Java version is currently set."
        return
    }

    # Get Java version
    try {
        $JavaVersionOutput = & "$JavaHome\bin\java.exe" -version 2>&1
        $JavaVersionLine = $JavaVersionOutput | Select-String 'version' | Select-Object -First 1
        $JavaVersion = $JavaVersionLine -replace 'java version', ''
        $JavaVersion = $JavaVersion.Trim('"')
    } catch {
        Write-Error "Unable to determine Java version: $_"
        return
    }

    Write-Host "Current Java Version:"
    Write-Host "- Version: $JavaVersion"
    Write-Host "- Path: $JavaHome"
}
