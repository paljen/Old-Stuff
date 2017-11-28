$serv = Import-Csv C:\Import\NLTAN.csv

foreach ($s in $serv)
{
	$netadapter = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'" -ComputerName $s.server
	
	Write-Output $s.server
	$netadapter.DNSServerSearchOrder
	Write-Output " "
}