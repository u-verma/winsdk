function Show-AvailableJava {
    # Path to the installed Java directory
    $JavaInstallDir = "C:\Program Files\WinSDK\InstalledSDK\Java"

    # Get installed Java versions
    $InstalledVersions = @()
    if (Test-Path $JavaInstallDir) {
        $InstalledVersions = Get-ChildItem -Path $JavaInstallDir -Directory | ForEach-Object {
            $_.Name -replace "jdk-", ""
        }
    }

    # Fetch available versions
    $AvailableVersions = Get-AvailableJavaVersions

    if ($AvailableVersions.Count -eq 0) {
        Write-Host "No Java versions are available for installation."
        return
    }

    # Prepare the header
    $header = @"
===============================================================================
Available Java Versions
===============================================================================
 Vendor        | Use | Version          | Dist    | Status     | Identifier
-------------------------------------------------------------------------------
"@

    Write-Host $header

    $Vendor = ""
    foreach ($version in $AvailableVersions) {
        # Only display Vendor name when it changes
        if ($Vendor -ne $version.Vendor) {
            $Vendor = $version.Vendor
            $VendorDisplay = $Vendor.PadRight(14)
        }
        else {
            $VendorDisplay = "".PadRight(14)
        }

        # Check if this version is installed
        $IsInstalled = $InstalledVersions -contains $version.Identifier
        $InstallMarker = if ($IsInstalled) { " <<".PadRight(10) } else { "".PadRight(10) }

        # Format the output line
        $line = "{0} | {1,-3} | {2,-16} | {3,-7} | {4,-10} | {5}{6}" -f `
            $VendorDisplay, `
            $version.Use, `
            $version.Version, `
            $version.Distribution, `
            $version.Status, `
            $version.Identifier, `
            $InstallMarker

        # Write the line with a visual indicator for installed versions
        if ($IsInstalled) {
            Write-Host $line -ForegroundColor Green
        }
        else {
            Write-Host $line
        }
    }

    Write-Host "==============================================================================="

    Write-Host ""
    Write-Host "Use the Identifier for installation: The green marker indicates already installed versions."
    Write-Host ""
    Write-Host "    winsdk install java <Identifier>" -ForegroundColor Green
    Write-Host ""
    Write-Host "if want to switch to a different version of Installed Version, use the following command:"
    Write-Host ""
    Write-Host "    winsdk use java <Identifier>" -ForegroundColor Green
}
