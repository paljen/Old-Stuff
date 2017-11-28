#Script Path
    $ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
    Write-host "$($ScriptPath)\scorch\scorch.psd1)"