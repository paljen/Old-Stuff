$data = Get-ADComputer -filter * -SearchBase "OU=ECCO,DC=prd,DC=eccocorp,DC=net" -Properties "whenChanged"

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Computer",([string]))
$Col2 = New-Object System.Data.DataColumn("DaysSinceLastContact",([string]))
$Col3 = New-Object System.Data.DataColumn("whenChanged",([string]))
$Col4 = New-Object System.Data.DataColumn("Enabled",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)

$now = Get-Date

foreach ($obj in $data)
{
	$Diff = $null
	if ($obj.Name.Length -le 7)
	{
		$Diff = New-TimeSpan -Start $obj.whenChanged -End $now
			
		if ($Diff.Days -ge 90)
		{
			$row = $table.NewRow();
			$row.Computer = $obj.Name
			$row.DaysSinceLastContact = $Diff.Days
			$row.whenChanged = $obj.whenChanged
			$row.Enabled = $obj.Enabled
			$table.Rows.Add($row)
		}
	}
}

$table | Export-Csv "C:\Test\TBD90.csv" -NoTypeInformation