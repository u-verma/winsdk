function Install-Java {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Identifier  # e.g., "23.0.1+11-hs-adpt"
    )

    # Parse the Identifier
    $parts = $Identifier -split "-"
    if ($parts.Length -ne 3) {
        Write-Error "Invalid Java version identifier. Please use the format <version>-<distribution>-<vendor> (e.g., 23.0.1+11-hs-adpt)."
        return
    }

    $Version = $parts[0]
    $Distribution = $parts[1]
    $VendorCode = $parts[2]

    # Construct the download URL
    $ApiUrl = "https://api.adoptium.net/v3/assets/version/$Version?architecture=x64&heap_size=normal&image_type=jdk&jvm_impl=hotspot&os=windows&vendor=eclipse"

    try {
        $AssetsResponse = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing
    } catch {
        Write-Error "Failed to fetch assets for version $Version $_"
        return
    }

    if (-not $AssetsResponse) {
        Write-Error "No assets found for version $Version."
        return
    }

    # Select the appropriate binary
    $Asset = $AssetsResponse[0][0]
    $DownloadUrl = $Asset.binary.package.link

    # Proceed with download and installation using $DownloadUrl
    # ...
}
