$data = Get-ADUser -filter * -SearchBase "OU=EXTERNALS,DC=prd,DC=eccocorp,DC=net" -Properties "EmailAddress","whenChanged"

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Username",([string]))
$Col2 = New-Object System.Data.DataColumn("Email",([string]))
$Col3 = New-Object System.Data.DataColumn("whenChanged",([string]))
$Col4 = New-Object System.Data.DataColumn("Enabled",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)

foreach ($obj in $data)
{
	if ($obj.EmailAddress -notlike "*@ecco.com")
	{
		$row = $table.NewRow();
		$row.Username = $obj.SamAccountName
		$row.Email = $obj.EmailAddress
		$row.whenChanged = $obj.whenChanged
		$row.Enabled = $obj.Enabled
		$table.Rows.Add($row);
	}
}

$table | Export-Csv "C:\Test\ExternalsIngenECCOMail.csv" -NoTypeInformation