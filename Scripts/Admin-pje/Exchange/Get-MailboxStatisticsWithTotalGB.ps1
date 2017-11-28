$ErrorActionPreference = "Continue"

$users = Import-Csv C:\script\cloudarchive.csv
$out = "C:\Users\pje\Desktop\archivesize.csv"
$total = "" | Select DisplayName,TotalItemSize

$users | ForEach-Object {

 $user = Get-MailboxStatistics $_.PrimarySmtpAddress -Archive | select DisplayName,TotalItemSize

     if($user -ne $null)
     {
        $total.TotalItemSize += [Double]($user | select @{l='TotalItemSize';e={[Double](($_.TotalItemSize.Value -split '[\(]') -split '[a-zA-Z]+\w{4}\b\)' | ?{$_})[1]}}).TotalItemSize
        $user | Export-Csv $out -Encoding UTF8 -NoTypeInformation -Append
     }
}
 
$total.TotalItemSize = (Measure-Object -InputObject $total -Property TotalItemSize -Sum).Sum / 1GB -as [Int]
$total.DisplayName = "Total GB"
$total | Export-Csv $out -Append -Force
