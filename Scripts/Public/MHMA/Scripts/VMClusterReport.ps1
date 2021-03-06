$VMReport = Get-SCVMHost

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("VMHostServer",([string]))
$Col2 = New-Object System.Data.DataColumn("ClusterName",([string]))
$Col3 = New-Object System.Data.DataColumn("PhysicalCPU",([string]))
$Col4 = New-Object System.Data.DataColumn("CPUCores",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)

foreach ($vm in $VMReport)
{
	$CPUinfo = gwmi -ComputerName $vm.Name win32_processor -Property "NumberOfCores"
	$CoreCount = $null
	
	foreach ($c in $CPUinfo)
	{
		$CoreCount = $c.NumberOfCores
	}
	$row = $table.NewRow()
	$row.VMHostServer = $vm.Name	
	$row.ClusterName = $vm.HostCluster
	$row.PhysicalCPU = $vm.PhysicalCPUCount
	$row.CPUCores = $CoreCount
	$table.Rows.Add($row)
	
	$CPUinfo = $null
}

$table | Export-Csv "C:\Toolbox\Reporting\VMClusterReport.csv" -NoTypeInformation