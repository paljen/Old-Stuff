$old = Get-ADGroupMember "SEC-Global DirectAccess Clients"
$Win7 = Get-ADGroup "SEC-Global DirectAccess HQ Access Win7 Clients"
$Win8 = Get-ADGroup "SEC-Global DirectAccess Win8 Clients"

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("SAM",([string]))
$Col2 = New-Object System.Data.DataColumn("objectClass",([string]))
$Col3 = New-Object System.Data.DataColumn("OldCluster",([string]))
$Col4 = New-Object System.Data.DataColumn("Win7Cluster",([string]))
$Col5 = New-Object System.Data.DataColumn("Win8Cluster",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)
$table.columns.add($Col5)

foreach ($obj in $old)
{
	if ($obj.objectClass -like "computer")
	{
		$CompObj = Get-ADComputer $obj -Properties MemberOf
		$row = $table.NewRow();
		$row.SAM = $obj.SamAccountName
		$row.objectClass = $obj.objectClass
		$row.OldCluster = "*"
		
		if ($CompObj.MemberOf -like $Win7.DistinguishedName)
		{
			$row.Win7Cluster = "*"
		}
		
		if ($CompObj.MemberOf -like $Win8.DistinguishedName)
		{
			$row.Win8Cluster = "*"
		}
		
		$table.Rows.Add($row)
	}
	
	if ($obj.objectClass -like "user")
	{
		$UserObj = Get-ADUser $obj -Properties MemberOf
		$row = $table.NewRow();
		$row.SAM = $obj.SamAccountName
		$row.objectClass = $obj.objectClass
		$row.OldCluster = "*"
		
		if ($UserObj.MemberOf -like $Win7.DistinguishedName)
		{
			$row.Win7Cluster = "*"
		}
		
		if ($UserObj.MemberOf -like $Win8.DistinguishedName)
		{
			$row.Win8Cluster = "*"
		}
		
		$table.Rows.Add($row)
	}
}

$table | Export-Csv "C:\Report\DirectAccessMemberships.csv" -NoTypeInformation