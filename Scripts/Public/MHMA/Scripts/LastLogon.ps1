$import = Import-Csv "C:\Import\lastlogon.csv"

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Username",([string]))
$Col2 = New-Object System.Data.DataColumn("LastLogon",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)

foreach ($user in $import)
{
	$data = Get-ADUser $user.User -Properties "LastLogonDate"
	
	$row = $table.NewRow();
	$row.Username = $user.User
	$row.LastLogon = $data.LastLogonDate
	$table.Rows.Add($row)
}

$table | Export-Csv "c:\Report\LastLogon.csv" -NoTypeInformation