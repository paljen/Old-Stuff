$CompObjs = Import-Csv C:\Import\CompSN.csv

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Computer",([string]))
$Col2 = New-Object System.Data.DataColumn("Status",([string]))
$Col3 = New-Object System.Data.DataColumn("OU",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)

foreach ($obj in $CompObjs)
{	
	try
	{
		$ADObj = Get-ADComputer $obj.Computer -Properties "CanonicalName","CN"
		if ($ADObj.Enabled -eq $false)
		{
			[string]$DN = $ADObj.CanonicalName
			[string]$OU = $DN.Trim($ADObj.CN)
		
			$row = $table.NewRow();
			$row.Computer = $ADObj.Name
			$row.Status = "Disabled"
			$row.OU = $OU
			$table.Rows.Add($row)
		}
	}
	catch
	{
		$row = $table.NewRow();
		$row.Computer = $obj.Computer
		$row.Status = "Not Found in AD"
		$row.OU = "-"
		$table.Rows.Add($row)
	}
}

$table | Export-Csv "C:\Test\SNADCheck.csv" -NoTypeInformation