$Data = Get-QADUser -SizeLimit 0 -SearchRoot 'prd.eccocorp.net/ECCO' -IncludedProperties "msDS-cloudExtensionAttribute1" | Where-Object {($_."msDS-cloudExtensionAttribute1" -eq "E3") -and ($_.AccountIsDisabled -eq $true) -and ($_.ParentContainerDN -notlike "*OU=Terminated*")}

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("SAM",([string]))
$Col2 = New-Object System.Data.DataColumn("OU",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)

foreach ($user in $Data)
{
	$row = $table.NewRow();
	$row.SAM = $user.SamAccountName
	$row.OU = $user.ParentContainer
	$table.Rows.Add($row)
}

$table | Export-Csv "C:\Report\O365RepDiabled.csv" -NoTypeInformation