$data = Get-VMHost -VMMServer "DKHQVMM02CR"
$children = New-Object System.Collections.ArrayList

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("VM",([string]))
$Col2 = New-Object System.Data.DataColumn("StartAction",([string]))
$Col3 = New-Object System.Data.DataColumn("StartDelay",([string]))
$Col4 = New-Object System.Data.DataColumn("IsDC",([string]))
$Col5 = New-Object System.Data.DataColumn("Host",([string]))
$Col6 = New-Object System.Data.DataColumn("Cluster",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)
$table.columns.add($Col5)
$table.columns.add($Col6)

foreach ($vmHost in $data)
{
	foreach ($vm in $vmHost.VMs)
	{
		$row = $table.NewRow();
		
		if($vm.Name -like "*DC*")
		{
			$row.VM = $vm.Name
			$row.StartAction = $vm.StartAction
			$row.StartDelay = $vm.DelayStart
			$row.IsDC = $true
			$row.Host = $vmHost.Name
			$row.Cluster = $vmHost.HostCluster
			$table.Rows.Add($row);
		}
		else
		{
			$row.VM = $vm.Name
			$row.StartAction = $vm.StartAction
			$row.StartDelay = $vm.DelayStart
			$row.IsDC = $false
			$row.Host = $vmHost.Name
			$row.Cluster = $vmHost.HostCluster
			$table.Rows.Add($row);
		}
	}
}

$table | Export-Csv C:\Report\VMGuestStartOptions.csv -NoTypeInformation -Encoding Unicode