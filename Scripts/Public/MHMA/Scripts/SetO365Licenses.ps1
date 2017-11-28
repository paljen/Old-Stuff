Import-Module ActiveDirectory
Import-Module MSOnline
Import-Module MSOnlineExtended

$AccountSkuId = "ecco:ENTERPRISEPACK"
$O365Licences = New-MsolLicenseOptions -AccountSkuId $AccountSkuId -DisabledPlans EXCHANGE_S_ENTERPRISE, MCOSTANDARD

$pwdfile = "C:\Powershell\pass.txt"
$pass = get-content $pwdfile | convertto-securestring
$MSOLogin = New-Object System.Management.Automation.PSCredential ("AzService-AADSync@ecco.onmicrosoft.com", $pass)

Connect-MsolService -Credential $MSOLogin


#**********************************************************************
#List all AD users with E3 license and compare to setings in Office 365
#**********************************************************************

#Find all AD users that have the E3 licens configured
$ADusers = Get-ADUser -Properties * -Filter {msDS-cloudExtensionAttribute1 -like "E3"}

foreach ($ADuser in $ADusers)
{
    $sCountry = "AD"

    if ($ADuser.c)
    {
        $sCountry = $ADuser.c
    }

    if ((Get-MsolUser -UserPrincipalName $ADuser.UserPrincipalName).isLicensed -eq $False)
    {
        #User is not licensed, configuring license and service plan:
        #Write-Host $ADuser.UserPrincipalName "- User is not licensed, configuring license and service plan"

        Set-MsolUser -UserPrincipalName $ADuser.UserPrincipalName -UsageLocation $sCountry -Erroraction Stop
        Set-MsolUserLicense -UserPrincipalName $ADuser.UserPrincipalName -AddLicenses $AccountSkuId -LicenseOptions $O365Licences -Erroraction Stop

        #Write-Host $ADuser.UserPrincipalName "- User is configured"
    }

    else
    {
        #User is already licensed, configuring service plan:
        #Write-Host $ADuser.UserPrincipalName "- User is already licensed, configuring service plan:"
        
        Set-MsolUserLicense -UserPrincipalName $ADuser.UserPrincipalName -LicenseOptions $O365Licences -Erroraction Stop
        
        #Write-Host $ADuser.UserPrincipalName "- User is configured"
    }

    #Write-Host $ADuser.UserPrincipalName "- Service Plan for user:"

    ((Get-MsolUser -UserPrincipalName $ADuser.UserPrincipalName).licenses)[0].servicestatus

    #write-host "`n"
}


#**********************************************************************
#List all Office 365 users and compare to setings in Active Directory
#**********************************************************************


#Find all Office 365 users
$MSOLusers = Get-MsolUser

foreach ($MSOLuser in $MSOLusers)
{
    if ($MSOLuser.isLicensed -eq $True)
    {
        $ADuser = $ADusers | Where-Object {$_.UserPrincipalName -eq $MSOLuser.UserPrincipalName}

        if ($ADuser.'msDS-cloudExtensionAttribute1' -notlike "E3")
        {
            #User is licensed, but should not be according to AD. License will be removed
            #Write-Host $MSOLuser.UserPrincipalName "- User is licensed, but should not be according to AD. License will be removed"

            Set-MsolUserLicense -UserPrincipalName $MSOLuser.UserPrincipalName -RemoveLicenses $AccountSkuId -Erroraction Stop
        }
    }
}