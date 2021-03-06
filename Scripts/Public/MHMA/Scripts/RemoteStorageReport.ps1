$Hosts = Import-Csv C:\Import\ClusterSharedHosts.csv

#Build datatable
$CSVtable = New-Object System.Data.DataTable

#Remote Storage Bracket
$Col21 = New-Object System.Data.DataColumn("VMHostServer",([string]))
$Col22 = New-Object System.Data.DataColumn("ServerModel",([string]))
$Col23 = New-Object System.Data.DataColumn("ClusterName",([string]))
$Col24 = New-Object System.Data.DataColumn("VolumeLabel",([string]))
$Col25 = New-Object System.Data.DataColumn("Size",([string]))
$Col26 = New-Object System.Data.DataColumn("FreeSpace",([string]))
$Col27 = New-Object System.Data.DataColumn("FreeSpacePct",([string]))

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

	#Gather
	$CSV = gwmi -Namespace "root\MSCluster" -class "MSCluster_DiskPartition" -ComputerName $h.ComputerName | Select VolumeLabel,@{Name="TotalSize";Expression={"{0:N1}" -f($_.TotalSize/1kb)}},@{Name="FreeSpace";Expression={"{0:N1}" -f($_.FreeSpace/1kb)}},@{Name="FreeSpacePct";Expression={"{0:N0}" -f(($_.FreeSpace/$_.TotalSize)*100)}}
	$ClusterName = $h.ComputerName.Substring(0, $h.ComputerName.Length - 3);
	$Model = gwmi -ComputerName $h.ComputerName Win32_ComputerSystem | Select Model
	
	#Populate Tables

	Foreach ($shared in $CSV)
	{
		$row = $CSVtable.NewRow();
		$row.VMHostServer = $h.ComputerName
		$row.ServerModel = $Model.Model
		$row.ClusterName = $ClusterName
		$row.VolumeLabel = $shared.VolumeLabel
		$row.Size = $shared.TotalSize
		$row.FreeSpace = $shared.FreeSpace
		$row.FreeSpacePct = $shared.FreeSpacePct
		$CSVtable.Rows.Add($row);
	}
}

$CSVtable | Export-Csv "C:\Report\Cluster\ClusterSharedVolumeReport.csv" -NoTypeInformation