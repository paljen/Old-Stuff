$O356Users = Get-QADUser -SizeLimit 0 -SearchRoot 'prd.eccocorp.net/ECCO'
$counter = 0

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Count",([string]))
$Col2 = New-Object System.Data.DataColumn("NTAccountName",([string]))
$Col3 = New-Object System.Data.DataColumn("OUPath",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)

foreach ($obj in $O356Users)
{
	if ($obj.AccountIsDisabled -eq $false -and $obj.UserPrincipalName -like "*ecco.com" -and $obj.Path -notlike "*Terminated*" -and $obj.Path -notlike "*PreStaging*" -and $obj.SamAccountName -notlike "MUL-*" -and $obj.SamAccountName -notlike "CON-*")
	{
		$counter++
		$row = $table.NewRow();
		$row.Count = $counter
		$row.NTAccountName = $obj.NTAccountName
		$row.OUPath = $obj.ParentContainer
		$table.Rows.Add($row)
	}
}

$table | Export-Csv "C:\Test\O365Report.csv" -NoTypeInformation