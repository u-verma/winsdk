function List-Java {
    # Fetch available Java versions from Adoptium API
    Write-Host "Fetching available Java versions..."
    $AvailableVersions = Get-AvailableJavaVersions

    if ($AvailableVersions.Count -eq 0) {
        Write-Host "No Java versions are available for installation."
    } else {
        Write-Host "Available Java versions for installation:"
        foreach ($Version in $AvailableVersions) {
            Write-Host "- $Version"
        }
    }
}
