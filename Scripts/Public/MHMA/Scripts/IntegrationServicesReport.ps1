$data = Get-VM | select name, VMAddition, operatingsystem

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("VM",([string]))
$Col2 = New-Object System.Data.DataColumn("ISV",([string]))
$Col3 = New-Object System.Data.DataColumn("OS",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)

foreach ($vm in $data)
{
	$row = $table.NewRow();
	$row.VM = $vm.Name
	$row.ISV = $vm.VMAddition
	$row.OS = $vm.operatingsystem
	$table.Rows.Add($row)
}

$table | Export-Csv "C:\Toolbox\Reports\IntegrationServices.csv" -NoTypeInformation