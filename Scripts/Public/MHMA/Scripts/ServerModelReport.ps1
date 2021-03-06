$data = Get-ADComputer -SearchBase "OU=MEMBER SERVERS,DC=prd,DC=eccocorp,DC=net" -Filter *

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Server",([string]))
$Col2 = New-Object System.Data.DataColumn("Model",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)

foreach ($d in $data)
{
	try
	{
		$wmidata = $null
		$wmidata = gwmi -ComputerName $d.Name Win32_ComputerSystem
		
		$row = $table.NewRow()
		$row.Server = $d.Name
		$row.Model = $wmidata.Model
		$table.Rows.Add($row)
	}
	catch
	{
		$row = $table.NewRow()
		$row.Server = $d.Name
		$row.Model = "No Data"
		$table.Rows.Add($row)
	}
}

$table | Export-Csv "C:\Report\ServerModels.csv" -NoTypeInformation