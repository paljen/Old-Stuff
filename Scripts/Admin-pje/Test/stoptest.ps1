while ($true) {

    $host.UI.RawUI.ReadKey()
    Write-Output "test"
    Start-Sleep 2
    if ($Host.UI.RawUI.KeyAvailable -and ("q" -eq $Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character)) {
        Write-Host "Exit" -Background DarkRed
        break;
    }
}