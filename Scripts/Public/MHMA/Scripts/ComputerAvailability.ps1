$data = Import-Csv C:\Import\SCCMTestComputers.csv

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Computer",([string]))
$Col2 = New-Object System.Data.DataColumn("Reachable",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)

foreach ($d in $data)
{
	$ConTest = Test-Connection -ComputerName $d.Computer -Count 1 -Quiet
	$row = $table.NewRow();
	$row.Computer = $d.Computer
	$row.Reachable = $ConTest
	$table.Rows.Add($row);
}

$table | Export-Csv "C:\Report\AreTestComputersReachable.csv" -NoTypeInformation