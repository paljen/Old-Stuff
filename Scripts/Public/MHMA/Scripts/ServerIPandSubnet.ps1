$servers = Get-ADComputer -Filter * -SearchBase "OU=MEMBER SERVERS,DC=prd,DC=eccocorp,DC=net" | where {$_.Name -like "CNFACVM06N01" -or $_.Name -like "CNFACVM06N02" -or $_.Name -like "IDFACVM01N01" -or $_.Name -like "IDFACVM01N02" -or $_.Name -like "NLTANVM01N01" -or $_.Name -like "NLTANVM01N02" -or $_.Name -like "THFACVM02N01" -or $_.Name -like "THFACVM02N02"}

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Server",([string]))
$Col2 = New-Object System.Data.DataColumn("IP",([string]))
$Col3 = New-Object System.Data.DataColumn("SN",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)

foreach ($s in $servers)
{
	$row = $table.NewRow();
	
	try
	{
		$IPObj = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $s.Name | ? {$_.IPEnabled} 
		$IPAdr = $IPObj.IPAddress[0]
		$IPSn = $IPObj.IPSubnet[0]
		
		$row.Server = $s.Name
		$row.IP = $IPAdr
		$row.SN = $IPSn
	}
	catch
	{
		$row.Server = $s.Name
		$row.IP = "ERROR"
		$row.SN = "ERROR"
	}
	
	$table.Rows.Add($row);
}

$table | Export-Csv C:\Report\ServerIPandSN1.csv -NoTypeInformation -Encoding Unicode