<#
.SYNOPSIS
Updates WinSDK to the latest version from the GitHub repository.

.DESCRIPTION
The Update-WinSDK function updates the WinSDK files and preserves the existing installed SDKs.

.EXAMPLE
Update-WinSDK
Updates the WinSDK to the latest version.
#>

function Update-WinSDK {
    [CmdletBinding()]
    param ()

    Write-Host "Starting WinSDK update process..."

    # Variables
    $InstallDir = "C:\Program Files\WinSDK"
    $RepoZipUrl = "https://github.com/u-verma/winsdk/archive/refs/heads/main.zip"
    $TempZip = "$env:TEMP\winsdk.zip"
    $TempExtractDir = "$env:TEMP\winsdk-update"

    try {
        # Download the latest version of WinSDK
        Write-Host "Downloading the latest version of WinSDK..."
        Invoke-WebRequest -Uri $RepoZipUrl -OutFile $TempZip -UseBasicParsing

        # Extract the repository to a temporary directory
        Write-Host "Extracting the downloaded WinSDK archive..."
        if (Test-Path $TempExtractDir) {
            Remove-Item -Recurse -Force -Path $TempExtractDir
        }
        Expand-Archive -Path $TempZip -DestinationPath $TempExtractDir -Force

        # Locate the extracted folder
        $ExtractedFolder = Get-ChildItem -Path $TempExtractDir -Directory | Where-Object { $_.Name -like "winsdk-*" } | Select-Object -First 1
        if (-not $ExtractedFolder) {
            Write-Error "Failed to locate the extracted WinSDK folder."
            throw "Extraction error: Folder not found."
        }

        # Copy updated files into the existing WinSDK directory
        Write-Host "Updating WinSDK files in $InstallDir..."
        $SourceDir = $ExtractedFolder.FullName
        Get-ChildItem -Path $SourceDir -Recurse | ForEach-Object {
            $DestinationPath = Join-Path $InstallDir ($_.FullName.Substring($SourceDir.Length).TrimStart('\'))
            if ($_.PSIsContainer) {
                if (-not (Test-Path $DestinationPath)) {
                    New-Item -ItemType Directory -Path $DestinationPath | Out-Null
                }
            }
            else {
                Copy-Item -Path $_.FullName -Destination $DestinationPath -Force
            }
        }

        # Clean up temporary files
        Write-Host "Cleaning up temporary files..."
        Remove-Item $TempZip -Force
        Remove-Item -Recurse -Force -Path $TempExtractDir

        Write-Host "WinSDK has been updated successfully."
        Write-Host "Please close and reopen your command prompt or PowerShell to start using the updated 'winsdk' command."
    }
    catch {
        Write-Error "An error occurred during the WinSDK update process: $_"

        # Cleanup on failure
        if (Test-Path $TempZip) {
            Remove-Item $TempZip -Force
        }
        if (Test-Path $TempExtractDir) {
            Remove-Item -Recurse -Force -Path $TempExtractDir
        }
    }
}
