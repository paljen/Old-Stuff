$data = import-csv c:\Import\Disable-22092016.csv -Delimiter ";"

foreach ($d in $data)
{
	Set-ADUser $d.User -Enabled $false
}