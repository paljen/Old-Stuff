#$Data = Import-Csv C:\Import\ChangePass.csv
$Disable = Import-Csv C:\Import\DisableUser.csv

<#foreach ($d in $Data)
{
	try
	{
		$obj = Get-ADUser $d.User
		Set-ADUser $d.User -ChangePasswordAtLogon $true
	}
	catch
	{
		Write-Output "Error changing property on user " + $d.User
	}
}#>

foreach ($u in $Disable)
{
	try
	{
		$obj = Get-ADUser $u.User
		Set-ADUser $u.User -Enabled $false
	}
	catch
	{
		Write-Output "Error disabling user " + $u.User
	}
}