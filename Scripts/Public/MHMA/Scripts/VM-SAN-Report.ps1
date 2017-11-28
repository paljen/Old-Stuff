$VMReport = Get-SCVMHost

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("VMHostServer",([string]))
$Col2 = New-Object System.Data.DataColumn("ClusterName",([string]))
$Col3 = New-Object System.Data.DataColumn("VM",([string]))
$Col4 = New-Object System.Data.DataColumn("SANRessource",([string]))
$Col5 = New-Object System.Data.DataColumn("Classification",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)
$table.columns.add($Col5)

foreach ($vm in $VMReport)
{
	foreach ($guest in $vm.VMs)
	{
		$disks = Get-SCVirtualHardDisk -vm $guest.Name
		
		foreach ($obj in $disks)
		{
			$row = $table.NewRow();
			$row.VMHostServer = $vm.Name	
			$row.ClusterName = $vm.HostCluster
			$row.VM = $guest.Name
			$row.SANRessource = $obj.HostVolume
			$row.Classification = $obj.Classification
			$table.Rows.Add($row)
		}
	}
}

$table | Export-Csv "C:\Toolbox\Reporting\VMReport.csv" -NoTypeInformation