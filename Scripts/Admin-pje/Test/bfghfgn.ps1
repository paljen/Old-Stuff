



Write-Host Press Ctrl-Q to Quit

do {
    write-host "test"
    Start-sleep 5

    $key = if ($host.UI.RawUI.KeyAvailable) {
    $host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown')

    

 }

} until ($key.VirtualKeyCode -eq 81 -and 

          $key.ControlKeyState -cmatch '^(Right|Left)CtrlPressed$')



 
       