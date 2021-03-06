$Servers = Get-ADComputer -Filter * -SearchBase "OU=MEMBER SERVERS,DC=prd,DC=eccocorp,DC=net"

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Server",([string]))
$Col2 = New-Object System.Data.DataColumn("AdminGroup",([string]))
$Col3 = New-Object System.Data.DataColumn("PowerusersGroup",([string]))
$Col4 = New-Object System.Data.DataColumn("RemoteDesktopGroup",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)

foreach ($s in $Servers)
{
	$Admin = "Srv-" + $s.Name + "-Admin"
	$PU = "Srv-" + $s.Name + "-PowerUse"
	$RDU = "Srv-" + $s.Name + "-RemoteDesktop"
	
	$row = $table.NewRow()
	$row.Server = $s.Name
	
	try
	{
		$test = Get-ADGroup -Identity $Admin
		$row.AdminGroup = $test.Name
	}
	catch
	{
		$row.AdminGroup = "No Group"
	}
	try
	{
		$test1 = Get-ADGroup -Identity $PU
		$row.PowerusersGroup = $test1.Name
	}
	catch
	{
		$row.PowerusersGroup = "No Group"
	}
	try
	{
		$test2 = Get-ADGroup -Identity $RDU
		$row.RemoteDesktopGroup = $test2.Name
	}
	catch
	{
		$row.RemoteDesktopGroup = "No Group"
	}
	
	$table.Rows.Add($row)
}

$table | Export-Csv C:\Report\PowerUse.csv -NoTypeInformation