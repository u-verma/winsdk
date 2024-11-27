function List-Java {
    $JavaInstallDir = Get-InstallDirectory -SDKName 'Java'
    $InstalledVersions = Get-ChildItem -Path $JavaInstallDir -Directory | ForEach-Object { $_.Name -replace 'jdk-', '' }

    if ($InstalledVersions.Count -eq 0) {
        Write-Host "No Java versions are installed."
    } else {
        Write-Host "Installed Java versions:"
        foreach ($Version in $InstalledVersions) {
            Write-Host "- $Version"
        }
    }
}
