$HDDS = Get-PSDrive -PSProvider FileSystem

foreach ($HDD in $HDDS)
{
	$drive = Get-ChildItem -Path $HDD.Root -Recurse
	$types = $drive

	#Build datatable
	$table = New-Object System.Data.DataTable
	$Col1 = New-Object System.Data.DataColumn("Filename",([string]))
	$Col2 = New-Object System.Data.DataColumn("Folder",([string]))
	$Col3 = New-Object System.Data.DataColumn("SizeInGB",([string]))
	$table.columns.add($Col1)
	$table.columns.add($Col2)
	$table.columns.add($Col3)

	foreach ($file in $types)
	{
		$rounded = "{0:N2}" -f ($file.Length / 1GB)
		if ($rounded -ge 100)
		{
			$row = $table.NewRow();
			$row.Filename = $file.Name
			$row.Folder = $file.Directory
			$row.SizeInGB = $rounded
			$table.Rows.Add($row)
		}
	}
	
	$ReportName = "C:\Report\FileExtensionScan-Drive"+$HDD.Name+".csv"
	
	$table | Export-Csv $ReportName -NoTypeInformation
}