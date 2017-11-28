
#DKHQDA01N01,DKHQDA01N02, DKHQDA01N03, DKHQDA01N04

#To export information about all connections in the last thirty days to a csv-file for further processing:
$now = Get-Date
$start = $now.AddDays(-1)

<#
Get-DAMultiSite -ComputerName DKHQDA01N02 | ForEach-Object { 
    $_.DaEntryPoints.Servers } | ForEach-Object {   
        Get-RemoteAccessConnectionStatistics -ComputerName $_ -StartDateTime $start -EndDateTime ([DateTime]::Now) 
       } | Select * #| Export-Csv c:\temp\file.csv -NoTypeInformation -Encoding "UTF8" 
#>


#To retrieve the total number of megabytes of data transferred through the Direct Access deployment since its installation:
$bytes = 0
Get-DAMultiSite -ComputerName DKHQDA01N02 | % { $_.DaEntryPoints.Servers } | % { Get-RemoteAccessConnectionStatistics -ComputerName $_ -EndDateTime ([DateTime]::Now) | % { $bytes+= $_.TotalBytesIn + $_.TotalBytesOut }
   }

$bytes/1MB 
