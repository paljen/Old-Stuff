$HDDS = Get-PSDrive -PSProvider FileSystem

foreach ($HDD in $HDDS)
{
	$drive = Get-ChildItem -Path $HDD.Root -Recurse
	$types = $drive | where {$_.Name -like "*torrent*" -or $_.Name -like "*gnutella*" -or $_.Name -like "*edonkey*" -or $_.Name -like "*filetopia*" -or $_.Name -like "*freenet*" -or $_.Name -like "*openft*" -or $_.Name -like "*fasttrack*" -or $_.Name -like "*neonet*" -or $_.Name -like "*emule*" -or $_.Name -like "*retroshare*" -or $_.Name -like "*filezilla*"}

	#Build datatable
	$table = New-Object System.Data.DataTable
	$Col1 = New-Object System.Data.DataColumn("Filename",([string]))
	$Col2 = New-Object System.Data.DataColumn("Folder",([string]))
	$Col3 = New-Object System.Data.DataColumn("SizeInMB",([string]))
	$table.columns.add($Col1)
	$table.columns.add($Col2)
	$table.columns.add($Col3)

	foreach ($file in $types)
	{
		$rounded = "{0:N2}" -f ($file.Length / 1MB)
		$row = $table.NewRow();
		$row.Filename = $file.Name
		$row.Folder = $file.Directory
		$row.SizeInMB = $rounded
		$table.Rows.Add($row)
	}
	
	$ReportName = "C:\Report\FileTypesScan-Drive"+$HDD.Name+".csv"
	
	$table | Export-Csv $ReportName -NoTypeInformation
}