function List-Java {
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
        } else {
            $VendorDisplay = "".PadRight(14)
        }

        $line = "{0} | {1,-3} | {2,-16} | {3,-7} | {4,-10} | {5}" -f `
            $VendorDisplay, `
            $version.Use, `
            $version.Version, `
            $version.Distribution, `
            $version.Status, `
            $version.Identifier

        Write-Host $line
    }

    Write-Host "==============================================================================="

    Write-Host ""
    Write-Host "Use the Identifier for installation:"
    Write-Host ""
    Write-Host "    winsdk install java <Identifier>"
}
