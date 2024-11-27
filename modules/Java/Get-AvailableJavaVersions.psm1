function Get-AvailableJavaVersions {
    param (
        [int]$PageSize = 20  # Number of versions to fetch
    )

    Write-Host "Fetching available Java versions..."

    $ApiUrl = "https://api.adoptium.net/v3/info/release_versions?architecture=x64&heap_size=normal&jvm_impl=hotspot&os=windows&page=0&page_size=$PageSize&project=jdk&release_type=ga&semver=false&sort_method=DEFAULT&sort_order=DESC&vendor=eclipse"

    try {
        $Response = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing

        $AvailableVersions = @()

        foreach ($version in $Response.versions) {
            $Vendor = "Adoptium"
            $Use = ""
            $OpenJDKVersion = $version.openjdk_version  # e.g., "23.0.1+11"
            $Distribution = "hs"  # HotSpot
            $Status = ""
            $Identifier = "$OpenJDKVersion-$Distribution-adpt"

            # Check if LTS
            if ($version.optional -eq "LTS") {
                $Status = "LTS"
            }

            $VersionData = [PSCustomObject]@{
                Vendor       = $Vendor
                Use          = $Use
                Version      = $OpenJDKVersion
                Distribution = $Distribution
                Status       = $Status
                Identifier   = $Identifier
            }

            $AvailableVersions += $VersionData
        }

        return $AvailableVersions

    } catch {
        Write-Error "Error fetching available Java versions: $_"
        return @()
    }
}
