function Install-Java {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Identifier
    )

    # Remove '-LTS-hs-adpt' or '-hs-adpt' from the identifier to get the version
    # Capture the version part without '-LTS' for API compatibility
    if ($Identifier -match '^(.*?)(-LTS)?-hs-adpt$') {
        $VersionWithLTS = $matches[1]       # e.g., "21.0.5+11" or "21.0.5+11-LTS"
        $HasLTS = $matches[2] -eq '-LTS'    # True if '-LTS' is present

        # For API, we need the version without '-LTS'
        $ApiVersion = $VersionWithLTS -replace '-LTS$', ''

        # For user messages and installation paths, we use the original version
        if ($HasLTS) {
            $Version = "$VersionWithLTS-LTS"
        } else {
            $Version = $VersionWithLTS
        }
    } else {
        Write-Error "Invalid Java version identifier. Please use the format <version>[-LTS]-hs-adpt (e.g., 21.0.5+11-LTS-hs-adpt or 23.0.1+11-hs-adpt)."
        return
    }

    # URL-encode the ApiVersion to handle special characters like '+'
    $EncodedApiVersion = [uri]::EscapeDataString("jdk-$ApiVersion")

    # Map Vendor Code to Vendor Name (we can hardcode 'eclipse' since we're only using 'adpt')
    $Vendor = "eclipse"

    # Set parameters
    $OS = "windows"
    $Arch = "x64"
    $ImageType = "jdk"
    $JVMImpl = "hotspot"
    $HeapSize = "normal"

    # Construct the API URL with the encoded version
    $ApiUrl = "https://api.adoptium.net/v3/binary/version/$EncodedApiVersion/$OS/$Arch/$ImageType/$JVMImpl/$HeapSize/$Vendor"

    Write-Host "Fetching download information from: $ApiUrl"

    try {
        # Get the download information
        $DownloadResponse = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing -ErrorAction Stop

        if ($DownloadResponse.Count -gt 0 -and $DownloadResponse[0].Count -gt 0) {
            # The response is an array of arrays; get the first binary
            $Asset = $DownloadResponse[0][0]
            $DownloadUrl = $Asset.binary.package.link
        } else {
            Write-Error "No assets found for version $Version."
            return
        }
    }
    catch {
        Write-Error "Failed to fetch binary for version $Version : $_"
        return
    }

    if (-not $DownloadUrl) {
        Write-Error "No binary found for version $Version."
        return
    }

    # Prepare installation directory
    $InstallDirRoot = "$env:ProgramFiles\WinSDK\Java"
    if (-not (Test-Path $InstallDirRoot)) {
        New-Item -ItemType Directory -Path $InstallDirRoot | Out-Null
    }

    $InstallDir = "$InstallDirRoot\jdk-$Version"
    $ZipFile = "$InstallDirRoot\jdk-$Version.zip"

    Write-Host "Downloading JDK from $DownloadUrl..."

    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile -UseBasicParsing
    }
    catch {
        Write-Error "Failed to download JDK: $_"
        return
    }

    Write-Host "Extracting JDK to $InstallDir..."

    try {
        Expand-Archive -Path $ZipFile -DestinationPath $InstallDir
    }
    catch {
        Write-Error "Failed to extract JDK: $_"
        return
    }

    # Remove the zip file
    Remove-Item $ZipFile -Force

    Write-Host "JDK version $Version installed successfully."

    # Optionally, set this version as the current version
    # Switch-Java -Version $Version
}
