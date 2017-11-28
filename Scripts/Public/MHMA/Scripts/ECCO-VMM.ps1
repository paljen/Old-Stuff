#$clusterNode = Read-Host
function Get-GuestStorageStatus ($clusterNode = $null)
{

	$table = New-Object System.Data.DataTable
	$Col1 = New-Object System.Data.DataColumn("VM",([string]))
	$Col2 = New-Object System.Data.DataColumn("Host",([string]))
	$Col3 = New-Object System.Data.DataColumn("VHD-on-CSV",([string]))
	$Col4 = New-Object System.Data.DataColumn("Local-C",([string]))
	$table.columns.add($Col1)
	$table.columns.add($Col2)
	$table.columns.add($Col3)
	$table.columns.add($Col4)
	
	$output = New-Object PSObject
	
	if ($clusterNode -eq $null)
	{
		$data = Get-SCVMHostGroup
	}
	else
	{
		$data = Get-SCVMHostGroup $clusterNode
	}
	
	foreach ($obj in $data.AllChildHosts)
	{
		foreach ($vm in $obj.VMs)
		{
			foreach ($vhd in $vm.VirtualHardDisks)
			{
				$VMName = $vm.Name
				$cDrive = "\\"+$VMName+"\c$"
				
				$partialPaths = $vhd.Location.Split(":")
				$path = "\\"+$vm.HostName+"\c$"+$partialPaths[1]
				
				[bool]$vhdReach = Test-Path $path
				[bool]$cReach = Test-Path $cDrive
				
				$row = $table.NewRow();
				$row.VM = $vm.Name	
				$row.Host = $vm.HostName
				$row.VHD-on-CSV = $vhdReach	
				$row.Local-C = $cReach
				$table.Rows.Add($row)
			}
		}
	}
	
	$table
}