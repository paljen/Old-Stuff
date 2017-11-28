Get-DAMultiSite -ComputerName DKHQDA01N01 | ForEach-Object { 
    $_.DaEntryPoints.Servers }