function Update-EnvironmentVariables {
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
    $OldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $PathEntries = $OldPath -split ';' | Where-Object { $_ -and ($_ -notmatch "\\$SDKName\\.*\\bin") } | ForEach-Object { $_.Trim() }

    if ($PathEntries -notcontains $SDKBinPath) {
        $PathEntries += $SDKBinPath
    }

    $NewPath = ($PathEntries | Select-Object -Unique) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $NewPath, 'Machine')

    Write-Host "Environment variables updated. Please restart your session to apply changes."
}
