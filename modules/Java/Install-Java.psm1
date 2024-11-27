function Install-Java {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    # Ensure administrator privileges
    Ensure-Administrator

    $JavaInstallDir = Get-InstallDirectory -SDKName 'Java'
    $JavaVersionDir = "$JavaInstallDir\jdk-$Version"

    if (Test-Path $JavaVersionDir) {
        Write-Host "Java version $Version is already installed."
        return
    }

    # Get download URL
    $DownloadUrl = Get-JavaDownloadUrl -Version $Version
    if (-not $DownloadUrl) {
        Write-Error "Failed to get download URL for Java version $Version."
        return
    }

    # Download and install
    $TempZip = "$env:TEMP\jdk-$Version.zip"
    Write-Host "Downloading Java $Version..."
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempZip -UseBasicParsing

    Write-Host "Installing Java $Version..."
    Expand-Archive -Path $TempZip -DestinationPath $JavaInstallDir -Force

    # Rename extracted folder if necessary
    $ExtractedDir = Get-ChildItem -Path $JavaInstallDir -Directory | Where-Object { $_.Name -match "jdk-*$Version*" } | Select-Object -First 1
    if ($ExtractedDir -and ($ExtractedDir.Name -ne "jdk-$Version")) {
        Rename-Item -Path $ExtractedDir.FullName -NewName "jdk-$Version"
    }

    Remove-Item $TempZip -Force

    Write-Host "Java $Version installed successfully."
}
