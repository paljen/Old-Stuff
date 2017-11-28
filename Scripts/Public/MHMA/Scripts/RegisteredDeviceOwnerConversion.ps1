$Data = Get-ADObject -filter * -SearchBase "CN=RegisteredDevices,DC=prd,DC=eccocorp,DC=net" -Properties "msDS-RegisteredOwner", "DisplayName"

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("DisplayName",([string]))
$Col2 = New-Object System.Data.DataColumn("TransSID",([string]))
$Col3 = New-Object System.Data.DataColumn("SID",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)

foreach ($obj in $Data)
{
	for($i=0;$i -lt $obj."msDS-RegisteredOwner".count; $i++)
    {
        $sidString = $sidString + [char]$obj."msDS-RegisteredOwner"[$i]
    }
	
	$objSID = New-Object System.Security.Principal.SecurityIdentifier($sidString)
	$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
		
	$row = $table.NewRow();
	$row.DisplayName = $obj.DisplayName
	$row.SID = $sidString
	$row.TransSID = $objUser.Value
	$table.Rows.Add($row)
	
	$objSID = $null
	$objUser = $null
	$sidString = $null
}

$table | Export-Csv "C:\Report\RegisteredOwner.csv" -NoTypeInformation