$VMReport = Get-SCVMHost

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("VM",([string]))
$Col2 = New-Object System.Data.DataColumn("vCPU",([string]))
$Col3 = New-Object System.Data.DataColumn("VMHostServer",([string]))
$Col4 = New-Object System.Data.DataColumn("ClusterName",([string]))
$Col5 = New-Object System.Data.DataColumn("PhysicalCPU",([string]))
$Col6 = New-Object System.Data.DataColumn("CPUCores",([string]))
$Col7 = New-Object System.Data.DataColumn("TotalLogicalCPUs",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)
$table.columns.add($Col5)
$table.columns.add($Col6)
$table.columns.add($Col7)

foreach ($vm in $VMReport)
{
	$CPUinfo = gwmi -ComputerName $vm.Name win32_processor -Property "NumberOfCores"
	$CoreCount = $null
	
	foreach ($c in $CPUinfo)
	{
		$CoreCount = $c.NumberOfCores
	}
	
	foreach ($guest in $vm.VMs)
	{
		$row = $table.NewRow();
		$row.VM = $guest.Name
		$row.vCPU = $guest.CPUCount
		$row.VMHostServer = $vm.Name	
		$row.ClusterName = $vm.HostCluster
		$row.PhysicalCPU = $vm.PhysicalCPUCount
		$row.CPUCores = $CoreCount
		$row.TotalLogicalCPUs = $vm.LogicalProcessorCount
		$table.Rows.Add($row)
	}
	
	$CPUinfo = $null
}

$table | Export-Csv "C:\Toolbox\Reporting\VMReport.csv" -NoTypeInformation