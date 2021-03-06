$Users = Get-ADUser -filter * -Properties PasswordLastSet,PasswordNeverExpires

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Name",([string]))
$Col2 = New-Object System.Data.DataColumn("PasswordLastSet",([string]))
$Col3 = New-Object System.Data.DataColumn("PasswordNeverExpires",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)

foreach ($user in $Users)
{
	[string]$date = $user.PasswordLastSet.day.ToString() + "-" + $user.PasswordLastSet.month.ToString() + "-" + $user.PasswordLastSet.year.ToString()
	
	$row = $table.NewRow()
	$row.Name = $user.Name
	$row.PasswordLastSet = $date
	$row.PasswordNeverExpires = $user.PasswordNeverExpires
	$table.Rows.Add($row)
}

$table | Export-Csv C:\Report\PasswordLastSet.csv -NoTypeInformation