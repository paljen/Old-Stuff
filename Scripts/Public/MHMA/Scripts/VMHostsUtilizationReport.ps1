$Hosts = Import-Csv C:\Import\VMHostsCompounded.csv #Get-ADComputer -SearchBase "OU=Virtualization,OU=MEMBER SERVERS,DC=prd,DC=eccocorp,DC=net" -Filter * -Properties "Description" | where{$_.Description -notlike "Failover cluster virtual network name account"} | Select Name

#Build datatable
$CPUtable = New-Object System.Data.DataTable
$Memtable = New-Object System.Data.DataTable
$Storagetable = New-Object System.Data.DataTable
$CSVtable = New-Object System.Data.DataTable
#CPU Bracket
$Col0 = New-Object System.Data.DataColumn("VMHostServer",([string]))
$Col1 = New-Object System.Data.DataColumn("ServerModel",([string]))
$Col2 = New-Object System.Data.DataColumn("ClusterName",([string]))
$Col3 = New-Object System.Data.DataColumn("CPUNumber",([string]))
$Col4 = New-Object System.Data.DataColumn("PhysicalCores",([string]))
$Col5 = New-Object System.Data.DataColumn("LogicalCores",([string]))
$Col6 = New-Object System.Data.DataColumn("CPULoadPct",([string]))
#Memory Bracket
$Col7 = New-Object System.Data.DataColumn("VMHostServer",([string]))
$Col8 = New-Object System.Data.DataColumn("ServerModel",([string]))
$Col9 = New-Object System.Data.DataColumn("ClusterName",([string]))
$Col10 = New-Object System.Data.DataColumn("MemTotal",([string]))
$Col11 = New-Object System.Data.DataColumn("MemFree",([string]))
$Col12 = New-Object System.Data.DataColumn("MemUsagePct",([string]))
#Local Storage Bracket
$Col13 = New-Object System.Data.DataColumn("VMHostServer",([string]))
$Col14 = New-Object System.Data.DataColumn("ServerModel",([string]))
$Col15 = New-Object System.Data.DataColumn("ClusterName",([string]))
$Col16 = New-Object System.Data.DataColumn("DriveLetter",([string]))
$Col17 = New-Object System.Data.DataColumn("VolumeLabel",([string]))
$Col18 = New-Object System.Data.DataColumn("Size",([string]))
$Col19 = New-Object System.Data.DataColumn("FreeSpace",([string]))
$Col20 = New-Object System.Data.DataColumn("FreeSpacePct",([string]))
#Remote Storage Bracket
$Col21 = New-Object System.Data.DataColumn("VMHostServer",([string]))
$Col22 = New-Object System.Data.DataColumn("ServerModel",([string]))
$Col23 = New-Object System.Data.DataColumn("ClusterName",([string]))
$Col24 = New-Object System.Data.DataColumn("VolumeLabel",([string]))
$Col25 = New-Object System.Data.DataColumn("Size",([string]))
$Col26 = New-Object System.Data.DataColumn("FreeSpace",([string]))
$Col27 = New-Object System.Data.DataColumn("FreeSpacePct",([string]))

#CPU Table
$CPUtable.columns.add($Col0)
$CPUtable.columns.add($Col1)
$CPUtable.columns.add($Col2)
$CPUtable.columns.add($Col3)
$CPUtable.columns.add($Col4)
$CPUtable.columns.add($Col5)
$CPUtable.columns.add($Col6)
#Memory Table
$Memtable.columns.add($Col7)
$Memtable.columns.add($Col8)
$Memtable.columns.add($Col9)
$Memtable.columns.add($Col10)
$Memtable.columns.add($Col11)
$Memtable.columns.add($Col12)
#Local Storage Table
$Storagetable.columns.add($Col13)
$Storagetable.columns.add($Col14)
$Storagetable.columns.add($Col15)
$Storagetable.columns.add($Col16)
$Storagetable.columns.add($Col17)
$Storagetable.columns.add($Col18)
$Storagetable.columns.add($Col19)
$Storagetable.columns.add($Col20)
#Remote Storage Table
$CSVtable.columns.add($Col21)
$CSVtable.columns.add($Col22)
$CSVtable.columns.add($Col23)
$CSVtable.columns.add($Col24)
$CSVtable.columns.add($Col25)
$CSVtable.columns.add($Col26)
$CSVtable.columns.add($Col27)

foreach ($h in $Hosts)
{
	#Reset Variables
	$Mem = $null
	$DiskInfo = $null
	$CPU = $null
	$CSV = $null
	$failover = $null
	
	#Gather Data
	$Mem = gwmi -Class Win32_OperatingSystem -Namespace root/cimv2 -ComputerName $h.Name | Select-Object @{Name="Total";Expression={"{0:N0}" -f($_.TotalVisibleMemorySize/1MB)}},@{Name="Free";Expression={"{0:N0}" -f($_.FreePhysicalMemory/1MB)}},@{Name="MemUsagePct";Expression={"{0:N0}" -f(($_.FreePhysicalMemory/$_.TotalVisibleMemorySize)*100)}}
	$DiskInfo = gwmi -Class Win32_LogicalDisk -ComputerName $h.Name | Select Name,VolumeName,@{Name="Size";Expression={"{0:N1}" -f($_.size/1gb)}},@{Name="FreeSpace";Expression={"{0:N1}" -f($_.freespace/1gb)}},@{Name="FreeSpacePct";Expression={"{0:N0}" -f(($_.FreeSpace/$_.Size)*100)}}
	$CPU = gwmi -Class Win32_Processor -ComputerName $h.Name | Select SocketDesignation,NumberOfCores,NumberOfLogicalProcessors,LoadPercentage
	$Model = gwmi -ComputerName $h.Name Win32_ComputerSystem | Select Model
	
	#Check for Failover Clustering
	$Check = CheckFeature $h.Name
	if ($Check -eq $true)
	{
		$CSV = gwmi -Namespace "root\MSCluster" -class "MSCluster_DiskPartition" -ComputerName $h.Name | Select VolumeLabel,@{Name="TotalSize";Expression={"{0:N1}" -f($_.TotalSize/1kb)}},@{Name="FreeSpace";Expression={"{0:N1}" -f($_.FreeSpace/1kb)}},@{Name="FreeSpacePct";Expression={"{0:N0}" -f(($_.FreeSpace/$_.TotalSize)*100)}}
		$ClusterName = $h.Name.Substring(0, $h.Name.Length - 3);
	}
	else
	{
		$ClusterName = "NA"
	}
	
	#Populate Tables
	
	#CPU
	foreach ($c in $CPU)
	{
		$row = $CPUtable.NewRow();
		$row.VMHostServer = $h.Name
		$row.ServerModel = $Model.Model
		$row.ClusterName = $ClusterName
		$row.CPUNumber = $c.SocketDesignation
		$row.PhysicalCores = $c.NumberOfCores
		$row.LogicalCores = $c.NumberOfLogicalProcessors
		$row.CPULoadPct = $c.LoadPercentage
		$CPUtable.Rows.Add($row);
	}
	
	#Local Storage
	Foreach ($d in $DiskInfo)
	{
		$row = $Storagetable.NewRow();
		$row.VMHostServer = $h.Name
		$row.ServerModel = $Model.Model
		$row.ClusterName = $ClusterName
		$row.DriveLetter = $d.Name
		$row.VolumeLabel = $d.VolumeName
		$row.Size = $d.Size
		$row.FreeSpace = $d.FreeSpace
		$row.FreeSpacePct = $d.FreeSpacePct
		$Storagetable.Rows.Add($row);
	}
	
	#Remote Storage
	if ($Check -eq $true)
	{
		Foreach ($shared in $CSV)
		{
			$row = $CSVtable.NewRow();
			$row.VMHostServer = $h.Name
			$row.ServerModel = $Model.Model
			$row.ClusterName = $ClusterName
			$row.VolumeLabel = $shared.VolumeLabel
			$row.Size = $shared.TotalSize
			$row.FreeSpace = $shared.FreeSpace
			$row.FreeSpacePct = $shared.FreeSpacePct
			$CSVtable.Rows.Add($row);
		}
	}
	
	#Memory
	$row = $Memtable.NewRow();
	$row.VMHostServer = $h.Name
	$row.ServerModel = $Model.Model
	$row.ClusterName = $ClusterName
	$row.MemTotal = $Mem.Total
	$row.MemFree = $Mem.Free
	$row.MemUsagePct = $Mem.MemUsagePct
	$Memtable.Rows.Add($row);
}

Function CheckFeature([string]$ComputerName)
{
	$Check = Get-WindowsFeature Failover-Clustering -ComputerName $ComputerName
	return $Check.Installed
}

$Memtable | Export-Csv "C:\Report\Cluster\MemoryReport1.csv" -NoTypeInformation
$Storagetable | Export-Csv "C:\Report\Cluster\LocalStorageReport1.csv" -NoTypeInformation
$CSVtable | Export-Csv "C:\Report\Cluster\ClusterSharedVolumeReport1.csv" -NoTypeInformation
$CPUtable | Export-Csv "C:\Report\Cluster\CPUReport1.csv" -NoTypeInformation