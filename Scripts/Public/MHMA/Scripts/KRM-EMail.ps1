$Data = Import-Csv C:\Import\KRM.csv

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Name",([string]))
$Col2 = New-Object System.Data.DataColumn("Alias",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)

foreach ($obj in $Data)
{
	$MLBX = Get-Mailbox $obj.Identity
	
	if ($MLBX -ne $null)
	{
		$row = $table.NewRow();
		$row.Name = $MLBX.Name
		$row.Alias = $MLBX.PrimarySmtpAddress
		$table.Rows.Add($row)
		
		$MLBX = $null
	}
}

$table | Export-Csv "C:\Test\KRM.csv" -NoTypeInformation