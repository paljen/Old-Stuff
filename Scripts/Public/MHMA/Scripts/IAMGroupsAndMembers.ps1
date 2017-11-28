$Data = Get-ADGroup -Filter * -SearchBase "OU=DK,OU=ECCO,DC=prd,DC=eccocorp,DC=net" -Properties "Description" | where {$_.DistinguishedName -notlike "CN=SECL*" -or $_.GroupScope -ne "DomainLocal"}

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Group",([string]))
$Col2 = New-Object System.Data.DataColumn("Desc",([string]))
$Col3 = New-Object System.Data.DataColumn("Member",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)

foreach ($d in $Data)
{
	$Members = Get-ADGroupMember $d
	
	foreach ($m in $Members)
	{
		$row = $table.NewRow();
		$row.Member = $m.Name
		$row.Desc = $d.Description
		$row.Group = $d.Name
		$table.Rows.Add($row);
	}
}

$table | Export-Csv "C:\Report\ADGroupMembers.csv" -NoTypeInformation