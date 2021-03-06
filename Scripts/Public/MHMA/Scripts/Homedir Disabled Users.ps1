$path = "\\DKHQFILE01\d$\UserData\DKHQ-UserData\"
$dest = $path + "-==Disabled Users"
$folders = Get-ChildItem $path
$DisabledUsers = New-Object System.Collections.ArrayList

foreach ($f in $folders)
{
	try
	{
		$ADUser = Get-ADUser $f.PSChildName.ToString()
		
		if ($ADUser.Enabled -eq $false)
		{
			$DisabledUsers.Add($ADUser.SamAccountName)
		}
	}
	catch
	{
		$DisabledUsers.Add($f.PSChildName.ToString())
	}
}

$DisabledUsers.Remove("-==Disabled Users")

foreach ($d in $DisabledUsers)
{
	$full = $path + $d
	Move-Item $full $dest
}