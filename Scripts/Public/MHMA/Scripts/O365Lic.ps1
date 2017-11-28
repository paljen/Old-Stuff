Param([string]$UserName)

Add-PSSnapin Quest.ActiveRoles.ADManagement
Import-Module MSOnline
Import-Module MSOnlineExtended

$pwdfile = "C:\Powershell\pass.txt"
$pass = get-content $pwdfile | convertto-securestring
$MSOLogin = New-Object System.Management.Automation.PSCredential ("AzService-AADSync@ecco.onmicrosoft.com", $pass)
$O365Licences = New-MsolLicenseOptions -AccountSkuId "ecco:ENTERPRISEPACK" -DisabledPlans "EXCHANGE_S_ENTERPRISE","MCOSTANDARD"

Connect-MsolService -Credential $MSOLogin

$users = Get-QADUser $UserName -IncludeAllProperties
#-SizeLimit 0 -SearchRoot 'prd.eccocorp.net/ECCO'
#$counter = 0
foreach ($user in $users)
{
	if ($user.AccountIsDisabled -eq $false -and $user.UserPrincipalName -like "*ecco.com" -and $user.Path -notlike "*Terminated*" -and $user.Path -notlike "*PreStaging*")
	{
		Set-QADUser $user -ObjectAttributes @{"msDS-cloudExtensionAttribute1"="E3"}
		#$counter++
		
		Set-MsolUser -UserPrincipalName $user.UserPrincipalName -UsageLocation $user.c -Erroraction Stop
		Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -AddLicenses "ecco:ENTERPRISEPACK" -LicenseOptions $O365Licences -Erroraction Stop
		
		if (Get-MsolUser -UserPrincipalName $user.UserPrincipalName | Where-Object {$_.IsLicensed -eq $true})
		{
			Write-Host "User:" $user.UserPrincipalName "has been licensed."
		}
		
		#Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -LicenseOptions $O365Licences
	}
	elseif ($user.AccountIsDisabled -eq $true)
	{
		Set-QADUser $user -ObjectAttributes @{"msDS-cloudExtensionAttribute1"=$null}
	}
}