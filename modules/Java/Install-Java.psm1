function Install-Java {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Identifier
    )

    # Updated regex pattern to match various identifier formats
    if ($Identifier -match '^(.*?)(-LTS)?(-hs-adpt)?$') {
        $VersionWithLTS = $matches[1]       # e.g., "21.0.5+11", "23+37", "18.0.1"
        $HasLTS = $matches[2] -eq '-LTS'    # True if '-LTS' is present
        $HasHSAdpt = $matches[3] -eq '-hs-adpt'  # True if '-hs-adpt' is present

        # For API, we need the version without '-LTS' and '-hs-adpt'
        $ApiVersion = $VersionWithLTS

        # For user messages and installation paths, we use the original version
        $Version = $VersionWithLTS
        if ($HasLTS) {
            $Version += '-LTS'
        }
        if ($HasHSAdpt) {
            $Version += '-hs-adpt'
        }
    } else {
        Write-Error "Invalid Java version identifier. Please use the format <version>[-LTS][-hs-adpt] (e.g., 21.0.5+11-LTS, 23+37-hs-adpt, or 18.0.1)."
        return
    }

    # URL-encode the ApiVersion to handle special characters like '+'
    $EncodedApiVersion = [uri]::EscapeDataString("jdk-$ApiVersion")

    # Set parameters
    $OS = "windows"
    $Arch = "x64"
    $ImageType = "jdk"
    $JVMImpl = "hotspot"
    $HeapSize = "normal"
    $Vendor = "eclipse"

    # Construct the API URL with the encoded version
    $ApiUrl = "https://api.adoptium.net/v3/binary/version/$EncodedApiVersion/$OS/$Arch/$ImageType/$JVMImpl/$HeapSize/$Vendor"

    Write-Host "Downloading JDK from: $ApiUrl"

    # Prepare installation directory
    $InstallDirRoot = "$env:ProgramFiles\WinSDK\InstalledSDK\Java"
    if (-not (Test-Path $InstallDirRoot)) {
        New-Item -ItemType Directory -Path $InstallDirRoot | Out-Null
    }

    $InstallDir = "$InstallDirRoot\jdk-$Version"
    $ZipFile = "$InstallDirRoot\jdk-$Version.zip"

    try {
        # Download the binary data directly to the zip file
        Invoke-WebRequest -Uri $ApiUrl -OutFile $ZipFile -UseBasicParsing -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to download JDK: $_"
        return
    }

    Write-Host "Extracting JDK to $InstallDir..."

    try {
        # Load the necessary assembly for System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem

        # Create a temporary extraction directory
        $TempExtractPath = Join-Path $InstallDirRoot "temp_extraction"
        if (Test-Path $TempExtractPath) {
            Remove-Item -Path $TempExtractPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $TempExtractPath | Out-Null

        # Extract the zip file to the temporary directory
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $TempExtractPath)

        # Get the inner directory (e.g., 'jdk-21.0.5+11')
        $InnerDir = Get-ChildItem -Path $TempExtractPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1

        if ($null -eq $InnerDir) {
            Write-Error "Extraction failed: Inner directory not found."
            return
        }

        # Remove the installation directory if it exists
        if (Test-Path $InstallDir) {
            Remove-Item -Path $InstallDir -Recurse -Force
        }

        # Move the inner directory to the installation directory
        Move-Item -Path $InnerDir.FullName -Destination $InstallDir
    }
    catch {
        Write-Error "Failed to extract JDK: $_"
        return
    }

    # Remove the temporary extraction directory
    if (Test-Path $TempExtractPath) {
        Remove-Item -Path $TempExtractPath -Recurse -Force
    }

    # Remove the zip file
    Remove-Item $ZipFile -Force

    Write-Host "Setting JAVA_HOME environment variable. Making java-$Version as Default JDK."

    # Optionally, set this version as the current version
    Switch-Java -Version $Version
    Write-Host "JDK version $Version installed successfully."
    Write-Host "Please restart your terminal to apply the changes."
}
