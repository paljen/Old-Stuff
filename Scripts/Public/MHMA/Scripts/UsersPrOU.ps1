$OU = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=ECCO,DC=prd,DC=eccocorp,DC=net"

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("OU",([string]))
$Col2 = New-Object System.Data.DataColumn("Count",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)

foreach ($O in $OU)
{
	$CountUser = 0
	$noNumbers = 0
	$CountUser = Get-ADUser -Filter * -SearchBase $O.DistinguishedName -SearchScope OneLevel | where {$_.enabled -eq $true}
	$noNumbers = $CountUser -notmatch "[0-9]"
	
	if ($noNumbers.Length -le 100 -and $noNumbers.Length -ge 50)
	{
		$row = $table.NewRow();
		$row.OU = $O.DistinguishedName
		$row.Count = $noNumbers.Length
		$table.Rows.Add($row)
	}
}

$table | Export-Csv "C:\Report\OUCounter.csv" -Delimiter "%" -NoTypeInformation