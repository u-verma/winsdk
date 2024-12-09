function Update-EnvironmentVariables {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SDKName,

        [Parameter(Mandatory = $true)]
        [string]$SDKPath
    )

    Update-SystemEnvironmentVariables -SDKName $SDKName -SDKPath $SDKPath
    Update-UserEnvironmentVariables -SDKName $SDKName -SDKPath $SDKPath
}

function Update-SystemEnvironmentVariables {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SDKName,

        [Parameter(Mandatory = $true)]
        [string]$SDKPath
    )

    $EnvVariableName = ($SDKName -replace '\s', '_').ToUpper() + "_HOME"
    [Environment]::SetEnvironmentVariable($EnvVariableName, $SDKPath, 'Machine')

    # Update PATH
    $SDKBinPath = "$SDKPath\bin" 
    $OldPath = [Environment]::GetEnvironmentVariable('Path', 'User')

    # Handle empty or single-entry PATH
    if (-not $OldPath) {
        # If PATH is empty, directly set it to the SDKBinPath
        [Environment]::SetEnvironmentVariable('Path', $SDKBinPath, 'Machine')
        Write-Host "User Environment variables updated. Please restart your session to apply changes."
        return
    }

    # Split the PATH into entries and clean it up
    $PathEntries = $OldPath -split ';' | Where-Object { $_ -and ($_ -notmatch "\\$SDKName\\.*\\bin") } | ForEach-Object { $_.Trim() }

    # Add SDKBinPath if it's not already in the PATH
    if ($PathEntries -notcontains $SDKBinPath) {
        $PathEntries += $SDKBinPath
    }

    # Join the entries with a semicolon
    $NewPath = ($PathEntries | Select-Object -Unique) -join ';'

    # Handle single-entry PATH (ensures proper format)
    if ($PathEntries.Count -eq 1 -and $PathEntries[0] -ne $SDKBinPath) {
        $NewPath = "$PathEntries[0];$SDKBinPath"
    }

    # Set the updated PATH
    [Environment]::SetEnvironmentVariable('Path', $NewPath, 'Machine')

    Write-Host "System Environment variables updated. Please restart your session to apply changes."
    
}

function Update-UserEnvironmentVariables {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SDKName,

        [Parameter(Mandatory = $true)]
        [string]$SDKPath
    )

    # Set SDK_HOME environment variable
    $EnvVariableName = ($SDKName -replace '\s', '_').ToUpper() + "_HOME"
    [Environment]::SetEnvironmentVariable($EnvVariableName, $SDKPath, 'User')

    # Update PATH
    $SDKBinPath = "$SDKPath\bin"
    $OldPath = [Environment]::GetEnvironmentVariable('Path', 'User')

    # Handle empty or single-entry PATH
    if (-not $OldPath) {
        # If PATH is empty, directly set it to the SDKBinPath
        [Environment]::SetEnvironmentVariable('Path', $SDKBinPath, 'User')
        Write-Host "User Environment variables updated. Please restart your session to apply changes."
        return
    }

    # Split the PATH into entries and clean it up
    $PathEntries = $OldPath -split ';' | Where-Object { $_ -and ($_ -notmatch "\\$SDKName\\.*\\bin") } | ForEach-Object { $_.Trim() }

    # Add SDKBinPath if it's not already in the PATH
    if ($PathEntries -notcontains $SDKBinPath) {
        $PathEntries += $SDKBinPath
    }

    # Join the entries with a semicolon
    $NewPath = ($PathEntries | Select-Object -Unique) -join ';'

    # Handle single-entry PATH (ensures proper format)
    if ($PathEntries.Count -eq 1 -and $PathEntries[0] -ne $SDKBinPath) {
        $NewPath = "$PathEntries[0];$SDKBinPath"
    }

    # Set the updated PATH
    [Environment]::SetEnvironmentVariable('Path', $NewPath, 'User')

    Write-Host "User Environment variables updated. Please restart your session to apply changes."
}
