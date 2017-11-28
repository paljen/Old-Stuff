$Data = Import-Csv C:\Import\O365RepDiabled.csv

#Add-PSSnapin Quest.ActiveRoles.ADManagement
Import-Module MSOnline
Import-Module MSOnlineExtended

$pwdfile = "C:\Powershell\pass.txt"
$pass = get-content $pwdfile | convertto-securestring
$MSOLogin = New-Object System.Management.Automation.PSCredential ("AzService-AADSync@ecco.onmicrosoft.com", $pass)

Connect-MsolService -Credential $MSOLogin

foreach ($obj in $Data)
{
	$ADobj = Get-ADUser $obj.Username
	$Lic = Get-MsolUser -UserPrincipalName $ADobj.UserPrincipalName
	
	if ($Lic.IsLicensed -eq $true)
	{
		Set-MsolUserLicense -UserPrincipalName $Lic.UserPrincipalName -RemoveLicenses "ecco:ENTERPRISEPACK" -ErrorAction Stop
	}
}