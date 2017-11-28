#To export information about all connections in the last thirty days to a csv-file for further processing: 
$now = Get-Date
$start = $now.adddays(-1)
$path = split-path -parent $MyInvocation.MyCommand.Definition

    
Get-DAMultiSite -ComputerName DKHQDA01N02 | ForEach-Object { 
    $_.DaEntryPoints.Servers } | ForEach-Object {   
        Get-RemoteAccessConnectionStatistics -ComputerName $_ -StartDateTime $start -EndDateTime ([DateTime]::Now) 
       } | Select * | Export-Csv "$path\DAReport.csv" -NoTypeInformation -Encoding "UTF8" 
#>
       
Get-DAMultiSite -ComputerName DKHQDA01N02 | ForEach-Object { 
    $_.DaEntryPoints.Servers } | ForEach-Object {   
        Get-RemoteAccessConnectionStatisticsSummary -ComputerName $_ -StartDateTime $start -EndDateTime ([DateTime]::Now) 
       } | Select * #| Export-Csv "$path\DAReport.csv" -NoTypeInformation -Encoding "UTF8" 
