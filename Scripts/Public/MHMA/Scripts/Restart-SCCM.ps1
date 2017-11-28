$Data = Get-ADComputer -Filter * -SearchBase "OU=Distribution Points,OU=SCCM,OU=MEMBER SERVERS,DC=prd,DC=eccocorp,DC=net"

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Servername",([string]))
$Col2 = New-Object System.Data.DataColumn("Status",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)

foreach ($server in $Data)
{	
	$row = $table.NewRow();
	
	if (Test-Connection $server.Name -BufferSize 16 -Count 2 -ea 0 -quiet)
	{
		$row.Servername = $server.Name
		Restart-Computer -ComputerName $server.Name -Force
		sleep -Seconds 10
		
		Do {$ping = Test-Connection $server.Name -BufferSize 16 -Count 2 -ea 0 -quiet}
		while ($ping -eq $false)
		
		$row.Status = "Success"
		$table.Rows.Add($row)
	}
	else
	{
		$row.Servername = $server.Name
		$row.Status = "Failed"
		$table.Rows.Add($row)
	}
}

$table | Export-Csv "C:\Test\SCCMRestart.csv" -NoTypeInformation