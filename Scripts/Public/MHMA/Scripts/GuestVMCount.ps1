$data = Import-Csv C:\Import\VMPatching.csv

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Guest",([string]))
$Col2 = New-Object System.Data.DataColumn("Host",([string]))
$Col3 = New-Object System.Data.DataColumn("VMCount",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)

foreach ($s in $data)
{
	$obj = Get-SCVMHost $s.server -VMMServer "DKHQVMM02CR"
	
	foreach ($vm in $obj.VMs)
	{
		$row = $table.NewRow();
		$row.Guest = $vm.Name
		$row.Host = $obj.Name
		$row.VMCount = $obj.VMs.Count
		$table.Rows.Add($row);
	}
}

$table | Export-Csv "C:\Report\VMPatching.csv" -NoTypeInformation -Encoding Unicode