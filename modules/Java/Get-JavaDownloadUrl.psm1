function Get-JavaDownloadUrl {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    # Use Adoptium API to get download URL
    $ApiUrl = "https://api.adoptium.net/v3/assets/latest/$Version/hotspot"
    try {
        $Assets = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing

        # Filter for Windows x64 ZIP
        $Asset = $Assets | Where-Object {
            $_.binary.os -eq 'windows' -and
            $_.binary.architecture -eq 'x64' -and
            $_.binary.image_type -eq 'jdk' -and
            $_.binary.package.extension -eq 'zip'
        } | Select-Object -First 1

        if ($Asset) {
            return $Asset.binary.package.link
        } else {
            return $null
        }
    } catch {
        Write-Error "Error fetching download URL: $_"
        return $null
    }
}
