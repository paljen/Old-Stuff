Import-Module RemoteDesktopServices
Import-Module ActiveDirectory
cd RDS:
cd GatewayServer
cd RAP
$RAPS = Get-ChildItem

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("UserName",([string]))
$Col2 = New-Object System.Data.DataColumn("Collection",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)

foreach ($r in $RAPS)
{
	cd $r.Name
	cd UserGroups
	$Grps = Get-ChildItem | select Name
	
	foreach ($g in $Grps)
	{
		$GroupName = $g.Name.trimend("@PRD")
		$ADusers = Get-ADGroup -Identity $GroupName | Get-ADGroupMember -Recursive
		
		foreach ($a in $ADusers)
		{
			$row = $table.NewRow();
			$row.UserName = $a.SamAccountName
			$row.Collection = $r.Name
			$table.Rows.Add($row);
		}
	}
	
	cd..
	cd..
}

$table | Export-Csv C:\Report\RDS2008Users.csv -NoTypeInformation -Encoding utf8