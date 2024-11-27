function Get-AvailableJavaVersions {
    # Use Adoptium API to get a list of available Java versions
    $ApiUrl = "https://api.adoptium.net/v3/info/available_releases"
    try {
        $ReleasesInfo = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing
        $AvailableVersions = $ReleasesInfo.available_lts_releases + $ReleasesInfo.available_releases
        $AvailableVersions = $AvailableVersions | Sort-Object -Descending
        return $AvailableVersions
    } catch {
        Write-Error "Error fetching available Java versions: $_"
        return @()
    }
}
