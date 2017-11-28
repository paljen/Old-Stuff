

$Computername = $env:COMPUTERNAME
$Path = "\\10.129.12.64\ClientLogs$"
$2Path = "C:\TEMP"
$log1 = "C:\Temp\TraceLog.log"
$log2 = "C:\Temp\Resultlog.log"

if (!(Test-Path -Path "$Path\$Computername"))
{ 
    $(New-Item -Path $Path -ItemType Directory -Name $Computername -ErrorAction SilentlyContinue)
    Copy-Item $log1 "$Path\$Computername" -Force
    Copy-Item $log2 "$Path\$Computername" -Force
}
    
    


