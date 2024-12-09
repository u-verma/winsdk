
function Show-Help {
    [CmdletBinding()]
    param ()

    Write-Host "WinSDK Management Tool" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available Commands:"
    Write-Host "  install <sdk> <version>     Installs the specified SDK and version."
    Write-Host "  use <sdk> <version>         Switches to the specified SDK version."
    Write-Host "  list <sdk>                  Lists available versions of the SDK."
    Write-Host "  current <sdk>               Displays the current version of the SDK in use."
    Write-Host "  uninstall <sdk> <version>   Uninstalls the specified version of the SDK."
    Write-Host "  update winsdk               Updates WinSDK to the latest version."
    Write-Host "  --help                      Displays this help message."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  winsdk install java 17"
    Write-Host "  winsdk uninstall winsdk"
    Write-Host "  winsdk --help"
}