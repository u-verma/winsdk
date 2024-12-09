function Remove-SDKEnvironment {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SDKName,  # The name of the SDK/tool, e.g., "java", "winsdk"

        [Parameter(Mandatory = $true)]
        [ValidateSet("User", "Machine")]
        [string]$Scope    # The scope: "User" or "Machine"
    )

    # Determine the SDK_HOME variable name
    $EnvVariableName = ($SDKName -replace '\s', '_').ToUpper() + "_HOME"

    # Remove <SDK>_HOME environment variable
    Write-Host "Removing $EnvVariableName for $Scope..."
    [Environment]::SetEnvironmentVariable($EnvVariableName, $null, $Scope)

    # Get the current PATH
    $OldPath = [Environment]::GetEnvironmentVariable('Path', $Scope)

    # Handle cases where PATH is empty or null
    if (-not $OldPath) {
        Write-Host "No PATH entries found for $Scope. Skipping PATH cleanup."
        return
    }

    # Normalize PATH entries
    $PathEntries = if ($OldPath -notmatch ';') {
        @($OldPath.Trim())
    } else {
        $OldPath -split ';' | ForEach-Object { $_.Trim() }
    }

    # Remove all PATH entries related to <SDK>_HOME
    $RegexPattern = [regex]::Escape("%$EnvVariableName%") + "(\\bin)?"
    $CleanedEntries = $PathEntries | Where-Object { $_ -notmatch $RegexPattern }

    # Join the cleaned entries and update PATH
    $NewPath = ($CleanedEntries | Select-Object -Unique) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $NewPath, $Scope)

    Write-Host "Removed PATH entries related to $EnvVariableName for $Scope."
    Write-Host "Updated PATH for $Scope : $NewPath"
}
