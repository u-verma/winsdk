function Set-SDKEnvironment {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SDKName,  # The name of the SDK/tool, e.g., "java", "winsdk"

        [Parameter(Mandatory = $true)]
        [string]$SDKPath,  # The installation path of the SDK/tool

        [Parameter(Mandatory = $true)]
        [ValidateSet("User", "Machine")]
        [string]$Scope,    # The scope: "User" or "Machine"

        [Parameter(Mandatory = $false)]
        [switch]$IncludeBin # Specify whether to include the "bin" subdirectory dynamically
    )

    # Set <SDK>_HOME environment variable
    $EnvVariableName = ($SDKName -replace '\s', '_').ToUpper() + "_HOME"
    [Environment]::SetEnvironmentVariable($EnvVariableName, $SDKPath, $Scope)

    # Determine the full path to add to PATH
    $PathToAdd = if ($IncludeBin) { "%$EnvVariableName%\bin" } else { "%$EnvVariableName%" }

    # Get the current PATH
    $OldPath = [Environment]::GetEnvironmentVariable('Path', $Scope)

    # Handle empty or null PATH
    if (-not $OldPath) {
        $NewPath = $PathToAdd
        [Environment]::SetEnvironmentVariable('Path', $NewPath, $Scope)
        Write-Host "Updated PATH for $Scope : $NewPath"
        return
    }

    # Normalize single entry without semicolon
    $PathEntries = if ($OldPath -notmatch ';') {
        @($OldPath.Trim())
    } else {
        $OldPath -split ';' | ForEach-Object { $_.Trim() }
    }

    # Remove any existing entries for this SDK
    $RegexPattern = [regex]::Escape("%$EnvVariableName%") + "(\\bin)?"
    $CleanedEntries = $PathEntries | Where-Object { $_ -notmatch $RegexPattern }

    # Add the new entry if not already present
    if ($CleanedEntries -notcontains $PathToAdd) {
        $CleanedEntries += $PathToAdd
    }

    # Join the cleaned entries and set the new PATH
    $NewPath = ($CleanedEntries | Select-Object -Unique) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $NewPath, $Scope)

    Write-Host "Updated $EnvVariableName to $SDKPath for $Scope"
    Write-Host "Updated PATH for $Scope : $NewPath"
}
