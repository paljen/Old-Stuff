$data = Get-ADUser -Properties "departmentNumber"

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("departmentNumber",([string]))
$table.columns.add($Col1)

foreach ($obj in $data)
{
	foreach ($dept in $obj.departmentNumber)
	{
		$row = $table.NewRow();
		$row.departmentNumber = $dept
		$table.Rows.Add($row)
	}
}

$table | Export-Csv "C:\Test\costcenter.csv" -NoTypeInformation